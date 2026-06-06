#!/usr/bin/env bats
# Generated from oils-for-unix spec/dbracket.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 [[ glob matching, [[ has no glob expansion' {
  local cmd='[[ foo.py == *.py ]] && echo true
[[ foo.p  == *.py ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 [[ glob matching with escapes' {
  local cmd='[[ '\''foo.*'\'' == *."*" ]] && echo true
# note that the pattern arg to fnmatch should be '\''*.\*'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 equality' {
  local cmd='[[ '\''*.py'\'' == '\''*.py'\'' ]] && echo true
[[ foo.py == '\''*.py'\'' ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 [[ glob matching with unquoted var' {
  local cmd='pat=*.py
[[ foo.py == $pat ]] && echo true
[[ foo.p  == $pat ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 [[ regex matching' {
  local cmd='# mksh doesn'\''t have this syntax of regex matching.  I guess it comes from perl?
regex='\''.*\.py'\''
[[ foo.py =~ $regex ]] && echo true
[[ foo.p  =~ $regex ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 [[ regex syntax error' {
  local cmd='# hm, it doesn'\''t show any error, but it exits 2.
[[ foo.py =~ * ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 [[ has no word splitting' {
  local cmd='var='\''one two'\''
[[ '\''one two'\'' == $var ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 [[ has quote joining' {
  local cmd='var='\''one two'\''
[[ '\''one '\''tw"o" == $var ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 [[ empty string is false' {
  local cmd='[[ '\''a'\'' ]] && echo true
[[ '\'''\''  ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 && chain' {
  local cmd='[[ t && t && '\'''\'' ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 || chain' {
  local cmd='[[ '\'''\'' || '\'''\'' || t ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 [[ compound expressions' {
  local cmd='# Notes on whitespace:
# - 1 and == need space seprating them, but ! and ( don'\''t.
# - [[ needs whitesapce after it, but ]] doesn'\''t need whitespace before it!
[[ '\'''\''||! (1 == 2)&&(2 == 2)]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 precedence of && and || inside [[' {
  local cmd='[[ True || '\'''\'' && '\'''\'' ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 precedence of && and || in a command context' {
  local cmd='if test True || test '\'''\'' && test '\'''\''; then
  echo YES
else
  echo "NO precedence"
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Octal literals with -eq' {
  local cmd='shopt -u strict_arith || true
decimal=15
octal=017   # = 15 (decimal)
[[ $decimal -eq $octal ]] && echo true
[[ $decimal -eq ZZZ$octal ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Hex literals with -eq' {
  local cmd='shopt -u strict_arith || true
decimal=15
hex=0x0f    # = 15 (decimal)
[[ $decimal -eq $hex ]] && echo true
[[ $decimal -eq ZZZ$hex ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 > on strings' {
  local cmd='# NOTE: < doesn'\''t need space, even though == does?  That'\''s silly.
[[ b>a ]] && echo true
[[ b<a ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 != on strings' {
  local cmd='# NOTE: b!=a does NOT work
[[ b != a ]] && echo true
[[ a != a ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 -eq on strings' {
  local cmd='# This is lame behavior: it does a conversion to 0 first for any string
shopt -u strict_arith || true
[[ a -eq a ]] && echo true
[[ a -eq b ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 [[ compare with literal -f (compare with test-builtin.test.sh)' {
  local cmd='var=-f
[[ $var == -f ]] && echo true
[[ '\''-f'\'' == $var ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 [[ with op variable (compare with test-builtin.test.sh)' {
  local cmd='# Parse error -- parsed BEFORE evaluation of vars
op='\''=='\''
[[ a $op a ]] && echo true
[[ a $op b ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 [[ with unquoted empty var (compare with test-builtin.test.sh)' {
  local cmd='empty='\'''\''
[[ $empty == '\'''\'' ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 [[ at runtime doesn'\''t work' {
  local cmd='dbracket=[[
$dbracket foo == foo ]]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 [[ with env prefix doesn'\''t work' {
  local cmd='FOO=bar [[ foo == foo ]]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 [[ over multiple lines is OK' {
  local cmd='# Hm it seems you can'\''t split anywhere?
[[ foo == foo
&& bar == bar
]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Argument that looks like a real operator' {
  local cmd='[[ -f < ]] && echo '\''should be parse error'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 User array compared to @ (broken unless shopt -s strict_array)' {
  local cmd='# Both are coerced to string!  It treats it more like an  UNQUOTED ${a[@]}.

a=('\''1 3'\'' 5)
b=(1 2 3)
set -- 1 '\''3 5'\''
[[ "$@" = "${a[@]}" ]] && echo true
[[ "$@" = "${b[@]}" ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Array coerces to string (shopt -s strict_array to disallow)' {
  local cmd='a=('\''1 3'\'' 5)
[[ '\''1 3 5'\'' = "${a[@]}" ]] && echo true
[[ '\''1 3 4'\'' = "${a[@]}" ]] || echo false'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 (( array1 == array2 )) doesn'\''t work' {
  local cmd='a=('\''1 3'\'' 5)
b=('\''1 3'\'' 5)
c=('\''1'\'' '\''3 5'\'')
d=('\''1'\'' '\''3 6'\'')

# shells EXPAND a and b first
(( a == b ))
echo status=$?

(( a == c ))
echo status=$?

(( a == d ))
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 Quotes don'\''t matter in comparison' {
  local cmd='[[ '\''3'\'' = 3 ]] && echo true
[[ '\''3'\'' -eq 3 ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 -eq does dynamic arithmetic parsing (not supported in OSH)' {
  local cmd='[[ 1+2 -eq 3 ]] && echo true
expr='\''1+2'\''
[[ $expr -eq 3 ]] && echo true  # must be dynamically parsed'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 -eq coercion produces weird results' {
  local cmd='shopt -u strict_arith || true
[[ '\'''\'' -eq 0 ]] && echo true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 [[ '\''('\'' ]] is treated as literal' {
  local cmd='[[ '\''('\'' ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 [[ '\''('\'' foo ]] is syntax error' {
  local cmd='[[ '\''('\'' foo ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 empty ! is treated as literal' {
  local cmd='[[ '\''!'\'' ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 [[ -z ]] is syntax error' {
  local cmd='[[ -z ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 [[ -z '\''>'\'' ]]' {
  local cmd='[[ -z '\''>'\'' ]] || echo false  # -z is operator'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 [[ -z '\''>'\'' a ]] is syntax error' {
  local cmd='[[ -z '\''>'\'' -- ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 test whether '\'']]'\'' is empty' {
  local cmd='[[ '\'']]'\'' ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 [[ ]] is syntax error' {
  local cmd='[[ ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 [[ && ]] is syntax error' {
  local cmd='[[ && ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 [[ a 3< b ]] doesn'\''t work (bug regression)' {
  local cmd='[[ a 3< b ]]
echo status=$?
[[ a 3> b ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 tilde expansion in [[' {
  local cmd='HOME=/home/bob
[[ ~ == /home/bob ]]
echo status=$?

[[ ~ == */bob ]]
echo status=$?

[[ ~ == */z ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 more tilde expansion' {
  local cmd='[[ ~ ]]
echo status=$?
HOME='\'''\''
[[ ~ ]]
echo status=$?
[[ -n ~ ]]
echo unary=$?

[[ ~ == ~ ]]
echo status=$?

[[ $HOME == ~ ]]
echo fnmatch=$?
[[ ~ == $HOME ]]
echo fnmatch=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 tilde expansion with =~ (confusing)' {
  local cmd='case $SH in mksh) exit ;; esac

HOME=foo
[[ ~ =~ $HOME ]]
echo regex=$?
[[ $HOME =~ ~ ]]
echo regex=$?

HOME='\''^a$'\''  # looks like regex
[[ ~ =~ $HOME ]]
echo regex=$?
[[ $HOME =~ ~ ]]
echo regex=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '046 [[ ]] with redirect' {
  local cmd='[[ $(stdout_stderr.py) == STDOUT ]] 2>$TMP/x.txt
echo $?
echo --
cat $TMP/x.txt'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '047 special chars' {
  local cmd='[[ ^ == ^ ]]
echo caret $?
[[ '\''!'\'' == ! ]]
echo bang $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 () in pattern (regression)' {
  local cmd='if [[ '\''foo()'\'' == *\(\) ]]; then echo match1; fi
if [[ '\''foo()'\'' == *'\''()'\'' ]]; then echo match2; fi
if [[ '\''foo()'\'' == '\''*()'\'' ]]; then echo match3; fi

shopt -s extglob

if [[ '\''foo()'\'' == *\(\) ]]; then echo match1; fi
if [[ '\''foo()'\'' == *'\''()'\'' ]]; then echo match2; fi
if [[ '\''foo()'\'' == '\''*()'\'' ]]; then echo match3; fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '049 negative numbers - zero, decimal, octal, hex, base N' {
  local cmd='[[ -0 -eq 0 ]]; echo zero=$?

[[ -42 -eq -42 ]]; echo decimal=$?

# note: mksh doesn'\''t do octal conversion
[[ -0123 -eq -83 ]]; echo octal=$?

[[ -0xff -eq -255 ]]; echo hex=$?

[[ -64#a -eq -10 ]]; echo baseN=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

