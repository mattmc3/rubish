#!/usr/bin/env bats
# Generated from oils-for-unix spec/command-sub.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 case' {
  local cmd='foo=a; case $foo in [0-9]) echo number;; [a-z]) echo letter ;; esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 case in subshell' {
  local cmd='# Hm this subhell has to know about the closing ) and stuff like that.
# case_clause is a compound_command, which is a command.  And a subshell
# takes a compound_list, which is a list of terms, which has and_ors in them
# ... which eventually boils down to a command.
echo $(foo=a; case $foo in [0-9]) echo number;; [a-z]) echo letter ;; esac)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Command sub word part' {
  local cmd='# "The token shall not be delimited by the end of the substitution."
foo=FOO; echo $(echo $foo)bar$(echo $foo)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Backtick' {
  local cmd='foo=FOO; echo `echo $foo`bar`echo $foo`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Backtick 2' {
  local cmd='echo `echo -n l; echo -n s`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Nested backticks' {
  local cmd='# Inner `` are escaped!  Not sure how to do triple..  Seems like an unlikely
# use case.  Not sure if I even want to support this!
echo X > $TMP/000000-first
echo `\`echo -n l; echo -n s\` $TMP | grep 000000-first`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Making command out of command sub should work' {
  local cmd='# Works in bash and dash!
$(echo ec)$(echo ho) split builtin'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Making keyword out of command sub should NOT work' {
  local cmd='$(echo f)$(echo or) i in a b c; do echo $i; done
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Command sub with here doc' {
  local cmd='echo $(<<EOF tac
one
two
EOF
)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Here doc with pipeline' {
  local cmd='<<EOF tac | tr '\''\n'\'' '\''X'\''
one
two
EOF'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Command Sub word split' {
  local cmd='argv.py $(echo '\''hi there'\'') "$(echo '\''hi there'\'')"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Command Sub trailing newline removed' {
  local cmd='s=$(python2 -c '\''print("ab\ncd\n")'\'')
argv.py "$s"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Command Sub trailing whitespace not removed' {
  local cmd='s=$(python2 -c '\''print("ab\ncd\n ")'\'')
argv.py "$s"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Command Sub and exit code' {
  local cmd='# A command resets the exit code, but an assignment doesn'\''t.
echo $(echo x; exit 33)
echo $?
x=$(echo x; exit 33)
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Command Sub in local sets exit code' {
  local cmd='# A command resets the exit code, but an assignment doesn'\''t.
f() {
  echo $(echo x; exit 33)
  echo $?
  local x=$(echo x; exit 33)
  echo $?
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Double Quotes in Command Sub in Double Quotes' {
  local cmd='# virtualenv'\''s bin/activate uses this.
# This is weird!  Double quotes within `` is different than double quotes
# within $()!  All shells agree.
# I think this is related to the nested backticks case!
echo "x $(echo hi)"
echo "x $(echo "hi")"
echo "x $(echo \"hi\")"
echo "x `echo hi`"
echo "x `echo "hi"`"
echo "x `echo \"hi\"`"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 Escaped quote in [[ ]]' {
  local cmd='file=$TMP/command-sub-dbracket
#rm -f $file
echo "123 `[[ $(echo \\" > $file) ]]` 456";
cat $file'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 Quoting  within ' {
  local cmd='echo 1 `echo \"`
#echo 2 `echo \\"`
#echo 3 `echo \\\"`
#echo 4 `echo \\\\"`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 Quoting  within ' {
  local cmd='echo 1 `echo $`
echo 2 `echo \$`
echo 3 `echo \\$`
echo 4 `echo \\\$`
echo 5 `echo \\\\$`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Quoting  within  within double quotes' {
  local cmd='echo "1 `echo $`"
echo "2 `echo \$`"
echo "3 `echo \\$`"
echo "4 `echo \\\$`"
echo "5 `echo \\\\$`"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Quoting  within ' {
  local cmd='# You need FOUR backslashes to make a literal \.
echo [1 `echo \ `]
echo [2 `echo \\ `]
echo [3 `echo \\\\ `]'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 Quoting  within  within double quotes' {
  local cmd='echo "[1 `echo \ `]"
echo "[2 `echo \\ `]"
echo "[3 `echo \\\\ `]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 Quoting ( within ' {
  local cmd='echo 1 `echo \(`
echo 2 `echo \\(`
echo 3 `echo \\ \\(`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 Quoting ( within  within double quotes' {
  local cmd='echo "1 `echo \(`"
echo "2 `echo \\(`"
echo "3 `echo \\ \\(`"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 Quoting non-special characters within ' {
  local cmd='echo [1 `echo \z]`
echo [2 `echo \\z]`
echo [3 `echo \\\z]`
echo [4 `echo \\\\z]`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 Quoting non-special characters within  within double quotes' {
  local cmd='echo "[1 `echo \z`]"
echo "[2 `echo \\z`]"
echo "[3 `echo \\\z`]"
echo "[4 `echo \\\\z`]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 Quoting double quotes within backticks' {
  local cmd='echo \"foo\"   # for comparison
echo `echo \"foo\"`
echo `echo \\"foo\\"`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 More levels of double quotes in backticks' {
  local cmd='# Shells don'\''t agree here, some of them give you form feeds!
# There are two levels of processing I don'\''t understand.

#echo BUG
#exit

echo `echo \\\"foo\\\"` -
echo `echo \\\\"foo\\\\"` -
echo `echo \\\\\"foo\\\\\"` -'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 Syntax errors with double quotes within backticks' {
  local cmd='# bash does print syntax errors but somehow it exits 0

$SH -c '\''echo `echo "`'\''
echo status=$?
$SH -c '\''echo `echo \\\\"`'\''
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 Empty command sub () (command::NoOp)' {
  local cmd='# IMPORTANT: catch assert() failure in child process!!!
shopt -s command_sub_errexit

echo -$()- ".$()."'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

