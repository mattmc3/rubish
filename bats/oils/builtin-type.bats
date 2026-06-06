#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-type.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 type -> keyword builtin' {
  local cmd='type while cd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 type -> alias external' {
  local cmd='mkdir -p _tmp
shopt -s expand_aliases || true  # bash

alias ll='\''ls -l'\''

touch _tmp/date
chmod +x _tmp/date
PATH=_tmp:/bin

normalize() {
  # ignore quotes and backticks
  # bash prints a left backtick
  quotes='\''"`'\''\'\''
  sed \
    -e "s/[$quotes]//g" \
    -e '\''s/shell function/function/'\'' \
    -e '\''s/is aliased to/is an alias for/'\''
}

type ll date | normalize

# Note: both procs and funcs go in var namespace?  So they don'\''t respond to
# '\''type'\''?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 type of relative path' {
  local cmd='mkdir -p _tmp
touch _tmp/file _tmp/ex
chmod +x _tmp/ex

type _tmp/file _tmp/ex

# dash and ash don'\''t care if it'\''s executable
# mksh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 type -> not found' {
  local cmd='type zz 2>err.txt
echo status=$?

# for bash and OSH: print to stderr
fgrep -o '\''zz: not found'\'' err.txt || true

# zsh and mksh behave the same - status 1
# dash and ash behave the same - status 127'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 special builtins are called out' {
  local cmd='type cd
type eval
type :
type true

echo
type export'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 more special builtins' {
  local cmd='case $SH in bash|zsh|dash) exit ;; esac

type .
type source

# no agreement here!
# type local
# type typeset'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

