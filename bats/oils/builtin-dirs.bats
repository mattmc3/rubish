#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-dirs.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 pushd/popd' {
  local cmd='set -o errexit
cd /
pushd /tmp
echo -n pwd=; pwd
popd
echo -n pwd=; pwd'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 pushd usage' {
  local cmd='pushd -z
echo status=$?
pushd /tmp >/dev/null
echo status=$?
pushd -- /tmp >/dev/null
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 popd usage error' {
  local cmd='pushd / >/dev/null
popd zzz
echo status=$?

popd -- >/dev/null
echo status=$?

popd -z
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 popd returns error on empty directory stack' {
  local cmd='message=$(popd 2>&1)
echo $?
echo "$message" | grep -o "directory stack"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 cd replaces the lowest entry on the directory stack!' {
  local cmd='# stable temp dir
dir=/tmp/oils-spec/builtin-dirs

mkdir -p $dir
cd $dir

pushd /tmp >/dev/null
echo pushd=$?

dirs

cd /
echo cd=$?

dirs

popd >/dev/null
echo popd=$?

popd >/dev/null
echo popd=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 dirs builtin' {
  local cmd='cd /
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 dirs -c to clear the stack' {
  local cmd='set -o errexit
cd /
pushd /tmp >/dev/null  # zsh pushd doesn'\''t print anything, but bash does
echo --
dirs
dirs -c
echo --
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 dirs -v to print numbered stack, one entry per line' {
  local cmd='set -o errexit
cd /
pushd /tmp >/dev/null
echo --
dirs -v
pushd /dev >/dev/null
echo --
dirs -v'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 dirs -p to print one entry per line' {
  local cmd='set -o errexit
cd /
pushd /tmp >/dev/null
echo --
dirs -p
pushd /dev >/dev/null
echo --
dirs -p'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 dirs -l to print in long format, no tilde prefix' {
  local cmd='# Can'\''t use the OSH test harness for this because
# /home/<username> may be included in a path.
cd /
HOME=/tmp
mkdir -p $HOME/oil_test
pushd $HOME/oil_test >/dev/null
dirs
dirs -l'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 dirs to print using tilde-prefix format' {
  local cmd='cd /
HOME=/tmp
mkdir -p $HOME/oil_test
pushd $HOME/oil_test >/dev/null
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 dirs test converting true home directory to tilde' {
  local cmd='cd /
HOME=/tmp
mkdir -p $HOME/oil_test/$HOME
pushd $HOME/oil_test/$HOME >/dev/null
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 dirs don'\''t convert to tilde when HOME is substring' {
  local cmd='cd /
mkdir -p /tmp/oil_test
mkdir -p /tmp/oil_tests
HOME=/tmp/oil_test
pushd /tmp/oil_tests
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 dirs tilde test when HOME is exactly PWD' {
  local cmd='cd /
mkdir -p /tmp/oil_test
HOME=/tmp/oil_test
pushd $HOME
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 dirs test of path alias ..' {
  local cmd='cd /tmp
pushd .. >/dev/null
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 dirs test of path alias .' {
  local cmd='cd /tmp
pushd . >/dev/null
dirs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 pushd does not take more than one argument' {
  local cmd='pushd . . >/dev/null || echo too many args!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 dirs does not take arguments' {
  local cmd='dirs a || echo failed
dirs -l a || echo failed'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

