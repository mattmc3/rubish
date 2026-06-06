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

@test 'test_heredoc_basic' {
  local cmd=$'cat <<EOF\na\nb\nc\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_quoted_no_expansion' {
  local cmd=$'a=foo; cat <<\'EOF\'\nthere$a\nstuff\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_unquoted_expansion' {
  local cmd=$'a=foo; cat <<EOF\nthere$a\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_tab_strip' {
  local cmd=$'cat <<- EOF\n\ttab1\n\ttab2\n\tEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_empty' {
  local cmd=$'cat <<EOF\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_var_in_body' {
  local cmd=$'x=hello; cat <<EOF\n$x world\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_basic_read' {
  local cmd='read x <<<alpha; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_cat' {
  local cmd='cat <<<hello'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_var' {
  local cmd='X=world; cat <<<\"hello $X\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_read_spaces' {
  local cmd='read x <<<'\''alpha beta'\''; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_read_first_line_only' {
  local cmd=$'read x <<EOF\na\nb\nc\nEOF\necho $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_quoted_delimiter_no_var_expansion' {
  local cmd=$'cat <<\'EOF\'\n$PS4\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_empty_read' {
  local cmd=$'read x <<EOF\nEOF\necho \"[$x]\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_empty_var_expansion' {
  local cmd=$'unset empty; read x <<EOF\n$empty\nEOF\necho \"[$x]\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_multiple_second_wins' {
  local cmd=$'cat << EOF1 << EOF2\nhi\nEOF1\nthere\nEOF2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_quoted_backslash_literal' {
  local cmd=$'cat <<\'EOF\'\nhi\\\nthere$a\nstuff\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_unquoted_backslash_newline_join' {
  local cmd=$'cat <<EOF\nline 1\\\nline 2\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_backslash_newline_in_delimiter' {
  local cmd=$'cat << EO\\\nF\nhi\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_backslash_newline_terminator' {
  local cmd=$'cat <<EOF\nhi\nEO\\\nF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_continuation_then_delimiter' {
  local cmd=$'cat <<EOF\nnext\\\nEOF\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_double_quote_in_body' {
  local cmd=$'cat <<EOF\necho \"\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_escaped_double_quote_in_body' {
  local cmd=$'cat <<EOF\necho \\\"\nEOF'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_comsub_herestring' {
  local cmd='echo $(cat <<<\"comsub here-string\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_bare_word' {
  local cmd='read x <<<beta; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_var_unquoted' {
  local cmd='X=4; read x <<<$X; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_var_double_quoted' {
  local cmd='X=4; read x <<<\"$X\"; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_empty_double_quoted' {
  local cmd='read x <<< \"\"; echo \"[$x]\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_empty_unset_var' {
  local cmd='unset empty; read x <<<\"$empty\"; echo \"[$x]\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_two_vars' {
  local cmd='a=hot; b=damn; cat <<<\"$a $b\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_single_quoted' {
  local cmd='cat <<<'\''what a fabulous window treatment'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_single_quoted_double_quote' {
  local cmd='cat <<<'\''double\"quote'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_single_quoted_no_comsub' {
  local cmd='cat <<<'\''echo $(echo hi)'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_double_quoted_literal' {
  local cmd='cat <<<\"echo ho\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_herestr_double_quoted_comsub' {
  local cmd='cat <<<\"echo $(echo '\''off to work we go'\'')\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

