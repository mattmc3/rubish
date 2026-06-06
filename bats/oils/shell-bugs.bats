#!/usr/bin/env bats
# Generated from oils-for-unix spec/shell-bugs.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 ./configure idiom' {
  local cmd='set -o errexit

if command time -f '\''%e %M'\'' true; then
  echo '\''supports -f'\''
  # BUG: this was wrong
  #time -f '\''%e %M'\'' true

  # Need '\''command time'\''
  command time -f '\''%e %M'\'' true
fi

if env time -f '\''%e %M'\'' true; then
  echo '\''env'\''
  env time -f '\''%e %M'\'' true
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

