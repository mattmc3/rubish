#!/usr/bin/env bats
# Generated from oils-for-unix spec/let.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 let' {
  local cmd='# NOTE: no spaces are allowed.  How is this tokenized?
let x=1
let y=x+2
let z=y*3  # zsh treats this as a glob; bash doesn'\''t
let z2='\''y*3'\''  # both are OK with this
echo $x $y $z $z2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 let with ()' {
  local cmd='let x=( 1 )
let y=( x + 2 )
let z=( y * 3 )
echo $x $y $z'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

