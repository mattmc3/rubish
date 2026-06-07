#!/usr/bin/env bats
# Generated from oils-for-unix spec/sh-options-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 SHELLOPTS is updated when options are changed' {
  local cmd='echo $SHELLOPTS | grep -q xtrace
echo $?
set -x
echo $SHELLOPTS | grep -q xtrace
echo $?
set +x
echo $SHELLOPTS | grep -q xtrace
echo $?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 SHELLOPTS is readonly' {
  local cmd='SHELLOPTS=x
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 SHELLOPTS and BASHOPTS are non-empty' {
  local cmd='# 2024-06 - tickled by Samuel testing Gentoo

if test -v SHELLOPTS; then
  echo '\''shellopts is set'\''
fi
if test -v BASHOPTS; then
	echo '\''bashopts is set'\''
fi

# bash: braceexpand:hashall etc.

echo shellopts ${SHELLOPTS:?} > /dev/null
echo bashopts ${BASHOPTS:?} > /dev/null'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 SHELLOPTS reflects flags like sh -x' {
  local cmd='$SH -x -c '\''echo $SHELLOPTS'\'' | grep -o xtrace'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 export SHELLOPTS does cross-process tracing' {
  local cmd='$SH -c '\''
export SHELLOPTS
set -x
echo 1
$SH -c "echo 2"
'\'' 2>&1 | sed '\''s/.*sh /sh /g'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 export SHELLOPTS does cross-process tracing with bash' {
  local cmd='# calling bash
$SH -c '\''
export SHELLOPTS
set -x
#echo SHELLOPTS=$SHELLOPTS
echo 1
bash -c "echo 2"
'\'' 2>&1 | sed '\''s/.*sh /sh /g'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 OSH calling bash with SHELLOPTS does not change braceexpand' {
  local cmd='#echo outside=$SHELLOPTS

# sed pattern to normalize spaces
normalize='\''s/[ \t]\+/ /g'\''

bash -c '\''
#echo bash=$SHELLOPTS
set -o | grep braceexpand | sed "$1"
'\'' unused "$normalize"

env SHELLOPTS= bash -c '\''
#echo bash2=$SHELLOPTS
set -o | grep braceexpand | sed "$1"
'\'' unused "$normalize"'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 If shopt --set xtrace is allowed, it should update SHELLOPTS, not BASHOPTS' {
  local cmd='shopt --set xtrace
echo SHELLOPTS=$SHELLOPTS
set -x
echo SHELLOPTS=$SHELLOPTS
set +x
echo SHELLOPTS=$SHELLOPTS'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 shopt -s progcomp hostcomplete are stubs (bash-completion)' {
  local cmd='shopt -s progcomp hostcomplete
echo status=$?

shopt -u progcomp hostcomplete
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

