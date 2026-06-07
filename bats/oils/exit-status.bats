#!/usr/bin/env bats
# Generated from oils-for-unix spec/exit-status.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Truncating '\''exit'\'' status' {
  local cmd='$SH -c '\''exit 255'\''
echo status=$?

$SH -c '\''exit 256'\''
echo status=$?

$SH -c '\''exit 257'\''
echo status=$?

echo ===

$SH -c '\''exit -1'\''
echo status=$?

$SH -c '\''exit -2'\''
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Truncating '\''return'\'' status' {
  local cmd='f() { return 255; }; f
echo status=$?

f() { return 256; }; f
echo status=$?

f() { return 257; }; f
echo status=$?

echo ===

f() { return -1; }; f
echo status=$?

f() { return -2; }; f
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 subshell OverflowError https://github.com/oilshell/oil/issues/996' {
  local cmd='# We have to capture stderr here 

filter_err() {
  # check for bash/dash/mksh messages, and unwanted Python OverflowError
  egrep -o '\''Illegal number|bad number|return: can only|expected a small integer|OverflowError'\''
  return 0
}

# true; disables subshell optimization!

# exit status too big, but integer isn'\''t
$SH -c '\''true; ( return 2147483647; )'\'' 2>err.txt
echo status=$?
cat err.txt | filter_err

# now integer is too big
$SH -c '\''true; ( return 2147483648; )'\'' 2> err.txt
echo status=$?
cat err.txt | filter_err

# even bigger
$SH -c '\''true; ( return 2147483649; )'\'' 2> err.txt
echo status=$?
cat err.txt | filter_err

echo
echo '\''--- negative ---'\''

# negative vlaues
$SH -c '\''true; ( return -2147483648; )'\'' 2>err.txt
echo status=$?
cat err.txt | filter_err

# negative vlaues
$SH -c '\''true; ( return -2147483649; )'\'' 2>err.txt
echo status=$?
cat err.txt | filter_err'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 func subshell OverflowError https://github.com/oilshell/oil/issues/996' {
  local cmd='# We have to capture stderr here 

filter_err() {
  # check for bash/dash/mksh messages, and unwanted Python OverflowError
  egrep -o '\''Illegal number|bad number|return: can only|expected a small integer|OverflowError'\''
  return 0
}

# exit status too big, but integer isn'\''t
$SH -c '\''f() ( return 2147483647; ); f'\'' 2>err.txt
echo status=$?
cat err.txt | filter_err

# now integer is too big
$SH -c '\''f() ( return 2147483648; ); f'\'' 2> err.txt
echo status=$?
cat err.txt | filter_err

# even bigger
$SH -c '\''f() ( return 2147483649; ); f'\'' 2> err.txt
echo status=$?
cat err.txt | filter_err'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 If empty command' {
  local cmd='if '\'''\''; then echo TRUE; else echo FALSE; fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 If subshell true' {
  local cmd='if `true`; then echo TRUE; else echo FALSE; fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 If subshell true WITH OUTPUT is different' {
  local cmd='if `sh -c '\''echo X; true'\''`; then echo TRUE; else echo FALSE; fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 If subshell true WITH ARGUMENT' {
  local cmd='if `true` X; then echo TRUE; else echo FALSE; fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 If subshell false -- exit code is propagated in a weird way (strict_argv prevents)' {
  local cmd='if `false`; then echo TRUE; else echo FALSE; fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Exit code when command sub evaluates to empty str, e.g. false (#2416)' {
  local cmd='# OSH had a bug here
`true`; echo $?
`false`; echo $?
$(true); echo $?
$(false); echo $?
echo ---

# OSH and others agree on these
eval true; echo $?
eval false; echo $?
`echo true`; echo $?
`echo false`; echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 More test cases with empty argv' {
  local cmd='true $(false)
echo status=$?

$(exit 42)
echo status=$?

$(exit 42) $(exit 43)
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

