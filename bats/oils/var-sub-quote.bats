#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-sub-quote.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 {empty:-}' {
  local cmd='empty=
argv.py "${empty:-}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 {empty:-}' {
  local cmd='empty=
argv.py ${empty:-}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 array with empty values' {
  local cmd='declare -a A=('\'''\'' x "" '\'''\'')
argv.py "${A[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 substitution of IFS character, quoted and unquoted' {
  local cmd='IFS=:
s=:
argv.py $s
argv.py "$s"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 :-' {
  local cmd='empty='\'''\''
argv.py ${empty:-a} ${Unset:-b}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 -' {
  local cmd='empty='\'''\''
argv.py ${empty-a} ${Unset-b}
# empty one is still elided!'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Inner single quotes' {
  local cmd='argv.py ${Unset:-'\''b'\''}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Inner single quotes, outer double quotes' {
  local cmd='# This is the WEIRD ONE.  Single quotes appear outside.  But all shells agree!
argv.py "${Unset:-'\''b'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Inner double quotes' {
  local cmd='argv.py ${Unset:-"b"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Inner double quotes, outer double quotes' {
  local cmd='argv.py "${Unset-"b"}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Multiple words: no quotes' {
  local cmd='argv.py ${Unset:-a b c}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Multiple words: no outer quotes, inner single quotes' {
  local cmd='argv.py ${Unset:-'\''a b c'\''}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Multiple words: no outer quotes, inner double quotes' {
  local cmd='argv.py ${Unset:-"a b c"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Multiple words: outer double quotes, no inner quotes' {
  local cmd='argv.py "${Unset:-a b c}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Multiple words: outer double quotes, inner double quotes' {
  local cmd='argv.py "${Unset:-"a b c"}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Multiple words: outer double quotes, inner single quotes' {
  local cmd='argv.py "${Unset:-'\''a b c'\''}"
# WEIRD ONE.'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Mixed inner quotes' {
  local cmd='argv.py ${Unset:-"a b" c}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Mixed inner quotes with outer quotes' {
  local cmd='argv.py "${Unset:-"a b" c}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 part_value tree with multiple words' {
  local cmd='argv.py ${a:-${a:-"1 2" "3 4"}5 "6 7"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 part_value tree on RHS' {
  local cmd='v=${a:-${a:-"1 2" "3 4"}5 "6 7"}
argv.py "${v}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Var with multiple words: no quotes' {
  local cmd='var='\''a b c'\''
argv.py ${Unset:-$var}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Multiple words: no outer quotes, inner single quotes' {
  local cmd='var='\''a b c'\''
argv.py ${Unset:-'\''$var'\''}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 Multiple words: no outer quotes, inner double quotes' {
  local cmd='var='\''a b c'\''
argv.py ${Unset:-"$var"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Multiple words: outer double quotes, no inner quotes' {
  local cmd='var='\''a b c'\''
argv.py "${Unset:-$var}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Multiple words: outer double quotes, inner double quotes' {
  local cmd='var='\''a b c'\''
argv.py "${Unset:-"$var"}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Multiple words: outer double quotes, inner single quotes' {
  local cmd='# WEIRD ONE.
#
# I think I should just disallow any word with single quotes inside double
# quotes.
var='\''a b c'\''
argv.py "${Unset:-'\''$var'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 No outer quotes, Multiple internal quotes' {
  local cmd='# It'\''s like a single command word.  Parts are joined directly.
var='\''a b c'\''
argv.py ${Unset:-A$var " $var"D E F}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Strip a string with single quotes, unquoted' {
  local cmd='foo="'\''a b c d'\''"
argv.py ${foo%d\'\''}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 Strip a string with single quotes, double quoted' {
  local cmd='foo="'\''a b c d'\''"
argv.py "${foo%d\'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 The string to strip is space sensitive' {
  local cmd='foo='\''a b c d'\''
argv.py "${foo%c d}" "${foo%c  d}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 The string to strip can be single quoted, outer is unquoted' {
  local cmd='foo='\''a b c d'\''
argv.py ${foo%'\''c d'\''} ${foo%'\''c  d'\''}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Syntax error for single quote in double quote' {
  local cmd='foo="'\''a b c d'\''"
argv.py "${foo%d'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 {undef-'\''c d'\''} and {foo%'\''c d'\''} are parsed differently' {
  local cmd='# quotes are LITERAL here
argv.py "${undef-'\''c d'\''}" "${undef-'\''c  d'\''}"
argv.py ${undef-'\''c d'\''} ${undef-'\''c  d'\''}

echo ---

# quotes are RESPECTED here
foo='\''a b c d'\''
argv.py "${foo%'\''c d'\''}" "${foo%'\''c  d'\''}"

case $SH in dash) exit ;; esac

argv.py "${foo//'\''c d'\''/zzz}" "${foo//'\''c  d'\''/zzz}"
argv.py "${foo//'\''c d'\''/'\''zzz'\''}" "${foo//'\''c  d'\''/'\''zzz'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 '\'''\'' allowed within VarSub arguments' {
  local cmd='# Odd behavior of bash/mksh: $'\'''\'' is recognized but NOT '\'''\''!
x=abc
echo ${x%$'\''b'\''*}
echo "${x%$'\''b'\''*}"  # git-prompt.sh relies on this'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 # operator with single quoted arg (dash/ash and bash/mksh disagree, reported by Crestwave)' {
  local cmd='var=a
echo -${var#'\''a'\''}-
echo -"${var#'\''a'\''}"-
var="'\''a'\''"
echo -${var#'\''a'\''}-
echo -"${var#'\''a'\''}"-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 / operator with single quoted arg (causes syntax error in regex in OSH, reported by Crestwave)' {
  local cmd='var="++--'\'''\''++--'\'''\''"
echo no plus or minus "${var//[+-]}"
echo no plus or minus "${var//['\''+-'\'']}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 single quotes work inside character classes' {
  local cmd='x='\''a[[[---]]]b'\''
echo "${x//['\''[]'\'']}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 comparison: :- operator with single quoted arg' {
  local cmd='echo ${unset:-'\''a'\''}
echo "${unset:-'\''a'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 Right Brace as argument (similar to #702)' {
  local cmd='echo "${var-}}"
echo "${var-\}}"
echo "${var-'\''}'\''}"
echo "${var-"}"}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 Var substitution with newlines (#2492)' {
  local cmd='echo "${var-a \
b}"
echo "${var-a
b}"

echo "${var:-c \
d}"
echo "${var:-c
d}"

var=set
echo "${var:+e \
f}"
echo "${var:+e
f}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 Var substitution with n in value' {
  local cmd='echo "${var-a\nb}"
echo "${var:-c\nd}"
var=val
echo "${var:+e\nf}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

