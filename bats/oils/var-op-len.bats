#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-op-len.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 String length' {
  local cmd='v=foo
echo ${#v}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Unicode string length (UTF-8)' {
  local cmd='v=$'\''_\u03bc_'\''
echo ${#v}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Unicode string length (spec/testdata/utf8-chars.txt)' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='v=$(cat $REPO_ROOT/spec/testdata/utf8-chars.txt)
echo ${#v}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 String length with incomplete utf-8' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='for num_bytes in 0 1 2 3 4 5 6 7 8 9 10 11 12 13; do
  s=$(head -c $num_bytes $REPO_ROOT/spec/testdata/utf8-chars.txt)
  echo ${#s}
done 2> $TMP/err.txt

grep '\''warning:'\'' $TMP/err.txt
true  # exit 0'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 String length with invalid utf-8 continuation bytes' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='for num_bytes in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
  s=$(head -c $num_bytes $REPO_ROOT/spec/testdata/utf8-chars.txt)$(echo -e "\xFF")
  echo ${#s}
done 2> $TMP/err.txt

grep '\''warning:'\'' $TMP/err.txt
true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Length of undefined variable' {
  local cmd='echo ${#undef}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Length of undefined variable with nounset' {
  local cmd='set -o nounset
echo ${#undef}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Length operator can'\''t be followed by test operator' {
  local cmd='echo ${#x-default}

x='\'''\''
echo ${#x-default}

x='\''foo'\''
echo ${#x-default}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 {#s} respects LC_ALL - length in bytes or code points' {
  local cmd='# This test case is sorta "infected" because spec-common.sh sets LC_ALL=C.UTF-8
#
# For some reason mksh behaves differently
#
# See demo/04-unicode.sh

#echo $LC_ALL
unset LC_ALL 

# note: this may depend on the CI machine config
LANG=en_US.UTF-8

#LC_ALL=en_US.UTF-8

for s in $'\''\u03bc'\'' $'\''\U00010000'\''; do
  LC_ALL=
  echo "len=${#s}"

  LC_ALL=C
  echo "len=${#s}"

  echo
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

