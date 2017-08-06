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

TIMEOUT_SECS = 60 * 60  # 1 hour

ACTION_CHOICES = ['set', 'match', 'get']


def fault(parser, message=None):
    if message:
        sys.stderr.write(message + '\n')
    else:
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
            "       read from STDIN if the [-x] option is set\n"
            "\n"
            "'get': echo value in Redis for <key> to STDOUT.\n"
            "       Returns ERRORLEVEL 100 if there is no such key in Redis\n"
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
            % ', '.join(ACTION_CHOICES[:-1])
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
        default=TIMEOUT_SECS,
        help=(
            'Expiry timeout in seconds for cached values (default: %s)'
            % TIMEOUT_SECS
        ),
    )
    parser.add_argument(
        '-x',
        dest='read_from_stdin',
        action='store_true',
        default=False,
        help='Read last argument from STDIN',
    )
    args = parser.parse_args()

    # Read input data from <value> argument or STDIN as requested, and
    # sanity-check argument values and combinations
    if args.action in ACTION_CHOICES[:-1]:  # Set actions
        if args.read_from_stdin:
            input_data = sys.stdin.read()
        elif not args.value:
            fault(
                parser,
                "You must provide <value> as a third argument or read from"
                " STDIN by setting the [-x] option"
            )
        else:
            input_data = args.value
    else:  # Get action
        if args.value or args.read_from_stdin:
            fault(
                parser,
                "You cannot provide <value> as an argument or read from STDIN"
                " by setting the [-x] option for get actions"
            )

    conn = redis.Redis(
        host=args.redis_host, port=args.redis_port,
    )

    if args.action == 'set':
        redis_set(conn, args.key, input_data, args.expire_secs)
    elif args.action == 'get':
        cached_data = redis_get(conn, args.key)
        if cached_data is None:
            sys.exit(100)
        else:
            sys.stdout.write(cached_data + "\n")
    elif args.action == 'match':
        # Read cached data
        cached_data = redis_get(conn, args.key)
        # Does cached data match input data?
        if cached_data == input_data:
            return
        else:
            sys.exit(100)
    else:
        raise Exception("Unimplemented action '%s'" % args.action)

if __name__ == '__main__':
    main()
