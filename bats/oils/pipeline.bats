#!/usr/bin/env bats
# Generated from oils-for-unix spec/pipeline.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Brace group in pipeline' {
  local cmd='{ echo one; echo two; } | tac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 For loop starts pipeline' {
  local cmd='for w in one two; do
  echo $w
done | tac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 While Loop ends pipeline' {
  local cmd='seq 3 | while read i
do
  echo ".$i"
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Redirect in Pipeline' {
  local cmd='echo hi 1>&2 | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Pipeline comments' {
  local cmd='echo abcd |    # input
               # blank line
tr a-z A-Z     # transform'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Exit code is last status' {
  local cmd='echo a | egrep '\''[0-9]+'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Initial value of PIPESTATUS is empty string' {
  local cmd='case $SH in dash|zsh) exit ;; esac

echo pipestatus ${PIPESTATUS[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 PIPESTATUS' {
  local cmd='return3() {
  return 3
}
{ sleep 0.03; exit 1; } | { sleep 0.02; exit 2; } | { sleep 0.01; return3; }
echo ${PIPESTATUS[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 PIPESTATUS is set on simple commands' {
  local cmd='case $SH in dash|zsh) exit ;; esac

false
echo pipestatus ${PIPESTATUS[@]}

exit 55 | (exit 44)
echo pipestatus ${PIPESTATUS[@]}

true
echo pipestatus ${PIPESTATUS[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 PIPESTATUS with shopt -s lastpipe' {
  local cmd='shopt -s lastpipe
return3() {
  return 3
}
{ sleep 0.03; exit 1; } | { sleep 0.02; exit 2; } | { sleep 0.01; return3; }
echo ${PIPESTATUS[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 |&' {
  local cmd='stdout_stderr.py |& cat'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 ! turns non-zero into zero' {
  local cmd='! $SH -c '\''exit 42'\''; echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 ! turns zero into 1' {
  local cmd='! $SH -c '\''exit 0'\''; echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 ! in if' {
  local cmd='if ! echo hi; then
  echo TRUE
else
  echo FALSE
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 ! with ||' {
  local cmd='! echo hi || echo FAILED'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 ! with { }' {
  local cmd='! { echo 1; echo 2; } || echo FAILED'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 ! with ( )' {
  local cmd='! ( echo 1; echo 2 ) || echo FAILED'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 ! is not a command' {
  local cmd='v='\''!'\''
$v echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Evaluation of argv[0] in pipeline occurs in child' {
  local cmd='${cmd=echo} hi | wc -l
echo "cmd=$cmd"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 bash/dash/mksh run the last command is run in its own process' {
  local cmd='echo hi | read line
echo "line=$line"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 shopt -s lastpipe (always on in OSH)' {
  local cmd='shopt -s lastpipe
echo hi | read line
echo "line=$line"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 shopt -s lastpipe (always on in OSH)' {
  local cmd='shopt -s lastpipe
i=0
seq 3 | while read line; do
  (( i++ ))
done
echo i=$i'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 SIGPIPE causes pipeline to die (regression for issue #295)' {
  local cmd='cat /dev/urandom | sleep 0.1
echo ${PIPESTATUS[@]}

# hm bash gives '\''1 0'\'' which seems wrong'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Nested pipelines' {
  local cmd='{ sleep 0.1 | seq 3; } | cat
{ sleep 0.1 | seq 10; } | { cat | cat; } | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Pipeline in eval' {
  local cmd='ls /dev/null | eval '\''cat | cat'\'' | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 shopt -s lastpipe and shopt -s no_last_fork interaction' {
  local cmd='case $SH in dash) exit ;; esac

$SH -c '\''
shopt -s lastpipe
set -o errexit
set -o pipefail

ls | false | wc -l'\''
echo status=$?

# Why does this give status 0?  It should fail

$SH -c '\''
shopt -s lastpipe
shopt -s no_fork_last  # OSH only
set -o errexit
set -o pipefail

ls | false | wc -l'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

