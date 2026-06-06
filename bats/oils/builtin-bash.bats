#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 help' {
  local cmd='help
echo status=$? >&2
help help
echo status=$? >&2
help -- help
echo status=$? >&2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 bad help topic' {
  local cmd='help ZZZ 2>$TMP/err.txt
echo "help=$?"
cat $TMP/err.txt | grep -i '\''no help topics'\'' >/dev/null
echo "grep=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 mapfile' {
  local cmd='type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\n'\'' {1..5..2} | {
  mapfile
  echo "n=${#MAPFILE[@]}"
  printf '\''[%s]\n'\'' "${MAPFILE[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 readarray (synonym for mapfile)' {
  local cmd='type readarray >/dev/null 2>&1 || exit 0
printf '\''%s\n'\'' {1..5..2} | {
  readarray
  echo "n=${#MAPFILE[@]}"
  printf '\''[%s]\n'\'' "${MAPFILE[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 mapfile (array name): arr' {
  local cmd='type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\n'\'' {1..5..2} | {
  mapfile arr
  echo "n=${#arr[@]}"
  printf '\''[%s]\n'\'' "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 mapfile (delimiter): -d delim' {
  local cmd='# Note: Bash-4.4+
type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s:'\'' {1..5..2} | {
  mapfile -d : arr
  echo "n=${#arr[@]}"
  printf '\''[%s]\n'\'' "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 mapfile (delimiter): -d '\'''\'' (null-separated)' {
  local cmd='# Note: Bash-4.4+
type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\0'\'' {1..5..2} | {
  mapfile -d '\'''\'' arr
  echo "n=${#arr[@]}"
  printf '\''[%s]\n'\'' "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 mapfile (truncate delim): -t' {
  local cmd='type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\n'\'' {1..5..2} | {
  mapfile -t arr
  echo "n=${#arr[@]}"
  printf '\''[%s]\n'\'' "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 mapfile -t doesn'\''t remove r' {
  local cmd='type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\r\n'\'' {1..5..2} | {
  mapfile -t arr
  argv.py "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 mapfile -t bugs (ble.sh)' {
  local cmd='# empty line
mapfile -t lines <<< $'\''hello\n\nworld'\''
echo len=${#lines[@]}
#declare -p lines

# initial newline
mapfile -t lines <<< $'\''\nhello'\''
echo len=${#lines[@]}
#declare -p lines

# trailing newline
mapfile -t lines <<< $'\''hello\n'\''
echo len=${#lines[@]}
#declare -p lines'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 mapfile (store position): -O start' {
  local cmd='type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\n'\'' a{0..2} | {
  arr=(x y z)
  mapfile -O 2 -t arr
  echo "n=${#arr[@]}"
  printf '\''[%s]\n'\'' "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 mapfile (input range): -s start -n count' {
  local cmd='type mapfile >/dev/null 2>&1 || exit 0
printf '\''%s\n'\'' a{0..10} | {
  mapfile -s 5 -n 3 -t arr
  echo "n=${#arr[@]}"
  printf '\''[%s]\n'\'' "${arr[@]}"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 mapfile / readarray stdin  TODO: Fix me.' {
  local cmd='shopt -s lastpipe  # for bash

seq 2 | mapfile m
seq 3 | readarray r
echo ${#m[@]}
echo ${#r[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

