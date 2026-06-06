#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-kill.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 kill -15 kills the process with SIGTERM' {
  local cmd='case $SH in mksh) exit ;; esac  # mksh is flaky

sleep 0.1 &
pid=$!
kill -15 $pid
echo kill=$?

wait $pid
echo wait=$?  # 143 is 128 + SIGTERM'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 kill -KILL kills the process with SIGKILL' {
  local cmd='sleep 0.1 & 
pid=$!
kill -KILL $pid 
echo kill=$?

wait $pid
echo wait=$?  # 137 is 128 + SIGKILL'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 kill -n 9 specifies the signal number' {
  local cmd='#case $SH in mksh|dash) exit ;; esac

sleep 0.1 &
pid=$!
kill -n 9 $pid
echo kill=$?

wait $pid
echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 kill -s TERM specifies the signal name' {
  local cmd='sleep 0.1 &
pid=$!
kill -s TERM $pid
echo kill=$?

wait $pid
echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 kill -terM -SigterM isn'\''t case sensitive' {
  local cmd='case $SH in mksh|dash|zsh) exit ;; esac

sleep 0.1 &
pid=$!
kill -SigterM $pid
echo kill=$?
wait $pid
echo wait=$?

sleep 0.1 &
pid=$!
kill -terM $pid
echo kill=$?
wait $pid
echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 kill HUP pid gives the correct error' {
  local cmd='case $SH in dash) exit ;; esac
sleep 0.1 &
builtin kill HUP $pid
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 kill -l shows signals' {
  local cmd='case $SH in dash) exit ;; esac

# Check if at least the HUP flag is reported.  The output format of all shells
# is different and the available signals may depend on your environment

builtin kill -l | grep HUP > /dev/null
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 kill -L also shows signals' {
  local cmd='case $SH in mksh|dash|zsh) exit ;; esac

builtin kill -L | grep HUP > /dev/null
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 kill -l 10 TERM translates between names and numbers' {
  local cmd='case $SH in mksh|dash) exit ;; esac

builtin kill -l 10 11 12
echo status=$?
echo

builtin kill -l SIGUSR1 SIGSEGV USR2
echo status=$?
echo

# mixed kind
builtin kill -l 10 SIGSEGV 12
echo status=$?
echo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 kill -L checks for invalid input' {
  local cmd='case $SH in mksh|dash) exit ;; esac

builtin kill -L 10 BAD 12
echo status=$?
echo

builtin kill -L USR1 9999 USR2
echo status=$?
echo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 kill -l with exit code' {
  local cmd='kill -l 134 # 128 + 6 (ABRT)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 kill -l with 128 is invalid' {
  local cmd='kill -l 128
if [ $? -ne 0 ]; then
    echo "invalid"
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 kill -l 0 returns EXIT' {
  local cmd='kill -l 0'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 kill -l 0 INT lists both signals' {
  local cmd='kill -l 0 INT'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 kill -9999 is an invalid signal' {
  local cmd='case $SH in dash)  exit ;; esac
sleep 0.1 &
pid=$!
kill -9999 $pid > /dev/null
echo kill=$?

wait $pid
echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 kill -15 %% kills current job' {
  local cmd='#case $SH in mksh|dash) exit ;; esac

sleep 0.5 &
pid=$!
kill -15 %%
echo kill=$?

wait %%
echo wait=$?

# no such job
wait %%
echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 kill -15 %- kills previous job' {
  local cmd='#case $SH in mksh|dash) exit ;; esac

sleep 0.1 &  # previous job
sleep 0.2 &  # current job

kill -15 %-
echo kill=$?

wait %-
echo wait=$?

# what does bash define here as the previous job?  May be a bug
#wait %-
#echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 kill multiple pids at once' {
  local cmd='sleep 0.1 &
pid1=$!
sleep 0.1 &
pid2=$!
sleep 0.1 &
pid3=$!

kill $pid1 $pid2 $pid3
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 kill pid and job at once' {
  local cmd='sleep 0.1 &
pid=$!
sleep 0.1 &
kill %2 $pid
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Numeric signal out of range - OSH may send it anyway' {
  local cmd='sleep 0.1 &

# OSH doesn'\''t validate this, but that could be useful for non-portable signals,
# which we don'\''t have a name for.

kill -s 9999 %%
echo kill=$?

wait
echo wait=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

