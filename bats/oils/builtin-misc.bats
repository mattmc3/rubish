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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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

case $SH in dash|mksh|zsh) return ;; esac


set | grep -A1 foo

# Will print multi-line and binary data literally!
#declare -p foo

printf '\''pf  %q\n'\'' "$foo"

echo '\''@Q '\'' ${foo@Q}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Print shell strings with normal chars: set and printf %q and {x@Q}' {
  local cmd='# There are variations on whether quotes are printed

case $SH in dash|zsh) return ;; esac

foo=spam

set | grep -A1 foo

# Will print multi-line and binary data literally!
typeset -p foo

printf '\''pf  %q\n'\'' "$foo"

echo '\''@Q '\'' ${foo@Q}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 time pipeline' {
  local cmd='time echo hi | wc -c'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 shift' {
  local cmd='set -- 1 2 3 4
shift
echo "$@"
shift 2
echo "$@"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Shifting too far' {
  local cmd='set -- 1
shift 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Invalid shift argument' {
  local cmd='shift ZZZ'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

