#!/usr/bin/env bats
# Generated from oils-for-unix spec/errexit-osh.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 command sub: errexit is NOT inherited and outer shell keeps going' {
  local cmd='# This is the bash-specific bug here:
# https://blogs.janestreet.com/when-bash-scripts-bite/
# See inherit_errexit below.
#
# I remember finding a script that relies on bash'\''s bad behavior, so OSH copies
# it.  But you can opt in to better behavior.

set -o errexit
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 command sub with inherit_errexit only' {
  local cmd='set -o errexit
shopt -s inherit_errexit || true
echo zero
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 strict_errexit and assignment builtins (local, export, readonly ...)' {
  local cmd='set -o errexit
shopt -s strict_errexit || true
#shopt -s command_sub_errexit || true

f() {
  local x=$(echo hi; false)
  echo x=$x
}

eval '\''f'\''
echo ---'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 strict_errexit and command sub in export / readonly' {
  local cmd='case $SH in dash|bash|mksh|ash) exit ;; esac

$SH -o errexit -O strict_errexit -c '\''echo a; export x=$(might-fail); echo b'\''
echo status=$?
$SH -o errexit -O strict_errexit -c '\''echo a; readonly x=$(might-fail); echo b'\''
echo status=$?
$SH -o errexit -O strict_errexit -c '\''echo a; x=$(true); echo b'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 strict_errexit disallows pipeline' {
  local cmd='set -o errexit
shopt -s strict_errexit || true

if echo 1 | grep 1; then
  echo one
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 strict_errexit allows singleton pipeline' {
  local cmd='set -o errexit
shopt -s strict_errexit || true

if ! false; then
  echo yes
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 strict_errexit with && || !' {
  local cmd='set -o errexit
shopt -s strict_errexit || true

if true && true; then
  echo A
fi

if true || false; then
  echo B
fi

if ! false && ! false; then
  echo C
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 strict_errexit detects proc in && || !' {
  local cmd='set -o errexit
shopt -s strict_errexit || true

myfunc() {
  echo '\''failing'\''
  false
  echo '\''should not get here'\''
}

if true && ! myfunc; then
  echo B
fi

if ! myfunc; then
  echo A
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 strict_errexit without errexit proc' {
  local cmd='myproc() {
  echo myproc
}
myproc || true

# This should be a no-op I guess
shopt -s strict_errexit || true
myproc || true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 strict_errexit without errexit proc / command sub' {
  local cmd='# Implementation quirk:
# - The proc check happens only if errexit WAS on and is disabled
# - But '\''shopt --unset allow_csub_psub'\'' happens if it was never on

shopt -s strict_errexit || true

p() {
  echo before
  local x
  # This line fails, which is a bit weird, but errexit
  x=$(false)
  echo x=$x
}

if p; then
  echo ok
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 strict_errexit and errexit disabled' {
  local cmd='case $SH in dash|bash|mksh|ash) exit ;; esac

shopt -s parse_brace strict_errexit || true

p() {
  echo before
  local x
  # This line fails, which is a bit weird, but errexit
  x=$(false)
  echo x=$x
}

set -o errexit
shopt --unset errexit {
  # It runs normally here, because errexit was disabled (just not by a
  # conditional)
  p
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 command sub with command_sub_errexit only' {
  local cmd='set -o errexit
shopt -s command_sub_errexit || true
echo zero
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 command_sub_errexit stops at first error' {
  local cmd='case $SH in dash|bash|mksh|ash) exit ;; esac

set -o errexit
shopt --set parse_brace command_sub_errexit verbose_errexit || true

rm -f BAD

try {
  echo $(date %d) $(touch BAD)
}
if ! test -f BAD; then  # should not exist
  echo OK
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 command sub with inherit_errexit and command_sub_errexit' {
  local cmd='set -o errexit

# bash implements inherit_errexit, but it'\''s not as strict as OSH.
shopt -s inherit_errexit || true
shopt -s command_sub_errexit || true
echo zero
echo $(echo one; false; echo two)  # bash/ash keep going
echo parent status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 command sub: last command fails but keeps going and exit code is 0' {
  local cmd='set -o errexit
echo $(echo one; false)  # we lost the exit code
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 global assignment with command sub: middle command fails' {
  local cmd='set -o errexit
s=$(echo one; false; echo two;)
echo "$s"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 global assignment with command sub: last command fails and it aborts' {
  local cmd='set -o errexit
s=$(echo one; false)
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 local: middle command fails and keeps going' {
  local cmd='set -o errexit
f() {
  echo good
  local x=$(echo one; false; echo two)
  echo status=$?
  echo $x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 local: last command fails and also keeps going' {
  local cmd='set -o errexit
f() {
  echo good
  local x=$(echo one; false)
  echo status=$?
  echo $x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 local and inherit_errexit / command_sub_errexit' {
  local cmd='# I'\''ve run into this problem a lot.
set -o errexit
shopt -s inherit_errexit || true  # bash option
shopt -s command_sub_errexit || true  # oil option
f() {
  echo good
  local x=$(echo one; false; echo two)
  echo status=$?
  echo $x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 global assignment when last status is failure' {
  local cmd='# this is a bug I introduced
set -o errexit
x=$(false) || true   # from abuild
[ -n "$APORTSDIR" ] && true
BUILDDIR=${_BUILDDIR-$BUILDDIR}
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 strict_errexit prevents errexit from being disabled in function' {
  local cmd='set -o errexit
fun() { echo fun; }

fun || true  # this is OK

shopt -s strict_errexit || true

echo '\''builtin ok'\'' || true
env echo '\''external ok'\'' || true

fun || true  # this fails'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 strict_errexit prevents errexit from being disabled in brace group' {
  local cmd='set -o errexit
# false failure is NOT respected either way
{ echo foo; false; echo bar; } || echo "failed"

shopt -s strict_errexit || true
{ echo foo; false; echo bar; } || echo "failed"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 strict_errexit prevents errexit from being disabled in subshell' {
  local cmd='set -o errexit
shopt -s inherit_errexit || true

# false failure is NOT respected either way
( echo foo; false; echo bar; ) || echo "failed"

shopt -s strict_errexit || true
( echo foo; false; echo bar; ) || echo "failed"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 strict_errexit and ! && || if while until' {
  local cmd='prelude='\''set -o errexit
shopt -s strict_errexit || true
fun() { echo fun; }'\''

$SH -c "$prelude; ! fun; echo '\''should not get here'\''"
echo bang=$?
echo --

$SH -c "$prelude; fun || true"
echo or=$?
echo --

$SH -c "$prelude; fun && true"
echo and=$?
echo --

$SH -c "$prelude; if fun; then true; fi"
echo if=$?
echo --

$SH -c "$prelude; while fun; do echo while; exit; done"
echo while=$?
echo --

$SH -c "$prelude; until fun; do echo until; exit; done"
echo until=$?
echo --'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 if pipeline doesn'\''t fail fatally' {
  local cmd='set -o errexit
set -o pipefail

f() {
  local dir=$1
	if ls $dir | grep '\'''\''; then
    echo foo
		echo ${PIPESTATUS[@]}
	fi
}
rmdir $TMP/_tmp || true
rm -f $TMP/*
f $TMP
f /nonexistent # should fail
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 errexit is silent (verbose_errexit for Oils)' {
  local cmd='shopt -u verbose_errexit 2>/dev/null || true
set -e
false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 command sub errexit preserves exit code' {
  local cmd='set -e
shopt -s command_sub_errexit || true

echo before
echo $(exit 42)
echo after'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 What'\''s in strict:all?' {
  local cmd='# inherit_errexit, strict_errexit, but not command_sub_errexit!
# for that you need oil:upgrade!

set -o errexit
shopt -s strict:all || true

# inherit_errexit is bash compatible, so we have it
#echo $(date %x)

# command_sub_errexit would hide errors!
f() {
  local d=$(date %x)
}
f

deploy_func() {
  echo one
  false
  echo two
}

if ! deploy_func; then
  echo failed
fi

echo '\''should not get here'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 command_sub_errexit causes local d=(date %x) to fail' {
  local cmd='set -o errexit
shopt -s inherit_errexit || true
#shopt -s strict_errexit || true
shopt -s command_sub_errexit || true

myproc() {
  # this is disallowed because we want a runtime error 100% of the time
  local x=$(true)

  # Realistic example.  Should fail here but shells don'\''t!
  local d=$(date %x)
  echo hi
}
myproc'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 command_sub_errexit and command sub in array' {
  local cmd='case $SH in dash|ash|mksh) exit ;; esac

set -o errexit
shopt -s inherit_errexit || true
#shopt -s strict_errexit || true
shopt -s command_sub_errexit || true

# We don'\''t want silent failure here
readonly -a myarray=( one "$(date %x)" two )

#echo len=${#myarray[@]}
argv.py "${myarray[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 OLD: command sub in conditional, with inherit_errexit' {
  local cmd='set -o errexit
shopt -s inherit_errexit || true
if echo $(echo 1; false; echo 2); then
  echo A
fi
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 OLD: command sub in redirect in conditional' {
  local cmd='set -o errexit

if echo tmp_contents > $(echo tmp); then
  echo 2
fi
cat tmp'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 Regression' {
  local cmd='case $SH in bash|dash|ash|mksh) exit ;; esac

shopt --set oil:upgrade

shopt --unset errexit {
  echo hi
}

proc p {
  echo p
}

shopt --unset errexit {
  p
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 ShAssignment used as conditional' {
  local cmd='while x=$(false)
do   
  echo while
done

if x=$(false)
then
  echo if
fi

if x=$(true)
then
  echo yes
fi

# Same thing with errexit -- NOT affected
set -o errexit

while x=$(false)
do   
  echo while
done

if x=$(false)
then
  echo if
fi

if x=$(true)
then
  echo yes
fi

# Same thing with strict_errexit -- NOT affected
shopt -s strict_errexit || true

while x=$(false)
do   
  echo while
done

if x=$(false)
then
  echo if
fi

if x=$(true)
then
  echo yes
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

