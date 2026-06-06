#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-bracket.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 zero args: [ ]' {
  local cmd='[ ] || echo false'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 one arg: [ x ] where x is one of '\''='\'' '\''!'\'' '\''('\'' '\'']'\''' {
  local cmd='[ = ]
echo status=$?
[ ] ]
echo status=$?
[ '\''!'\'' ]
echo status=$?
[ '\''('\'' ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 one arg: empty string is false.  Equivalent to -n.' {
  local cmd='test '\''a'\''  && echo true
test '\'''\''   || echo false'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 -a as unary operator (alias of -e)' {
  local cmd='# NOT IMPLEMENTED FOR OSH, but could be later.  See comment in core/id_kind.py.
[ -a / ]
echo status=$?
[ -a /nonexistent ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 two args: -z with = ! ( ]' {
  local cmd='[ -z = ]
echo status=$?
[ -z ] ]
echo status=$?
[ -z '\''!'\'' ]
echo status=$?
[ -z '\''('\'' ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 three args' {
  local cmd='[ foo = '\'''\'' ]
echo status=$?
[ foo -a '\'''\'' ]
echo status=$?
[ foo -o '\'''\'' ]
echo status=$?
[ ! -z foo ]
echo status=$?
[ \( foo \) ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 four args' {
  local cmd='[ ! foo = foo ]
echo status=$?
[ \( -z foo \) ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 test with extra args is syntax error' {
  local cmd='test -n x ]
echo status=$?
test -n x y
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 ] syntax errors' {
  local cmd='[
echo status=$?
test  # not a syntax error
echo status=$?
[ -n x  # missing ]
echo status=$?
[ -n x ] y  # extra arg after ]
echo status=$?
[ -n x y  # extra arg
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 -n' {
  local cmd='test -n '\''a'\''  && echo true
test -n '\'''\''   || echo false'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 ! -a' {
  local cmd='[ -z '\'''\'' -a ! -z x ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 -o' {
  local cmd='[ -z x -o ! -z x ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 ( )' {
  local cmd='[ -z '\'''\'' -a '\''('\'' ! -z x '\'')'\'' ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 ( ) ! -a -o with system version of [' {
  local cmd='command [ --version
command [ -z '\'''\'' -a '\''('\'' ! -z x '\'')'\'' ] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 == is alias for =' {
  local cmd='[ a = a ] && echo true
[ a == a ] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 == and = does not do glob' {
  local cmd='[ abc = '\''a*'\'' ]
echo status=$?
[ abc == '\''a*'\'' ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 [ with op variable' {
  local cmd='# OK -- parsed AFTER evaluation of vars
op='\''='\''
[ a $op a ] && echo true
[ a $op b ] || echo false'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 [ with unquoted empty var' {
  local cmd='empty='\'''\''
[ $empty = '\'''\'' ] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 [ compare with literal -f' {
  local cmd='# Hm this is the same
var=-f
[ $var = -f ] && echo true
[ '\''-f'\'' = $var ] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 [ '\''('\'' foo ] is runtime syntax error' {
  local cmd='[ '\''('\'' foo ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 -z '\''>'\'' implies two token lookahead' {
  local cmd='[ -z ] && echo true  # -z is operand
[ -z '\''>'\'' ] || echo false  # -z is operator
[ -z '\''>'\'' -- ] && echo true  # -z is operand'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 operator/operand ambiguity with ]' {
  local cmd='# bash parses this as '\''-z'\'' AND '\'']'\'', which is true.  It'\''s a syntax error in
# dash/mksh.
[ -z -a ] ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 operator/operand ambiguity with -a' {
  local cmd='# bash parses it as '\''-z'\'' AND '\''-a'\''.  It'\''s a syntax error in mksh but somehow a
# runtime error in dash.
[ -z -a -a ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 -d' {
  local cmd='test -d $TMP
echo status=$?
test -d $TMP/__nonexistent_Z_Z__
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 -x' {
  local cmd='rm -f $TMP/x
echo '\''echo hi'\'' > $TMP/x
test -x $TMP/x || echo '\''no'\''
chmod +x $TMP/x
test -x $TMP/x && echo '\''yes'\''
test -x $TMP/__nonexistent__ || echo '\''bad'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 -r' {
  local cmd='echo '\''1'\'' > $TMP/testr_yes
echo '\''2'\'' > $TMP/testr_no
chmod -r $TMP/testr_no  # remove read permission
test -r $TMP/testr_yes && echo '\''yes'\''
test -r $TMP/testr_no || echo '\''no'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 -w' {
  local cmd='rm -f $TMP/testw_*
echo '\''1'\'' > $TMP/testw_yes
echo '\''2'\'' > $TMP/testw_no
chmod -w $TMP/testw_no  # remove write permission
test -w $TMP/testw_yes && echo '\''yes'\''
test -w $TMP/testw_no || echo '\''no'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 -k for sticky bit' {
  local cmd='# not isolated: /tmp usually has sticky bit on
# https://en.wikipedia.org/wiki/Sticky_bit

test -k /tmp
echo status=$?

test -k /bin
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 -h and -L test for symlink' {
  local cmd='tmp=$TMP/builtin-test-1
mkdir -p $tmp
touch $tmp/zz
ln -s -f $tmp/zz $tmp/symlink
ln -s -f $tmp/__nonexistent_ZZ__ $tmp/dangling
test -L $tmp/zz || echo no
test -h $tmp/zz || echo no
test -f $tmp/symlink && echo is-file
test -L $tmp/symlink && echo symlink
test -h $tmp/symlink && echo symlink
test -L $tmp/dangling && echo dangling
test -h $tmp/dangling  && echo dangling
test -f $tmp/dangling  || echo '\''dangling is not file'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 -t 1 for stdout' {
  local cmd='# There is no way to get a terminal in the test environment?
[ -t 1 ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 [ -t invalid ]' {
  local cmd='[ -t invalid ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 -ot and -nt' {
  local cmd='touch -d 2017/12/31 $TMP/x
touch -d 2018/01/01 > $TMP/y
test $TMP/x -ot $TMP/y && echo '\''older'\''
test $TMP/x -nt $TMP/y || echo '\''not newer'\''
test $TMP/x -ot $TMP/x || echo '\''not older than itself'\''
test $TMP/x -nt $TMP/x || echo '\''not newer than itself'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 [ a -eq b ]' {
  local cmd='[ a -eq a ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 test -s' {
  local cmd='test -s __nonexistent
echo status=$?
touch $TMP/empty
test -s $TMP/empty
echo status=$?
echo nonempty > $TMP/nonempty
test -s $TMP/nonempty
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 test -b -c -S (block, character, socket)' {
  local cmd='# NOTE: we do not have the "true" case

echo -b
test -b nonexistent
echo status=$?
test -b testdata
echo status=$?
test -b /
echo status=$?

echo -c
test -c nonexistent
echo status=$?
test -c testdata
echo status=$?

echo -S
test -S nonexistent
echo status=$?
test -S testdata
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 test -p named pipe' {
  local cmd='mkfifo $TMP/fifo
test -p $TMP/fifo
echo status=$?

test -p testdata
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 -G and -O for effective user ID and group ID' {
  local cmd='mkdir -p $TMP/bin

test -O $TMP/bin
echo status=$?
test -O __nonexistent__
echo status=$?

test -G $TMP/bin
echo status=$?
test -G __nonexistent__
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 -u for setuid, -g too' {
  local cmd='touch $TMP/setuid $TMP/setgid
chmod u+s $TMP/setuid
chmod g+s $TMP/setgid

test -u $TMP/setuid
echo status=$?

test -u $TMP/setgid
echo status=$?

test -g $TMP/setuid
echo status=$?

test -g $TMP/setgid
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 -v to test variable (bash)' {
  local cmd='test -v nonexistent
echo global=$?

g=1
test -v g
echo global=$?

f() {
  local f_var=0
  g
}

g() {
  test -v f_var
  echo dynamic=$?
  test -v g
  echo dynamic=$?
  test -v nonexistent
  echo dynamic=$?
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 test -o for options' {
  local cmd='# note: it'\''s lame that the '\''false'\'' case is confused with the '\''typo'\'' case.
# but checking for error code 2 is unlikely anyway.
test -o nounset
echo status=$?

set -o nounset
test -o nounset
echo status=$?

test -o _bad_name_
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '041 -nt -ot' {
  local cmd='[ present -nt absent ] || exit 1
[ absent -ot present ] || exit 2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '042 -ef' {
  local cmd='left=$TMP/left
right=$TMP/right
touch $left $right

ln -f $TMP/left $TMP/hardlink

test $left -ef $left && echo same
test $left -ef $TMP/hardlink && echo same
test $left -ef $right || echo different

test $TMP/__nonexistent -ef $right || echo different'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '043 Overflow error' {
  local cmd='test -t 12345678910
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '044 Bug regression' {
  local cmd='test "$ipv6" = "yes" -a "$ipv6lib" != "none"
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '045 test -c' {
  local cmd='test -c /dev/zero
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '046 test -S' {
  local cmd='test -S /dev/zero
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '047 bug from pnut: negative number ((-1))' {
  local cmd='# https://lobste.rs/s/lplim1/design_self_compiling_c_transpiler#c_km2ywc

[ $((-42)) -le 0 ]
echo status=$?

[ $((-1)) -le 0 ]
echo status=$?

echo

[ -1 -le 0 ]
echo status=$?

[ -42 -le 0 ]
echo status=$?

echo

test -1 -le 0
echo status=$?

test -42 -le 0
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '048 negative octal numbers, etc.' {
  local cmd='# zero
[ -0 -eq 0 ]
echo zero=$?

# octal numbers can be negative
[ -0123 -eq -83 ]
echo octal=$?

# hex doesn'\''t have negative numbers?
[ -0xff -eq -255 ]
echo hex=$?

# base N doesn'\''t either
[ -64#a -eq -10 ]
echo baseN=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '049 More negative numbers' {
  local cmd='case $SH in dash) exit ;; esac

[[ -1 -le 0 ]]
echo status=$?

[[ $((-1)) -le 0 ]]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '050 No octal, hex, base N conversion - leading 0 is a regular decimal' {
  local cmd='# arithmetic has octal conversion
echo $(( 073 ))
echo $(( -073 ))

echo

# Bracket does NOT have octal conversion!  That is annoying.
[ 073 -eq 73 ]
echo status=$?

[ -073 -eq -73 ]
echo status=$?

echo

[ 0xff -eq 255 ]
echo hex=$?
[ 64#a -eq 10 ]
echo baseN=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '051 Looks like octal, but digit is too big' {
  local cmd='# arithmetic has octal conversion
echo $(( 083 ))
echo status=$?

echo $(( -083 ))
echo status=$?

echo

# Bracket does NOT have octal conversion!  That is annoying.
[ 083 -eq 83 ]
echo status=$?

[ -083 -eq -83 ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '052 no recursive arith [ 1+2 -eq 3 ]' {
  local cmd='[ 1+2 -eq 3 ]
echo status=$?

s='\''1+2'\''
[ "$s" -eq 3 ]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

