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

@test 'test_bracket_d_dir' {
  local cmd='[ -d /etc ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_d_not_dir' {
  local cmd='[ -d /dev/null ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_f_regular_file' {
  local cmd='[ -f /etc/passwd ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_f_directory' {
  local cmd='[ -f /etc ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_e_exists' {
  local cmd='[ -e /dev/null ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_e_nonexist' {
  local cmd='[ -e /nonexist_xyz_rubish ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_r_readable' {
  local cmd='[ -r /dev/null ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_w_writable' {
  local cmd='[ -w /dev/null ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_x_executable' {
  local cmd='[ -x /bin/sh ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_z_empty_string' {
  local cmd='[ -z '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_z_nonempty_string' {
  local cmd='[ -z '\''foo'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_n_nonempty_string' {
  local cmd='[ -n '\''hello'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_n_empty_string' {
  local cmd='[ -n '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_eq_true' {
  local cmd='[ '\''hello'\'' = '\''hello'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_eq_false' {
  local cmd='[ '\''hello'\'' = '\''goodbye'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_ne_true' {
  local cmd='[ '\''hello'\'' != '\''goodbye'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_ne_false' {
  local cmd='[ '\''hello'\'' != '\''hello'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_string_nonempty' {
  local cmd='[ '\''foo'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_string_empty' {
  local cmd='[ '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_true' {
  local cmd='[ 200 -eq 200 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_false' {
  local cmd='[ 34 -eq 222 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_ne_true' {
  local cmd='[ 34 -ne 222 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_ne_false' {
  local cmd='[ 200 -ne 200 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_gt_true' {
  local cmd='[ 340 -gt 222 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_gt_false' {
  local cmd='[ 200 -gt 200 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_lt_true' {
  local cmd='[ 34 -lt 222 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_lt_false' {
  local cmd='[ 200 -lt 200 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_ge_equal' {
  local cmd='[ 200 -ge 200 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_ge_false' {
  local cmd='[ 34 -ge 222 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_le_equal' {
  local cmd='[ 200 -le 200 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_le_false' {
  local cmd='[ 340 -le 222 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_not' {
  local cmd='[ ! -z '\''foo'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_and_true' {
  local cmd='[ -n '\''a'\'' -a -z '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_and_false' {
  local cmd='[ -n '\''a'\'' -a -n '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_or_true' {
  local cmd='[ -n '\''a'\'' -o -n '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_or_both_false' {
  local cmd='[ -n '\'''\'' -o -n '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_double_not' {
  local cmd='[ ! ! '\''foo'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_compound_and' {
  local cmd='[ 700 -le 1000 -a -n '\''1'\'' -a '\''20'\'' = '\''20'\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_unequal' {
  local cmd='[ 12 -eq 34 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_not_eq_unequal' {
  local cmd='[ ! 12 -eq 34 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_parens' {
  local cmd='[ \\( -n '\''x'\'' \\) ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_no_args' {
  local cmd='test; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_no_args' {
  local cmd='[ ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_c_char_device' {
  local cmd='[ -c /dev/tty ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_c_not_char_device' {
  local cmd='[ -c /etc ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_d_empty_string' {
  local cmd='[ -d '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_double_eq_true' {
  local cmd='[ hello == hello ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_double_eq_false' {
  local cmd='[ hello == goodbye ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_gt_true' {
  local cmd='[ hello \\> goodbye ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_str_lt_false' {
  local cmd='[ hello \\< goodbye ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_t_non_terminal_fd' {
  local cmd='[ -t 20 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_negative_vs_positive' {
  local cmd='[ -32 -eq 32 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_negative_equal' {
  local cmd='[ -32 -eq -32 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_non_numeric' {
  local cmd='[ 4+3 -eq 7 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_or_with_bare_string' {
  local cmd='[ -n abcd -o aaa ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_or_first_true' {
  local cmd='[ -n abcd -o -z aaa ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_and_with_bare_string' {
  local cmd='[ -n abcd -a aaa ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_and_second_false' {
  local cmd='[ -n abcd -a -z aaa ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_bare_and_both_nonempty' {
  local cmd='[ xx -a yy ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_bare_or_first_nonempty' {
  local cmd='[ xx -o '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_bare_and_second_empty' {
  local cmd='[ xx -a '\'''\'' ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_not_parens_compound' {
  local cmd='[ ! \\( 700 -le 1000 -a -n 1 -a 20 = 20 \\) ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_r_fd0' {
  local cmd='[ -r /dev/fd/0 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_w_fd1' {
  local cmd='[ -w /dev/fd/1 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

