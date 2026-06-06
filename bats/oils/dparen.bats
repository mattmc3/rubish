#!/usr/bin/env bats
# Generated from oils-for-unix spec/dparen.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 (( )) result' {
  local cmd='(( 1 )) && echo True
(( 0 )) || echo False'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 negative number is true' {
  local cmd='(( -1 )) && echo True'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 (( )) in if statement' {
  local cmd='if (( 3 > 2)); then
  echo True
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 (( ))' {
  local cmd='# What is the difference with this and let?  One difference: spaces are allowed.
(( x = 1 ))
(( y = x + 2 ))
echo $x $y'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 (( )) with arrays' {
  local cmd='a=(4 5 6)
(( sum = a[0] + a[1] + a[2] ))
echo $sum'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 (( )) with error' {
  local cmd='(( a = 0 )) || echo false
(( b = 1 )) && echo true
(( c = -1 )) && echo true
echo $((a + b + c))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 bash and mksh: V in (( a[K] = V )) gets coerced to integer' {
  local cmd='shopt -u strict_arith || true
K=key
V=value
typeset -a a
(( a[K] = V ))

# not there!
echo a[\"key\"]=${a[$K]}

echo keys = ${!a[@]}
echo values = ${a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 bash: K in (( A[K] = V )) is a constant string' {
  local cmd='K=5
V=42
typeset -A A
(( A[K] = V ))

echo A["5"]=${A["5"]}
echo keys = ${!A[@]}
echo values = ${A[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 BUG: (( V = A[K] )) doesn'\''t retrieve the right value' {
  local cmd='typeset -A A
K=5
V=42
A["$K"]=$V
A["K"]=oops
A[K]=oops2

# We don'\''t neither 42 nor "oops".  Bad!
(( V = A[K] ))

echo V=$V'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 bash: V in (( A[K] = V )) gets coerced to integer' {
  local cmd='shopt -u strict_arith || true
K=key
V=value
typeset -A A || exit 1
(( A["K"] = V ))

# not there!
echo A[\"key\"]=${A[$K]}

echo keys = ${!A[@]}
echo values = ${A[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 literal strings inside (( ))' {
  local cmd='declare -A A
A['\''x'\'']=42
(( x = A['\''x'\''] ))
(( A['\''y'\''] = '\''y'\'' ))  # y is a variable, gets coerced to 0
echo $x ${A['\''y'\'']}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 (( )) with redirect' {
  local cmd='(( a = $(stdout_stderr.py 42) + 10 )) 2>$TMP/x.txt
echo $a
echo --
cat $TMP/x.txt'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Assigning whole raray (( b = a ))' {
  local cmd='a=(4 5 6)
(( b = a ))

echo "${a[@]}"

# OSH doesn'\''t like this
echo "${b[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 set associative array' {
  local cmd='declare -A A=(['\''foo'\'']=bar ['\''spam'\'']=42)
(( x = A['\''spam'\''] ))
echo $x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Example of incrementing associative array entry with var key (ble.sh)' {
  local cmd='declare -A A=(['\''foo'\'']=42)
key='\''foo'\''

# note: in bash, (( A[\$key] += 1 )) works the same way.

set -- 1 2
(( A[$key] += $2 ))

echo foo=${A['\''foo'\'']}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

