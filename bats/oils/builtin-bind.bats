#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-bind.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 bind -l should report readline functions' {
  local cmd='# This test depends on the exact version
# bind -l | sort > _tmp/this-shell-bind-l.txt
# comm -23 $REPO_ROOT/spec/testdata/bind/bind_l_function_list.txt _tmp/this-shell-bind-l.txt

# More relaxed test
bind -l | grep accept-line'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 bind -p -P to print function names and key bindings' {
  local cmd='# silly workaround for spec test format - change # comment to %
bind -p | grep vi-subst | sed '\''s/^#/%/'\''
echo

bind -P | grep vi-subst'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 bind -s -S accepted' {
  local cmd='# TODO: add non-trivial tests here

bind -s
bind -S'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 bind -v -V accepted' {
  local cmd='bind -v | grep blink-matching-paren
echo

# transform silly quote so we don'\''t mess up syntax highlighting
bind -V | grep blink-matching-paren | sed "s/\`/'\''/g"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 bind -q' {
  local cmd='bind -q zz-bad
echo status=$?

# bash prints message to stdout

bind -q vi-subst
echo status=$?

bind -q yank
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 bind -X' {
  local cmd='bind -X | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?

bind -x '\''"\C-o\C-s\C-h": echo foo'\''
bind -X | grep -oF '\''\C-o\C-s\C-h'\''
bind -X | grep -oF '\''echo foo'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 bind -m with bind -x/-X' {
  local cmd='bind -X | grep -oF '\''emacs|vi'\''
echo status=$?

bind -m emacs -x '\''"\C-o\C-s\C-h": echo emacs'\''
bind -m emacs -X | grep -oF '\''emacs'\''
echo status=$?

bind -m vi -x '\''"\C-o\C-s\C-h": echo vi'\''
bind -m vi -X | grep -oF '\''vi'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 bind -r' {
  local cmd='bind -q yank | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?

bind '\''"\C-o\C-s\C-h": yank'\''
bind -q yank | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?

bind -r "\C-o\C-s\C-h"
bind -q yank | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 bind -r of bind -x commands' {
  local cmd='bind -X | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?

bind -x '\''"\C-o\C-s\C-h": echo foo'\''
bind -X | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?

bind -r "\C-o\C-s\C-h"
bind -X | grep -oF '\''\C-o\C-s\C-h'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

