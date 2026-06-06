#!/usr/bin/env bats
# Generated from oils-for-unix spec/for-expr.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 C-style for loop' {
  local cmd='n=10
for ((a=1; a <= n ; a++))  # Double parentheses, and naked '\''n'\''
do
  if test $a = 3; then
    continue
  fi
  if test $a = 6; then
    break
  fi
  echo $a
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 For loop with and without semicolon' {
  local cmd='for ((a=1; a <= 3; a++)); do
  echo $a
done
for ((a=1; a <= 3; a++)) do
  echo $a
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Accepts { } syntax too' {
  local cmd='for ((a=1; a <= 3; a++)) {
  echo $a
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Empty init' {
  local cmd='i=1
for ((  ;i < 4;  i++ )); do
  echo $i
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Empty init and cond' {
  local cmd='i=1
for ((  ; ;  i++ )); do
  if test $i = 4; then
    break
  fi
  echo $i
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Infinite loop with ((;;))' {
  local cmd='a=1
for ((  ;  ;  )); do
  if test $a = 4; then
    break
  fi
  echo $((a++))
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Arith lexer mode' {
  local cmd='# bash is lenient; zsh disagrees

for ((i = '\''3'\'';  i < '\''5'\'';  ++i)); do echo $i; done
for ((i = "3";  i < "5";  ++i)); do echo $i; done
for ((i = $'\''3'\''; i < $'\''5'\''; ++i)); do echo $i; done
for ((i = $"3"; i < $"5"; ++i)); do echo $i; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Integers near 31, 32, 62 bits' {
  local cmd='# Hm this was never a bug, but it'\''s worth testing.
# The bug was EvalToInt() in the condition.

for base in 31 32 62; do

  start=$(( (1 << $base) - 2))
  end=$(( (1 << $base) + 2))

  for ((i = start; i < end; ++i)); do
    echo $i
  done
  echo ---
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Condition that'\''s greater than 32 bits' {
  local cmd='iters=0

for ((i = 1 << 32; i; ++i)); do
  echo $i
  iters=$(( iters + 1 ))
  if test $iters -eq 5; then
    break
  fi
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

