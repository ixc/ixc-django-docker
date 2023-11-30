#!/bin/bash

# Create a database for 'PG*'. If 'SRC_PGDATABASE' ('initial_data.sql' in
# 'PROJECT_DIR' by default) is an '*.sql' file, try to restore it.
# Otherwise, 'SRC_PGDATABASE' should be the name of a database to dump and
# restore from 'SRC_PG*' (which match 'PG*' by default).

set -e

# Wait for PostgreSQL to become available.
COUNT=0
until psql -l > /dev/null 2>&1; do
	if [[ "$COUNT" == 0 ]]; then
		echo "Waiting for PostgreSQL ($PGUSER@$PGHOST:$PGPORT)..."
	fi
	(( COUNT += 1 ))
	sleep 1
done
if (( COUNT > 0 )); then
	echo "Waited $COUNT seconds for PostgreSQL."
fi

# Database already exists.
if psql -l | grep -q "\s$PGDATABASE\s"; then
	if [[ -z "$SETUP_POSTGRES_FORCE" ]]; then
		exit 0
	else
		echo "Database '$PGDATABASE' ($PGHOST:$PGPORT) already exists and SETUP_POSTGRES_FORCE is set. Rename existing database."
		# Prompt for confirmation.
		if [[ -t 1 && -z ${SETUP_TESTS+1} ]]; then
			>&2 echo "Are you SURE you want to rename '$PGDATABASE' to '${PGDATABASE}_old'? This will overwrite any existing '${PGDATABASE}_old' database, which cannot be undone."
			select yn in 'Yes' 'No'; do
				case $yn in
					Yes ) break;;
					No ) exit 1;;
				esac
			done
		fi
		# Drop old database.
		if psql -l | grep -q "\s${PGDATABASE}_old\s"; then
			psql -c "ALTER DATABASE \"${PGDATABASE}_old\" CONNECTION LIMIT 0; SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${PGDATABASE}_old';" -d postgres -o /dev/null
			dropdb "${PGDATABASE}_old"
		fi
		# Rename database.
		psql -c "ALTER DATABASE \"$PGDATABASE\" CONNECTION LIMIT 0; SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$PGDATABASE';" -d postgres -o /dev/null
		psql -c "ALTER DATABASE \"$PGDATABASE\" RENAME TO \"${PGDATABASE}_old\";" -d postgres -o /dev/null
	fi
fi

# Create database.
echo "Create database '$PGDATABASE'."
createdb "$PGDATABASE"

# Restore from file or source database.
SRC_PGDATABASE="${SRC_PGDATABASE:-$PROJECT_DIR/initial_data.sql}"
if [[ "$SRC_PGDATABASE" == *.sql ]]; then
	if [[ -f "$SRC_PGDATABASE" ]]; then
		echo "Restore to database '$PGDATABASE' from file '$SRC_PGDATABASE'."
		pv "$SRC_PGDATABASE" | psql -d "$PGDATABASE" > /dev/null
	fi
elif [[ "$SRC_PGDATABASE" == *.sql.gz ]]; then
	if [[ -f "$SRC_PGDATABASE" ]]; then
		echo "Restore to database '$PGDATABASE' from file '$SRC_PGDATABASE'."
		pv "$SRC_PGDATABASE" | gunzip | psql -d "$PGDATABASE" > /dev/null
	fi
elif [[ -n "$SRC_PGDATABASE" ]]; then
	# Get source database credentials.
	SRC_PGHOST="${SRC_PGHOST:-${PGHOST}}"
	SRC_PGPASSWORD="${SRC_PGPASSWORD:-${PGPASSWORD}}"
	SRC_PGPORT="${SRC_PGPORT:-${PGPORT}}"
	SRC_PGUSER="${SRC_PGUSER:-${PGUSER}}"
	# Wait for PostgreSQL to become available.
	COUNT=0
	until PGPASSWORD="$SRC_PGPASSWORD" psql -l -h "$SRC_PGHOST" -p "$SRC_PGPORT" -U "$SRC_PGUSER" > /dev/null 2>&1; do
		if [[ "$COUNT" == 0 ]]; then
			echo "Waiting for PostgreSQL ($SRC_PGUSER@$SRC_PGHOST:$SRC_PGPORT)..."
		fi
		(( COUNT += 1 ))
		sleep 1
	done
	if (( COUNT > 0 )); then
		echo "Waited $COUNT seconds for PostgreSQL."
	fi
	echo "Restore to destination database '$PGDATABASE' ($PGHOST:$PGPORT) from source database '$SRC_PGDATABASE' ($SRC_PGHOST:$SRC_PGPORT)."
	PGPASSWORD="$SRC_PGPASSWORD" pg_dump $SRC_PGDUMP_EXTRA -h "$SRC_PGHOST" -p "$SRC_PGPORT" -U "$SRC_PGUSER" -O -x "$SRC_PGDATABASE" | pv | psql -d "$PGDATABASE" > /dev/null
fi
