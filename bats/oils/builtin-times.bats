#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-times.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 times shows two formatted lines' {
  local cmd='output=$(times)
echo "$output" | while read line
do
	echo "$line" | egrep -q '\''[0-9]+m[0-9]+.[0-9]+s [0-9]+m[0-9]+.[0-9]+s'\'' && echo "pass"
done

echo "$output" | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

