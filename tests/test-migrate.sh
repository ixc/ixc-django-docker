#!/bin/bash

set -e

REPOSITORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ixc-migrate-test.XXXXXX")"
BIN_DIR="$TEST_DIR/bin"

trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/python.sh" <<'EOF'
#!/bin/bash

case "$*" in
	*"(1, 7)"*)
		[[ "$FAKE_DJANGO_VERSION" == "1.6" ]]
		;;
	*"(1, 8)"*)
		[[ "$FAKE_DJANGO_VERSION" == "1.6" || "$FAKE_DJANGO_VERSION" == "1.7" ]]
		;;
	*"(1, 10)"*)
		[[ "$FAKE_DJANGO_VERSION" != "1.10" ]]
		;;
	*)
		echo "Unexpected python.sh invocation: $*" >&2
		exit 1
		;;
esac

if [[ "$?" == "0" ]]; then
	echo True
else
	echo False
fi
EOF

cat > "$BIN_DIR/manage.py" <<'EOF'
#!/bin/bash

echo "$*" >> "$COMMAND_LOG"

case "$*" in
	"migrate --list" | "showmigrations")
		echo "[X] test_migration"
		;;
esac
EOF

chmod +x "$BIN_DIR/python.sh" "$BIN_DIR/manage.py"

assert_commands()
{
	local version="$1"
	local expected="$2"
	local state_dir="$TEST_DIR/state-$version"
	local command_log="$TEST_DIR/commands-$version.log"

	FAKE_DJANGO_VERSION="$version" \
	COMMAND_LOG="$command_log" \
	PATH="$BIN_DIR:$PATH" \
		bash "$REPOSITORY_DIR/ixc_django_docker/bin/migrate.sh" "$state_dir"

	if [[ "$version" == "1.7" ]] && grep -q -- "--fake-initial" "$command_log"; then
		echo "Django 1.7 must not receive --fake-initial:" >&2
		cat "$command_log" >&2
		return 1
	fi

	if ! diff -u <(printf "%s\n" "$expected") "$command_log"; then
		echo "Unexpected migration commands for Django $version" >&2
		return 1
	fi
}

assert_commands "1.6" "syncdb --noinput
migrate --list
migrate --noinput
migrate --list"

assert_commands "1.7" "migrate --list
migrate --noinput
migrate --list"

assert_commands "1.8" "migrate --list
migrate --fake-initial --noinput
migrate --list"

echo "migrate.sh version compatibility tests passed"
