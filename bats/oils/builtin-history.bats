#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-history.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 history -a' {
  local cmd='rm -f tmp

echo '\''
history -c

HISTFILE=tmp
echo 1
history -a
cat tmp

echo 2

cat tmp
'\'' | $SH -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 history -w writes out the in-memory history to the history file' {
  local cmd='cd $TMP

# Populate a history file with a command to be overwritten
echo '\''cmd old'\'' > tmp
HISTFILE=tmp
history -c
echo '\''cmd new'\'' > /dev/null
history -w # Overwrite history file

# Verify that old command is gone
grep '\''old'\'' tmp > /dev/null
echo "found=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 history -r reads from the history file, and appends it to the current history' {
  local cmd='cd $TMP
printf "cmd orig%s\n" {1..10} > tmp
HISTFILE=tmp

history -c

history -r
history -r

history | grep orig | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 history -n reads *new* commands from the history file, and appends them to the current history' {
  local cmd='# NB: Based on line ranges, not contents

cd $TMP

printf "cmd orig%s\n" {1..10} > tmp1
cp tmp1 tmp2
printf "cmd new%s\n" {1..10} >> tmp2

history -c
HISTFILE=tmp1 history -r
HISTFILE=tmp2 history -n

history | grep orig | wc -l
history | grep new | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 history -c clears in-memory history' {
  local cmd='$SH --norc -i <<'\''EOF'\''
echo '\''foo'\'' > /dev/null
echo '\''bar'\'' > /dev/null
history -c 
history | wc -l
EOF

case $SH in bash) echo '\''^D'\'' ;; esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 history -d to delete 1 item' {
  local cmd='cd $TMP
HISTFILE=tmp
printf "cmd orig%s\n" {1..3} > tmp
history -c
history -r
history -d 1
history | grep orig1 > /dev/null
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 history -d to delete history from end' {
  local cmd='# bash 4 doesn'\''t support negative indices or ranges

rm -f myhist
export HISTFILE=myhist

$SH --norc -i <<'\''EOF'\''

echo 42
echo 43
echo 44

history -a

history -d 1
echo status=$?

# Invalid integers
history -d -1
echo status=$?
history -d -2
echo status=$?
history -d 99
echo status=$?

case $SH in bash*) echo '\''^D'\'' ;; esac

EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 HISTFILE is defined initially' {
  local cmd='echo '\''
if test -n $HISTFILE; then echo exists; fi
'\'' | $SH -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 HISTFILE must point to a file' {
  local cmd='rm -f _tmp/does-not-exist

echo '\''
HISTFILE=_tmp/does-not-exist
history -r
echo status=$?
'\'' | $SH -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 HISTFILE set to array' {
  local cmd='echo '\''
HISTFILE=(a b c)
history -a
echo status=$?
'\'' | $SH -i

case $SH in bash) echo '\''^D'\'' ;; esac

# note that bash actually writes the file '\''a'\'', since that'\''s ${HISTFILE[0]} '
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 HISTFILE unset' {
  local cmd='echo '\''
unset HISTFILE
history -a
echo status=$?
'\'' | $SH -i

case $SH in bash) echo '\''^D'\'' ;; esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 history usage' {
  local cmd='history not-a-number
echo status=$?

history 3 too-many
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 HISTSIZE shrinks the in-memory history when changed' {
  local cmd='cd $TMP
printf "cmd %s\n" {1..10} > tmp
HISTFILE=tmp
history -c
history -r
history | wc -l
HISTSIZE=5
history | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 HISTFILESIZE shrinks the history file when changed' {
  local cmd='cd $TMP
printf "cmd %s\n" {1..10} > tmp
HISTFILE=tmp
HISTFILESIZE=5
cat tmp | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 recording history can be toggled with set -o/+o history' {
  local cmd='cd $TMP
printf "echo %s\n" {1..3} > tmp
HISTFILE=tmp $SH -i <<'\''EOF'\''
set +o history
echo "not recorded" >> /dev/null
set -o history
echo "recorded" >> /dev/null
EOF

case $SH in bash) echo '\''^D'\'' ;; esac

grep "not recorded" tmp >> /dev/null
echo status=$?
grep "recorded" tmp >> /dev/null
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 shopt histappend toggle check' {
  local cmd='shopt -s histappend
echo status=$?
shopt -p histappend
shopt -u histappend
echo status=$?
shopt -p histappend

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 shopt histappend - osh ignores shopt and appends, bash sometimes overwrites' {
  local cmd='# When set, bash always appends when exiting, no matter what. 
# When unset, bash will append anyway as long the # of new commands < the hist length
# Either way, the file is truncated to HISTFILESIZE afterwards.
# osh always appends

cd $TMP 

export HISTSIZE=10
export HISTFILESIZE=1000
export HISTFILE=tmp

histappend_test() {
  local histopt
  if [[ "$1" == true ]]; then
    histopt='\''shopt -s histappend'\''
  else
    histopt='\''shopt -u histappend'\''
  fi

  printf "cmd orig%s\n" {1..10} > tmp

  $SH --norc -i <<EOF
  HISTSIZE=2 # Stifle the history down to 2 commands
  $histopt
  # Now run >2 commands to trigger bash'\''s overwrite behavior
  echo cmd new1 > /dev/null
  echo cmd new2 > /dev/null
  echo cmd new3 > /dev/null
EOF

  case $SH in bash) echo '\''^D'\'' ;; esac
}

# If we force histappend, bash won'\''t overwrite the history file
histappend_test true
grep "orig" tmp > /dev/null
echo status=$?

# If we don'\''t force histappend, bash will overwrite the history file when the number of cmds exceeds HISTSIZE
histappend_test false
grep "orig" tmp > /dev/null
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

