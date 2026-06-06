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

@test 'test_varenv_swap_not_atomic' {
  local cmd='c=1; d=2; d=$c; c=$d; echo $c $d'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_unset_default' {
  local cmd='unset d; echo ${d-unset}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_length' {
  local cmd='a=bcde; echo ${#a}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_export_visible' {
  local cmd='export HOME=/usr/chet; echo $HOME'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_local_env_assign' {
  local cmd='HOME=/a/b/c printenv HOME'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_basic_assign' {
  local cmd='c=1; d=2; echo $c $d'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_readonly' {
  local cmd='readonly RO_VAR=5; echo $RO_VAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_export_child' {
  local cmd='export MYVAR=hello; echo $(printenv MYVAR)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_unset' {
  local cmd='x=foo; unset x; echo ${x:-gone}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_subshell_not_affect_parent' {
  local cmd='x=parent; (x=child); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_string_append' {
  local cmd='a=5; a+=3; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_multiple_assign' {
  local cmd='a=1; b=2; c=3; echo $a $b $c'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_command_local' {
  local cmd='X=old; X=new printenv X'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_same_line_assign_propagates' {
  local cmd='HOME=/a/b/c a=$HOME; echo $HOME $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_temp_env_no_affect_expansion' {
  local cmd='export HOME=/usr/chet; HOME=/a/b/c /bin/echo $HOME'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_function_local_var' {
  local cmd='func() { local YYZ; YYZ='\''song by rush'\''; echo $YYZ; }; YYZ='\''toronto airport'\''; echo $YYZ; func; echo $YYZ'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_temp_env_for_function' {
  local cmd='func() { echo $A; }; A=AVAR; A=BVAR func; echo $A'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_no_expansion_from_builtin_prefix_assign' {
  local cmd='export A=AVAR; A=ZVAR echo $A'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_local_array_in_function' {
  local cmd='func2() { local -a avar=(a b c); echo ${avar[@]}; }; avar=42; echo $avar; func2; echo $avar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_declare_integer' {
  local cmd='declare -i ivar; ivar=10; declare -p ivar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_export_unset_then_assign' {
  local cmd='export ivar; echo ${ivar-unset}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_export_attr_persists' {
  local cmd='export ivar; ivar=42; declare -p ivar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_set_a_typeset_export' {
  local cmd='unset FOOFOO; FOOFOO=bar; set -a; typeset FOOFOO=abcde; printenv FOOFOO'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_typeset_function_scope' {
  local cmd='tt() { typeset a=b; echo a=$a; }; a=z; echo a=$a; tt; echo a=$a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

