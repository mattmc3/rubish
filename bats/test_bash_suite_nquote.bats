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

@test 'test_nquote_basic_string' {
  local cmd='echo $'\''abc'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_newlines' {
  local cmd='echo $'\''\\n\\n\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_newline_in_var' {
  local cmd='f=$'\''\\n'\''; echo \"++$f++\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_empty_string' {
  local cmd='z1=$'\'''\''; echo \"$z1\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_combined' {
  local cmd='ZIFS=$'\''\\n'\''$'\''\\t'\''$'\'' '\''; echo \"$ZIFS\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_in_case' {
  local cmd='z=$'\''\\v\\f\\a\\b'\''; case \"$z\" in $'\''\\v\\f\\a\\b'\'') echo ok;; *) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_escaped_single_quotes' {
  local cmd='echo $'\''\\'\''abcd\\'\'''\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_octal_escape' {
  local cmd='echo \"$(echo $'\''\\t\\t\\101\\104\\n\\105'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_cr_esc_bel' {
  local cmd='echo $'\''\\r\\e\\aabc'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_dollar_literal' {
  local cmd='echo $'\''ab$cde'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_dollar_dquote_literal' {
  local cmd='echo $'\''hello, $\"world\"'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_escaped_dollar_literal' {
  local cmd='echo $'\''hello, \\$\"world\"'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_escaped_dquote_in_ansi' {
  local cmd='echo $'\''hello, $\\\"world\"'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_semicolon_literal' {
  local cmd='echo \"$(echo $'\'';foo'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_no_expand_in_dquotes' {
  local cmd='echo \"$'\''a\\tb\\tc'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_in_command_substitution' {
  local cmd='echo $(set -- $'\''a b'\''; echo $#)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_tab_no_word_split' {
  local cmd='args() { for a in \"$@\"; do echo \"'\''$a'\''\"; done; }; args $'\''A\\tB'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_in_default_value' {
  local cmd='unset mytab; echo \"${mytab:-$'\''\\t'\''}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

