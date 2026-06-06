#!/usr/bin/env bats
# Generated from oils-for-unix spec/bool-parse.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 test builtin - Unexpected trailing word '\''--'\'' (#2409)' {
  local cmd='# Minimal repro of sqsh build error
set -- -o; test $# -ne 0 -a "$1" != "--"
echo status=$?

# Now hardcode $1
test $# -ne 0 -a "-o" != "--"
echo status=$?

# Remove quotes around -o
test $# -ne 0 -a -o != "--"
echo status=$?

# How about a different flag?
set -- -z; test $# -ne 0 -a "$1" != "--"
echo status=$?

# A non-flag?
set -- z; test $# -ne 0 -a "$1" != "--"
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 test builtin: ( = ) is confusing: equality test or non-empty string test' {
  local cmd='# here it'\''s equality
test '\''('\'' = '\'')'\''
echo status=$?

# here it'\''s like -n =
test 0 -eq 0 -a '\''('\'' = '\'')'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 test builtin: ( == ) is confusing: equality test or non-empty string test' {
  local cmd='# here it'\''s equality
test '\''('\'' == '\'')'\''
echo status=$?

# here it'\''s like -n ==
test 0 -eq 0 -a '\''('\'' == '\'')'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Allowed: [[ = ]] and [[ == ]]' {
  local cmd='[[ = ]]
echo status=$?
[[ == ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Not allowed: [[ ) ]] and [[ ( ]]' {
  local cmd='[[ ) ]]
echo status=$?
[[ ( ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 test builtin: ( x ) behavior is the same in both cases' {
  local cmd='test '\''('\'' x '\'')'\''
echo status=$?

test 0 -eq 0 -a '\''('\'' x '\'')'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 [ -f = ] and [ -f == ]' {
  local cmd='[ -f = ]
echo status=$?
[ -f == ]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 [[ -f -f ]] and [[ -f == ]]' {
  local cmd='[[ -f -f ]]
echo status=$?

[[ -f == ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

