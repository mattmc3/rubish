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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 File redirect without matching any file' {
  local cmd='echo hi > zz-*-xx
echo status=$?

echo zz*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 ysh behavior when glob doesn'\''t match' {
  local cmd='shopt -s ysh:upgrade

echo hi > qq-*-zz
echo status=$?

echo qq*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 File redirect without matching any file, with failglob' {
  local cmd='shopt -s failglob

echo hi > zz-*-xx
echo status=$?

echo zz*
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Redirect to empty (in function body)' {
  local cmd='empty='\'''\''
fun() { echo hi; } > $empty
fun
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Redirect to '\'''\''' {
  local cmd='echo hi > '\'''\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 File redirect to var with glob char' {
  local cmd='touch two-bar

star='\''*'\''

# This gets glob-expanded, as it does outside redirects
echo hi > two-$star
echo status=$?

head two-bar two-\*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 File redirect that globs to more than one file (bash and zsh only)' {
  local cmd='touch foo-bar
touch foo-spam

echo hi > foo-*
echo status=$?

head foo-bar foo-spam'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 File redirect with extended glob' {
  local cmd='shopt -s extglob

touch foo-bar

echo hi > @(*-bar|other)
echo status=$?

cat foo-bar'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Extended glob that doesn'\''t match anything' {
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Non-file redirects don'\''t respect glob args (we differe from bash)' {
  local cmd='touch 10

exec 10>&1  # open stdout as descriptor 10

# Does this go to stdout?  ONLY bash respects it, not zsh
echo should-not-be-on-stdout >& 1*

echo stdout
echo stderr >&2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Redirect with brace expansion isn'\''t allowed' {
  local cmd='echo hi > a-{one,two}
echo status=$?

head a-*
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 File redirects have word splitting too!' {
  local cmd='file='\''foo bar'\''

echo hi > $file
echo status=$?

cat "$file"
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

