#!/usr/bin/env python

""" Set and fetch data cached in Redis """

import os
import sys
import argparse
import logging

import redis

logging.basicConfig(format='%(message)s')
logger = logging.getLogger(__name__)

REDIS_HOST, REDIS_PORT = \
    os.environ.get('REDIS_ADDRESS', 'localhost:6379').split(':')

DEFAULT_EXPIRE_TIMEOUT_SECS = None

ACTION_CHOICES = ['set', 'match', 'get', 'delete']


def fault(parser, logger, message=None):
    if message:
        logger.error(message)
        sys.stderr.write(message + '\n')
    else:
        logger.error("Invalid use of program, printing usage instructions")
        parser.print_help()
    sys.exit(1)


def redis_set(conn, key, value, expiry_secs):
    return conn.set(key, value, ex=expiry_secs)


def redis_get(conn, key):
    return conn.get(key)


def main():
    parser = argparse.ArgumentParser(
        description='Set or fetch data cached in Redis',
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        'action',
        choices=ACTION_CHOICES,
        help=(
            "Action to perform:\n"
            "\n"
            "'set': set Redis <key> to the given <value> argument or data\n"
            "       read from STDIN if the [-x] option is set.\n"
            "\n"
            "'get': echo value in Redis for <key> to STDOUT.\n"
            "       Returns ERRORLEVEL 100 if there is no such key in Redis,\n"
            "       so this action also works as an existance check.\n"
            "\n"
            "'delete': delete <key> value from Redis. The <key> value does\n"
            "       not need to exist.\n"
            "\n"
            "'match': return ERRORLEVEL 0 if Redis has a value for\n"
            "       <key> matching the given <value> argument or STDIN,\n"
            "       or ERRORLEVEL 100 if there is no match.\n"
            "\n"
        ),
    )
    parser.add_argument(
        'key',
        help='Cache key name',
    )
    parser.add_argument(
        'value',
        nargs='?',
        help=(
            'Value to set in cache, valid only for actions: %s'
            % ', '.join(ACTION_CHOICES[:-2])
        )
    )
    parser.add_argument(
        '--redis-host',
        default=REDIS_HOST,
        help='Host of redis server (default: %s)' % REDIS_HOST,
    )
    parser.add_argument(
        '--redis-port',
        default=REDIS_PORT,
        help='Port of redis server (default: %s)' % REDIS_PORT,
    )
    parser.add_argument(
        '--expire-secs',
        default=DEFAULT_EXPIRE_TIMEOUT_SECS,
        help=(
            'Expiry timeout in seconds for cached values (default: %s)'
            % DEFAULT_EXPIRE_TIMEOUT_SECS
        ),
    )
    parser.add_argument(
        '-x',
        dest='read_from_stdin',
        action='store_true',
        default=False,
        help='Read last argument from STDIN',
    )
    parser.add_argument(
        '-q',
        '--quiet',
        action='store_true',
        help='Silence standard output',
    )
    parser.add_argument(
        '-v',
        '--verbose',
        action='count',
        default=0,
        dest='verbosity',
        help='Increase verbosity for each occurrence',
    )
    args = parser.parse_args()

    # Configure log level with verbosity argument.
    levels = (
        # logging.CRITICAL,
        # logging.ERROR,
        logging.WARNING,
        logging.INFO,
        logging.DEBUG,
    )
    try:
        logger.setLevel(levels[args.verbosity])
    except IndexError:
        logger.setLevel(logging.DEBUG)
    # Silence standard output.
    if args.quiet:
        logger.debug("Suppressing STDOUT because the [--quiet] option is set")
        sys.stdout = open(os.devnull, 'w')

    # Read input data from <value> argument or STDIN as requested, and
    # sanity-check argument values and combinations
    if args.action in ACTION_CHOICES[:-2]:  # Set actions
        if args.read_from_stdin:
            input_data = sys.stdin.read()
        elif not args.value:
            fault(
                parser,
                logger,
                "You must provide <value> as a third argument or read from"
                " STDIN by setting the [-x] option"
            )
        else:
            input_data = args.value
    else:  # Get/delete actions
        if args.value or args.read_from_stdin:
            fault(
                parser,
                logger,
                "You cannot provide <value> as an argument or read from STDIN"
                " by setting the [-x] option for get actions"
            )

    conn = redis.StrictRedis(
        host=args.redis_host, port=args.redis_port,
    )

    if args.action == 'set':
        redis_set(conn, args.key, input_data, args.expire_secs)
        logger.debug(
            "Set Redis key '%s' to value: %s" % (args.key, input_data))
    elif args.action == 'get':
        cached_data = redis_get(conn, args.key)
        logger.debug(
            "Get for Redis key '%s' returned value: %s"
            % (args.key, cached_data))
        if cached_data is None:
            sys.exit(100)
        else:
            sys.stdout.write(cached_data + "\n")
    elif args.action == 'delete':
        conn.delete(args.key)
        logger.debug("Deleted Redis key '%s'" % args.key)
    elif args.action == 'match':
        # Read cached data
        cached_data = redis_get(conn, args.key)
        # Does cached data match input data?
        logger.debug(
            "Checking for match for Redis key '%s' and input value: %s"
            % (args.key, input_data))
        if cached_data == input_data:
            logger.info("Match result YES for Redis key '%s'" % args.key)
            return
        else:
            logger.info("Match result NO for Redis key '%s'" % args.key)
            sys.exit(100)
    else:
        raise Exception("Unimplemented action '%s'" % args.action)

if __name__ == '__main__':
    # Store original standard output destination
    orig_stdout = sys.stdout
    try:
        main()
    except:
        raise
    finally:
        # Restore original standard output.
        sys.stdout = orig_stdout
