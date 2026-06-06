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

@test 'test_printf_tab' {
  local cmd='printf '\''\\tone\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_literal_percent' {
  local cmd='printf '\''%%\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_c_format' {
  local cmd='printf '\''%c\\n'\'' ABCD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_format' {
  local cmd='printf '\''%s\\n'\'' unquoted'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_format' {
  local cmd='printf '\''%d\\n'\'' 42'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_zero_pad' {
  local cmd='printf '\''%05d\\n'\'' 42'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_x_format' {
  local cmd='printf '\''%x\\n'\'' 255'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_o_format' {
  local cmd='printf '\''%o\\n'\'' 8'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_e_format' {
  local cmd='printf '\''%e\\n'\'' 3.14'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_format' {
  local cmd='printf '\''%f\\n'\'' 3.14'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_right_justify' {
  local cmd='printf '\''%10s\\n'\'' hi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_left_justify' {
  local cmd='printf '\''%-10s|\\n'\'' hi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_multiple_args' {
  local cmd='printf '\''%s %s %s\\n'\'' a b c'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_repeats_format' {
  local cmd='printf '\''%s\\n'\'' a b c'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_v_assigns_var' {
  local cmd='printf -v myvar '\''%s'\'' hello; echo $myvar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_escape' {
  local cmd='printf '\''%b\n'\'' '\''a\\tb'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_four_zero_pad' {
  local cmd='printf '\''%04d\n'\'' 7'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_precision' {
  local cmd='printf '\''%.3f\n'\'' 3.14159'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_sign' {
  local cmd='printf '\''%+d %+d\n'\'' 5 -5'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_no_newline' {
  local cmd='printf '\''%s'\'' hello'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_c_escape_stops_output' {
  local cmd='printf '\''one\\ctwo\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_unrecognized_backslash_preserved' {
  local cmd='printf '\''4\\.2\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_no_newline_concat' {
  local cmd='printf '\''no newline '\''; printf '\''now newline\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_octal_045' {
  local cmd='printf '\''\\045'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_octal_045d' {
  local cmd='printf '\''\\045d\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_format' {
  local cmd='printf '\''%s %q\\n'\'' unquoted quoted'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_special_chars' {
  local cmd='printf '\''%q\\n'\'' '\''this&that'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_format_reused' {
  local cmd='printf '\''%d '\'' 1 2 3 4 5'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_args_zero' {
  local cmd='printf '\''%s %d %d %d\\n'\'' onestring'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_args_float' {
  local cmd='printf '\''%s %d %u %4.2f\\n'\'' onestring'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_double_dash' {
  local cmd='printf -- '\''--%s %s--\\n'\'' 4.2 '\'''\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_double_dash_missing_arg' {
  local cmd='printf -- '\''--%s %s--\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_octal_101' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''\\t\\0101'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_octal_101_short' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''\\t\\101'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_hex_two_digits' {
  local cmd='printf '\''%b\\n'\'' '\''\\x417'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_double_quote_escape' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''\\\"abcd\\\"'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_single_quote_escape' {
  local cmd='printf -- '\''--%b--\\n'\'' \"\\'\''abcd\\'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_backslash_x' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''a\\\\x'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_empty_arg' {
  local cmd='printf -- '\''--%b--\\n'\'' '\'''\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_c_stops_output' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''4.2\\c5.4\\n'\''; printf '\''\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_unrecognized_escape_preserved' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''4\\.2'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_bare_backslash' {
  local cmd='printf -- '\''--%b--\\n'\'' '\''\\'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_extra_args_ignored' {
  local cmd='printf '\''\\n'\'' 4.4 BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_width_precision' {
  local cmd='printf '\''%10.8s\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_dynamic_width_precision' {
  local cmd='printf '\''%*.*s\\n'\'' 10 8 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_width' {
  local cmd='printf '\''%6b\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_dynamic_width' {
  local cmd='printf '\''%*b\\n'\'' 6 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_right_justify' {
  local cmd='printf '\''%10b\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_left_justify' {
  local cmd='printf -- '\''--%-10b--\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_width_and_precision' {
  local cmd='printf '\''%4.2b\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_precision_only' {
  local cmd='printf '\''%.3b\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_left_justify_width' {
  local cmd='printf -- '\''--%-8b--\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_numeric_conversions' {
  local cmd='printf '\''%d %u %i 0%o 0x%x 0x%X\\n'\'' 255 255 255 255 255 255'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_numeric_alternate_form' {
  local cmd='printf '\''%d %u %i %#o %#x %#X\\n'\'' 255 255 255 255 255 255'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_width_negative' {
  local cmd='printf '\''%10d\\n'\'' -42'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_dynamic_width' {
  local cmd='printf '\''%*d\\n'\'' 10 42'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_dynamic_width_negative' {
  local cmd='printf '\''%*d\\n'\'' 10 -42'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_width_precision' {
  local cmd='printf '\''%4.2f\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_alternate_form' {
  local cmd='printf '\''%#4.2f\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_alternate_one_decimal' {
  local cmd='printf '\''%#4.1f\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_dynamic_width_precision' {
  local cmd='printf '\''%*.*f\\n'\'' 4 2 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_E_format' {
  local cmd='printf '\''%E\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_E_width_precision' {
  local cmd='printf '\''%6.1E\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_e_width_precision' {
  local cmd='printf '\''%6.1e\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_G_format' {
  local cmd='printf '\''%G\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_g_format' {
  local cmd='printf '\''%g\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_G_width_precision' {
  local cmd='printf '\''%6.2G\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_g_width_precision' {
  local cmd='printf '\''%6.2g\\n'\'' 4.2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_char_value' {
  local cmd='printf '\''%d\\n'\'' \"'\''string'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_o_char_value' {
  local cmd='printf '\''%#o\\n'\'' \"'\''string'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_x_char_value' {
  local cmd='printf '\''%#x\\n'\'' \"'\''string'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_X_char_value' {
  local cmd='printf '\''%#X\\n'\'' '\''\"string\"'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_char_value' {
  local cmd='printf '\''%6.2f\\n'\'' \"'\''string'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_width_precision_long' {
  local cmd='printf -- '\''--%6.4s--\\n'\'' abcdefghijklmnopqrstuvwxyz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_width_precision_long' {
  local cmd='printf -- '\''--%6.4b--\\n'\'' abcdefghijklmnopqrstuvwxyz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_width_precision_long2' {
  local cmd='printf -- '\''--%12.10s--\\n'\'' abcdefghijklmnopqrstuvwxyz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_width_precision_long2' {
  local cmd='printf -- '\''--%12.10b--\\n'\'' abcdefghijklmnopqrstuvwxyz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_format_single_quote_escape' {
  local cmd='printf \"\\'\''abcd\\'\''\\n\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_no_single_quote_translation' {
  local cmd='printf '\''%b\\n'\'' \\\\\\'\''abcd\\\\\\'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_format_backslash_escape' {
  local cmd='printf '\''\\\\abcd\\\\\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_backslash_escape' {
  local cmd='printf '\''%b\\n'\'' '\''\\\\abcd\\\\'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_hex_input' {
  local cmd='printf '\''%d\\n'\'' 0x1a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_octal_input' {
  local cmd='printf '\''%d\\n'\'' 032'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_zero_precision' {
  local cmd='printf '\''%.0s'\'' foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_dynamic_zero_precision' {
  local cmd='printf '\''%.*s'\'' 0 foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_s_zero_precision' {
  local cmd='printf '\''%.0b-%.0s\\n'\'' foo bar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_s_negative_width' {
  local cmd='printf '\''(%*b)(%*s)\\n'\'' -4 foo -4 bar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_octal_7' {
  local cmd='printf '\''%b\\n'\'' '\''\\7'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_octal_0007' {
  local cmd='printf '\''%b\\n'\'' '\''\\0007'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_format_nul_then_7' {
  local cmd='printf '\''\\0007\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_format_hex_stops_at_two_digits' {
  local cmd='printf '\''\\x07e\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_format_quote_question_escape' {
  local cmd='printf '\''\\\"\\?\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_zero_dot_precision' {
  local cmd='printf '\''%0.5d\\n'\'' 1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_width_no_pad' {
  local cmd='printf '\''%5d\\n'\'' 1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_d_zero_flag_no_width' {
  local cmd='printf '\''%0d\\n'\'' 1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_G_zero' {
  local cmd='printf '\''%G\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_g_zero' {
  local cmd='printf '\''%g\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_G_zero_width_precision' {
  local cmd='printf '\''%4.2G\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_g_zero_width_precision' {
  local cmd='printf '\''%4.2g\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_G_four' {
  local cmd='printf '\''%G\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_g_four' {
  local cmd='printf '\''%g\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_G_four_width_precision' {
  local cmd='printf '\''%4.2G\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_g_four_width_precision' {
  local cmd='printf '\''%4.2g\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_F_zero' {
  local cmd='printf '\''%F\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_zero' {
  local cmd='printf '\''%f\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_F_zero_precision' {
  local cmd='printf '\''%4.2F\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_zero_precision' {
  local cmd='printf '\''%4.2f\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_F_four' {
  local cmd='printf '\''%F\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_four' {
  local cmd='printf '\''%f\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_F_four_precision' {
  local cmd='printf '\''%4.2F\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_f_four_precision' {
  local cmd='printf '\''%4.2f\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_E_zero' {
  local cmd='printf '\''%E\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_e_zero' {
  local cmd='printf '\''%e\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_E_zero_precision' {
  local cmd='printf '\''%4.2E\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_e_zero_precision' {
  local cmd='printf '\''%4.2e\\n'\'' 0'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_E_four' {
  local cmd='printf '\''%E\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_e_four' {
  local cmd='printf '\''%e\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_E_four_precision' {
  local cmd='printf '\''%4.2E\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_e_four_precision' {
  local cmd='printf '\''%4.2e\\n'\'' 4'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_X_zero_pad_hex' {
  local cmd='printf '\''%08X\\n'\'' 2604292517'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_empty_string' {
  local cmd='printf '\''%q\\n'\'' '\'''\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_s_empty_string' {
  local cmd='printf '\''%s\\n'\'' '\'''\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_empty_string_newline' {
  local cmd='printf '\''%b\\n'\'' '\'''\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_args_string_b' {
  local cmd='printf '\''<%3s><%3b>\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_int_arg' {
  local cmd='printf '\''%d\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_char_arg' {
  local cmd='printf '\''%c\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_x_arg' {
  local cmd='printf '\''%x\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_f_arg' {
  local cmd='printf '\''%4.2f\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_q_arg' {
  local cmd='printf '\''%q\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_with_width' {
  local cmd='printf '\''%s%10q\\n'\'' unquoted quoted'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_width_precision' {
  local cmd='printf '\''%10.8q\\n'\'' 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_dynamic_width_precision' {
  local cmd='printf '\''%*.*q\\n'\'' 10 8 4.4BSD'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

