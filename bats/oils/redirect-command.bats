#!/usr/bin/env bats
# Generated from oils-for-unix spec/redirect-command.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 >file touches a file' {
  local cmd='rm -f myfile
test -f myfile
echo status=$?

>myfile
test -f myfile
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 (< file) yields the contents of the file' {
  local cmd='seq 2 3 > myfile
foo=$(< myfile)
argv.py "$foo"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 < file behaves like (< file)' {
  local cmd='seq 7 8 > myfile

x=`< myfile`

echo "[$x]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 (< file; end) is not a special case' {
  local cmd='seq 5 6 > myfile

# zsh prints the file each time!
# other shells do nothing?

foo=$(echo begin; < myfile)
echo $foo
echo ---

foo=$(< myfile; echo end)
echo $foo
echo ---

foo=$(< myfile; <myfile)
echo $foo
echo ---'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 < file in pipeline and subshell doesn'\''t work' {
  local cmd='echo FOO > file2

# This only happens in command subs, which is weird
< file2 | tr A-Z a-z
( < file2 )
echo end'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Leading redirect in a simple command' {
  local cmd='echo hello >$TMP/hello.txt  # temporary fix
<$TMP/hello.txt cat'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Redirect in the middle of a simple command' {
  local cmd='f=$TMP/out
echo -n 1 2 '\''3 '\'' > $f
echo -n 4 5 >> $f '\''6 '\''
echo -n 7 >> $f 8 '\''9 '\''
echo -n >> $f 1 2 '\''3 '\''
echo >> $f -n 4 5 '\''6'\''

cat $f
echo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Redirect in command sub' {
  local cmd='FOO=$(echo foo 1>&2)
echo $FOO'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Redirect in the middle of two assignments' {
  local cmd='FOO=foo >$TMP/out.txt BAR=bar printenv.py FOO BAR
tac $TMP/out.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Redirect in assignment' {
  local cmd='# dash captures stderr to a file here, which seems correct.  Bash doesn'\''t and
# just lets it go to actual stderr.
# For now we agree with dash/mksh, since it involves fewer special cases in the
# code.

FOO=$(echo foo 1>&2) 2>$TMP/no-command.txt
echo FILE=
cat $TMP/no-command.txt
echo "FOO=$FOO"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Redirect in function body' {
  local cmd='fun() { echo hi; } 1>&2
fun'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Redirect in function body is evaluated multiple times' {
  local cmd='i=0
fun() { echo "file $i"; } 1> "$TMP/file$((i++))"
fun
fun
echo i=$i
echo __
cat $TMP/file0
echo __
cat $TMP/file1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Redirect in function body AND function call' {
  local cmd='fun() { echo hi; } 1>&2
fun 2>&1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 redirect bash extensions:   [[  ((  for ((' {
  local cmd='rm -f dbracket dparen for-expr

[[ x = x ]] > dbracket

(( 42 )) > dparen

for ((x = 0; x < 1; ++x)); do
  echo for-expr
done > for-expr

wc -l dbracket dparen for-expr'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 redirect if' {
  local cmd='if true; then
  echo if-body
fi >out

cat out'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 redirect case' {
  local cmd='case foo in
  foo)
    echo case-body
    ;;
esac > out

cat out'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 redirect while' {
  local cmd='while true; do
  echo while-body
  break
done > out

cat out'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 redirect for loop' {
  local cmd='for i in $(seq 3)
do
  echo $i
done > $TMP/redirect-for-loop.txt
cat $TMP/redirect-for-loop.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 redirect subshell' {
  local cmd='( echo foo ) 1>&2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Prefix redirect for loop -- not allowed' {
  local cmd='>$TMP/redirect2.txt for i in $(seq 3)
do
  echo $i
done
cat $TMP/redirect2.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Brace group redirect' {
  local cmd='# Suffix works, but prefix does NOT work.
# That comes from '\''| compound_command redirect_list'\'' in the grammar!
{ echo block-redirect; } > $TMP/br.txt
cat $TMP/br.txt | wc -c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 Redirect function stdout' {
  local cmd='f() { echo one; echo two; }
f > $TMP/redirect-func.txt
cat $TMP/redirect-func.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 Nested function stdout redirect' {
  local cmd='# Shows that a stack is necessary.
inner() {
  echo i1
  echo i2
}
outer() {
  echo o1
  inner > $TMP/inner.txt
  echo o2
}
outer > $TMP/outer.txt
cat $TMP/inner.txt
echo --
cat $TMP/outer.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

