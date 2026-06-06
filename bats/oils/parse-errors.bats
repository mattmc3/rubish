#!/usr/bin/env bats
# Generated from oils-for-unix spec/parse-errors.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Long Token - 65535 bytes' {
  local cmd='python2 -c '\''print("echo -n %s" % ("x" * 65535))'\'' > tmp.sh
$SH tmp.sh > out
wc --bytes out'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Token that'\''s too long for Oils - 65536 bytes' {
  local cmd='python2 -c '\''print("echo -n %s" % ("x" * 65536))'\'' > tmp.sh
$SH tmp.sh > out
echo status=$?
wc --bytes out'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 % is not a parse error' {
  local cmd='echo $%'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Bad braced var sub -- not allowed' {
  local cmd='echo ${%}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Bad var sub caught at parse time' {
  local cmd='if test -f /; then
  echo ${%}
else
  echo ok
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Incomplete while' {
  local cmd='echo hi; while
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Incomplete for' {
  local cmd='echo hi; for
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Incomplete if' {
  local cmd='echo hi; if
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 do unexpected' {
  local cmd='do echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 } is a parse error' {
  local cmd='}
echo should not get here'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 { is its own word, needs a space' {
  local cmd='# bash and mksh give parse time error because of }
# dash gives 127 as runtime error
{ls; }
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 } on the second line' {
  local cmd='set -o errexit
{ls;
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Invalid for loop variable name' {
  local cmd='for i.j in a b c; do
  echo hi
done
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 bad var name globally isn'\''t parsed like an assignment' {
  local cmd='# bash and dash disagree on exit code.
FOO-BAR=foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 bad var name in export' {
  local cmd='# bash and dash disagree on exit code.
export FOO-BAR=foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 bad var name in local' {
  local cmd='# bash and dash disagree on exit code.
f() {
  local FOO-BAR=foo
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 misplaced parentheses are not a subshell' {
  local cmd='echo a(b)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 incomplete command sub' {
  local cmd='$(x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 incomplete backticks' {
  local cmd='`x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 misplaced ;;' {
  local cmd='echo 1 ;; echo 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 empty clause in [[' {
  local cmd='# regression test for commit 451ca9e2b437e0326fc8155783d970a6f32729d8
[[ || true ]]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 interactive parse error (regression)' {
  local cmd='flags='\'''\''
case $SH in
  bash*|*osh)
    flags='\''--rcfile /dev/null'\''
    ;;
esac  
$SH $flags -i -c '\''var=)'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 array literal inside array is a parse error' {
  local cmd='a=( inside=() )
echo len=${#a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 array literal inside loop is a parse error' {
  local cmd='f() {
  for x in a=(); do
    echo x=$x
  done
  echo done
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 array literal in case' {
  local cmd='f() {
  case a=() in
    foo)
      echo hi
      ;;
  esac
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 %foo=() is parse error (regression)' {
  local cmd='# Lit_VarLike and then (, but NOT at the beginning of a word.

f() {
  %foo=()
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 echo =word is allowed' {
  local cmd='echo =word'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

