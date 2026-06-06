#!/usr/bin/env bats
# Generated from oils-for-unix spec/background.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 wait with nothing to wait for' {
  local cmd='wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 wait -n with arguments - arguments are respected' {
  local cmd='case $SH in dash|mksh) exit ;; esac

echo x &

# here, you can'\''t tell if it'\''s -n or the other
wait -n $!
echo status=$?

# by the bash error, you can tell which is preferred
wait -n $! bad 2>err.txt
echo status=$?
echo

n=$(wc -l < err.txt)
if test "$n" -gt 0; then
  echo '\''got error lines'\''
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 wait -n with nothing to wait for' {
  local cmd='# The 127 is STILL overloaded.  Copying bash for now.
wait -n'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 wait with jobspec syntax %nonexistent' {
  local cmd='wait %nonexistent'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 wait with invalid PID' {
  local cmd='wait 12345678'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 wait with invalid arg' {
  local cmd='wait zzz'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 wait for N parallel jobs' {
  local cmd='for i in 3 2 1; do
  { sleep 0.0$i; exit $i; } &
done
wait

# status is lost
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 wait for N parallel jobs and check failure' {
  local cmd='set -o errexit

pids='\'''\''
for i in 3 2 1; do
  { sleep 0.0$i; echo $i; exit $i; } &
  pids="$pids $!"
done

for pid in $pids; do
  set +o errexit
  wait $pid
  status=$?
  set -o errexit

  echo status=$status
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Builtin in background' {
  local cmd='echo async &
wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 External command in background' {
  local cmd='sleep 0.01 &
wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Start background pipeline, wait pid' {
  local cmd='echo hi | { exit 99; } &
echo status=$?
wait $!
echo status=$?
echo --

pids='\'''\''
for i in 3 2 1; do
  sleep 0.0$i | echo i=$i | ( exit $i ) &
  pids="$pids $!"
done
#echo "PIDS $pids"

for pid in $pids; do
  wait $pid
  echo status=$?
done

# Not cleaned up
if false; then
  echo '\''DEBUG'\''
  jobs --debug
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Start background pipeline, wait %job_spec' {
  local cmd='case $SH in mksh) exit ;; esac  # flakiness?

echo hi | { exit 99; } &
echo status=$?
wait %1
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Wait for job and PIPESTATUS' {
  local cmd='# foreground
{ echo hi; exit 55; } | false
echo fore status=$? pipestatus=${PIPESTATUS[@]}

# background
{ echo hi; exit 44; } | false &
echo back status=$? pipestatus=${PIPESTATUS[@]}

# wait for pipeline
wait %+
#wait %1
#wait $!
echo wait status=$? pipestatus=${PIPESTATUS[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Wait for job and PIPESTATUS - cat' {
  local cmd='# foreground
exit 55 | ( cat; exit 99 )
echo fore status=$? pipestatus=${PIPESTATUS[@]}

# background
exit 44 | ( cat; exit 88 ) &
echo back status=$? pipestatus=${PIPESTATUS[@]}

# wait for pipeline
wait %+
#wait %1
#wait $!
echo wait status=$? pipestatus=${PIPESTATUS[@]}
echo

# wait for non-pipeline
( exit 77 ) &
wait %+
echo wait status=$? pipestatus=${PIPESTATUS[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Brace group in background, wait all' {
  local cmd='{ sleep 0.09; exit 9; } &
{ sleep 0.07; exit 7; } &
wait  # wait for all gives 0
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Wait on background process PID' {
  local cmd='{ sleep 0.09; exit 9; } &
pid1=$!
{ sleep 0.07; exit 7; } &
pid2=$!
wait $pid2
echo "status=$?"
wait $pid1
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Wait on multiple specific IDs returns last status' {
  local cmd='{ sleep 0.08; exit 8; } &
jid1=$!
{ sleep 0.09; exit 9; } &
jid2=$!
{ sleep 0.07; exit 7; } &
jid3=$!
wait $jid1 $jid2 $jid3  # NOTE: not using %1 %2 %3 syntax on purpose
echo "status=$?"  # third job I think'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 wait -n' {
  local cmd='case $SH in dash|mksh) return ;; esac

{ sleep 0.09; exit 9; } &
{ sleep 0.03; exit 3; } &
wait -n
echo "status=$?"
wait -n
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Async for loop' {
  local cmd='for i in 1 2 3; do
  echo $i
  sleep 0.0$i
done &
wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Background process doesn'\''t affect parent' {
  local cmd='echo ${foo=1}
echo $foo
echo ${bar=2} &
wait
echo $bar  # bar is NOT SET in the parent process'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Background process and then a singleton pipeline' {
  local cmd='# This was inspired by #416, although that symptom there was timing, so it'\''s
# technically not a regression test.  It'\''s hard to test timing.

{ sleep 0.1; exit 42; } &
echo begin
! true
echo end
wait $!
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 jobs prints one line per job' {
  local cmd='sleep 0.1 & 
sleep 0.1 | cat & 

# dash doesn'\''t print if it'\''s not a terminal?
jobs | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 jobs -p prints one line per job' {
  local cmd='sleep 0.1 &
sleep 0.1 | cat &

jobs -p > tmp.txt

cat tmp.txt | wc -l  # 2 lines, one for each job
cat tmp.txt | wc -w  # each line is a single "word"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 No stderr spew when shell is not interactive' {
  local cmd='# in interactive shell, this prints '\''Process'\'' or '\''Pipeline'\''
sleep 0.01 &
sleep 0.01 | cat &
wait'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 YSH wait --all' {
  local cmd='case $SH in dash|bash|mksh) exit ;; esac

sleep 0.01 &
(exit 55) &
true &
wait
echo wait $?

sleep 0.01 &
(exit 44) &
true &
wait --all
echo wait --all $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 YSH wait --verbose' {
  local cmd='case $SH in dash|bash|mksh) exit ;; esac

sleep 0.01 &
(exit 55) &
wait --verbose
echo wait $?

(exit 44) &
sleep 0.01 &
wait --all --verbose
echo wait --all $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Signal message for killed background job' {
  local cmd='case $SH in dash|mksh) exit ;; esac

sleep 1 &
kill -HUP $!
wait $! 2>err.txt
echo status=$?
grep -o "Hangup" err.txt'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

