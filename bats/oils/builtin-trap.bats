#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-trap.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 trap accepts/ignores --' {
  local cmd='trap -- '\''echo hi'\'' EXIT
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 trap foo gives non-zero error' {
  local cmd='trap '\''foo'\''
if test $? -ne 0; then
  echo ok
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 SIGINT and INT are aliases' {
  local cmd='trap - SIGINT
echo $?
trap - INT
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 trap without args prints traps' {
  local cmd='trap '\''echo exit'\'' EXIT
echo status=$?

trap
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 print trap handler with multiple lines' {
  local cmd='trap '\''echo 1
echo 2
echo 3'\'' INT

trap'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 trap -p is like trap: it prints the handlers and full signal names' {
  local cmd='case $SH in dash) exit ;; esac
trap "echo INT" INT
trap "echo EXIT" EXIT
trap -p'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Register the same handler for multiple signals' {
  local cmd='trap '\''echo test'\'' TERM 2 EXIT
trap'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 trap 0 is equivalent to trap EXIT' {
  local cmd='trap "echo INT" INT
trap "echo EXIT" 0  # EXIT
trap
echo ---
trap 0
trap'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 exit 1 when trap code string is invalid' {
  local cmd='# All shells spew warnings to stderr, but don'\''t actually exit!  Bad!
trap '\''echo <'\'' EXIT
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 trap EXIT calling exit' {
  local cmd='cleanup() {
  echo "cleanup [$@]"
  exit 42
}
trap '\''cleanup x y z'\'' EXIT'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 trap EXIT return status ignored' {
  local cmd='cleanup() {
  echo "cleanup [$@]"
  return 42
}
trap '\''cleanup x y z'\'' EXIT'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 trap EXIT with PARSE error' {
  local cmd='trap '\''echo FAILED'\'' EXIT
for'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 trap EXIT with PARSE error and explicit exit' {
  local cmd='trap '\''echo FAILED; exit 0'\'' EXIT
for'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 trap EXIT with explicit exit' {
  local cmd='trap '\''echo IN TRAP; echo $stdout'\'' EXIT 
stdout=FOO
exit 42'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 trap EXIT with command sub / subshell / pipeline' {
  local cmd='trap '\''echo EXIT TRAP'\'' EXIT 

echo $(echo command sub)

( echo subshell )

echo pipeline | cat'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 eval in the exit trap (regression for issue #293)' {
  local cmd='trap '\''eval "echo hi"'\'' 0'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 exit codes for traps are isolated' {
  local cmd='trap '\''echo USR1 trap status=$?; ( exit 42 )'\'' USR1

echo before=$?

# Equivalent to '\''kill -USR1 $$'\'' except OSH doesn'\''t have "kill" yet.
# /bin/kill doesn'\''t exist on Debian unless '\''procps'\'' is installed.
sh -c "kill -USR1 $$"
echo after=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 trap USR1, sleep, SIGINT: non-interactively' {
  local cmd='$REPO_ROOT/spec/testdata/builtin-trap-usr1.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 trap INT, sleep, SIGINT: non-interactively' {
  local cmd='# mksh behaves differently in CI -- maybe when it'\''s not connected to a
# terminal?
case $SH in mksh) echo mksh; exit ;; esac

$REPO_ROOT/spec/testdata/builtin-trap-int.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 trap EXIT, sleep, SIGINT: non-interactively' {
  local cmd='$REPO_ROOT/spec/testdata/builtin-trap-exit.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 trap '\'''\'' sets handler to empty string (SIG_IGN)' {
  local cmd='# Note: this doesn'\''t actually test that it'\''s SIG_IGN

trap '\'''\'' USR1
trap'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 trap '\'''\'' with multiple signals' {
  local cmd='trap '\'''\'' USR1 USR2
trap'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 trap with command.NoOp - check internal invariant' {
  local cmd='$SH -c '\''trap "> zz" EXIT'\''
wc -l zz  # should exist'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

