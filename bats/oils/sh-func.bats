#!/usr/bin/env bats
# Generated from oils-for-unix spec/sh-func.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Locals don'\''t leak' {
  local cmd='f() {
  local f_var=f_var
}
f
echo $f_var'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Globals leak' {
  local cmd='f() {
  f_var=f_var
}
f
echo $f_var'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Return statement' {
  local cmd='f() {
  echo one
  return 42
  echo two
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Dynamic Scope' {
  local cmd='f() {
  echo $g_var
}
g() {
  local g_var=g_var
  f
}
g'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Dynamic Scope Mutation (wow this is bad)' {
  local cmd='f() {
  g_var=f_mutation
}
g() {
  local g_var=g_var
  echo "g_var=$g_var"
  f
  echo "g_var=$g_var"
}
g
echo g_var=$g_var'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Assign local separately' {
  local cmd='f() {
  local f
  f='\''new-value'\''
  echo "[$f]"
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Assign a local and global on same line' {
  local cmd='myglobal=
f() {
  local mylocal
  mylocal=L myglobal=G
  echo "[$mylocal $myglobal]"
}
f
echo "[$mylocal $myglobal]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Return without args gives previous' {
  local cmd='f() {
  ( exit 42 )
  return
}
f
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 return  (a lot of disagreement)' {
  local cmd='f() {
  echo f
  return ""
}

f
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 return empty' {
  local cmd='f() {
  echo f
  empty=
  return $empty
}

f
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Subshell function' {
  local cmd='f() ( return 42; )
# BUG: OSH raises invalid control flow!  I think we should just allow '\''return'\''
# but maybe not '\''break'\'' etc.
g() ( return 42 )
# bash warns here but doesn'\''t cause an error
# g() ( break )

f
echo status=$?
g
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Scope of global variable when sourced in function (Shell Functions aren'\''t Closures)' {
  local cmd='set -u

echo >tmp.sh '\''
g="global"
local L="local"

test_func() {
  echo "g = $g"
  echo "L = $L"
}
'\''

main() {
  # a becomes local here
  # test_func is defined globally
  . ./tmp.sh
}

main

# a is not defined
test_func'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

