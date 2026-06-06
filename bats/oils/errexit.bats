#!/usr/bin/env bats
# Generated from oils-for-unix spec/errexit.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 errexit aborts early' {
  local cmd='set -o errexit
false
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 errexit for nonexistent command' {
  local cmd='set -o errexit
nonexistent__ZZ
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 errexit aborts early on pipeline' {
  local cmd='set -o errexit
echo hi | grep nonexistent
echo two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 errexit with { }' {
  local cmd='# This aborts because it'\''s not part of an if statement.
set -o errexit
{ echo one; false; echo two; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 errexit with if and { }' {
  local cmd='set -o errexit
if { echo one; false; echo two; }; then
  echo three
fi
echo four'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 errexit with ||' {
  local cmd='set -o errexit
echo hi | grep nonexistent || echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 errexit with &&' {
  local cmd='set -o errexit
echo ok && echo hi | grep nonexistent '
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 errexit test && -- from gen-module-init' {
  local cmd='set -o errexit
test "$mod" = readline && echo "#endif"
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 errexit test && and fail' {
  local cmd='set -o errexit
test -n X && false
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 More && ||' {
  local cmd='$SH -c '\''set -e; false || { echo group; false; }; echo bad'\''
echo status=$?
echo

$SH -c '\''set -e; false || ( echo subshell; exit 42 ); echo bad'\''
echo status=$?
echo

# noforklast optimization
$SH -c '\''set -e; false || /bin/false; echo bad'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 errexit and loop' {
  local cmd='set -o errexit
for x in 1 2 3; do
  test $x = 2 && echo "hi $x"
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 errexit and brace group { }' {
  local cmd='set -o errexit
{ test no = yes && echo hi; }
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 errexit and time { }' {
  local cmd='set -o errexit
time false
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 errexit with !' {
  local cmd='set -o errexit
echo one
! true
echo two
! false
echo three'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 errexit with ! and ;' {
  local cmd='# AST has extra Sentence nodes; there was a REGRESSION here.
set -o errexit; echo one; ! true; echo two; ! false; echo three'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 errexit with while/until' {
  local cmd='set -o errexit
while false; do
  echo ok
done
until false; do
  echo ok  # do this once then exit loop
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 errexit with (( ))' {
  local cmd='# from http://mywiki.wooledge.org/BashFAQ/105, this changed between versions.
# ash says that '\''i++'\'' is not found, but it doesn'\''t exit.  I guess this is the 
# subshell problem?
set -o errexit
i=0
(( i++ ))
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 errexit with subshell' {
  local cmd='set -o errexit
( echo one; false; echo two; )
echo three'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 set -o errexit while it'\''s being ignored (moot with strict_errexit)' {
  local cmd='set -o errexit
# osh aborts early here
if { echo 1; false; echo 2; set -o errexit; echo 3; false; echo 4; }; then
  echo 5;
fi
echo 6
false  # this is the one that makes shells fail
echo 7'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 set +o errexit while it'\''s being ignored (moot with strict_errexit)' {
  local cmd='set -o errexit
if { echo 1; false; echo 2; set +o errexit; echo 3; false; echo 4; }; then
  echo 5;
fi
echo 6
false  # does NOT fail, because we restored it.
echo 7'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 set +o errexit with 2 levels of ignored' {
  local cmd='set -o errexit
if { echo 1; ! set +o errexit; echo 2; }; then
  echo 3
fi
echo 6
false
echo 7'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 setting errexit in a subshell works but doesn'\''t affect parent shell' {
  local cmd='( echo 1; false; echo 2; set -o errexit; echo 3; false; echo 4; )
echo 5
false
echo 6'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 set errexit while it'\''s ignored in a subshell (moot with strict_errexit)' {
  local cmd='set -o errexit
if ( echo 1; false; echo 2; set -o errexit; echo 3; false; echo 4 ); then
  echo 5;
fi
echo 6  # This is executed because the subshell just returns false
false 
echo 7'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 shopt -s strict:all || true while errexit is on' {
  local cmd='set -o errexit
shopt -s strict:all || true
echo one
false  # fail
echo two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 errexit double guard' {
  local cmd='# OSH bug fix.  ErrExit needs a counter, not a boolean.
set -o errexit
if { ! false; false; true; } then
  echo true
fi
false
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 background processes respect errexit' {
  local cmd='set -o errexit
{ echo one; false; echo two; exit 42; } &
wait $!'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 pipeline process respects errexit' {
  local cmd='set -o errexit
# It is respected here.
{ echo one; false; echo two; } | cat

# Also respected here.
{ echo three; echo four; } | while read line; do
  echo "[$line]"
  false
done
echo four'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 simple command / assign - redir failure DOES respect errexit' {
  local cmd='$SH -c '\''
set -o errexit
true > /
echo builtin status=$?
'\''
echo status=$?

$SH -c '\''
set -o errexit
/bin/true > /
echo extern status=$?
'\''
echo status=$?

$SH -c '\''
set -o errexit
assign=foo > /
echo assign status=$?
'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 simple command that'\''s an alias - redir failure checked' {
  local cmd='# bash 5.2 fixed bash 4.4 bug: this is now checked

$SH -c '\''
shopt -s expand_aliases

set -o errexit
alias zz="{ echo 1; echo 2; }"
zz > /
echo alias status=$?
'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 bash atoms [[ (( - redir failure checked' {
  local cmd='# bash 5.2 fixed bash 4.4 bug: this is now checked

case $SH in dash) exit ;; esac

$SH -c '\''
set -o errexit
[[ x = x ]] > /
echo dbracket status=$?
'\''
echo status=$?

$SH -c '\''
set -o errexit
(( 42 )) > /
echo dparen status=$?
'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 brace group - redir failure checked' {
  local cmd='# bash 5.2 fixed bash 4.4 bug: this is now checked

# case from
# https://lists.gnu.org/archive/html/bug-bash/2020-05/msg00066.html

set -o errexit

{ cat ; } < not_exist.txt   

echo status=$?
echo '\''should not get here'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 while loop - redirect failure checked' {
  local cmd='# bash 5.2 fixed bash 4.4 bug: this is now checked

# case from
# https://lists.gnu.org/archive/html/bug-bash/2020-05/msg00066.html

set -o errexit

while read line; do
 echo $line
done < not_exist.txt   

echo status=$?
echo '\''should not get here'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 set -e enabled in function (regression)' {
  local cmd='foo() {
  set -e
  false
  echo "should be executed"
}
#foo && true
#foo || true

if foo; then
  true
fi

echo "should be executed"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 set -e in function #2' {
  local cmd='foo() {
  set -e
  false
  echo "should be executed"
}
! foo

echo "should be executed"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 Command sub exit code is lost' {
  local cmd='echo ft $(false) $(true)
echo status=$?

set -o errexit
shopt -s inherit_errexit || true

# This changes it
#shopt -s command_sub_errexit || true

echo f $(date %x)
echo status=$?

# compare with 
# x=$(date %x)         # FAILS
# local x=$(date %x)   # does NOT fail

echo ft $(false) $(true)
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

