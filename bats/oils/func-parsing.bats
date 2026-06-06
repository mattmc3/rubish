#!/usr/bin/env bats
# Generated from oils-for-unix spec/func-parsing.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Unbraced function body.' {
  local cmd='# dash allows this, but bash does not.  The POSIX grammar might not allow
# this?  Because a function body needs a compound command.
# function_body    : compound_command
#                  | compound_command redirect_list  /* Apply rule 9 */'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Function with spaces, to see if ( and ) are separate tokens.' {
  local cmd='# NOTE: Newline after ( is not OK.
fun ( ) { echo in-func; }; fun'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 subshell function' {
  local cmd='# bash allows this.
i=0
j=0
inc() { i=$((i+5)); }
inc_subshell() ( j=$((j+5)); )
inc
inc_subshell
echo $i $j'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Hard case, function with } token in it' {
  local cmd='rbrace() { echo }; }; rbrace'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 . in function name' {
  local cmd='# bash accepts; dash doesn'\''t
func-name.ext ( ) { echo func-name.ext; }
func-name.ext'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 = in function name' {
  local cmd='# WOW, bash is so lenient. foo=bar is a command, I suppose.  I  think I'\''m doing
# to disallow this one.
func-name=ext ( ) { echo func-name=ext; }
func-name=ext'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Function name with ' {
  local cmd='$foo-bar() { ls ; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Function name with command sub' {
  local cmd='foo-$(echo hi)() { ls ; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Function name with !' {
  local cmd='# bash allows this; dash doesn'\''t.
foo!bar() { ls ; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Function name with -' {
  local cmd='# bash allows this; dash doesn'\''t.
foo-bar() { ls ; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Break after ) is OK.' {
  local cmd='# newline is always a token in "normal" state.
echo hi; fun ( )
{ echo in-func; }
fun'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Nested definition' {
  local cmd='# A function definition is a command, so it can be nested
fun() {
  nested_func() { echo nested; }
  nested_func
}
fun'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

