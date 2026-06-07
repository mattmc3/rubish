#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-special.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 true is not special; prefix assignments don'\''t persist, it can be redefined' {
  local cmd='foo=bar true
echo foo=$foo

true() {
  echo true func
}
foo=bar true
echo foo=$foo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Prefix assignments persist after special builtins, like : (set -o posix)' {
  local cmd='case $SH in
  bash) set -o posix ;;
esac

foo=bar :
echo foo=$foo

# Not true when you use '\''builtin'\''
z=Z builtin :
echo z=$Z'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Prefix assignments persist after readonly, but NOT exported (set -o posix)' {
  local cmd='# Bash only implements it behind the posix option
case $SH in
  bash) set -o posix ;;
esac
foo=bar readonly spam=eggs
echo foo=$foo
echo spam=$spam

# should NOT be exported
printenv.py foo
printenv.py spam'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Prefix binding for exec is a special case (versus e.g. readonly)' {
  local cmd='pre1=pre1 readonly x=x
pre2=pre2 exec sh -c '\''echo pre1=$pre1 x=$x pre2=$pre2'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 exec without args is a special case of the special case in some shells' {
  local cmd='FOO=bar exec >& 2
echo FOO=$FOO
#declare -p | grep FOO'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Which shells allow special builtins to be redefined?' {
  local cmd='eval() {
  echo '\''eval func'\'' "$@"
}
eval '\''echo hi'\''

# we allow redefinition, but the definition is NOT used!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Special builtins can'\''t be redefined as shell functions (set -o posix)' {
  local cmd='case $SH in
  bash) set -o posix ;;
esac

eval '\''echo hi'\''

eval() {
  echo '\''sh func'\'' "$@"
}

eval '\''echo hi'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Non-special builtins CAN be redefined as functions' {
  local cmd='test -n "$BASH_VERSION" && set -o posix
true() {
  echo '\''true func'\''
}
true hi
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Shift is special and fails whole script' {
  local cmd='# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_14
#
# 2.8.1 - Consequences of shell errors
#
# Special built-ins should exit a non-interactive shell
# bash and busybox dont'\''t implement this even with set -o posix, so it seems risky
# dash and mksh do it; so does AT&T ksh

$SH -c '\''
if test -n "$BASH_VERSION"; then
  set -o posix
fi
set -- a b
shift 3
echo status=$?
'\''
if test "$?" != 0; then
  echo '\''non-zero status'\''
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 set is special and fails whole script, even if using || true' {
  local cmd='$SH -c '\''
if test -n "$BASH_VERSION"; then
  set -o posix
fi

shopt -s invalid_ || true
echo ok
set -o invalid_ || true
echo should not get here
'\''
if test "$?" != 0; then
  echo '\''non-zero status'\''
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 bash '\''type'\'' gets confused - says '\''function'\'', but runs builtin' {
  local cmd='case $SH in dash|mksh|zsh|ash|yash) exit ;; esac

echo TRUE
type -t true  # builtin
true() { echo true func; }
type -t true  # now a function
echo ---

echo EVAL

type -t eval  # builtin
# define function before set -o posix
eval() { echo "shell function: $1"; }
# bash runs the FUNCTION, but OSH finds the special builtin
# OSH doesn'\''t need set -o posix
eval '\''echo before posix'\''

if test -n "$BASH_VERSION"; then
  # this makes the eval definition invisible!
  set -o posix
fi

eval '\''echo after posix'\''  # this is the builtin eval
# bash claims it'\''s a function, but it'\''s a builtin
type -t eval

# it finds the function and the special builtin
#type -a eval'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 command, builtin - both can be redefined, not special (regression)' {
  local cmd='case $SH in dash|ash|yash) exit ;; esac

builtin echo b
command echo c

builtin() {
  echo builtin-redef "$@"
}

command() {
  echo command-redef "$@"
}

builtin echo b
command echo c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

