#!/usr/bin/env bats

RUBISH="bundle exec exe/rubish"

setup_file() {
  export BATS_TEST_TIMEOUT=2
}

setup() {
  # Isolate each test in bats's auto-cleaned temp dir so a test that
  # writes a file (even a failing one) never leaves a mess in the repo.
  cd "$BATS_TEST_TMPDIR" || return 1
}

@test 'test_while_countdown' {
  local cmd='x=3; while [ $x -gt 0 ]; do echo $x; x=$(( x - 1 )); done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_while_false_no_output' {
  local cmd='while false; do echo nope; done; echo done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_until_count_to_3' {
  local cmd='x=0; until [ $x -eq 3 ]; do echo $x; x=$(( x + 1 )); done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_while_break' {
  local cmd='i=0; while true; do if [ $i -eq 3 ]; then break; fi; echo $i; i=$(( i + 1 )); done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_while_continue' {
  local cmd='i=0; while [ $i -lt 5 ]; do i=$(( i + 1 )); if [ $i -eq 3 ]; then continue; fi; echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_while_nested' {
  local cmd='i=1; while [ $i -le 2 ]; do j=1; while [ $j -le 2 ]; do echo $i$j; j=$(( j + 1 )); done; i=$(( i + 1 )); done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_until_false_runs_once' {
  local cmd='until false; do echo once; break; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

