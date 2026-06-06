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

@test 'test_strip_all_blank_lines' {
  local cmd='v=`echo '\'''\'' ; echo '\'''\'' ; echo '\'''\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_no_newline_spaces_preserved' {
  local cmd='v=`echo -n '\'' ab '\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_no_newline_space' {
  local cmd='v=`echo -n '\'' '\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_no_newline_empty' {
  local cmd='v=`echo -n '\'''\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_single_blank_line' {
  local cmd='v=`echo '\'''\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_bare_echo' {
  local cmd='v=`echo`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_content_stripped_newline' {
  local cmd='v=`echo ababababababab`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_trailing_spaces_in_content' {
  local cmd='v=`echo '\''ababababababab  '\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_no_newline_content_spaces' {
  local cmd='v=`echo -n '\''ababababababab  '\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_internal_newline_preserved' {
  local cmd='v=`printf '\''abababa\nbababab  '\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

