#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-meta.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 command -v' {
  local cmd='myfunc() { echo x; }
command -v echo
echo $?

command -v myfunc
echo $?

command -v nonexistent  # doesn'\''t print anything
echo nonexistent=$?

command -v '\'''\''  # BUG FIX, shouldn'\''t succeed
echo empty=$?

command -v for
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 command -v executable, builtin' {
  local cmd='#command -v grep ls

command -v grep | egrep -o '\''/[^/]+$'\''
command -v ls | egrep -o '\''/[^/]+$'\''
echo

command -v true
command -v eval'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 command -v with multiple names' {
  local cmd='# ALL FOUR SHELLS behave differently here!
#
# bash chooses to swallow the error!  We agree with zsh if ANY word lookup
# fails, then the whole thing fails.

myfunc() { echo x; }
command -v echo myfunc ZZZ for
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 command -v doesn'\''t find non-executable file' {
  local cmd='# PATH resolution is different

mkdir -p _tmp
PATH="_tmp:$PATH"
touch _tmp/non-executable _tmp/executable
chmod +x _tmp/executable

command -v _tmp/non-executable
echo status=$?

command -v _tmp/executable
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 command -v doesn'\''t find executable dir' {
  local cmd='mkdir -p _tmp
PATH="_tmp:$PATH"
mkdir _tmp/cat

command -v _tmp/cat
echo status=$?
command -v cat
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 command -V' {
  local cmd='myfunc() { echo x; }

shopt -s expand_aliases
alias ll='\''ls -l'\''

backtick=\`
command -V ll | sed "s/$backtick/'\''/g"
echo status=$?

command -V echo
echo status=$?

# Paper over insignificant difference
command -V myfunc | sed '\''s/shell function/function/'\''
echo status=$?

command -V nonexistent  # doesn'\''t print anything
echo status=$?

command -V for
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 command -V nonexistent' {
  local cmd='command -V nonexistent 2>err.txt
echo status=$?
fgrep -o '\''nonexistent: not found'\'' err.txt || true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 command skips function lookup' {
  local cmd='seq() {
  echo "$@"
}
command  # no-op
seq 3
command seq 3
# subshell shouldn'\''t fork another process (but we don'\''t have a good way of
# testing it)
( command seq 3 )'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 command command seq 3' {
  local cmd='command command seq 3'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 command command -v seq' {
  local cmd='seq() {
  echo 3
}
command command -v seq'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 command -p (override existing program)' {
  local cmd='# Tests whether command -p overrides the path
# tr chosen because we need a simple non-builtin
mkdir -p $TMP/bin
echo "echo wrong" > $TMP/bin/tr
chmod +x $TMP/bin/tr
PATH="$TMP/bin:$PATH"
echo aaa | tr "a" "b"
echo aaa | command -p tr "a" "b"
rm $TMP/bin/tr'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 command -p (hide tool in custom path)' {
  local cmd='mkdir -p $TMP/bin
echo "echo hello" > $TMP/bin/hello
chmod +x $TMP/bin/hello
export PATH=$TMP/bin
command -p hello'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 command -p (find hidden tool in default path)' {
  local cmd='export PATH='\'''\''
command -p ls'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 (command type ls)' {
  local cmd='type() { echo FUNCTION; }
type
s=$(command type echo)
echo $s | grep builtin > /dev/null
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 builtin' {
  local cmd='cd () { echo "hi"; }
cd
builtin cd / && pwd
unset -f cd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 builtin ls not found' {
  local cmd='builtin ls'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 builtin usage' {
  local cmd='builtin
echo status=$?

builtin --
echo status=$?

builtin -- false
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 builtin command echo hi' {
  local cmd='builtin command echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

