#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-trap-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 trap -l' {
  local cmd='trap -l | grep INT >/dev/null'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 trap -p' {
  local cmd='trap '\''echo exit'\'' EXIT

trap -p > parent.txt

grep EXIT parent.txt >/dev/null
if test $? -eq 0; then
  echo shown
else
  echo not shown
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 trap -p in child is BUGGY in bash' {
  local cmd='# It shows the trap even though it doesn'\''t execute it!

trap '\''echo exit'\'' EXIT

trap -p | cat > child.txt

grep EXIT child.txt >/dev/null
if test $? -eq 0; then
  echo shown
else
  echo not shown
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 trap DEBUG ignores ?' {
  local cmd='debuglog() {
  echo "  [$@]"
  return 42     # IGNORED FAILURE
}

trap '\''debuglog $LINENO'\'' DEBUG

echo status=$?
echo A
echo status=$?
echo B
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 but trap DEBUG respects errexit' {
  local cmd='set -o errexit

debuglog() {
  echo "  [$@]"
  return 42
}

trap '\''debuglog $LINENO'\'' DEBUG

echo status=$?
echo A
echo status=$?
echo B
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 trap DEBUG with '\''return'\''' {
  local cmd='debuglog() {
  echo "  [$@]"
}

trap '\''debuglog $LINENO; return 42'\'' DEBUG

echo status=$?
echo A
echo status=$?
echo B
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 trap DEBUG with '\''exit'\''' {
  local cmd='debuglog() {
  echo "  [$@]"
}

trap '\''debuglog $LINENO; exit 42'\'' DEBUG

echo status=$?
echo A
echo status=$?
echo B
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 trap DEBUG with non-compound commands' {
  local cmd='case $SH in dash|mksh) exit ;; esac

debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

echo a
echo b; echo c

echo d && echo e
echo f || echo g

(( h = 42 ))
[[ j == j ]]

var=value

readonly r=value'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 trap DEBUG and control flow' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

while true; do
  echo hello
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 trap DEBUG and command sub / subshell' {
  local cmd='case $SH in dash|mksh) exit ;; esac

debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

echo "result = $(echo command sub; echo two)"
( echo subshell
  echo two
)
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 trap DEBUG not run in forked interpreter for first pipeline part' {
  local cmd='debuglog() {
  #echo "  PID=$$ BASHPID=$BASHPID LINENO=$1"
  echo "  LINENO=$1"
}
trap '\''debuglog $LINENO'\'' DEBUG

{ echo pipe1;
  echo pipe2; } \
  | cat
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 One '\''echo'\'' in first pipeline part - why does bash behave differently from case above?' {
  local cmd='# TODO: bash runs the trap 3 times, and osh only twice.  I don'\''t see why.  Is
# it because Process::Run() does trap_state.ClearForSubProgram()?  Probably
#echo top PID=$$ BASHPID=$BASHPID
#shopt -s lastpipe

debuglog() {
  #echo "  PID=$$ BASHPID=$BASHPID LINENO=$1"
  #echo "  LINENO=$1 $BASH_COMMAND"
  # LINENO=6 echo pipeline
  # LINENO=7 cat
  echo "  LINENO=$1"
}
trap '\''debuglog $LINENO'\'' DEBUG

echo pipeline \
  | cat
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 trap DEBUG and pipeline (lastpipe difference)' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

# gets run for each one of these
{ echo a; echo b; }

# only run for the last one, maybe I guess because traps aren'\''t inherited?
{ echo x; echo y; } | wc -l

# bash runs for all of these, but OSH doesn'\''t because we have SubProgramThunk
# Hm.
date | cat | wc -l

date |
  cat |
  wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 trap DEBUG function call' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

f() {
  local mylocal=1
  for i in "$@"; do
    echo i=$i
  done
}

f A B  # executes ONCE here, but does NOT go into the function call

echo next

f X Y

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 trap DEBUG case' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

name=foo.py

case $name in 
  *.py)
    echo python
    ;;
  *.sh)
    echo shell
    ;;
esac
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 trap DEBUG for each' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

for x in 1 2; do
  echo x=$x
done

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 trap DEBUG for expr' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

for (( i =3 ; i < 5; ++i )); do
  echo i=$i
done

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 trap DEBUG if while' {
  local cmd='debuglog() {
  echo "  [$@]"
}
trap '\''debuglog $LINENO'\'' DEBUG

if test x = x; then
  echo if
fi 

while test x != x; do
  echo while
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 trap RETURN' {
  local cmd='profile() {
  echo "profile [$@]"
}
g() {
  echo --
  echo g
  echo --
  return
}
f() {
  echo --
  echo f
  echo --
  g
}
# RETURN trap doesn'\''t fire when a function returns, only when a script returns?
# That'\''s not what the manual says.
trap '\''profile x y'\'' RETURN
f
. $REPO_ROOT/spec/testdata/return-helper.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Compare trap DEBUG vs. trap ERR' {
  local cmd='# Pipelines and AndOr are problematic

# THREE each
trap '\''echo dbg $LINENO'\'' DEBUG

false | false | false

false || false || false

! true

trap - DEBUG


# ONE EACH
trap '\''echo err $LINENO'\'' ERR

false | false | false

false || false || false

! true  # not run

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Combine DEBUG trap and USR1 trap' {
  local cmd='case $SH in dash|mksh|ash) exit ;; esac

trap '\''false; echo $LINENO usr1'\'' USR1
trap '\''false; echo $LINENO dbg'\'' DEBUG

sh -c "kill -USR1 $$"
echo after=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Combine ERR trap and USR1 trap' {
  local cmd='case $SH in dash|mksh|ash) exit ;; esac

trap '\''false; echo $LINENO usr1'\'' USR1
trap '\''false; echo $LINENO err'\'' ERR

sh -c "kill -USR1 $$"
echo after=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 Combine DEBUG trap and ERR trap' {
  local cmd='case $SH in dash|mksh|ash) exit ;; esac

trap '\''false; echo $LINENO err'\'' ERR
trap '\''false; echo $LINENO debug'\'' DEBUG

false
echo after=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

