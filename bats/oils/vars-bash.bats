#!/usr/bin/env bats
# Generated from oils-for-unix spec/vars-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 SHELL is set to what is in /etc/passwd' {
  local cmd='sh=$(which $SH)

unset SHELL

prog='\''
if test -n "$SHELL"; then
  # the exact value is different on CI, so do not assert
  echo SHELL is set
  echo SHELL=$SHELL >&2
fi
'\''

$SH -c "$prog"

$SH -i -c "$prog"

# make it a login shell
$SH -l -c "$prog"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

