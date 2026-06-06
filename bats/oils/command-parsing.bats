#!/usr/bin/env bats
# Generated from oils-for-unix spec/command-parsing.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Prefix env on assignment' {
  local cmd='f() {
  # NOTE: local treated like a special builtin!
  E=env local v=var
  echo $E $v
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Redirect on assignment (enabled 7/2019)' {
  local cmd='f() {
  # NOTE: local treated like a special builtin!
  local E=env > _tmp/r.txt
}
rm -f _tmp/r.txt
f
test -f _tmp/r.txt && echo REDIRECTED'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Prefix env on control flow' {
  local cmd='for x in a b c; do
  echo $x
  E=env break
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Redirect on control flow (ignored in OSH)' {
  local cmd='rm -f _tmp/r.txt
for x in a b c; do
  break > _tmp/r.txt
done
if test -f _tmp/r.txt; then
  echo REDIRECTED
else
  echo NO
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Redirect on control flow with ysh:all (no_parse_ignored)' {
  skip "YSH syntax not supported"
  local cmd='shopt -s ysh:all
rm -f _tmp/r.txt
for x in a b c; do
  break > _tmp/r.txt
done
test -f _tmp/r.txt && echo REDIRECTED'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

