#!/usr/bin/env bats
# Generated from oils-for-unix spec/arith.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Side Effect in Array Indexing' {
  local cmd='a=(4 5 6)
echo "${a[b=2]} b=$b"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Add one to var' {
  local cmd='i=1
echo $(($i+1))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003  is optional' {
  local cmd='i=1
echo $((i+1))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 SimpleVarSub within arith' {
  local cmd='j=0
echo $(($j + 42))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 BracedVarSub within ArithSub' {
  local cmd='echo $((${j:-5} + 1))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Arith word part' {
  local cmd='foo=1; echo $((foo+1))bar$(($foo+1))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Arith sub with word parts' {
  local cmd='# Making 13 from two different kinds of sub.  Geez.
echo $((1 + $(echo 1)${undefined:-3}))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Constant with quotes like '\''1'\''' {
  local cmd='# NOTE: Compare with [[.  That is a COMMAND level expression, while this is a
# WORD level expression.
echo $(('\''1'\'' + 2))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Arith sub within arith sub' {
  local cmd='# This is unnecessary but works in all shells.
echo $((1 + $((2 + 3)) + 4))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Backticks within arith sub' {
  local cmd='# This is unnecessary but works in all shells.
echo $((`echo 1` + 2))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Invalid string to int' {
  local cmd='# bash, mksh, and zsh all treat strings that don'\''t look like numbers as zero.
shopt -u strict_arith || true
s=foo
echo $((s+5))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Invalid string to int with strict_arith' {
  local cmd='shopt -s strict_arith || true
s=foo
echo $s
echo $((s+5))
echo '\''should not get here'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Integer constant parsing' {
  local cmd='echo $(( 0x12A ))
echo $(( 0x0A ))
echo $(( 0777 ))
echo $(( 0010 ))
echo $(( 24#ag7 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Integer constant validation' {
  local cmd='check() {
  $SH -c "shopt --set strict_arith; echo $1"
  echo status=$?
}

check '\''$(( 0x1X ))'\''
check '\''$(( 09 ))'\''
check '\''$(( 2#A ))'\''
check '\''$(( 02#0110 ))'\'''
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Newline in the middle of expression' {
  local cmd='echo $((1
+ 2))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Ternary operator' {
  local cmd='a=1
b=2
echo $((a>b?5:10))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 Preincrement' {
  local cmd='a=4
echo $((++a))
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 Postincrement' {
  local cmd='a=4
echo $((a++))
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 Increment undefined variables' {
  local cmd='shopt -u strict_arith || true
(( undef1++ ))
(( ++undef2 ))
echo "[$undef1][$undef2]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Increment and decrement array elements' {
  local cmd='shopt -u strict_arith || true
a=(5 6 7 8)
(( a[0]++, ++a[1], a[2]--, --a[3] ))
(( undef[0]++, ++undef[1], undef[2]--, --undef[3] ))
echo "${a[@]}" - "${undef[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Increment undefined variables with nounset' {
  local cmd='set -o nounset
(( undef1++ ))
(( ++undef2 ))
echo "[$undef1][$undef2]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 Comma operator (borrowed from C)' {
  local cmd='a=1
b=2
echo $((a,(b+1)))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 Augmented assignment' {
  local cmd='a=4
echo $((a+=1))
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 Comparison Ops' {
  local cmd='echo $(( 1 == 1 ))
echo $(( 1 != 1 ))
echo $(( 1 < 1 ))
echo $(( 1 <= 1 ))
echo $(( 1 > 1 ))
echo $(( 1 >= 1 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 Logical Ops' {
  local cmd='echo $((1 || 2))
echo $((1 && 2))
echo $((!(1 || 2)))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 Logical Ops Short Circuit' {
  local cmd='x=11
(( 1 || (x = 22) ))
echo $x
(( 0 || (x = 33) ))
echo $x
(( 0 && (x = 44) ))
echo $x
(( 1 && (x = 55) ))
echo $x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 Bitwise ops' {
  local cmd='echo $((1|2))
echo $((1&2))
echo $((1^2))
echo $((~(1|2)))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 Unary minus and plus' {
  local cmd='a=1
b=3
echo $((- a + + b))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 No floating point' {
  local cmd='echo $((1 + 2.3))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 Array indexing in arith' {
  local cmd='# zsh does 1-based indexing!
array=(1 2 3 4)
echo $((array[1] + array[2]*3))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 Constants in base 36' {
  local cmd='echo $((36#a))-$((36#z))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 Constants in bases 2 to 64' {
  local cmd='# This is a truly bizarre syntax.  Oh it comes from zsh... which allows 36.
echo $((64#a))-$((64#z)), $((64#A))-$((64#Z)), $((64#@)), $(( 64#_ ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 Multiple digit constants with base N' {
  local cmd='echo $((10#0123)), $((16#1b))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 Dynamic base constants' {
  local cmd='base=16
echo $(( ${base}#a ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 Octal constant' {
  local cmd='echo $(( 011 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 Dynamic octal constant' {
  local cmd='zero=0
echo $(( ${zero}11 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 Dynamic hex constants' {
  local cmd='zero=0
echo $(( ${zero}xAB ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 Hex constant with capital X' {
  local cmd='echo $(( 0XAA ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 Dynamic var names - result of runtime parse/eval' {
  local cmd='foo=5
x=oo
echo $(( foo + f$x + 1 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 Recursive name evaluation is a result of runtime parse/eval' {
  local cmd='foo=5
bar=foo
spam=bar
eggs=spam
echo $((foo+1)) $((bar+1)) $((spam+1)) $((eggs+1))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '041 nounset with arithmetic' {
  local cmd='set -o nounset
x=$(( y + 5 ))
echo "should not get here: x=${x:-<unset>}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '042 64-bit integer doesn'\''t overflow' {
  local cmd='a=$(( 1 << 31 ))
echo $a

b=$(( a + a ))
echo $b

c=$(( b + a ))
echo $c

x=$(( 1 << 62 ))
y=$(( x - 1 ))
echo "max positive = $(( x + y ))"

#echo "overflow $(( x + x ))"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '043 More 64-bit ops' {
  local cmd='#shopt -s strict_arith

# This overflows - the extra 9 puts it above 2**31
#echo $(( 12345678909 ))

[[ 12345678909 = $(( 1 << 30 )) ]]
echo eq=$?
[[ 12345678909 = 12345678909 ]]
echo eq=$?

# Try both [ and [[
[ 12345678909 -gt $(( 1 << 30 )) ]
echo greater=$?
[[ 12345678909 -gt $(( 1 << 30 )) ]]
echo greater=$?

[[ 12345678909 -ge $(( 1 << 30 )) ]]
echo ge=$?
[[ 12345678909 -ge 12345678909 ]]
echo ge=$?

[[ 12345678909 -le $(( 1 << 30 )) ]]
echo le=$?
[[ 12345678909 -le 12345678909 ]]
echo le=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '044 Invalid LValue' {
  local cmd='a=9
(( (a + 2) = 3 ))
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '045 Invalid LValue that looks like array' {
  local cmd='(( 1[2] = 3 ))
echo "status=$?"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '046 Invalid LValue: two sets of brackets' {
  local cmd='(( a[1][2] = 3 ))
echo "status=$?"
#   shells treat this as a NON-fatal error'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '047 Operator Precedence' {
  local cmd='echo $(( 1 + 2*3 - 8/2 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '048 Exponentiation with **' {
  local cmd='echo $(( 3 ** 0 ))
echo $(( 3 ** 1 ))
echo $(( 3 ** 2 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '049 Exponentiation operator has buggy precedence' {
  local cmd='# NOTE: All shells agree on this, but R and Python give -9, which is more
# mathematically correct.
echo $(( -3 ** 2 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '050 Negative exponent' {
  local cmd='# bash explicitly disallows negative exponents!
echo $(( 2**-1 * 5 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '051 Comment not allowed in the middle of multiline arithmetic' {
  local cmd='echo $((
1 +
2 + \
3
))
echo $((
1 + 2  # not a comment
))
(( a = 3 + 4  # comment
))
echo [$a]'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '052 Add integer to indexed array (a[0] decay)' {
  local cmd='declare -a array=(1 2 3)
echo $((array + 5))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '053 Add integer to associative array (a[0] decay)' {
  local cmd='typeset -A assoc
assoc[0]=42
echo $((assoc + 5))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '054 Double subscript' {
  local cmd='a=(1 2 3)
echo $(( a[1] ))
echo $(( a[1][1] ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '055 result of ArithSub -- array[0] decay' {
  local cmd='a=(4 5 6)
echo declared
b=$(( a ))
echo $b'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '056 result of ArithSub -- assoc[0] decay' {
  local cmd='declare -A A=(['\''foo'\'']=bar ['\''spam'\'']=eggs)
echo declared
b=$(( A ))
echo $b'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '057 comma operator' {
  local cmd='a=(4 5 6)

# zsh and osh can'\''t evaluate the array like that
# which is consistent with their behavior on $(( a ))

echo $(( a, last = a[2], 42 ))
echo last=$last'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '058 assignment with dynamic var name' {
  local cmd='foo=bar
echo $(( x$foo = 42 ))
echo xbar=$xbar'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '059 array assignment with dynamic array name' {
  local cmd='foo=bar
echo $(( x$foo[5] = 42 ))
echo '\''xbar[5]='\''${xbar[5]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '060 unary assignment with dynamic var name' {
  local cmd='foo=bar
xbar=42
echo $(( x$foo++ ))
echo xbar=$xbar'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '061 unary array assignment with dynamic var name' {
  local cmd='foo=bar
xbar[5]=42
echo $(( x$foo[5]++ ))
echo '\''xbar[5]='\''${xbar[5]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '062 Dynamic parsing of arithmetic' {
  local cmd='e=1+2
echo $(( e + 3 ))
[[ e -eq 3 ]] && echo true
[ e -eq 3 ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '063 Dynamic parsing on empty string' {
  local cmd='a='\'''\''
echo $(( a ))

a2='\'' '\''
echo $(( a2 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '064 nested ternary (bug fix)' {
  local cmd='echo $((1?2?3:4:5))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '065 1 ? a=1 : b=2 ( bug fix)' {
  local cmd='echo $((1 ? a=1 : 42 ))
echo a=$a

# this does NOT work
#echo $((1 ? a=1 : b=2 ))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '066 Invalid constant' {
  local cmd='echo $((a + x42))
echo status=$?

# weird asymmetry -- the above is a syntax error, but this isn'\''t
$SH -c '\''echo $((a + 42x))'\''
echo status=$?

# regression
echo $((a + 42x))
echo status=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '067 Negative numbers with integer division /' {
  local cmd='echo $(( 10 / 3))
echo $((-10 / 3))
echo $(( 10 / -3))
echo $((-10 / -3))

echo ---

a=20
: $(( a /= 3 ))
echo $a

a=-20
: $(( a /= 3 ))
echo $a

a=20
: $(( a /= -3 ))
echo $a

a=-20
: $(( a /= -3 ))
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '068 Negative numbers with %' {
  local cmd='echo $(( 10 % 3))
echo $((-10 % 3))
echo $(( 10 % -3))
echo $((-10 % -3))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '069 Negative numbers with bit shift' {
  local cmd='echo $(( 5 << 1 ))
echo $(( 5 << 0 ))
$SH -c '\''echo $(( 5 << -1 ))'\''  # implementation defined - OSH fails
echo ---

echo $(( 16 >> 1 ))
echo $(( 16 >> 0 ))
$SH -c '\''echo $(( 16 >> -1 ))'\''  # not sure why this is zero
$SH -c '\''echo $(( 16 >> -2 ))'\''  # also 0
echo ---'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '070 undef[0]' {
  local cmd='echo ARITH $(( undef[0] ))
echo status=$?
echo

(( undef[0] ))
echo status=$?
echo

echo UNDEF ${undef[0]}
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '071 undef[0] with nounset' {
  local cmd='set -o nounset
echo UNSET $(( undef[0] ))
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '072 s[0] with string abc' {
  local cmd='s='\''abc'\''
echo abc $(( s[0] )) $(( s[1] ))
echo status=$?
echo

(( s[0] ))
echo status=$?
echo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '073 s[0] with string 42' {
  local cmd='s='\''42'\''
echo 42 $(( s[0] )) $(( s[1] ))
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '074 s[0] with string '\''12 34'\''' {
  local cmd='s='\''12 34'\''
echo '\''12 34'\'' $(( s[0] )) $(( s[1] ))
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

