#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-trap-err.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 trap can use original LINENO' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

false
false
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 trap ERR and set -o errexit' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

false
echo a

set -o errexit

echo b
false   # trap executed, and executation also halts
echo c  # doesn'\''t get here'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 trap ERR and errexit disabled context' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

false
echo a

set -o errexit

echo b
if false; then
  echo xx
fi
echo c  # doesn'\''t get here'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 trap ERR and if statement' {
  local cmd='if test -f /nope; then echo file exists; fi

trap '\''echo err'\'' ERR
#trap '\''echo line=$LINENO'\'' ERR

if test -f /nope; then echo file exists; fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 trap ERR and || conditional' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

false || false || false
echo ok

false && false
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 trap ERR and pipeline' {
  local cmd='# mksh and bash have different line numbers in this case
#trap '\''echo line=$LINENO'\'' ERR
trap '\''echo line=$LINENO'\'' ERR

# it'\''s run for the last '\''false'\''
false | false | false

{ echo pipeline; false; } | false | false

# it'\''s never run here
! true
! false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 trap ERR pipelines without simple commands' {
  local cmd='trap '\''echo assign'\'' ERR
a=$(false) | a=$(false) | a=$(false)

trap '\''echo dparen'\'' ERR
(( 0 )) | (( 0 )) | (( 0 ))

trap '\''echo dbracket'\'' ERR
[[ a = b ]] | [[ a = b ]] | [[ a = b ]]

# bash anomaly - it gets printed twice?
trap '\''echo subshell'\'' ERR
(false) | (false) | (false) | (false)

# same bug
trap '\''echo subshell2'\'' ERR 
(false) | (false) | (false) | (false; false)

trap '\''echo group'\'' ERR
{ false; } | { false; } | { false; }

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Pipeline group quirk' {
  local cmd='# Oh this is because it'\''s run for the PIPELINE, not for the last thing!  Hmmm

trap '\''echo group2'\'' ERR
{ false; } | { false; } | { false; false; }

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 trap ERR does not run in errexit situations' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

if false; then
  echo if
fi

while false; do
  echo while
done

until false; do
  echo until
  break
done

false || false || false

false && false && false

false; false; false

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 trap ERR doesn'\''t run in subprograms - subshell, command sub, async' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

( false; echo subshell )

x=$( false; echo command sub )

false & wait

{ false; echo async; } & wait

false
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 set -o errtrace: trap ERR runs in subprograms' {
  local cmd='case $SH in mksh) exit ;; esac

set -o errtrace
trap '\''echo line=$LINENO'\'' ERR

( false; echo subshell )

x=$( false; echo command sub )

false
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 trap ERR doesn'\''t run with &' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

false & wait

{ false; echo async; } & wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 set -o errtrace: trap ERR with &' {
  local cmd='case $SH in mksh) exit ;; esac

set -o errtrace
trap '\''echo line=$LINENO'\'' ERR

false & wait

{ false; echo async; } & wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 trap ERR not active in shell functions in (bash behavior)' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

f() {
  false 
  true
}

f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 set -o errtrace - trap ERR runs in shell functions' {
  local cmd='trap '\''echo err'\'' ERR

passing() {
  false  # line 4
  true
}

failing() {
  true
  false
}

passing
failing

set -o errtrace

echo '\''now with errtrace'\''
passing
failing

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 set -o errtrace - trap ERR runs in shell functions (LINENO)' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

passing() {
  false  # line 4
  true
}

failing() {
  true
  false
}

passing
failing

set -o errtrace

echo '\''now with errtrace'\''
passing
failing

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 trap ERR with atoms: assignment (( [[' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

x=$(false)

[[ a == b ]]

(( 0 ))
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 trap ERR with for,  case, { }' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

for y in 1 2; do
  false
done

case x in
  x) false ;;
  *) false ;;
esac

{ false; false; false; }
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 trap ERR with redirect' {
  local cmd='trap '\''echo line=$LINENO'\'' ERR

false

{ false 
  true
} > /zz  # error
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 trap ERR with YSH proc' {
  local cmd='case $SH in bash|mksh|ash) exit ;; esac

# seems the same

shopt -s ysh:upgrade

proc handler {
  echo err
}

if test -f /nope { echo file exists }

trap handler ERR

if test -f /nope { echo file exists }

false || true  # not run for the first part here
false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 trap ERR' {
  local cmd='err() {
  echo "err [$@] $?"
}
trap '\''err x y'\'' ERR 

echo A

false
echo B

( exit 42 )
echo C

trap - ERR  # disable trap

false
echo D

trap '\''echo after errexit $?'\'' ERR 

set -o errexit

( exit 99 )
echo E'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 trap ERR and pipelines - PIPESTATUS difference' {
  local cmd='case $SH in ash) exit ;; esac

err() {
  echo "err [$@] status=$? [${PIPESTATUS[@]}]"
}
trap '\''err'\'' ERR 

echo A

false

# succeeds
echo B | grep B

# fails
echo C | grep zzz

echo D | grep zzz | cat

set -o pipefail
echo E | grep zzz | cat

trap - ERR  # disable trap

echo F | grep zz
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 error in trap ERR (recursive)' {
  local cmd='case $SH in dash) exit ;; esac

err() {
  echo err status $?
  false
  ( exit 2 )  # not recursively triggered
  echo err 2
}
trap '\''err'\'' ERR 

echo A
false
echo B

# Try it with errexit
set -e
false
echo C'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

