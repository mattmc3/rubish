#!/usr/bin/env bats
# Generated from oils-for-unix spec/nocasematch-match.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 [[ equality matching' {
  local cmd='shopt -s nocasematch
[[ a == A ]]; echo $?
[[ A == a ]]; echo $?
[[ A == [a] ]]; echo $?
[[ a == [A] ]]; echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 [[ regex matching' {
  local cmd='shopt -s nocasematch
[[ a =~ A ]]; echo $?
[[ A =~ a ]]; echo $?
[[ a =~ [A] ]]; echo $?
[[ A =~ [a] ]]; echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 [ matching' {
  local cmd='shopt -s nocasematch
[ a = A ]; echo $?
[ A = a ]; echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 case matching' {
  local cmd='shopt -s nocasematch
case a in A) echo 0 ;; *) echo 1 ;; esac
case A in a) echo 0 ;; *) echo 1 ;; esac
case a in [A]) echo 0 ;; *) echo 1 ;; esac
case A in [a]) echo 0 ;; *) echo 1 ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 file matching' {
  local cmd='shopt -s nocasematch
touch a B
echo [A] [b]'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 parameter expansion matching' {
  local cmd='shopt -s nocasematch
foo=a
bar=A
echo "${foo#A}" "${foo#[A]}"
echo "${bar#a}" "${bar#[a]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

