#!/usr/bin/env python

"""Acquire Redis lock and execute a command."""

import argparse
import datetime
import errno
import logging
import os
import subprocess
import sys
import time

from redis.exceptions import ConnectionError
import redis
import redis_lock

logging.basicConfig(format='%(message)s')
logger = logging.getLogger(__name__)

REDIS_HOST, REDIS_PORT = \
    os.environ.get('REDIS_ADDRESS', 'localhost:6379').split(':')


def execute(cmd):
    args = [cmd]

    import fcntl
    import select

    # See: http://stackoverflow.com/a/7730201

    # Helper function to add the O_NONBLOCK flag to a file descriptor
    def make_async(fd):
        fcntl.fcntl(
            fd, fcntl.F_SETFL, fcntl.fcntl(fd, fcntl.F_GETFL) | os.O_NONBLOCK)

    # Helper function to read some data from a file descriptor, ignoring EAGAIN
    # errors
    def read_async(fd):
        try:
            return fd.read()
        except IOError as e:
            if e.errno != errno.EAGAIN:
                raise e
            else:
                return ''

    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    make_async(process.stdout)
    make_async(process.stderr)

    stdout = str()
    stderr = str()
    returnCode = None

    while True:
        # Wait for data to become available
        select.select([process.stdout, process.stderr], [], [])

        # Try reading some data from each
        stdoutPiece = (read_async(process.stdout) or b'').decode('utf-8')
        stderrPiece = (read_async(process.stderr) or b'').decode('utf-8')

        if stdoutPiece:
            sys.stdout.write(stdoutPiece)
        if stderrPiece:
            sys.stderr.write(stderrPiece)

        stdout += stdoutPiece
        stderr += stderrPiece
        returnCode = process.poll()

        if returnCode != None:
            return (returnCode, stdout, stderr)


def waitlock(cmd, block=False):
    conn = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT)

    # Create lock object.
    lock = redis_lock.Lock(conn, name=cmd, expire=60, auto_renewal=True)

    # Retry on connection errors, when told to block.
    while True:
        try:
            # Attempt to acquire lock.
            if lock.acquire(blocking=False):
                logger.debug('Acquired lock. Executing command: %s' % cmd)

            # Block until lock is available, then execute.
            elif block:
                logger.info('Waiting to acquire lock for command: %s' % cmd)
                when = datetime.datetime.now()
                lock.acquire()
                duration = datetime.datetime.now() - when
                logger.info(
                    'Waited %s seconds to acquire lock. Executing command: %s' % (
                        duration.seconds,
                        cmd,
                    ))

            # Abort.
            else:
                logger.info('Unable to acquire lock.')
                return 0
        except ConnectionError:
            # Retry.
            if block:
                logger.warning(
                    "Unable to connect to Redis at '%s:%s'. Retrying in 1 "
                    'second.' % (
                        REDIS_HOST,
                        REDIS_PORT,
                    ))
                time.sleep(1)
                continue
            logger.info(
                'Unable to acquire lock. Unable to connect to Redis at '
                "'%s:%s'." % (
                    REDIS_HOST,
                    REDIS_PORT,
                ))
            return 0
        break

    # Execute command and get exit code from subprocess.
    exit_code = execute(cmd)[0]

    # Attempt to release lock.
    try:
        lock.release()
    except redis_lock.NotAcquired:
        pass

    return exit_code


def main():
    # Parse arguments.
    parser = argparse.ArgumentParser(
        description='Attempt to acquire Redis lock and execute command.',
    )
    parser.add_argument(
        'cmd',
        help='command to execute when lock has been acquired',
        nargs=argparse.REMAINDER,
    )
    parser.add_argument(
        '-b',
        '--block',
        action='store_true',
        help='block until lock is acquired',
    )
    parser.add_argument(
        '--redis-host',
        default=REDIS_HOST,
        help='host of redis server (default: %s)' % REDIS_HOST,
    )
    parser.add_argument(
        '--redis-port',
        default=REDIS_PORT,
        help='port of redis server (default: %s)' % REDIS_PORT,
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '-q',
        '--quiet',
        action='store_true',
        help='silence standard output',
    )
    group.add_argument(
        '-v',
        '--verbose',
        action='count',
        default=0,
        dest='verbosity',
        help='increase verbosity for each occurrence',
    )
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    args = parser.parse_args()

    # Configure log level with verbosity argument.
    levels = (
        # logging.CRITICAL,
        # logging.ERROR,
        # logging.WARNING,
        logging.INFO,
        logging.DEBUG,
    )
    try:
        logger.setLevel(levels[args.verbosity])
    except IndexError:
        logger.setLevel(logging.DEBUG)

    # Silence standard output.
    stdout = sys.stdout
    if args.quiet:
        sys.stdout = open(os.devnull, 'w')
    # Execute.
    exit_code = waitlock(' '.join(args.cmd), args.block)
    # Restore standard output.
    sys.stdout = stdout
    exit(exit_code)

if __name__ == '__main__':
    main()
