#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-trap.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 traps are not active inside subshells () ()  trap | cat' {
  local cmd='# TODO: should we change this?  We'\''re not compatible with bash or busybox ash

trap '\''echo bye'\'' EXIT

# NOT a subshell
trap > traps.txt
wc -l traps.txt

echo '\''( )'\''
( trap )

echo '\''$(trap)'\''
echo $(trap)

echo '\''trap | cat'\''
trap | cat'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 trap accepts/ignores --' {
  local cmd='trap -- '\''echo hi'\'' EXIT
echo ok'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Register invalid trap, remove invalid trap' {
  local cmd='trap '\''foo'\'' SIGINVALID
if test $? -ne 0; then
  echo ok
fi

trap - SIGINVALID
if test $? -ne 0; then
  echo ok
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 trap foo gives non-zero error' {
  local cmd='trap '\''foo'\''
if test $? -ne 0; then
  echo ok
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 SIGINT and INT are aliases' {
  local cmd='trap - SIGINT
echo $?
trap - INT
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 trap without args prints traps' {
  local cmd='trap '\''echo exit'\'' EXIT
echo status=$?

trap
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 print trap handler with multiple lines' {
  local cmd='trap '\''echo 1
echo 2
echo 3'\'' INT

trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 trap -p is like trap: it prints the handlers and full signal names' {
  local cmd='trap "echo INT" INT
trap "echo EXIT" EXIT
trap -p'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Register the same handler for multiple signals' {
  local cmd='trap '\''echo test'\'' TERM 2 EXIT
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Remove multiple handlers with trap -' {
  local cmd='trap "echo int" INT
trap "echo e" EXIT
trap - int 0 3
trap

echo ---
trap "echo int" INT
trap "echo e" EXIT
trap - int 0 -99
if test $? -ne 0; then
  echo ok
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 trap EXIT clears the EXIT trap' {
  local cmd='trap "echo INT" INT
trap "echo EXIT" EXIT
trap
echo ---
trap EXIT
trap
echo ---
trap INT
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 trap 0 is equivalent to trap EXIT' {
  local cmd='trap "echo INT" INT
trap "echo EXIT" 0  # EXIT
trap
echo ---
trap 0
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 trap 1 is equivalent to SIGHUP; HUP is equivalent to SIGHUP' {
  local cmd='trap '\''echo HUP'\'' SIGHUP
echo status=$?
trap '\''echo HUP'\'' HUP
echo status=$?
trap '\''echo HUP'\'' 1
echo status=$?
trap - HUP
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 trap 0 2 resets EXIT AND SIGINT' {
  local cmd='trap "echo EXIT" EXIT
echo ---
trap
echo ---
trap 0 2
trap
echo ---
trap "echo INT" INT
trap "echo EXIT" EXIT
trap 2 EXIT
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 trap '\'''\'' EXIT - printing state' {
  local cmd='trap '\''echo exit'\'' EXIT
trap
echo

trap '\'''\'' EXIT
trap
echo

trap '\''# comment'\'' EXIT
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 trap '\''echo hi'\'' KILL (regression test, caught by smoosh suite)' {
  local cmd='trap '\''echo hi'\'' 9
echo status=$?

trap '\''echo hi'\'' KILL
echo status=$?

trap '\''echo hi'\'' STOP
echo status=$?

trap '\''echo hi'\'' TERM
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 exit 1 when trap code string is invalid' {
  local cmd='# All shells spew warnings to stderr, but don'\''t actually exit!  Bad!
trap '\''echo <'\'' EXIT
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 trap EXIT calling exit' {
  local cmd='cleanup() {
  echo "cleanup [$@]"
  exit 42
}
trap '\''cleanup x y z'\'' EXIT'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 trap EXIT return status ignored' {
  local cmd='cleanup() {
  echo "cleanup [$@]"
  return 42
}
trap '\''cleanup x y z'\'' EXIT'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 trap EXIT with PARSE error' {
  local cmd='trap '\''echo FAILED'\'' EXIT
for'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 trap EXIT with PARSE error and explicit exit' {
  local cmd='trap '\''echo FAILED; exit 0'\'' EXIT
for'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 trap EXIT with explicit exit' {
  local cmd='trap '\''echo IN TRAP; echo $stdout'\'' EXIT 
stdout=FOO
exit 42'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 trap EXIT with command sub / subshell / pipeline' {
  local cmd='trap '\''echo EXIT TRAP'\'' EXIT 

echo $(echo command sub)

( echo subshell )

echo pipeline | cat'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 eval in the exit trap (regression for issue #293)' {
  local cmd='trap '\''eval "echo hi"'\'' 0'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 exit codes for traps are isolated' {
  local cmd='trap '\''echo USR1 trap status=$?; ( exit 42 )'\'' USR1

echo before=$?

# Equivalent to '\''kill -USR1 $$'\'' except OSH doesn'\''t have "kill" yet.
# /bin/kill doesn'\''t exist on Debian unless '\''procps'\'' is installed.
sh -c "kill -USR1 $$"
echo after=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 traps are cleared in subshell (started with &)' {
  local cmd='# Test with SIGURG because the default handler is SIG_IGN
#
# If we use SIGUSR1, I think the shell reverts to killing the process

# https://man7.org/linux/man-pages/man7/signal.7.html

trap '\''echo SIGURG'\'' URG

kill -URG $$

# Hm trap doesn'\''t happen here
{ echo begin child; sleep 0.1; echo end child; } &
kill -URG $!
wait
echo "wait status $?"

# In the CI, mksh sometimes gives:
#
# USR1
# begin child
# done
# 
# leaving off '\''end child'\''.  This seems like a BUG to me?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 trap USR1, sleep, SIGINT: non-interactively' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='$REPO_ROOT/spec/testdata/builtin-trap-usr1.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 trap INT, sleep, SIGINT: non-interactively' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='# mksh behaves differently in CI -- maybe when it'\''s not connected to a
# terminal?

$REPO_ROOT/spec/testdata/builtin-trap-int.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 trap EXIT, sleep, SIGINT: non-interactively' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='$REPO_ROOT/spec/testdata/builtin-trap-exit.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 Remove trap with an unsigned integer' {
  local cmd='$SH -e -c '\''
trap "echo noprint" EXIT
trap 0 EXIT
echo ok0
'\''
echo

$SH -e -c '\''
trap "echo noprint" EXIT
trap " 42 " EXIT
echo ok42space
'\''
echo

# corner case: sometimes 07 is treated as octal, but not here
$SH -e -c '\''
trap "echo noprint" EXIT
trap 07 EXIT
echo ok07
'\''
echo

$SH -e -c '\''
trap "echo trap-exit" EXIT
trap -1 EXIT
echo bad
'\''
if test $? -ne 0; then
  echo failure
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 trap '\'''\'' sets handler to empty string (SIG_IGN)' {
  local cmd='# Note: this doesn'\''t actually test that it'\''s SIG_IGN

trap '\'''\'' USR1
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 trap '\'''\'' with multiple signals' {
  local cmd='trap '\'''\'' USR1 USR2
trap'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 trap with command.NoOp - check internal invariant' {
  local cmd='$SH -c '\''trap "> zz" EXIT'\''
wc -l zz  # should exist'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

