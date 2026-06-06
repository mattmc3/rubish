#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-type-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 type -t -> function' {
  local cmd='f() { echo hi; }
type -t f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 type -t -> alias' {
  local cmd='shopt -s expand_aliases
alias foo=bar
type -t foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 type -t -> builtin' {
  local cmd='type -t echo read : [ declare local'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 type -t -> keyword' {
  local cmd='type -t for time ! fi do {'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 type -t control flow' {
  local cmd='type -t break continue return exit'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 type -t -> file' {
  local cmd='type -t find xargs'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 type -t doesn'\''t find non-executable (like command -v)' {
  local cmd='PATH="$TMP:$PATH"
touch $TMP/non-executable
type -t non-executable'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 type -t -> not found' {
  local cmd='type -t echo ZZZ find ==
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 type -p and -P builtin -> file' {
  local cmd='touch /tmp/{mv,tar,grep}
chmod +x /tmp/{mv,tar,grep}
PATH=/tmp:$PATH

type -p mv tar grep
echo --
type -P mv tar grep'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 type -a -P gives multiple files' {
  local cmd='touch _tmp/pwd
chmod +x _tmp/pwd
PATH="_tmp:/bin"

type -a -P pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 type -p builtin -> not found' {
  local cmd='type -p FOO BAR NOT_FOUND'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 type -p builtin -> not a file' {
  local cmd='type -p cd type builtin command'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 type -P builtin -> not found' {
  local cmd='type -P FOO BAR NOT_FOUND'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 type -P builtin -> not a file' {
  local cmd='type -P cd type builtin command'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 type -P builtin -> not a file but file found' {
  local cmd='touch _tmp/{mv,tar,grep}
chmod +x _tmp/{mv,tar,grep}
PATH=_tmp:$PATH

mv () { ls; }
tar () { ls; }
grep () { ls; }
type -P mv tar grep cd builtin command type'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 type -f builtin -> not found' {
  local cmd='type -f FOO BAR NOT FOUND'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 type -f builtin -> function and file exists' {
  local cmd='touch /tmp/{mv,tar,grep}
chmod +x /tmp/{mv,tar,grep}
PATH=/tmp:$PATH

mv () { ls; }
tar () { ls; }
grep () { ls; }
type -f mv tar grep'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 type prints function source code' {
  local cmd='f () { echo; }
type -a f
echo

type f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 type -ap -> function' {
  local cmd='f () { :; }
type -ap f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 type -a -> alias; prints alias definition' {
  local cmd='shopt -s expand_aliases
alias ll="ls -lha"
type -a ll'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 type -ap -> alias' {
  local cmd='shopt -s expand_aliases
alias ll="ls -lha"
type -ap ll'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 type -a -> builtin' {
  local cmd='type -a cd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 type -ap -> builtin' {
  local cmd='type -ap cd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 type -a -> keyword' {
  local cmd='type -a while'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 type -a -> file' {
  local cmd='touch _tmp/date
chmod +x _tmp/date
PATH=/bin:_tmp  # control output

type -a date'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 type -ap -> file; abbreviated' {
  local cmd='touch _tmp/date
chmod +x _tmp/date
PATH=/bin:_tmp  # control output

type -ap date'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 type -a -> builtin and file' {
  local cmd='touch _tmp/pwd
chmod +x _tmp/pwd
PATH=/bin:_tmp  # control output

type -a pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 type -a -> builtin and file and shell function' {
  local cmd='touch _tmp/pwd
chmod +x _tmp/pwd
PATH=/bin:_tmp  # control output

type -a pwd
echo ---

pwd () 
{ 
    echo function-too
}

osh-normalize() {
  sed '\''s/shell function/function/'\''
}

type -a pwd | osh-normalize
echo ---

type -a -f pwd | osh-normalize'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 type -ap -> builtin and file; doesn'\''t print builtin or function' {
  local cmd='touch _tmp/pwd
chmod +x _tmp/pwd
PATH=/bin:_tmp  # control output

# Function is also ignored
pwd() { echo function-too; }

type -ap pwd
echo ---

type -p pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 type -a -> executable not in PATH' {
  local cmd='touch _tmp/executable
chmod +x _tmp/executable
type -a executable'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 type -P does not find directories (regression)' {
  local cmd='mkdir -p _tmp
PATH="_tmp:$PATH"
mkdir _tmp/cat

type -P _tmp/cat
echo status=$?
type -P cat
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

