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

@test 'test_quote_single_literal_backslash_n' {
  local cmd='echo '\''foo\\nbar'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_single_literal_backslash' {
  local cmd='echo '\''foo\\bar'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_interpolates_var' {
  local cmd='x=hello; echo \"$x world\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_preserves_spaces' {
  local cmd='echo \"  spaces  \"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_cmd_sub_strips_trailing_newline' {
  local cmd='v=$(echo hello); echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_backtick_strips_trailing_newline' {
  local cmd='v=`echo hello`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_unquoted_cmd_sub_splits' {
  local cmd='for w in $(echo '\''a b c'\''); do echo $w; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_cmd_sub_preserves_spaces' {
  local cmd='echo \"$(echo '\''a b c'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_string_ending_backslash' {
  local cmd='echo '\''string \\'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_cmd_sub_multiple_trailing_newlines_stripped' {
  local cmd='v=$(printf '\''hi\\n\\n\\n'\''); echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_single_embedded_newline' {
  local cmd='echo '\''foo\nbar'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_single_backslash_newline_literal' {
  local cmd='echo '\''foo\\\nbar'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_embedded_newline' {
  local cmd='echo \"foo\nbar\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_backslash_newline_continuation' {
  local cmd='echo \"foo\\\nbar\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_backtick_newline_word_splits' {
  local cmd='echo `echo '\''foo\nbar'\''`'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_dollar_paren_newline_word_splits' {
  local cmd='echo $(echo '\''foo\nbar'\'')'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_dollar_paren_double_backslash_newline_continuation' {
  local cmd='echo $(echo \"foo\\\nbar\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_backtick_preserves_newline' {
  local cmd='echo \"`echo '\''foo\nbar'\''`\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_dollar_paren_preserves_newline' {
  local cmd='echo \"$(echo '\''foo\nbar'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_dollar_paren_single_backslash_newline_literal' {
  local cmd='echo $(echo '\''foo\\\nbar'\'')'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_dollar_paren_single_backslash_newline' {
  local cmd='echo \"$(echo '\''foo\\\nbar'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_unquoted_backslash_escape' {
  local cmd='echo string\\ \\\\'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_param_default_single_quoted_backslash' {
  local cmd='unset foo; echo ${foo:-'\''string \\'\''}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_param_default_unquoted_backslash_brace' {
  local cmd='unset foo; echo ${foo:-string \\\\\\}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

