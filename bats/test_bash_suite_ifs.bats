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

@test 'test_ifs_colon_split_var_in_for' {
  local cmd='x=a:b:c; for i in $x; do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_colon_cmd_sub_split_in_for' {
  local cmd='for i in $(echo a:b:c); do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_default_splits_spaces_in_for' {
  local cmd='x='\''one two three'\''; for i in $x; do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_empty_suppresses_split' {
  local cmd='x='\''one two'\''; for i in $x; do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_quoted_var_no_split' {
  local cmd='x='\''one two three'\''; echo \"$x\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_eval_assign_no_split_after_restore' {
  local cmd='OIFS=\"$IFS\"; IFS=\":$IFS\"; eval foo=\"a:b:c\"; IFS=\"$OIFS\"; echo $foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_comsub_captured_with_colon_ifs_then_default_for' {
  local cmd='OIFS=$IFS; IFS=\":$IFS\"; foo=$(echo a:b:c); IFS=$OIFS; for i in $foo; do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_backtick_comsub_captured_with_colon_ifs_then_default_for' {
  local cmd='OIFS=$IFS; IFS=\":$IFS\"; foo=`echo a:b:c`; IFS=$OIFS; for i in $foo; do echo $i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_typeset_local_in_function_splits_echo' {
  local cmd='function f { typeset IFS=:; echo $1; }; f a:b:c:d:e'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_env_prefix_for_function_splits_inside' {
  local cmd='function ff { echo $1; }; x=a:b:c:d:e; IFS=: ff a:b:c:d:e'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_env_prefix_function_does_not_change_global_ifs' {
  local cmd='function ff { echo $1; }; x=a:b:c:d:e; IFS=: ff a:b:c:d:e > /dev/null; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_env_prefix_simple_cmd_no_split' {
  local cmd='x=a:b:c:d:e; IFS=: echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_env_prefix_eval_splits' {
  local cmd='x=a:b:c:d:e; IFS=: eval echo \\$x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_posix_assignment_before_export_is_global' {
  local cmd='x=a:b:c:d:e; set -o posix; IFS=: export x; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

