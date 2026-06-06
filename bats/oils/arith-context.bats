#!/usr/bin/env bats
# Generated from oils-for-unix spec/arith-context.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Multiple right brackets inside expression' {
  local cmd='a=(1 2 3)
echo ${a[a[0]]} ${a[a[a[0]]]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Slicing of string with constants' {
  local cmd='s='\''abcd'\''
echo ${s:0} ${s:0:4} ${s:1:1}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Slicing of string with variables' {
  local cmd='s='\''abcd'\''
zero=0
one=1
echo ${s:$zero} ${s:$zero:4} ${s:$one:$one}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Array index on LHS of assignment' {
  local cmd='a=(1 2 3)
zero=0
a[zero+5-4]=X
echo ${a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Array index on LHS with indices' {
  local cmd='a=(1 2 3)
a[a[1]]=X
echo ${a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Slicing of string with expressions' {
  local cmd='# mksh accepts ${s:0} and ${s:$zero} but not ${s:zero}
# zsh says unrecognized modifier '\''z'\''
s='\''abcd'\''
zero=0
echo ${s:zero} ${s:zero+0} ${s:zero+1:zero+1}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Ambiguous colon in slice' {
  local cmd='s='\''abcd'\''
echo $(( 0 < 1 ? 2 : 0 ))  # evaluates to 2
echo ${s: 0 < 1 ? 2 : 0 : 1}  # 2:1 -- TRICKY THREE COLONS'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Triple parens should be disambiguated' {
  local cmd='# The first paren is part of the math, parens 2 and 3 are a single token ending
# arith sub.
((a=1 + (2*3)))
echo $a $((1 + (2*3)))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Quadruple parens should be disambiguated' {
  local cmd='((a=1 + (2 * (3+4))))
echo $a $((1 + (2 * (3+4))))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 [ is a synonym for ((' {
  local cmd='echo $[1+2] $[3 * 4]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 [var is a synonym for ((var (#2426)' {
  local cmd='var=1
echo $[$var+2]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 [undefined] is a synonym for ((undefined (#2566)' {
  local cmd='a[0]=$[1+3]
b[0]=$[b[0]]
c[0]=$[b[0]]
echo ${c[0]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Empty expression (( ))  (( ))' {
  local cmd='(( ))
echo status=$?

echo $(( ))

#echo $[]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Empty expression for (( ))' {
  local cmd='for (( ; ; )); do
  echo one
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Empty expression in {a[@]: : }' {
  local cmd='a=(a b c d e f)

# space required here -- see spec/var-op-slice
echo slice ${a[@]: }
echo status=$?
echo

echo slice ${a[@]: : }
echo status=$?
echo

# zsh doesn'\''t accept this
echo slice ${a[@]:: }
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Empty expression a[]' {
  local cmd='a=(1 2 3)

a[]=42
echo status=$?
echo ${a[@]}

echo ${a[]}
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

