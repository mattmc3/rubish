#!/usr/bin/env bats
# Generated from oils-for-unix spec/array-basic.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 {a[@]} and {a[*]}' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[@]}" "${a[*]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 {a[@]} and {a[*]}' {
  local cmd='a=(1 '\''2 3'\'')
argv.py ${a[@]} ${a[*]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 4 ways to interpolate empty array' {
  local cmd='argv.py 1 "${a[@]}" 2 ${a[@]} 3 "${a[*]}" 4 ${a[*]} 5'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 empty array' {
  local cmd='empty=()
argv.py "${empty[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Empty array with :-' {
  local cmd='empty=()
argv.py ${empty[@]:-not one} "${empty[@]:-not one}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

