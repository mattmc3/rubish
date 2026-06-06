#!/usr/bin/env bats
# Generated from oils-for-unix spec/bugs.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 echo keyword' {
  local cmd='echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 if/else' {
  local cmd='if false; then
  echo THEN
else
  echo ELSE
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Turn an array into an integer.' {
  local cmd='a=(1 2 3)
(( a = 42 )) 
echo $a'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 assign readonly -- one line' {
  local cmd='readonly x=1; x=2; echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 assign readonly -- multiple lines' {
  local cmd='readonly x=1
x=2
echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 assign readonly -- multiple lines -- set -o posix' {
  local cmd='set -o posix
readonly x=1
x=2
echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 unset readonly -- one line' {
  local cmd='readonly x=1; unset x; echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 unset readonly -- multiple lines' {
  local cmd='readonly x=1
unset x
echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 First word like foox() and foo[1+2] (regression)' {
  local cmd='# Problem: $x() func call broke this error message
foo$identity('\''z'\'')

foo$[1+2]

echo DONE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Function names' {
  local cmd='foo$x() {
  echo hi
}

foo $x() {
  echo hi
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 file with NUL byte' {
  local cmd='echo -e '\''echo one \0 echo two'\'' > tmp.sh
$SH tmp.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 fastlex: PS1 format string that'\''s incomplete / with NUL byte' {
  local cmd='case $SH in bash) exit ;; esac

x=$'\''\\D{%H:%M'\''  # leave off trailing }
echo x=${x@P}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 '\''echo'\'' and printf fail on writing to full disk' {
  local cmd='# Inspired by https://blog.sunfishcode.online/bugs-in-hello-world/

echo hi > /dev/full
echo status=$?

printf '\''%s\n'\'' hi > /dev/full
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 other builtins fail on writing to full disk' {
  local cmd='type echo > /dev/full
echo status=$?

# other random builtin
ulimit -a > /dev/full
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 subshell while running a script (regression)' {
  local cmd='# Ensures that spawning a subshell doesn'\''t cause a seek on the file input stream
# representing the current script (issue #1233).
cat >tmp.sh <<'\''EOF'\''
echo start
(:)
echo end
EOF
$SH tmp.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 for loop (issue #1446)' {
  local cmd='case $SH in dash|mksh|ash) exit ;; esac

for (( n=0; n<(3-(1)); n++ )) ; do echo $n; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 for loop 2 (issue #1446)' {
  local cmd='case $SH in dash|mksh|ash) exit ;; esac


for (( n=0; n<(3- (1)); n++ )) ; do echo $n; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 autoconf word split (#1449)' {
  local cmd='mysed() {
  for line in "$@"; do
    echo "[$line]"
  done
}

sedinputs="f1 f2"
sedscript='\''my sed command'\''

# Parsed and evaluated correctly: with word_part.EscapedLiteral \"

x=$(eval "mysed -n \"\$sedscript\" $sedinputs")
echo '\''--- $()'\''
echo "$x"

# With backticks, the \" gets lost somehow

x=`eval "mysed -n \"\$sedscript\" $sedinputs"`
echo '\''--- backticks'\''
echo "$x"


# Test it in a case statement

case `eval "mysed -n \"\$sedscript\" $sedinputs"` in 
  (*'\''[my sed command]'\''*)
    echo '\''NOT SPLIT'\''
    ;;
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 autoconf arithmetic - relaxed eval_unsafe_arith (#1450)' {
  local cmd='as_fn_arith ()
{
    as_val=$(( $* ))
}
as_fn_arith 1 + 1
echo $as_val'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 command execution (echo 42 | tee PWNED) not allowed' {
  local cmd='rm -f PWNED

x='\''a[$(echo 42 | tee PWNED)]=1'\''
echo $(( x ))

if test -f PWNED; then
  cat PWNED
else
  echo NOPE
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 process sub <(echo 42 | tee PWNED) not allowed' {
  local cmd='rm -f PWNED

x='\''a[<(echo 42 | tee PWNED)]=1'\''
echo $(( x ))

if test -f PWNED; then
  cat PWNED
else
  echo NOPE
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 unset doesn'\''t allow command execution' {
  local cmd='typeset -a a  # for mksh
a=(42)
echo len=${#a[@]}

unset -v '\''a[$(echo 0 | tee PWNED)]'\''
echo len=${#a[@]}

if test -f PWNED; then
  echo PWNED
  cat PWNED
else
  echo NOPE
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 printf integer size bug' {
  local cmd='# from Koiche on Zulip

printf '\''%x\n'\'' 2147483648
printf '\''%u\n'\'' 2147483648'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 (( status bug' {
  local cmd='case $SH in dash|ash) exit ;; esac

# from Koiche on Zulip

(( 1 << 32 ))
echo status=$?

(( 1 << 32 )) && echo yes'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 autotools as_fn_arith bug in configure' {
  local cmd='# Causes '\''grep -e'\'' check to infinite loop.
# Reduced from a configure script.

as_fn_arith() {
  as_val=$(( $* ))
}

as_fn_arith 0 + 1
echo as_val=$as_val'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 OSH can use ARGV name' {
  local cmd='case $SH in dash|ash) exit ;; esac

foo() {
  if test -v ARGV; then
    echo '\''BUG local'\''
  fi
  ARGV=( a b )
  echo len=${#ARGV[@]}
}

if test -v ARGV; then
  echo '\''BUG global'\''
fi
foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Crash in {1..10} - issue #2296' {
  local cmd='{1..10}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Crash after changing [] to be alias of (( ))' {
  local cmd='echo $[i + 1]
case foo in
  foo) echo hello ;;
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 #2640 Hanging when reading from character devices' {
  local cmd='# Relies on timeout from GNU coreutils
timeout 0.5 $SH -c '\''cat /dev/zero | cat | head -c 5 | tr \\0 0; echo'\''

# The exact cause of the issue is:
#
#  $ cat /dev/zero | cat | head -c 5
#
# A pipe through cat is necessary and the first cat MUST be reading from a
# character device.

# Other cases without the bug above
printf '\''\0\0\0\0\0\0\0'\'' > tmp.txt
$SH -c '\''cat </dev/zero | head -c 5 | tr \\0 0; echo'\''
$SH -c '\''cat /dev/zero | head -c 5 | tr \\0 0; echo'\''
$SH -c '\''cat tmp.txt | cat | head -c 5 | tr \\0 0; echo'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

