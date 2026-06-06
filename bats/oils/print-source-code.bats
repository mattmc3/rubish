#!/usr/bin/env bats
# Generated from oils-for-unix spec/print-source-code.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 typeset -f prints function source code' {
  local cmd=': prefix; myfunc() { echo serialized; }

code=$(typeset -f myfunc)

$SH -c "$code; myfunc"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 typeset -f with function keyword (ksh style)' {
  local cmd=': prefix; function myfunc {
	echo serialized
}

code=$(typeset -f myfunc)

$SH -c "$code; myfunc"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 typeset -f prints function source code - nested functions' {
  local cmd='outer() {
  echo outer
  : prefix; inner() {
    echo inner
  }
}

code=$(typeset -f outer)

if false; then
  echo ---
  echo $code
  echo ---
fi

$SH -c "$code; outer; inner"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 non-{ } function bodies can be serialized (rare)' {
  local cmd='# TODO: we can add more of these

f() ( echo '\''subshell body'\'' )

code=$(typeset -f f)

$SH -c "$code; f"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

