#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-eval-source.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Eval' {
  local cmd='eval "a=3"
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 eval accepts/ignores --' {
  local cmd='eval -- echo hi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 eval usage' {
  local cmd='eval -
echo $?
eval -z
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 eval string with '\''break continue return error'\''' {
  local cmd='set -e

sh_func_that_evals() {
  local code_str=$1
  for i in 1 2; do
    echo $i
    eval "$code_str"
  done
  echo '\''end func'\''
}

for code_str in break continue return false; do
  echo "--- $code_str"
  sh_func_that_evals "$code_str"
done
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 eval YSH block with '\''break continue return error'\''' {
  skip "YSH syntax not supported"
  local cmd='shopt -s ysh:all

proc proc_that_evals(; ; ;b) {
  for i in 1 2; do
    echo $i
    call io->eval(b)
  done
  echo '\''end func'\''
}

var cases = [
  ['\''break'\'', ^(break)],
  ['\''continue'\'', ^(continue)],
  ['\''return'\'', ^(return)],
  ['\''false'\'', ^(false)],
]

for test_case in (cases) {
  var code_str, block = test_case
  echo "--- $code_str"
  proc_that_evals (; ; block)
}
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 exit within eval (regression)' {
  local cmd='eval '\''exit 42'\''
echo '\''should not get here'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 exit within source (regression)' {
  local cmd='cd $TMP
echo '\''exit 42'\'' > lib.sh
. ./lib.sh
echo '\''should not get here'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Source' {
  local cmd='lib=$TMP/spec-test-lib.sh
echo '\''LIBVAR=libvar'\'' > $lib
. $lib  # dash doesn'\''t have source
echo $LIBVAR'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 source accepts/ignores --' {
  local cmd='echo '\''echo foo'\'' > $TMP/foo.sh
source -- $TMP/foo.sh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Source nonexistent' {
  local cmd='source /nonexistent/path
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Source with no arguments' {
  local cmd='source
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Source with arguments' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='. $REPO_ROOT/spec/testdata/show-argv.sh foo bar  # dash doesn'\''t have source'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Source from a function, mutating argv and defining a local var' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='f() {
  . $REPO_ROOT/spec/testdata/source-argv.sh              # no argv
  . $REPO_ROOT/spec/testdata/source-argv.sh args to src  # new argv
  echo $@
  echo foo=$foo  # defined in source-argv.sh
}
f args to func
echo foo=$foo  # not defined'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Source with syntax error' {
  local cmd='# TODO: We should probably use dash behavior of a fatal error.
# Although set-o errexit handles this.  We don'\''t want to break the invariant
# that a builtin like '\''source'\'' behaves like an external program.  An external
# program can'\''t halt the shell!
echo '\''echo >'\'' > $TMP/syntax-error.sh
. $TMP/syntax-error.sh
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Eval with syntax error' {
  local cmd='eval '\''echo >'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Eval in does tilde expansion' {
  local cmd='x="~"
eval y="$x"  # scalar
test "$x" = "$y" || echo FALSE
[[ $x == /* ]] || echo FALSE  # doesn'\''t start with /
[[ $y == /* ]] && echo TRUE

#argv "$x" "$y"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 Eval in bash does tilde expansion in array' {
  local cmd='# the "make" plugin in bash-completion relies on this?  wtf?
x="~"

# UPSTREAM CODE

#eval array=( "$x" )

# FIXED CODE -- proper quoting.

eval '\''array=('\'' "$x" '\'')'\''  # array

test "$x" = "${array[0]}" || echo FALSE
[[ $x == /* ]] || echo FALSE  # doesn'\''t start with /
[[ "${array[0]}" == /* ]] && echo TRUE'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 source works for files in current directory (bash only)' {
  local cmd='cd $TMP
echo "echo current dir" > cmd
. cmd
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 source looks in PATH for files' {
  local cmd='mkdir -p dir
echo "echo hi" > dir/cmd
PATH="dir:$PATH"
. cmd
rm dir/cmd'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 source finds files in PATH before current dir' {
  local cmd='cd $TMP
mkdir -p dir
echo "echo path" > dir/cmd
echo "echo current dir" > cmd
PATH="dir:$PATH"
. cmd
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 source works for files in subdirectory' {
  local cmd='mkdir -p dir
echo "echo path" > dir/cmd
. dir/cmd
rm dir/cmd'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 source doesn'\''t crash when targeting a directory' {
  local cmd='cd $TMP
mkdir -p dir
. ./dir/
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 sourcing along PATH should ignore directories' {
  local cmd='mkdir -p _tmp/shell
mkdir -p _tmp/dir/hello.sh
printf '\''echo hi'\'' >_tmp/shell/hello.sh

DIR=$PWD/_tmp/dir
SHELL=$PWD/_tmp/shell

# Should find the file hello.sh right away and source it
PATH="$SHELL:$PATH" . hello.sh
echo status=$?

# Should fail because hello.sh cannot be found
PATH="$DIR:$SHELL:$PATH" . hello.sh
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

