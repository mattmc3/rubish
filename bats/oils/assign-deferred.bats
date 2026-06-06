#!/usr/bin/env bats
# Generated from oils-for-unix spec/assign-deferred.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 typeset a[3]=4' {
  local cmd='typeset a[3]=4 a[5]=6
echo status=$?
argv.py "${!a[@]}" "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 typeset -a a[1]=a a[3]=c' {
  local cmd='# declare works the same way in bash, but not mksh.
# spaces are NOT allowed here.
typeset -a a[1*1]=x a[1+2]=z
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 local a[3]=4' {
  local cmd='f() {
  local a[3]=4 a[5]=6
  echo status=$?
  argv.py "${!a[@]}" "${a[@]}"
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 readonly a[7]=8' {
  local cmd='readonly b[7]=8
echo status=$?
argv.py "${!b[@]}" "${b[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 export a[7]=8' {
  local cmd='export a[7]=8
echo status=$?
argv.py "${!a[@]}" "${a[@]}"
printenv.py a'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 '\''builtin'\'' prefix is allowed on assignments' {
  local cmd='builtin export e='\''E'\''
echo e=$e'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 '\''command'\'' prefix is allowed on assignments' {
  local cmd='readonly r1='\''R1'\''  # zsh has this
command readonly r2='\''R2'\''  # but not this
echo r1=$r1
echo r2=$r2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 is '\''builtin'\'' prefix and array allowed?  OSH is smarter' {
  local cmd='builtin typeset a=(1 2 3)
echo len=${#a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 is '\''command'\'' prefix and array allowed?  OSH is smarter' {
  local cmd='command typeset a=(1 2 3)
echo len=${#a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

