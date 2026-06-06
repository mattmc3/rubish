#!/usr/bin/env bats
# Generated from oils-for-unix spec/append.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Append string to string' {
  local cmd='s='\''abc'\''
s+=d
echo $s'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Append array to array' {
  local cmd='a=(x y )
a+=(t '\''u v'\'')
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Append string to undefined variable' {
  local cmd='s+=foo
echo s=$s

# bash and mksh agree that this does NOT respect set -u.
# I think that'\''s a mistake, but += is a legacy construct, so let'\''s copy it.

set -u

t+=foo
echo t=$t
t+=foo
echo t=$t'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Append to array to undefined variable' {
  local cmd='y+=(c d)
argv.py "${y[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 error: s+=(my array)' {
  local cmd='s='\''abc'\''
s+=(d e f)
argv.py "${s[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 error: myarray+=s' {
  local cmd='# They treat this as implicit index 0.  We disallow this on the LHS, so we will
# also disallow it on the RHS.
a=(x y )
a+=z
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 typeset s+=(my array)' {
  local cmd='typeset s='\''abc'\''
echo $s

typeset s+=(d e f)
echo status=$?
argv.py "${s[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 error: typeset myarray+=s' {
  local cmd='typeset a=(x y)
argv.py "${a[@]}"
typeset a+=s
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 error: append used like env prefix' {
  local cmd='# This should be an error in other shells but it'\''s not.
A=a
A+=a printenv.py A'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 myarray[1]+=s - Append to element' {
  local cmd='# They treat this as implicit index 0.  We disallow this on the LHS, so we will
# also disallow it on the RHS.
a=(x y )
a[1]+=z
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 myarray[-1]+=s - Append to last element' {
  local cmd='# Works in bash, but not mksh.  It seems like bash is doing the right thing.
# a[-1] is allowed on the LHS.  mksh doesn'\''t have negative indexing?
a=(1 '\''2 3'\'')
a[-1]+='\'' 4'\''
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Try to append list to element' {
  local cmd='# bash - runtime error: cannot assign list to array number
# mksh - a[-1]+: is not an identifier
# osh - parse error -- could be better!
a=(1 '\''2 3'\'')
a[-1]+=(4 5)
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Strings have value semantics, not reference semantics' {
  local cmd='s1='\''abc'\''
s2=$s1
s1+='\''d'\''
echo $s1 $s2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 typeset s+=' {
  local cmd='typeset s+=foo
echo s=$s

# bash and mksh agree that this does NOT respect set -u.
# I think that'\''s a mistake, but += is a legacy construct, so let'\''s copy it.

set -u

typeset t+=foo
echo t=$t
typeset t+=foo
echo t=$t'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 typeset s{dyn}+=' {
  local cmd='dyn=x

typeset s${dyn}+=foo
echo sx=$sx

# bash and mksh agree that this does NOT respect set -u.
# I think that'\''s a mistake, but += is a legacy construct, so let'\''s copy it.

set -u

typeset t${dyn}+=foo
echo tx=$tx
typeset t${dyn}+=foo
echo tx=$tx'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 export readonly +=' {
  local cmd='export e+=foo
echo e=$e

readonly r+=bar
echo r=$r

set -u

export e+=foo
echo e=$e

#readonly r+=foo
#echo r=$e'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 local +=' {
  local cmd='f() {
  local s+=foo
  echo s=$s

  set -u
  local s+=foo
  echo s=$s
}

f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 assign builtin appending array: declare d+=(d e)' {
  local cmd='declare d+=(d e)
echo "${d[@]}"
declare d+=(c l)
echo "${d[@]}"

readonly r+=(r e)
echo "${r[@]}"
# can'\''t do this again

f() {
  local l+=(l o)
  echo "${l[@]}"

  local l+=(c a)
  echo "${l[@]}"
}

f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 export+=array disallowed (strict_array)' {
  local cmd='shopt -s strict_array

export e+=(e x)
echo "${e[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Type mismatching of lhs+=rhs should not cause a crash' {
  local cmd='case $SH in mksh|zsh) exit ;; esac
s=
a=()
declare -A d=([lemon]=yellow)

s+=(1)
s+=([melon]=green)

a+=lime
a+=([1]=banana)

d+=orange
d+=(0)

true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

