#!/usr/bin/env bats
# Generated from oils-for-unix spec/assign-dialects.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 K and V are variables in (( array[K] = V ))' {
  local cmd='K=5
V=42
typeset -a array
(( array[K] = V ))

echo array[5]=${array[5]}
echo keys = ${!array[@]}
echo values = ${array[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 test -v with strings' {
  local cmd='test -v str
echo str=$?

str=x

test -v str
echo str=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 test -v with arrays' {
  local cmd='typeset -a a

test -v a
echo a=$?
test -v '\''a[0]'\''
echo "a[0]=$?"
echo

a[0]=1

test -v a
echo a=$?
test -v '\''a[0]'\''
echo "a[0]=$?"
echo

test -v '\''a[1]'\''
echo "a[1]=$?"

# stupid rule about undefined '\''x'\''
test -v '\''a[x]'\''
echo "a[x]=$?"
echo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 test -v with assoc arrays' {
  local cmd='typeset -A A

test -v A
echo A=$?
test -v '\''A[0]'\''
echo "A[0]=$?"
echo

A['\''0'\'']=x

test -v A
echo A=$?
test -v '\''A[0]'\''
echo "A[0]=$?"
echo

test -v '\''A[1]'\''
echo "A[1]=$?"

# stupid rule about undefined '\''x'\''
test -v '\''A[x]'\''
echo "A[x]=$?"
echo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

