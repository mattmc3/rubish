#!/usr/bin/env bats
# Generated from oils-for-unix spec/introspect.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 {FUNCNAME[@]} array' {
  local cmd='g() {
  argv.py "${FUNCNAME[@]}"
}
f() {
  argv.py "${FUNCNAME[@]}"
  g
  argv.py "${FUNCNAME[@]}"
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 FUNCNAME with source (scalar or array)' {
  local cmd='cd $REPO_ROOT

# Comments on bash quirk:
# https://github.com/oilshell/oil/pull/656#issuecomment-599162211

f() {
  . spec/testdata/echo-funcname.sh
}
g() {
  f
}

g
echo -----

. spec/testdata/echo-funcname.sh
echo -----

argv.py "${FUNCNAME[@]}"

# Show bash inconsistency.  FUNCNAME doesn'\''t behave like a normal array.
case $SH in 
  (bash)
    echo -----
    a=('\''A'\'')
    argv.py '\''  @'\'' "${a[@]}"
    argv.py '\''  0'\'' "${a[0]}"
    argv.py '\''${}'\'' "${a}"
    argv.py '\''  $'\'' "$a"
    ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 BASH_SOURCE and BASH_LINENO scalar or array (e.g. for virtualenv)' {
  local cmd='cd $REPO_ROOT

# https://github.com/pypa/virtualenv/blob/master/virtualenv_embedded/activate.sh
# https://github.com/akinomyoga/ble.sh/blob/6f6c2e5/ble.pp#L374

argv.py "$BASH_SOURCE"  # SimpleVarSub
argv.py "${BASH_SOURCE}"  # BracedVarSub
argv.py "$BASH_LINENO"  # SimpleVarSub
argv.py "${BASH_LINENO}"  # BracedVarSub
argv.py "$FUNCNAME"  # SimpleVarSub
argv.py "${FUNCNAME}"  # BracedVarSub
echo __
source spec/testdata/bash-source-string.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 {FUNCNAME} with prefix/suffix operators' {
  local cmd='check() {
  argv.py "${#FUNCNAME}"
  argv.py "${FUNCNAME::1}"
  argv.py "${FUNCNAME:1}"
}
check'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 operators on FUNCNAME' {
  local cmd='check() {
  argv.py "${FUNCNAME}"
  argv.py "${#FUNCNAME}"
  argv.py "${FUNCNAME::1}"
  argv.py "${FUNCNAME:1}"
}
check'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 {FUNCNAME} and set -u (OSH regression)' {
  local cmd='set -u
argv.py "$FUNCNAME"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 ((BASH_LINENO)) (scalar form in arith)' {
  local cmd='check() {
  echo $((BASH_LINENO))
}
check'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 {BASH_SOURCE[@]} with source and function name' {
  local cmd='cd $REPO_ROOT

argv.py "${BASH_SOURCE[@]}"
source spec/testdata/bash-source-simple.sh
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 {BASH_SOURCE[@]} with line numbers' {
  local cmd='cd $REPO_ROOT

$SH spec/testdata/bash-source.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 {BASH_LINENO[@]} is a stack of line numbers for function calls' {
  local cmd='# note: it'\''s CALLS, not DEFINITIONS.
g() {
  argv.py G "${BASH_LINENO[@]}"
}
f() {
  argv.py '\''begin F'\'' "${BASH_LINENO[@]}"
  g  # line 6
  argv.py '\''end F'\'' "${BASH_LINENO[@]}"
}
argv.py ${BASH_LINENO[@]}
f  # line 9'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Locations with temp frame' {
  local cmd='cd $REPO_ROOT

$SH spec/testdata/bash-source-pushtemp.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Locations when sourcing' {
  local cmd='cd $REPO_ROOT

# like above test case, but we source

# bash location doesn'\''t make sense:
# - It says '\''source'\'' happens at line 1 of bash-source-pushtemp.  Well I think
# - It really happens at line 2 of '\''-c'\'' !    I guess that'\''s to line up
#   with the '\''main'\'' frame

$SH -c '\''true;
source spec/testdata/bash-source-pushtemp.sh'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Sourcing inside function grows the debug stack' {
  local cmd='cd $REPO_ROOT

$SH spec/testdata/bash-source-source.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

