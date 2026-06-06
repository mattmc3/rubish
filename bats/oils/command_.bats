#!/usr/bin/env bats
# Generated from oils-for-unix spec/command_.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Command block' {
  local cmd='PATH=/bin

{ which ls; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Permission denied' {
  local cmd='touch $TMP/text-file
$TMP/text-file'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Not a dir' {
  local cmd='$TMP/not-a-dir/text-file'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Name too long' {
  local cmd='./0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 External programs don'\''t have _OVM in environment' {
  local cmd='# bug fix for leakage
env | grep _OVM
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 File with no shebang is executed' {
  local cmd='# most shells execute /bin/sh; bash may execute itself
echo '\''echo hi'\'' > $TMP/no-shebang
chmod +x $TMP/no-shebang
$SH -c '\''$TMP/no-shebang'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 File with relative path and no shebang is executed' {
  local cmd='cd $TMP
echo '\''echo hi'\'' > no-shebang
chmod +x no-shebang
"$SH" -c '\''./no-shebang'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 File in relative subdirectory and no shebang is executed' {
  local cmd='cd $TMP
mkdir -p test-no-shebang
echo '\''echo hi'\'' > test-no-shebang/script
chmod +x test-no-shebang/script
"$SH" -c '\''test-no-shebang/script'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 PATH lookup' {
  local cmd='cd $TMP
mkdir -p one two
echo '\''echo one'\'' > one/mycmd
echo '\''echo two'\'' > two/mycmd
chmod +x one/mycmd two/mycmd

PATH='\''one:two'\''
mycmd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 filling PATH cache, then insert the same command earlier in cache' {
  local cmd='cd $TMP
PATH="one:two:$PATH"
mkdir -p one two
rm -f one/* two/*
echo '\''echo two'\'' > two/mycmd
chmod +x two/mycmd
mycmd

# Insert earlier in the path
echo '\''echo one'\'' > one/mycmd
chmod +x one/mycmd
mycmd  # still runs the cached '\''two'\''

# clear the cache
hash -r
mycmd  # now it runs the new '\''one'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 filling PATH cache, then deleting command' {
  local cmd='cd $TMP
PATH="one:two:$PATH"
mkdir -p one two
rm -f one/mycmd two/mycmd

echo '\''echo two'\'' > two/mycmd
chmod +x two/mycmd
mycmd
echo status=$?

# Insert earlier in the path
echo '\''echo one'\'' > one/mycmd
chmod +x one/mycmd
rm two/mycmd
mycmd  # still runs the cached '\''two'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Non-executable on PATH' {
  local cmd='# shells differ in whether they actually execve('\''one/cmd'\'') and get EPERM

mkdir -p one two
PATH="one:two:$PATH"

rm -f one/mycmd two/mycmd
echo '\''echo one'\'' > one/mycmd
echo '\''echo two'\'' > two/mycmd

# only make the second one executable
chmod +x two/mycmd
mycmd
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 hash without args prints the cache' {
  local cmd='whoami >/dev/null
hash
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 hash with args' {
  local cmd='hash whoami
echo status=$?
hash | grep -o /whoami  # prints it twice
hash _nonexistent_
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 hash -r doesn'\''t allow additional args' {
  local cmd='hash -r whoami >/dev/null  # avoid weird output with mksh
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Executing command with same name as directory in PATH (#2429)' {
  local cmd='# Make the following directory structure. File type and permission bits are
# given on the left.
# [drwxr-xr-x]  _tmp
# +-- [drwxr-xr-x]  bin
# |   \-- [-rwxr-xr-x]  hello
# +-- [drwxr-xr-x]  notbin
# |   \-- [-rw-r--r--]  hello
# \-- [drwxr-xr-x]  dir
#     \-- [drwxr-xr-x]  hello
mkdir -p _tmp/bin
mkdir -p _tmp/bin2
mkdir -p _tmp/notbin
mkdir -p _tmp/dir/hello
printf '\''#!/usr/bin/env sh\necho hi\n'\'' >_tmp/notbin/hello
printf '\''#!/usr/bin/env sh\necho hi\n'\'' >_tmp/bin/hello
chmod +x _tmp/bin/hello

DIR=$PWD/_tmp/dir
BIN=$PWD/_tmp/bin
NOTBIN=$PWD/_tmp/notbin

# The command resolution will search the path for matching *files* (not
# directories) WITH the execute bit set.

# Should find executable hello right away and run it
PATH="$BIN:$PATH" hello
echo status=$?

hash -r  # Needed to clear the PATH cache

# Will see hello dir, skip it and then find&run the hello exe
PATH="$DIR:$BIN:$PATH" hello
echo status=$?

hash -r  # Needed to clear the PATH cache

# Will see hello (non-executable) file, skip it and then find&run the hello exe
PATH="$NOTBIN:$BIN:$PATH" hello
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

