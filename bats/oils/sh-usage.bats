#!/usr/bin/env bats
# Generated from oils-for-unix spec/sh-usage.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 sh -c' {
  local cmd='$SH -c '\''echo hi'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 empty -c input' {
  local cmd='# had a bug here
$SH -c '\'''\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 sh +c is accepted' {
  local cmd='$SH +c '\''echo hi'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 empty stdin' {
  local cmd='# had a bug here
echo -n '\'''\'' | $SH'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 sh - and sh -- stop flag processing' {
  local cmd='echo '\''echo foo'\'' > foo.sh

$SH -x -v -- foo.sh

echo -  
echo - >& 2

$SH -x -v - foo.sh'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 shell obeys --help (regression for OSH)' {
  local cmd='n=$($SH --help | wc -l)
if test $n -gt 0; then
  echo yes
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 args are passed' {
  local cmd='$SH -c '\''argv.py "$@"'\'' dummy a b'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 args that look like flags are passed after script' {
  local cmd='script=$TMP/sh1.sh
echo '\''argv.py "$@"'\'' > $script
chmod +x $script
$SH $script --help --help -h'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 args that look like flags are passed after -c' {
  local cmd='$SH -c '\''argv.py "$@"'\'' --help --help -h'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 exit with explicit arg' {
  local cmd='exit 42'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 exit with no args' {
  local cmd='false
exit'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 --rcfile in non-interactive shell prints warnings' {
  local cmd='echo '\''echo rc'\'' > rc

$SH --rcfile rc -i </dev/null 2>interactive.txt
grep -q '\''warning'\'' interactive.txt
echo warned=$? >&2

$SH --rcfile rc </dev/null 2>non-interactive.txt
grep -q '\''warning'\'' non-interactive.txt
echo warned=$? >&2

head *interactive.txt'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 accepts -l flag' {
  local cmd='$SH -l -c '\''exit 0'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 accepts --login flag (dash and mksh don'\''t accept long flags)' {
  local cmd='$SH --login -c '\''exit 0'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 osh --eval' {
  local cmd='echo '\''echo one "$@"'\'' > one.sh
echo '\''echo fail "$@"; ( exit 42 )'\'' > fail.sh

$SH --eval one.sh \
  -c '\''echo status=$? flag -c "$@"'\'' dummy x y z
echo

# Even though errexit is off, the shell exits if the last status of an --eval
# file was non-zero.

$SH --eval one.sh --eval fail.sh \
  -c '\''echo status=$? flag -c "$@"'\'' dummy x y z
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Set LC_ALL LC_CTYPE LC_COLLATE LANG - affects glob ?' {
  local cmd='# note: test/spec-common.sh sets LC_ALL
unset LC_ALL

touch _x_ _μ_

LC_ALL=C       $SH -c '\''echo LC_ALL _?_'\''
LC_ALL=C.UTF-8 $SH -c '\''echo LC_ALL _?_'\''
echo

LC_CTYPE=C       $SH -c '\''echo LC_CTYPE _?_'\''
LC_CTYPE=C.UTF-8 $SH -c '\''echo LC_CTYPE _?_'\''
echo

LC_COLLATE=C       $SH -c '\''echo LC_COLLATE _?_'\''
LC_COLLATE=C.UTF-8 $SH -c '\''echo LC_COLLATE _?_'\''
echo

LANG=C       $SH -c '\''echo LANG _?_'\''
LANG=C.UTF-8 $SH -c '\''echo LANG _?_'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 LC_CTYPE=invalid' {
  local cmd='# note: test/spec-common.sh sets LC_ALL
unset LC_ALL

touch _x_ _μ_

{ LC_CTYPE=invalid $SH -c '\''echo LC_CTYPE _?_'\'' 
} 2> err.txt

#cat err.txt
wc -l err.txt'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 sh -c -- '\''echo hi'\'' does not run anything (#2637)' {
  local cmd='$SH -c -z '\''echo z'\''
if test $? -ne 0; then
  echo '\''z failed'\''
fi
echo

$SH -c --- '\''echo three'\''
if test $? -ne 0; then
  echo three failed
fi
echo

$SH -c -- '\''echo two'\''
echo two=$?
echo

$SH -c - '\''echo one'\''
echo one=$?
echo

$SH -c '\'''\'' '\''echo zero'\''
echo zero=$?
echo

# odd
$SH -c '\''echo aa'\'' '\''echo bb'\''
echo aa=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 sh -c with multiple -- args' {
  local cmd='# variant of above case

$SH -c -- -- '\''echo two'\''
echo status=$?

$SH -c -- -- -- '\''echo two'\''
echo status=$?

$SH -c -z '\''echo z'\''
if test $? -ne 0; then
  echo '\''z failed'\''
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 sh -c with no arg after --' {
  local cmd='# variant of above case

$SH -c --
if test $? -ne 0; then
  echo failed
fi

$SH -c -
if test $? -ne 0; then
  echo failed
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Other flag parsers are not affected by - rule' {
  local cmd='# -c is special, with quit_parsing_flags

echo '\''foo-bar'\'' | { read -d -; echo reply=$REPLY; }'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 weird flag parsing -oo errexit noglob' {
  local cmd='prog='\''
case $- in
  *e*) echo e ;;
esac

case $- in
  *f*) echo f ;;
esac
'\''

# normal way
$SH -o errexit -o noglob -c "$prog"

# odd way
$SH -oo errexit noglob -c "$prog"'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 '\''sh -c -z'\'' does not try to run -z' {
  local cmd='$SH -c -z
case $? in
  1) echo flag-parsing-error ;;
  2) echo flag-parsing-error ;;
  *) echo fail ;;
esac

$SH -c '\''echo 0=$0 1=$1'\'' -z
echo status=$?

$SH -c '\''echo 0=$0 1=$1'\'' foo -z
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 sh -c -x '\''echo hi'\'' - order is reversed' {
  local cmd='$SH -c -x '\''echo hi'\''

# two flags before the command
$SH -c -x -e '\''zz; true'\'' 2> /dev/null
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

