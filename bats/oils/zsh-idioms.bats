#!/usr/bin/env bats
# Generated from oils-for-unix spec/zsh-idioms.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 git-completion snippet' {
  local cmd='# copied directly from git completion - 2024-04

if false; then
  unset ${(M)${(k)parameters[@]}:#__gitcomp_builtin_*} 2>/dev/null
fi
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 asdf snippet' {
  local cmd='# copied directly from asdf - 2024-04

if false; then
  ASDF_DIR=${(%):-%x}
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 zsh var sub is rejected at runtime' {
  local cmd='eval '\''echo z ${(m)foo} z'\''
echo status=$?

eval '\''echo ${x:-${(m)foo}}'\''
echo status=$?

# double quoted
eval '\''echo "${(m)foo}"'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

