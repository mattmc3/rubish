#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-sub.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Bad var sub' {
  local cmd='echo ${a&}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Braced block inside {}' {
  local cmd='# NOTE: This bug was in bash 4.3 but fixed in bash 4.4.
echo ${foo:-$({ ls /bin/ls; })}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Nested {}' {
  local cmd='bar=ZZ
echo ${foo:-${bar}}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Filename redirect with @' {
  local cmd='# bash - ambiguous redirect -- yeah I want this error
#   - But I want it at PARSE time?  So is there a special DollarAtPart?
#     MultipleArgsPart?
# mksh - tries to create '\''_tmp/var-sub1 _tmp/var-sub2'\''
# dash - tries to create '\''_tmp/var-sub1 _tmp/var-sub2'\''
fun() {
  echo hi > "$@"
}
fun _tmp/var-sub1 _tmp/var-sub2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Descriptor redirect to bad @' {
  local cmd='# All of them give errors:
# dash - bad fd number, parse error?
# bash - ambiguous redirect
# mksh - illegal file descriptor name
set -- '\''2 3'\'' '\''c d'\''
echo hi 1>& "$@"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Here doc with bad @ delimiter' {
  local cmd='# bash - syntax error
# dash - syntax error: end of file unexpected
# mksh - runtime error: here document unclosed
#
# What I want is syntax error: bad delimiter!
#
# This means that "$@" should be part of the parse tree then?  Anything that
# involves more than one token.
fun() {
  cat << "$@"
hi
1 2
}
fun 1 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

