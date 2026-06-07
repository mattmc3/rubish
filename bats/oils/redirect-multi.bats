#!/usr/bin/env bats
# Generated from oils-for-unix spec/redirect-multi.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 File redirects with glob args (bash and zsh only)' {
  local cmd='touch one-bar

echo hi > one-*

cat one-bar

echo escaped > one-\*

cat one-\*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 File redirect without matching any file' {
  local cmd='echo hi > zz-*-xx
echo status=$?

echo zz*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 ysh behavior when glob doesn'\''t match' {
  skip "YSH syntax not supported"
  local cmd='shopt -s ysh:upgrade

echo hi > qq-*-zz
echo status=$?

echo qq*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 File redirect without matching any file, with failglob' {
  local cmd='shopt -s failglob

echo hi > zz-*-xx
echo status=$?

echo zz*
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Redirect to empty (in function body)' {
  local cmd='empty='\'''\''
fun() { echo hi; } > $empty
fun
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Redirect to '\'''\''' {
  local cmd='echo hi > '\'''\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 File redirect to var with glob char' {
  local cmd='touch two-bar

star='\''*'\''

# This gets glob-expanded, as it does outside redirects
echo hi > two-$star
echo status=$?

head two-bar two-\*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 File redirect that globs to more than one file (bash and zsh only)' {
  local cmd='touch foo-bar
touch foo-spam

echo hi > foo-*
echo status=$?

head foo-bar foo-spam'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 File redirect with extended glob' {
  local cmd='shopt -s extglob

touch foo-bar

echo hi > @(*-bar|other)
echo status=$?

cat foo-bar'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Extended glob that doesn'\''t match anything' {
  skip 'YSH-only mode (shopt -s ysh:); not bash-applicable'
  local cmd='shopt -s extglob
rm bad_*

# They actually write this literal file!  This is what EvalWordToString() does,
# as opposed to _EvalWordToParts.
echo foo > bad_@(*.cc|*.h)
echo status=$?

echo bad_*

shopt -s failglob

# Note: ysh:ugprade doesn'\''t allow extended globs
# shopt -s ysh:upgrade

echo foo > bad_@(*.cc|*.h)
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Non-file redirects don'\''t respect glob args (we differe from bash)' {
  local cmd='touch 10

exec 10>&1  # open stdout as descriptor 10

# Does this go to stdout?  ONLY bash respects it, not zsh
echo should-not-be-on-stdout >& 1*

echo stdout
echo stderr >&2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Redirect with brace expansion isn'\''t allowed' {
  local cmd='echo hi > a-{one,two}
echo status=$?

head a-*
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 File redirects have word splitting too!' {
  local cmd='file='\''foo bar'\''

echo hi > $file
echo status=$?

cat "$file"
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

