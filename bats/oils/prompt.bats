#!/usr/bin/env bats
# Generated from oils-for-unix spec/prompt.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 sh -i' {
  local cmd='# Notes:
# - OSH prompt goes to stdout and bash goes to stderr
# - This test seems to fail on the system bash, but succeeds with spec-bin/bash
echo '\''echo foo'\'' | PS1='\''[prompt] '\'' $SH --rcfile /dev/null -i >out.txt 2>err.txt
fgrep -q '\''[prompt]'\'' out.txt err.txt
echo match=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 [] are non-printing' {
  local cmd='PS1='\''\[foo\]\$'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 literal escapes' {
  local cmd='PS1='\''\a\e\r\n'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 special case for ' {
  local cmd='# NOTE: This might be broken for # but it'\''s hard to tell since we don'\''t have
# root.  Could inject __TEST_EUID or something.
PS1='\''$'\''
echo "${PS1@P}"
PS1='\''\$'\''
echo "${PS1@P}"
PS1='\''\\$'\''
echo "${PS1@P}"
PS1='\''\\\$'\''
echo "${PS1@P}"
PS1='\''\\\\$'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 PS1 evaluation order' {
  local cmd='x='\''\'\''
y='\''h'\''
PS1='\''$x$y'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 PS1 evaluation order 2' {
  local cmd='foo=foo_value
dir=$TMP/'\''$foo'\''  # Directory name with a dollar!
mkdir -p $dir
cd $dir
PS1='\''\w $foo'\''
test "${PS1@P}" = "$PWD foo_value"
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 1004' {
  local cmd='PS1='\''\1004$'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 001 octal literals are supported' {
  local cmd='PS1='\''[\045]'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 555 is beyond max octal byte of 377 and wrapped to m' {
  local cmd='PS1='\''\555$'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 x55 hex literals not supported' {
  local cmd='PS1='\''[\x55]'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Single backslash' {
  local cmd='PS1='\''\'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Escaped backslash' {
  local cmd='PS1='\''\\'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 0001 octal literals are not supported' {
  local cmd='PS1='\''[\0455]'\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 u0001 unicode literals not supported' {
  local cmd='PS1='\''[\u0001]'\''
USER=$(whoami)
test "${PS1@P}" = "[${USER}0001]"
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 constant string' {
  local cmd='PS1='\''$ '\''
echo "${PS1@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 hostname' {
  local cmd='# NOTE: This test is not hermetic.  On my machine the short and long host name
# are the same.

PS1='\''\h '\''
test "${PS1@P}" = "$(hostname -s) "  # short name
echo status=$?
PS1='\''\H '\''
test "${PS1@P}" = "$(hostname) "
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 username' {
  local cmd='PS1='\''\u '\''
USER=$(whoami)
test "${PS1@P}" = "${USER} "
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 current working dir' {
  local cmd='PS1='\''\w '\''
test "${PS1@P}" = "${PWD} "
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 W is basename of working dir' {
  local cmd='PS1='\''\W '\''
test "${PS1@P}" = "$(basename $PWD) "
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 t for 24h time (HH:MM:SS)' {
  local cmd='PS1='\''foo \t bar'\''
echo "${PS1@P}" | egrep -q '\''foo [0-2][0-9]:[0-5][0-9]:[0-5][0-9] bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 T for 12h time (HH:MM:SS)' {
  local cmd='PS1='\''foo \T bar'\''
echo "${PS1@P}" | egrep -q '\''foo [0-1][0-9]:[0-5][0-9]:[0-5][0-9] bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 @ for 12h time (HH:MM AM/PM)' {
  local cmd='PS1='\''foo \@ bar'\''
echo "${PS1@P}" | egrep -q '\''foo [0-1][0-9]:[0-5][0-9] (A|P)M bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 A for 24h time (HH:MM)' {
  local cmd='PS1='\''foo \A bar'\''
echo "${PS1@P}" | egrep -q '\''foo [0-2][0-9]:[0-5][0-9] bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 d for date' {
  local cmd='PS1='\''foo \d bar'\''
echo "${PS1@P}" | egrep -q '\''foo [A-Z][a-z]+ [A-Z][a-z]+ [0-9]+ bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 D{%H:%M} for strftime' {
  local cmd='PS1='\''foo \D{%H:%M} bar'\''
echo "${PS1@P}" | egrep -q '\''foo [0-9][0-9]:[0-9][0-9] bar'\''
echo matched=$?

PS1='\''foo \D{%H:%M:%S} bar'\''
echo "${PS1@P}" | egrep -q '\''foo [0-9][0-9]:[0-9][0-9]:[0-9][0-9] bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 D{} for locale specific strftime' {
  local cmd='# In bash y.tab.c uses %X when string is empty
# This doesn'\''t seem to match exactly, but meh for now.

PS1='\''foo \D{} bar'\''
echo "${PS1@P}" | egrep -q '\''^foo [0-9][0-9]:[0-9][0-9]:[0-9][0-9]( ..)? bar$'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 s for shell, v for major.minor version, and V for full version' {
  local cmd='PS1='\''foo \s bar'\''
echo "${PS1@P}" | egrep -q '\''^foo (bash|osh) bar$'\''
echo match=$?

PS1='\''foo \v bar'\''
echo "${PS1@P}" | egrep -q '\''^foo [0-9]+\.[0-9]+ bar$'\''
echo match=$?

PS1='\''foo \V bar'\''
echo "${PS1@P}" | egrep -q '\''^foo [0-9]+\.[0-9]+\.[0-9]+ bar$'\''
echo match=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 j for number of jobs' {
  local cmd='set -m # enable job control
PS1='\''foo \j bar'\''
echo "${PS1@P}" | egrep -q '\''foo 0 bar'\''
echo matched=$?
sleep 5 &
echo "${PS1@P}" | egrep -q '\''foo 1 bar'\''
echo matched=$?
kill %%
fg
echo "${PS1@P}" | egrep -q '\''foo 0 bar'\''
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 l for TTY device basename' {
  local cmd='PS1='\''foo \l bar'\''
# FIXME this never an actual TTY when using ./test/spec.sh
tty="$(tty)"
if [[ "$tty" == "not a tty" ]]; then
    expected="tty"
else
    expected="$(basename "$tty")"
fi
echo "${PS1@P}" | egrep -q "foo $expected bar"
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 ! for history number' {
  local cmd='set -o history # enable history
PS1='\''foo \! bar'\''
history -c # clear history
echo "${PS1@P}" | egrep -q "foo 1 bar"
echo matched=$?
echo "_${PS1@P}" | egrep -q "foo 3 bar"
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 # for command number' {
  local cmd='PS1='\''foo \# bar'\''
prev_cmd_num="$(echo "${PS1@P}" | egrep -o '\''foo [0-9]+ bar'\'' | sed -E '\''s/foo ([0-9]+) bar/\1/'\'')"
echo "${PS1@P}" | egrep -q "foo $((prev_cmd_num + 1)) bar"
echo matched=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 @P with array' {
  local cmd='$SH -c '\''echo ${@@P}'\'' dummy a b c
echo status=$?
$SH -c '\''echo ${*@P}'\'' dummy a b c
echo status=$?
$SH -c '\''a=(x y); echo ${a@P}'\'' dummy a b c
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 default PS1' {
  local cmd='#flags='\''--norc --noprofile'\''
flags='\''--rcfile /dev/null'\''

$SH $flags -i -c '\''echo "_${PS1}_"'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

