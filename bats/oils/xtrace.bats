#!/usr/bin/env bats
# Generated from oils-for-unix spec/xtrace.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 unset PS4' {
  local cmd='case $SH in dash) echo '\''weird bug'\''; exit ;; esac

set -x
echo 1
unset PS4
echo 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 set -o verbose prints unevaluated code' {
  local cmd='set -o verbose
x=foo
y=bar
echo $x
echo $(echo $y)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 xtrace with unprintable chars' {
  local cmd='case $SH in dash) exit ;; esac

$SH >stdout 2>stderr <<'\''EOF'\''

s=$'\''a\x03b\004c\x00d'\''
set -o xtrace
echo "$s"
EOF

show_hex() { od -A n -t c -t x1; }

echo STDOUT
cat stdout | show_hex
echo

echo STDERR
grep '\''echo'\'' stderr '
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 xtrace with unicode chars' {
  local cmd='case $SH in dash) exit ;; esac

mu1='\''[μ]'\''
mu2=$'\''[\u03bc]'\''

set -o xtrace
echo "$mu1" "$mu2"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 xtrace with paths' {
  local cmd='set -o xtrace
echo my-dir/my_file.cc'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 xtrace with tabs' {
  local cmd='case $SH in dash) exit ;; esac

set -o xtrace
echo $'\''[\t]'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 xtrace with whitespace, quotes, and backslash' {
  local cmd='set -o xtrace
echo '\''1 2'\'' \'\'' \" \\'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 xtrace with newlines' {
  local cmd='# bash and dash trace this badly.  They print literal newlines, which I don'\''t
# want.
set -x
echo $'\''[\n]'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 xtrace written before command executes' {
  local cmd='set -x
echo one >&2
echo two >&2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Assignments and assign builtins' {
  local cmd='set -x
x=1 x=2; echo $x; readonly x=3'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 [[ ]]' {
  local cmd='case $SH in dash|mksh) exit ;; esac

set -x

dir=/
if [[ -d $dir ]]; then
  (( a = 42 ))
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 PS4 is scoped' {
  local cmd='set -x
echo one
f() { 
  local PS4='\''- '\''
  echo func;
}
f
echo two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 xtrace with variables in PS4' {
  local cmd='PS4='\''+$x:'\''
set -o xtrace
x=1
echo one
x=2
echo two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 PS4 with unterminated {' {
  local cmd='# osh shows inline error; maybe fail like dash/mksh?
x=1
PS4='\''+${x'\''
set -o xtrace
echo one
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 PS4 with unterminated (' {
  local cmd='# osh shows inline error; maybe fail like dash/mksh?
x=1
PS4='\''+$(x'\''
set -o xtrace
echo one
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 PS4 with runtime error' {
  local cmd='# osh shows inline error; maybe fail like dash/mksh?
x=1
PS4='\''+oops $(( 1 / 0 )) \$'\''
set -o xtrace
echo one
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Reading ? in PS4' {
  local cmd='PS4='\''[last=$?] '\''
set -x
false
echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Regression: xtrace for declare -a a+=(v)' {
  local cmd='case $SH in dash|mksh) exit ;; esac

a=(1)
set -x
declare a+=(2)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Regression: xtrace for a+=(v)' {
  local cmd='case $SH in dash|mksh) exit ;; esac

a=(1)
set -x
a+=(2)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

