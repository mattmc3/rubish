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

@test 'test_appendop_string' {
  local cmd='a=1; a+=4; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_in_env' {
  local cmd='a=1; a+=4; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_array' {
  local cmd='x=(1 2 3); x+=(4 5 6); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_export' {
  local cmd='a=1; export a+=4; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_array_element_string' {
  local cmd='x=(1 2 3); x+=(4 5 6); x[4]+=1; echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_command_env_prefix' {
  local cmd='a=1; a+=4; a+=5 printenv a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_command_env_prefix_unchanged' {
  local cmd='a=1; a+=4; a+=5 printenv a > /dev/null; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_empty' {
  local cmd='a=; typeset -i a; a+=7; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_arith' {
  local cmd='b=4+1; typeset -i b; b+=37; echo $b'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_array_element' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x[4]+=7; echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_array_arith_init' {
  local cmd='unset x; typeset -i x; x=([0]=7+11); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_array_index_arith' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_array_literal_pluseq' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); x=( 1 2 [2]+=7 4 5 ); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_array_sparse_append' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); x=( 1 2 [2]+=7 4 5 ); x+=( [3]+=9 [5]=9 ); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_typeset_integer_init' {
  local cmd='unset x; typeset -i x=4+5; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_typeset_unset_pluseq' {
  local cmd='unset x; typeset x+=4; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_typeset_integer_pluseq' {
  local cmd='unset x; typeset x+=4; typeset -i x+=5; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_readonly_pluseq' {
  local cmd='unset x; typeset x+=4; typeset -i x+=5; readonly x+=7; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_readonly_error' {
  local cmd='unset x; typeset x+=4; typeset -i x+=5; readonly x+=7; x+=5; true'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

