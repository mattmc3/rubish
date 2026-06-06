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

@test 'test_posixpat_xdigit_matches_e' {
  local cmd='case e in ([[:xdigit:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_alpha_with_literals_matches_a' {
  local cmd='case a in ([[:alpha:]123]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_alpha_with_literals_matches_1' {
  local cmd='case 1 in ([[:alpha:]123]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_not_alpha_matches_9' {
  local cmd='case 9 in ([![:alpha:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_not_alpha_no_match_a' {
  local cmd='case a in ([![:alpha:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_invalid_class_no_match' {
  local cmd='case a in ([[:al:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_punct_matches_bang' {
  local cmd='case '\''!'\'' in ([abc[:punct:][0-9]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_alpha_star_matches_PATH' {
  local cmd='case '\''PATH'\'' in ([_[:alpha:]]*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_alpha_alnum_star_matches_PATH' {
  local cmd='case PATH in ([_[:alpha:]][_[:alnum:]]*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_not_cntrl_matches_A' {
  local cmd='case A in ([[:cntrl:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_digit_matches_9' {
  local cmd='case 9 in ([[:digit:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_digit_no_match_X' {
  local cmd='case X in ([[:digit:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_lower_upper_pair' {
  local cmd='case aB in ([[:lower:]][[:upper:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_alpha_or_digit' {
  local cmd='case a in ([[:alpha:][:digit:]]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_identifier_prefix' {
  local cmd='case PS3 in ([_[:alpha:]][_[:alnum:]][_[:alnum:]]*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_literal_bracket_matches_a' {
  local cmd='case a in ([:al:]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_cntrl_matches_ctrl_c' {
  local cmd='case $'\''\\003'\'' in ([[:cntrl:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_graph_no_match_esc' {
  local cmd='case $'\''\\033'\'' in ([[:graph:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_graph_no_match_space_oct' {
  local cmd='case $'\''\\040'\'' in ([[:graph:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_graph_no_match_space' {
  local cmd='case '\'' '\'' in ([[:graph:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_print_matches_space_oct' {
  local cmd='case $'\''\\040'\'' in ([[:print:]]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_dangling_backslash_in_bracket' {
  local cmd='case a in ([[:alpha:]\\]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_newline_is_space_not_blank' {
  local cmd='case $'\''\\n'\'' in ([[:blank:]]) echo bad;; ([[:space:]]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_tab_is_blank' {
  local cmd='case $'\''\\t'\'' in ([[:blank:]]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_high_byte_not_ascii' {
  local cmd='case $'\''\\377'\'' in ([[:ascii:]]) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_9_not_in_alpha_1_2_3' {
  local cmd='case 9 in ([1[:alpha:]123]) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_unterminated_bracket_no_match' {
  local cmd='case a in ([[:alpha:]) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_backspace_not_graph' {
  local cmd='case $'\''\\b'\'' in ([[:graph:]]) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_backspace_not_print' {
  local cmd='case $'\''\\b'\'' in ([[:print:]]) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_space_not_punct' {
  local cmd='case $'\'' '\'' in ([[:punct:]]) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_a_matches_a' {
  local cmd='case a in ([[.a.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_hyphen_range' {
  local cmd='case '\''-'\'' in ([[.hyphen.]-9]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_a_to_z_range' {
  local cmd='case p in ([[.a.]-[.z.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_dash' {
  local cmd='case '\''-'\'' in ([[.-.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_space' {
  local cmd='case '\'' '\'' in ([[.space.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_grave_no_match_space' {
  local cmd='case '\'' '\'' in ([[.grave-accent.]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_dash_to_9' {
  local cmd='case '\''4'\'' in ([[.-.]-9]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_range_no_match' {
  local cmd='case c in ([[.yyz.]-[.z.]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_sym_with_valid_range' {
  local cmd='case c in ([[.yyz.][.a.]-z]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_sym_with_az_range' {
  local cmd='case c in ([[.yyz.][.a.]-[.z.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_bad_range_a_Z' {
  local cmd='case p in ([[.a.]-[.Z.]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_end_sym_literal_p' {
  local cmd='case p in ([[.a.]-[.zz.]p]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_start_sym_literal_p' {
  local cmd='case p in ([[.aa.]-[.z.]p]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_sym_with_literal_c' {
  local cmd='case c in ([[.yyz.]cde]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_multichar_sym_with_range' {
  local cmd='case abc in ([[.cb.]a-Za]*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_tab_in_whitespace_set' {
  local cmd='case $'\''\\t'\'' in ([[.space.][.tab.][.newline.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_equiv_class_b_matches_b' {
  local cmd='case abc in ([[:alpha:]][[=b=]][[:ascii:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_equiv_class_B_no_match_b' {
  local cmd='case abc in ([[:alpha:]][[=B=]][[:ascii:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_incomplete_equiv_class_no_match' {
  local cmd='case a in ([[=b=]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

