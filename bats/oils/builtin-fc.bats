#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-fc.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 fc -l lists history commands' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 fc -ln lists history commands without numbers' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -ln
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 fc -lr lists history commands in reverse order' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -lr
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 fc -lnr lists history commands without numbers in reverse order' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -lnr
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 fc -l lists history commands with default page size' {
  local cmd='printf "echo %s\n" {1..16} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 fc -l [first] where first is an index' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l 2
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 fc -l [first] where first is an offset from current command' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l -3
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 fc -l [first] [last] where first and last are indexes' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l 2 3
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 fc -l [first] [last] where first and last are offsets from current command' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l -3 -2
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 fc -l [first] [last] where first and last are reversed indexes' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -l 3 2
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 fc -lr [first] [last] where first and last are reversed indexes does not undo reverse' {
  local cmd='printf "echo %s\n" {1..3} > tmp

echo '\''
HISTFILE=tmp
history -c
history -r

fc -lr 3 2
'\'' | $SH --norc -i

# match osh'\''s behaviour of echoing ^D for EOF
case $SH in bash) echo '\''^D'\'' ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 fc ignores too many args' {
  local cmd='fc -l 0 1 2 || echo too many args!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 fc errors out on too many args with strict_arg_parse' {
  local cmd='shopt -s strict_arg_parse || true
fc -l 0 1 2 || echo too many args!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 fc -l when no history is present' {
  local cmd='fc -l'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

