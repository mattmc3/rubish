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

@test 'test_tilde_expands_to_home' {
  local cmd='HOME=/usr/xyz; echo ~/foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_quoted_no_expand' {
  local cmd='echo \"~chet\"/\"foo\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_not_at_start_no_expand' {
  local cmd='echo abcd~chet'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_in_assignment' {
  local cmd='HOME=/usr/xyz; SHELL=~/bash; echo $SHELL'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_in_colon_path' {
  local cmd='HOME=/usr/xyz; path=/usr/ucb:/bin:~/bin:~/tmp/bin:/usr/bin; echo $path'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_mid_word_no_expand' {
  local cmd='echo '\'':~chet/'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_in_case' {
  local cmd='HOME=/usr/xyz; case ~ in \$HOME) echo ok;; *) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_in_export' {
  local cmd='HOME=/usr/xyz; XPATH=/bin:/usr/bin:.; export PPATH=$XPATH:~/bin; echo $PPATH'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_backslash_mid_username' {
  local cmd='HOME=/usr/xyz; echo ~ch\\et'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_escaped_tilde_no_expand' {
  local cmd='echo \\~chet/foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_backslash_after_tilde' {
  local cmd='HOME=/usr/xyz; echo ~\\chet/bar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_empty_string_suffix' {
  local cmd='echo ~chet\"\"/bar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quoted_string_with_tilde' {
  local cmd='HOME=/usr/xyz; echo \"SHELL=~/bash\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_after_colon_in_arg' {
  local cmd='echo abcd:~chet'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_minus_oldpwd' {
  local cmd='cd /usr; cd /tmp; echo ~-'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_plus_pwd' {
  local cmd='cd /usr; cd /tmp; echo ~+'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_q_formats_tilde' {
  local cmd='printf '\''%q\\n'\'' '\''~'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_in_case_pattern' {
  local cmd='HOME=/usr/xyz; case ~ in ~) echo '\''ok 2'\'';; \\~) echo '\''bad 2a'\'';; *) echo '\''bad 2b'\'';; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_unset_var_empty' {
  local cmd='case \"$tilde_test_unset_var\" in \"\") echo '\''ok 3'\'';; *) echo '\''bad 3'\'';; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_dollar_var_no_expand' {
  local cmd='USER=root; echo ~\\$USER'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_in_assignment_like_arg' {
  local cmd='HOME=/usr/xyz; echo foo=bar:~'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_posix_mode_no_expand_in_arg' {
  local cmd='HOME=/usr/xyz; set -o posix; echo foo=bar:~'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

