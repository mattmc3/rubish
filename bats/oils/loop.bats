#!/usr/bin/env bats
# Generated from oils-for-unix spec/loop.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 implicit for loop' {
  local cmd='# This is like "for i in $@".
fun() {
  for i; do
    echo $i
  done
  echo "finished=$i"
}
fun 1 2 3'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 empty for loop (has in)' {
  local cmd='set -- 1 2 3
for i in ; do
  echo $i
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 for loop with invalid identifier' {
  local cmd='# should be compile time error, but runtime error is OK too
for - in a b c; do
  echo hi
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 the word '\''in'\'' can be the loop variable' {
  local cmd='for in in a b c; do
  echo $in
done
echo finished=$in'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Tilde expansion within for loop' {
  local cmd='HOME=/home/bob
for name in ~/src ~/git; do
  echo $name
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Brace Expansion within Array' {
  local cmd='for i in -{a,b} {c,d}-; do
  echo $i
  done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 using loop var outside loop' {
  local cmd='fun() {
  for i in a b c; do
    echo $i
  done
  echo $i
}
fun'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 continue' {
  local cmd='for i in a b c; do
  echo $i
  if test $i = b; then
    continue
  fi
  echo $i
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 break' {
  local cmd='for i in a b c; do
  echo $i
  if test $i = b; then
    break
  fi
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 while in while condition' {
  local cmd='# This is a consequence of the grammar
while while true; do echo cond; break; done
do
  echo body
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 while in pipe' {
  local cmd='x=$(find spec/ | wc -l)
y=$(find spec/ | while read path; do
  echo $path
done | wc -l
)
test $x -eq $y
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 while in pipe with subshell' {
  local cmd='i=0
seq 3 | ( while read foo; do
  i=$((i+1))
  #echo $i
done
echo $i )'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 until loop' {
  local cmd='# This is just the opposite of while?  while ! cond?
until false; do
  echo hi
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 continue at top level' {
  local cmd='if true; then
  echo one
  continue
  echo two
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 continue in subshell' {
  local cmd='for i in $(seq 2); do
  echo "> $i"
  ( if true; then continue; fi; echo "Should not print" )
  echo subshell status=$?
  echo ". $i"
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 continue in subshell aborts with errexit' {
  local cmd='# The other shells don'\''t let you recover from this programming error!
set -o errexit
for i in $(seq 2); do
  echo "> $i"
  ( if true; then continue; fi; echo "Should not print" )
  echo '\''should fail after subshell'\''
  echo ". $i"
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 bad arg to break' {
  local cmd='x=oops
while true; do 
  echo hi
  break $x
  sleep 0.1
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 too many args to continue' {
  local cmd='# OSH treats this as a parse error
for x in a b c; do
  echo $x
  # bash breaks rather than continue or fatal error!!!
  continue 1 2 3
done
echo --'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 break in condition of loop' {
  local cmd='while break; do
  echo x
done
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 break in condition of nested loop' {
  local cmd='for i in 1 2 3; do
  echo i=$i
  while break; do
    echo x
  done
done
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 return within eval' {
  local cmd='f() {
  echo one
  eval '\''return'\''
  echo two
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 break/continue within eval' {
  local cmd='# NOTE: This changes things
# set -e
f() {
  for i in $(seq 5); do 
    if test $i = 2; then
      eval continue
    fi
    if test $i = 4; then
      eval break
    fi
    echo $i
  done

  eval '\''return'\''
  echo '\''done'\''
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 break/continue within source' {
  local cmd='# NOTE: This changes things
# set -e

cd $REPO_ROOT
f() {
  for i in $(seq 5); do 
    if test $i = 2; then
      . spec/testdata/continue.sh
    fi
    if test $i = 4; then
      . spec/testdata/break.sh
    fi
    echo $i
  done

  # Return is different!
  . spec/testdata/return.sh
  echo done
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 top-level break/continue/return (without strict_control_flow)' {
  local cmd='$SH -c '\''break; echo break=$?'\''
$SH -c '\''continue; echo continue=$?'\''
$SH -c '\''return; echo return=$?'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 multi-level break with argument' {
  local cmd='# reported in issue #1459

counterA=100
counterB=100

while test "$counterA" -gt 0
do
    counterA=$((counterA - 1))
    while test "$counterB" -gt 0
    do
        counterB=$((counterB - 1))
        if test "$counterB" = 50
        then
            break 2
        fi
    done
done

echo "$counterA"
echo "$counterB"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 multi-level continue' {
  local cmd='for i in 1 2; do
  for j in a b c; do
    if test $j = b; then
      continue
    fi
    echo $i $j
  done
done

echo ---

for i in 1 2; do
  for j in a b c; do
    if test $j = b; then
      continue 2   # MULTI-LEVEL
    fi
    echo $i $j
  done
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 b break, c continue, r return, e exit' {
  local cmd='# hm would it be saner to make FATAL builtins called break/continue/etc.?
# On the other hand, this spits out errors loudly.

echo '\''- break'\''
b=break
for i in 1 2 3; do
  echo $i
  $b
done

echo '\''- continue'\''
c='\''continue'\''
for i in 1 2 3; do
  if test $i = 2; then
    $c
  fi
  echo $i
done

r='\''return'\''
f() {
  echo '\''- return'\''
  for i in 1 2 3; do
    echo $i
    if test $i = 2; then
      $r 99
    fi
  done
}
f
echo status=$?

echo '\''- exit'\''
e='\''exit'\''
$e 5
echo '\''not executed'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 break continue return exit' {
  local cmd='echo '\''- break'\''
for i in 1 2 3; do
  echo $i
  \break
done

echo '\''- continue'\''
for i in 1 2 3; do
  if test $i = 2; then
    \continue
  fi
  echo $i
done

f() {
  echo '\''- return'\''
  for i in 1 2 3; do
    echo $i
    if test $i = 2; then
      \return 99
    fi
  done
}
f
echo status=$?

echo '\''- exit'\''
\exit 5
echo '\''not executed'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 builtin,command break,continue,return,exit' {
  local cmd='case $SH in dash|zsh) exit ;; esac

echo '\''- break'\''
for i in 1 2 3; do
  echo $i
  builtin break
done

echo '\''- continue'\''
for i in 1 2 3; do
  if test $i = 2; then
    command continue
  fi
  echo $i
done

f() {
  echo '\''- return'\''
  for i in 1 2 3; do
    echo $i
    if test $i = 2; then
      builtin command return 99
    fi
  done
}
f
echo status=$?

echo '\''- exit'\''
command builtin exit 5
echo '\''not executed'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

