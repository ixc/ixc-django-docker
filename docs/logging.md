Logging with LogEntries
=======================

Docker containers are often run on ephemeral infrastructure with no persistent
storage for logs. You can send and aggregate container stdout, Python logs, and
file based logs to [LogEntries](https://logentries.com/) in realtime.

1. Create a new log set named `{PROJECT_NAME}.{DOTENV}`.

2. Create manual (token TCP) logs named `docker-logentries`, `docker-logspout`
   and `python` in that log set.

3. Replace `{DOCKER_LOGENTRIES_TOKEN}` and `{DOCKER_LOGSPOUT_TOKEN}` in your
   compose or stack file, and `{PYTHON_TOKEN}` in your dotenv file, with the
   tokens created above.

4. Copy your account key to `LOGENTRIES_ACCOUNT_KEY` in your dotenv file. See:
   https://docs.logentries.com/v1.0/docs/accountkey/

5. Add `logentries.py` to `BASE_SETTINGS` in your `.env.base` file.
