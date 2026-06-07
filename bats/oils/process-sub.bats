#!/usr/bin/env bats
# Generated from oils-for-unix spec/process-sub.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Process sub input' {
  local cmd='f=process-sub.txt
{ echo 1; echo 2; echo 3; } > $f
cat <(head -n 2 $f) <(tail -n 2 $f)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Process sub from external process to stdin' {
  local cmd='seq 3 > >(tac)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Process sub from shell to stdin' {
  local cmd='{ echo 1; echo 2; echo 3; } > >(tac)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Non-linear pipeline with >()' {
  local cmd='stdout_stderr() {
  echo o1
  echo o2

  sleep 0.1  # Does not change order

  { echo e1;
    echo warning: e2 
    echo e3;
  } >& 2
}
stdout_stderr 2> >(grep warning) | tac >$TMP/out.txt
wait $!  # this does nothing in bash 4.3, but probably does in bash 4.4.
echo OUT
cat $TMP/out.txt
# PROBLEM -- OUT comes first, and then '\''warning: e2'\'', and then '\''o2 o1'\''.  It
# looks like it'\''s because nobody waits for the proc sub.
# http://lists.gnu.org/archive/html/help-bash/2017-06/msg00018.html'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 (<file) idiom with process sub' {
  local cmd='echo FOO >foo

# works in bash and zsh
echo $(<foo)

# this works in zsh, but not in bash
tr A-Z a-z < <(<foo)

cat < <(<foo; echo hi)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 status code is available' {
  local cmd='shopt --set parse_at

cat <(seq 2; exit 2) <(seq 3; exit 3)

echo status @_process_sub_status
echo done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 shopt -s process_sub_fail' {
  local cmd='shopt --set parse_at

cat <(echo a; exit 2) <(echo b; exit 3)
echo status=$? ps @_process_sub_status

echo __
shopt -s process_sub_fail

cat <(echo a; exit 2) <(echo b; exit 3)
echo status=$? ps @_process_sub_status

# Now exit because of it
set -o errexit

cat <(echo a; exit 2) <(echo b; exit 3)
echo status=$? ps @_process_sub_status'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 process subs and pipelines together' {
  local cmd='# zsh is very similar to bash, but don'\''t bother with the assertions

shopt --set parse_at

f() {
  cat <(seq 1; exit 1) | {
    cat <(seq 2; exit 2) <(seq 3; exit 3)

    # 2022-11 workaround for race condition: sometimes we get pipeline=141 4
    # instead of pipeline=0 4, which means that the first '\''cat'\'' got SIGPIPE.
    # If we make this part of the pipeline take longer, then '\''cat'\'' should have
    # a chance to finish.

    sleep 0.01

    (exit 4)
  }
  echo status=$?
  echo process_sub @_process_sub_status
  echo pipeline @_pipeline_status
  echo __
}

f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 process sub in background &' {
  local cmd='cat <(seq 3; sleep 0.1) & wait

echo sync

# This one escapes, and the shell should still exit
cat <(sleep 0.1) &

echo fork'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

