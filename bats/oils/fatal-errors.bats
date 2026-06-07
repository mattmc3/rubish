#!/usr/bin/env bats
# Generated from oils-for-unix spec/fatal-errors.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Unrecoverable: divide by zero in redirect word' {
  local cmd='$SH -c '\''
echo hi > file$(( 42 / 0 )) in
echo inside=$?
'\''
echo outside=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Unrecoverable: divide by zero in conditional word' {
  local cmd='$SH -c '\''
if test foo$(( 42 / 0 )) = foo; then
  echo true
else
  echo false
fi
echo inside=$?
'\''
echo outside=$?

echo ---

$SH -c '\''
if test foo$(( 42 / 0 )) = foo; then
  echo true
fi
echo inside=$?
'\''
echo outside=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Unrecoverable: divide by zero in case' {
  local cmd='$SH -c '\''
case $(( 42 / 0 )) in
  (*) echo hi ;;
esac
echo inside=$?
'\''
echo outside=$?

echo ---

$SH -c '\''
case foo in
  ( $(( 42 / 0 )) )
    echo hi
    ;;
esac
echo inside=$?
'\''
echo outside=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Unrecoverable: {undef?message}' {
  local cmd='$SH -c '\''
echo ${undef?message}
echo inside=$?
'\''
echo outside=$?

$SH -c '\''
case ${undef?message} in 
  (*) echo hi ;;
esac
echo inside=$?
'\''
echo outside=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 {undef} with nounset' {
  local cmd='$SH -c '\''
set -o nounset
case ${undef} in 
  (*) echo hi ;;
esac
echo inside=$?
'\''
echo outside=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

