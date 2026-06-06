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

@test 'test_func_define_and_call' {
  local cmd='f() { echo hello; }; f'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_return_value' {
  local cmd='f() { return 5; }; f; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_local_var' {
  local cmd='zz=outer; f() { local zz=inner; echo $zz; }; f; echo $zz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_local_var_unset_after_return' {
  local cmd='zz=ZZ; f1() { local zz=abcde; echo $zz; unset zz; zz=defghi; echo $zz; }; zz=ZZ; echo $zz; f1; echo $zz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_chained_return_codes' {
  local cmd='a() { return 5; }; b() { a; echo $?; }; b'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_with_args' {
  local cmd='greet() { echo hello $1; }; greet world'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_sees_global_var' {
  local cmd='X=global; f() { echo $X; }; f'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_modifies_global_var' {
  local cmd='X=1; f() { X=2; }; f; echo $X'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_nested_calls' {
  local cmd='inner() { echo inner; }; outer() { echo outer; inner; }; outer'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_subshell_isolation' {
  local cmd='X=orig; f() { X=changed; }; (f); echo $X'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_recursive' {
  local cmd='count() { if [ $1 -gt 0 ]; then echo $1; count $(($1-1)); fi; }; count 3'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_unset' {
  local cmd='f() { echo exists; }; unset -f f; f 2>&1; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_subshell_return_code' {
  local cmd='f1() { return 5; }; (f1); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_temp_env_prefix' {
  local cmd='f1() { echo $AVAR; }; AVAR=AVAR; AVAR=foo f1; echo $AVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_subshell_return_inside_body' {
  local cmd='f1() { (return 5); status=$?; echo $status; return $status; }; f1; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_declare_capital_f' {
  local cmd='f1() { return 5; }; declare -F f1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_declare_lowercase_f' {
  local cmd='f1() { return 5; }; declare -f f1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_funcname_array_tracks_current_function' {
  local cmd='func2() { echo \"FUNCNAME = ${FUNCNAME[0]}\"; }; func() { echo \"before: FUNCNAME = ${FUNCNAME[0]}\"; func2; echo \"after: FUNCNAME = ${FUNCNAME[0]}\"; }; func'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_funcname_empty_outside_function' {
  local cmd='echo \"outside: FUNCNAME = ${FUNCNAME[0]}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_body_redirect' {
  local cmd='myfunction() { echo \"bad shell function redirection\"; } >> /dev/null; myfunction'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_return_in_pipeline' {
  local cmd='segv() { echo foo | return 5; }; segv; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_readonly_f' {
  local cmd='rfunc() { echo hi; }; readonly -f rfunc; readonly -f'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

