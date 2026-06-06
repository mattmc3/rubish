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

@test 'test_echo_n' {
  local cmd='echo -n foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_basic_herestr' {
  local cmd='read x <<<hello; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_two_vars' {
  local cmd='read x y <<<'\''hello world'\''; echo $x $y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_r_backslash' {
  local cmd='read -r x <<<'\''a\\\\b'\''; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_true_exit_code' {
  local cmd='true; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_false_exit_code' {
  local cmd='false; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_colon_noop' {
  local cmd=': ; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_exit_code_in_subshell' {
  local cmd='(exit 42); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_if_true' {
  local cmd='if true; then echo yes; else echo no; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_if_false' {
  local cmd='if false; then echo yes; else echo no; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_if_elif' {
  local cmd='if false; then echo no; elif true; then echo yes; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_if_nested' {
  local cmd='if true; then if false; then echo inner; else echo outer; fi; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_if_bracket_test' {
  local cmd='x=5; if [ $x -gt 3 ]; then echo big; else echo small; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_break_stops_loop' {
  local cmd='for i in a b c; do echo $i; break; echo bad-$i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_break_1_stops_loop' {
  local cmd='for i in a b c; do echo $i; break 1; echo bad-$i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_continue_skips_rest' {
  local cmd='for i in a b c; do echo $i; continue; echo bad-$i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_continue_1_skips_rest' {
  local cmd='for i in a b c; do echo $i; continue 1; echo bad-$i; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_eval_double_expands' {
  local cmd='AVAR='\''$BVAR'\''; BVAR=foo; eval echo $AVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_builtin_no_double_expand' {
  local cmd='AVAR='\''$BVAR'\''; BVAR=foo; builtin echo $AVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_command_no_double_expand' {
  local cmd='AVAR='\''$BVAR'\''; BVAR=foo; command echo $BVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_eval_escaped_var' {
  local cmd='AVAR='\''$BVAR'\''; BVAR=foo; eval echo \\$AVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_eval_temp_env' {
  local cmd='AVAR=bar eval echo \\$AVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_umask_print_octal' {
  local cmd='umask 022; umask'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_umask_symbolic' {
  local cmd='umask 022; umask -S'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_umask_p_reusable' {
  local cmd='umask 002; umask -p'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_umask_p_symbolic' {
  local cmd='umask 002; umask -p -S'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_umask_zero' {
  local cmd='umask 0; umask -S'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_unset_v_removes_var' {
  local cmd='MYVAR=hello; unset -v MYVAR; echo ${MYVAR:-unset}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_unset_removes_var' {
  local cmd='MYVAR=hello; unset MYVAR; echo ${MYVAR:-gone}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_shift_zero' {
  local cmd='set -- a b c; shift 0; echo $#'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_shift_one' {
  local cmd='set -- a b c; shift; echo $@'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_shift_n' {
  local cmd='set -- a b c d; shift 2; echo $@'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_export_sets_env' {
  local cmd='export TESTVAR=hello; echo $TESTVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_readonly_marks_var' {
  local cmd='readonly RO=42; RO=99; echo $RO'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_exit_non_numeric_arg' {
  local cmd='(exit status); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_declare_p_shows_var' {
  local cmd='FOO=bar; declare -p FOO'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_declare_x_exports_var' {
  local cmd='declare -x MYEXPORT=hello; echo $MYEXPORT'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_pwd_prints_cwd' {
  local cmd='pwd'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_alias_define_and_list' {
  local cmd='alias mygreet='\''echo hi'\''; alias mygreet'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_unalias_removes_alias' {
  local cmd='alias foo='\''bar'\''; unalias foo; alias foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

