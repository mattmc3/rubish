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

@test 'test_arith_for_basic' {
  local cmd='for ((i=0; i<3; i++)); do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_count_3' {
  local cmd='for ((i=1; i<=3; i++)); do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_increment_in_body' {
  local cmd='for ((i=0; i<3; )); do echo $i; (( i++ )); done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_break' {
  local cmd='for ((i=0; ; i++)); do if (( i >= 3 )); then break; fi; echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_continue' {
  local cmd='for ((i=0; i<5; i++)); do if (( i == 2 )); then continue; fi; echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_descend' {
  local cmd='for ((i=3; i>0; i--)); do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_final_value' {
  local cmd='for ((i=0; i<20; i++)); do :; done; echo $i'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_nested' {
  local cmd='for ((i=0; i<2; i++)); do for ((j=0; j<2; j++)); do echo $i$j; done; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_sum' {
  local cmd='s=0; for ((i=1; i<=5; i++)); do (( s += i )); done; echo $s'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_infinite_break' {
  local cmd='i=0; for ((;;)); do if (( i > 2 )); then break; fi; echo $i; (( i++ )); done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_missing_init' {
  local cmd='i=0; for (( ; i < 3; i++ )); do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_quoted_string_condition' {
  local cmd='for (( i=0; \"i < 3\"; i++ )); do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_continue_double_increment' {
  local cmd='for ((i = 0; ;i++ )); do echo $i; if (( i < 3 )); then (( i++ )); continue; fi; break; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_oneliner_do' {
  local cmd='for ((i=0; i < 20; i++)) do :; done; echo $i'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_brace_body' {
  local cmd='for ((i=0; i < 20; i++)) { :; }; echo $i'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_descend_semicolon_before_do' {
  local cmd='for (( i = 4; ;i--)) ; do echo $i; if (( $i == 0 )); then break; fi; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_no_init_no_cond_decrement' {
  local cmd='i=4; for (( ;;i--)) ; do echo -n $i; if (( i == 0 )); then break; fi; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_error_in_step' {
  local cmd='for (( i=1; i < 4; 7++ )); do echo ok$i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_bad_init_continues' {
  local cmd='for ((j=;;)); do :; done; echo X'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_break_outside_loop_continues' {
  local cmd='break; echo after'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

