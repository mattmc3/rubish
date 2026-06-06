#!/usr/bin/env bats

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() {
  export BATS_TEST_TIMEOUT=2
}

setup() {
  # Isolate each test in bats's auto-cleaned temp dir so a test that
  # writes a file (even a failing one) never leaves a mess in the repo.
  cd "$BATS_TEST_TMPDIR" || return 1
}

@test 'test_subshell_basic' {
  local cmd='(echo hello)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_subshell_var_isolation' {
  local cmd='x=outer; (x=inner); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_subshell_multiple_commands' {
  local cmd='(echo a; echo b)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_subshell_in_comsub' {
  local cmd='echo $( (echo nested) )'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_subshell_exit_code' {
  local cmd='(exit 5); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_subshell_pipeline' {
  local cmd='echo foo | (cat; echo bar)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

