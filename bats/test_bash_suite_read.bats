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

@test 'test_read_strips_leading_trailing_whitespace' {
  local cmd='echo '\'' a '\'' | (read x; echo \"$x.\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_two_vars_strips_whitespace' {
  local cmd='echo '\'' a  b  '\'' | (read x y; echo -\"$x\"-\"$y\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_one_var_captures_rest' {
  local cmd='echo '\'' a  b  '\'' | (read x; echo -\"$x\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_empty_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | (IFS= read line; echo \"$line\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_heredoc' {
  local cmd='read a b c <<EOF\na b c\nEOF\necho \"a=$a b=$b c=$c\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_backslash_in_second_var' {
  local cmd='echo '\'' a  b\\ '\'' | (read x y; echo -\"$x\"-\"$y\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_one_var_trailing_backslash_dropped' {
  local cmd='echo '\'' a  b\\ '\'' | (read x; echo -\"$x\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_raw_two_vars_preserves_backslash' {
  local cmd='echo '\'' a  b\\ '\'' | (read -r x y; echo -\"$x\"-\"$y\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_raw_one_var_preserves_backslash' {
  local cmd='echo '\'' a  b\\ '\'' | (read -r x; echo -\"$x\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_raw_leading_backslash_two_vars' {
  local cmd='echo '\''\\ a  b\\ '\'' | (read -r x y; echo -\"$x\"-\"$y\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_raw_leading_backslash_one_var' {
  local cmd='echo '\''\\ a  b\\ '\'' | (read -r x; echo -\"$x\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_raw_space_backslash_two_vars' {
  local cmd='echo '\'' \\ a  b\\ '\'' | (read -r x y; echo -\"$x\"-\"$y\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_raw_space_backslash_one_var' {
  local cmd='echo '\'' \\ a  b\\ '\'' | (read -r x; echo -\"$x\"-)'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_empty_var_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | { IFS= ; read line; echo \"$line\"; }'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_unset_strips_leading_space' {
  local cmd='echo '\'' foo'\'' | (unset IFS; read line; echo \"$line\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_newline_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | (IFS=$'\''\\n'\''; read line; echo \"$line\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_colon_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | (IFS='\'':'\''; read line; echo \"$line\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_readonly_var_error' {
  local cmd='readonly b; read a b c <<EOF\na b c\nEOF\necho \"a = $a b = $b c = $c stat = $?\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

