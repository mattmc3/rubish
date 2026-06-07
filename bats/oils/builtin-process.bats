#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-process.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 exec builtin' {
  local cmd='exec echo hi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 exec builtin with redirects' {
  local cmd='exec 1>&2
echo '\''to stderr'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 exec builtin with here doc' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='# This has in a separate file because both code and data can be read from
# stdin.
$SH $REPO_ROOT/spec/bin/builtins-exec-here-doc-helper.sh'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 exec builtin accepts --' {
  local cmd='exec -- echo hi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 exec -- 2>&1' {
  local cmd='exec -- 3>&1
echo stdout 1>&3'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 exec -a sets argv[0]' {
  local cmd='exec -a FOOPROC sh -c '\''echo $0'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Exit out of function' {
  local cmd='f() { exit 3; }
f
exit 4'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Exit builtin with invalid arg' {
  local cmd='exit invalid
# Rationale: runtime errors are 1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Exit builtin with too many args' {
  local cmd='# This is a parse error in OSH.
exit 7 8 9
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 time with brace group argument' {
  local cmd='err=time-$(basename $SH).txt
{
  time {
    sleep 0.01
    sleep 0.02
  }
} 2> $err

grep --only-matching user $err
echo result=$?

# Regression: check fractional seconds
gawk '\''
BEGIN { ok = 0 }
match( $0, /\.([0-9]+)/, m) {
  if (m[1] > 0) {  # check fractional seconds
    ok = 1
  }
}
END { if (ok) { print "non-zero" } }
'\'' $err'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 ulimit with no flags is like -f' {
  local cmd='ulimit > no-flags.txt
echo status=$?

ulimit -f > f.txt
echo status=$?

diff -u no-flags.txt f.txt
echo diff=$?

# Print everything
# ulimit -a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 ulimit too many args' {
  local cmd='ulimit 1 2
if test $? -ne 0; then
  echo pass
else
  echo fail
fi

#ulimit -f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 ulimit negative flag' {
  local cmd='ulimit -f

# interpreted as a flag
ulimit -f -42
if test $? -ne 0; then
  echo pass
else
  echo fail
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 ulimit negative arg' {
  local cmd='ulimit -f

# an arg
ulimit -f -- -42
if test $? -ne 0; then
  echo pass
else
  echo fail
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 ulimit -a doesn'\''t take arg' {
  local cmd='ulimit -a 42
if test $? -ne 0; then
  echo '\''failure that was expected'\''
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 ulimit doesn'\''t accept multiple flags - reduce confusion between shells' {
  local cmd='# - bash, zsh, busybox ash accept multiple "commands", which requires custom
#   flag parsing, like

#   ulimit -f 999 -n
#   ulimit -f 999 -n 888
#
# - dash and mksh accept a single ARG
#
# we want to make it clear we'\''re like the latter

# can'\''t print all and -f
ulimit -f -a >/dev/null
echo status=$?

ulimit -f -n >/dev/null
echo status=$?

ulimit -f -n 999 >/dev/null
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 YSH readability: ulimit --all the same as ulimit -a' {
  local cmd='ulimit -a > short.txt
ulimit --all > long.txt

wc -l short.txt long.txt

diff -u short.txt long.txt
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 ulimit accepts '\''unlimited'\''' {
  local cmd='for arg in zz unlimited; do
  echo "  arg $arg"
  ulimit -f
  echo status=$?
  ulimit -f $arg
  if test $? -ne 0; then
    echo '\''FAILED'\''
  fi
  echo
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 ulimit of 2**32, 2**31 (int overflow)' {
  local cmd='echo -n '\''one '\''; ulimit -f

ulimit -f $(( 1 << 32 ))

echo -n '\''two '\''; ulimit -f

# mksh fails because it overflows signed int, turning into negative number
ulimit -f $(( 1 << 31 ))

echo -n '\''three '\''; ulimit -f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 ulimit that is 64 bits' {
  local cmd='# no 64-bit integers

echo -n '\''before '\''; ulimit -f

# 1 << 63 overflows signed int

# 512 is 1 << 9, so make it 62-9 = 53 bits

lim=$(( 1 << 53 ))
#echo $lim

# bash says this is out of range
ulimit -f $lim

echo -n '\''after '\''; ulimit -f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 arg that would overflow 64 bits is detected' {
  local cmd='# no 64-bit integers

echo -n '\''before '\''; ulimit -f

# 1 << 63 overflows signed int

lim=$(( (1 << 62) + 1 ))
#echo lim=$lim

# bash detects that this is out of range
# so does osh-cpp, but not osh-cpython

ulimit -f $lim
echo -n '\''after '\''; ulimit -f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 ulimit -f 1 prevents files larger 512 bytes' {
  local cmd='trap - XFSZ  # don'\''t handle this

rm -f err.txt
touch err.txt

bytes() {
  local n=$1
  local st=0
  for i in $(seq $n); do
    echo -n x
    st=$?
    if test $st -ne 0; then
      echo "ERROR: echo failed with status $st" >> err.txt
    fi
  done
}

ulimit -f 1

bytes 512 > ok.txt
echo 512 status=$?

bytes 513 > too-big.txt
echo 513 status=$?
echo

wc --bytes ok.txt too-big.txt
echo

cat err.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 write big file with ulimit' {
  local cmd='# I think this will test write() errors, rather than the final flush() error
# (which is currently skipped by C++

{ echo '\''ulimit -f 1'\''
  # More than 8 KiB may cause a flush()
  python2 -c '\''print("echo " + "X"*9000 + " >out.txt")'\''
  echo '\''echo inner=$?'\''
} > big.sh

$SH big.sh
echo outer=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 ulimit -S for soft limit (default), -H for hard limit' {
  local cmd='# Note: ulimit -n -S 1111 is OK in osh/dash/mksh, but not bash/zsh
# Mus be ulimit -S -n 1111

show_state() {
  local msg=$1
  echo "$msg"
  echo -n '\''  '\''; ulimit -S -t
  echo -n '\''  '\''; ulimit -H -t
  echo
}

show_state '\''init'\''

ulimit -S -t 123456
show_state '\''-S'\''

ulimit -H -t 123457
show_state '\''-H'\''

ulimit -t 123455
show_state '\''no flag'\''

echo '\''GET'\''

ulimit -S -t 123454
echo -n '\''  '\''; ulimit -t
echo -n '\''  '\''; ulimit -S -t
echo -n '\''  '\''; ulimit -H -t'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 Changing resource limit is denied' {
  local cmd='# Not sure why these don'\''t work

flag=-t

ulimit -S -H $flag 100
echo both=$?

ulimit -S $flag 90
echo soft=$?

ulimit -S $flag 95
echo soft=$?

ulimit -S $flag 105
if test $? -ne 0; then
  echo soft OK
else
  echo soft fail
fi

ulimit -H $flag 200
if test $? -ne 0; then
  echo hard OK
else
  echo hard fail
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 ulimit -n limits file descriptors' {
  local cmd='# OSH bug
# https://oilshell.zulipchat.com/#narrow/channel/502349-osh/topic/alpine.20build.20failures.20-.20make.20-.20ulimit.20-n.2064/with/519691301

$SH -c '\''ulimit -n 64; echo hi >out'\''
echo status=$?

$SH -c '\''ulimit -n 0; echo hi >out'\''
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

