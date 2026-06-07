#!/usr/bin/env bats
# Generated from oils-for-unix spec/globstar.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 globstar is off -> ** is treated like *' {
  local cmd='shopt -u globstar

mkdir -p c/subdir
touch {leaf.md,c/leaf.md,c/subdir/leaf.md}

echo **/*.* | sort'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 each occurrence of ** recurses through all depths' {
  local cmd='shopt -s globstar

mkdir -p c/subdir
touch {leaf.md,c/leaf.md,c/subdir/leaf.md}

echo **/*.* | tr '\'' '\'' '\''\n'\'' | sort
echo
echo **/**/*.* | tr '\'' '\'' '\''\n'\'' | sort'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 within braces, globstar works when there is a comma' {
  local cmd='shopt -s globstar

mkdir -p c/subdir
touch c/subdir/leaf.md

echo {**/*.*,} | sort | sed '\''s/[[:space:]]*$//'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 ** behaves like * if adjacent to anything other than /' {
  local cmd='shopt -s globstar

mkdir directory
touch leaf.md
touch directory/leaf.md

echo **/*.* | sort
echo directory/**/*.md | sort
echo d**/*.md | sort
echo **y/*.md | sort
echo d**y/*.md | sort'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 in zsh, ***/ follows symlinked directories, while **/ does not' {
  local cmd='mkdir directory-1
mkdir directory-2
touch directory-2/leaf-2.md
ln -s -T ../directory-2 directory-1/symlink

echo **/*.* | sort
echo ***/*.* | sort'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

