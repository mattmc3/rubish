#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-misc.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 history builtin usage' {
  local cmd='history
echo status=$?
history +5  # hm bash considers this valid
echo status=$?
history -5  # invalid flag
echo status=$?
history f 
echo status=$?
history too many args
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Print shell strings with weird chars: set and printf %q and {x@Q}' {
  local cmd='# bash declare -p will print binary data, which makes this invalid UTF-8!
foo=$(/bin/echo -e '\''a\nb\xffc'\''\'\''d)

# let'\''s test the easier \x01, which doesn'\''t give bash problems
foo=$(/bin/echo -e '\''a\nb\x01c'\''\'\''d)

# dash:
#   only supports '\''set'\''; prints it on multiple lines with binary data
#   switches to "'\''" for single quotes, not \'\''
# zsh:
#   print binary data all the time, except for printf %q
#   does print $'\'''\'' strings
# mksh:
#   prints binary data for @Q
#   prints $'\'''\'' strings

# All are very inconsistent.

set | grep -A1 foo

# Will print multi-line and binary data literally!
#declare -p foo

printf '\''pf  %q\n'\'' "$foo"

echo '\''@Q '\'' ${foo@Q}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Print shell strings with normal chars: set and printf %q and {x@Q}' {
  local cmd='# There are variations on whether quotes are printed

foo=spam

set | grep -A1 foo

# Will print multi-line and binary data literally!
typeset -p foo

printf '\''pf  %q\n'\'' "$foo"

echo '\''@Q '\'' ${foo@Q}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 time pipeline' {
  local cmd='time echo hi | wc -c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 shift' {
  local cmd='set -- 1 2 3 4
shift
echo "$@"
shift 2
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Shifting too far' {
  local cmd='set -- 1
shift 2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Invalid shift argument' {
  local cmd='shift ZZZ'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

