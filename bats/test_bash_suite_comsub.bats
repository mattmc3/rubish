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

@test 'test_comsub_basic' {
  local cmd='x=$(echo hello); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_multiline' {
  local cmd='x=$(echo a; echo b); echo \"$x\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_nested' {
  local cmd='echo $(echo $(echo hi))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_in_arith' {
  local cmd='echo $(($(echo 3) + 4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_pipeline' {
  local cmd='echo $(echo '\''a b c'\'' | tr '\'' '\'' '\''\n'\'' | wc -l | tr -d '\'' '\'')'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_strips_trailing_newline' {
  local cmd='x=$(printf '\''hi\n'\''); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_empty' {
  local cmd='echo --$()--'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_assigns' {
  local cmd='a=$(echo foo); echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_quoted_spaces_preserved' {
  local cmd='echo \"$(echo '\''a b c'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_backtick' {
  local cmd='x=`echo hello`; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_inline_concat' {
  local cmd='echo ab$(echo mn; echo op)yz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_pipeline_grep_assign' {
  local cmd='a=$(echo '\''a b c'\'' | tr '\'' '\'' '\''\\n'\'' | grep '\''b'\''); echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_empty_multiline' {
  local cmd='printf '\''blank --%s--\\n'\'' \"$(true)\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_deeply_nested' {
  local cmd='echo $(echo $(echo $(echo $( echo nested ))))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_strips_multiple_trailing_newlines' {
  local cmd='x=$(printf '\''hello\\n\\n\\n'\''); echo \"[$x]\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_strips_trailing_preserves_internal' {
  local cmd='x=$(printf '\''a\\nb\\nc\\n\\n\\n'\''); echo \"$x\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_word_split_unquoted' {
  local cmd='x=$(echo '\''a b c'\''); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_no_word_split_quoted' {
  local cmd='x=$(echo '\''a  b  c'\''); echo \"$x\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_backtick_chained' {
  local cmd='x=`echo hello`; y=`echo $x world`; echo $y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_in_param_default' {
  local cmd='echo ${foo:-$(echo fallback)}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_return_aborts_comsub' {
  local cmd='func() { local v; v=$(echo comsub; return; echo after); echo \"$FUNCNAME: v = $v\"; }; func'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_prefix_suffix_inline' {
  local cmd='echo prefix-$(echo hello)-suffix'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_backtick_escaped_dollar' {
  local cmd='echo `echo '\''\\$'\'' bab`'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_backtick_escaped_backslash' {
  local cmd='echo `echo '\''\\\\'\'' ab`'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_exit_status' {
  local cmd='$(exit 42); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

