#!/usr/bin/env bats
# Generated from oils-for-unix spec/arith-dynamic.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Double quotes' {
  local cmd='echo $(( "1 + 2" * 3 ))
echo $(( "1+2" * 3 ))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Single quotes' {
  local cmd='echo $(( '\''1'\'' + '\''2'\'' * 3 ))
echo status=$?

echo $(( '\''1 + 2'\'' * 3 ))
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Substitutions' {
  local cmd='x='\''1 + 2'\''
echo $(( $x * 3 ))
echo $(( "$x" * 3 ))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Variable references' {
  local cmd='x='\''1'\''
echo $(( x + 2 * 3 ))
echo status=$?

# Expression like values are evaluated first (this is unlike double quotes)
x='\''1 + 2'\''
echo $(( x * 3 ))
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

