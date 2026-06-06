#!/usr/bin/env bats
# Generated from oils-for-unix spec/word-split.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 IFS is scoped' {
  local cmd='IFS=b
word=abcd
f() { local IFS=c; argv.py $word; }
f
argv.py $word'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Tilde sub is not split, but var sub is' {
  local cmd='HOME="foo bar"
argv.py ~
argv.py $HOME'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Word splitting' {
  local cmd='a="1 2"
b="3 4"
argv.py $a"$b"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Word splitting 2' {
  local cmd='a="1 2"
b="3 4"
c="5 6"
d="7 8"
argv.py $a"$b"$c"$d"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 *' {
  local cmd='fun() { argv.py -$*-; }
fun "a 1" "b 2" "c 3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 *' {
  local cmd='fun() { argv.py "-$*-"; }
fun "a 1" "b 2" "c 3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 @' {
  local cmd='# How does this differ from $* ?  I don'\''t think it does.
fun() { argv.py -$@-; }
fun "a 1" "b 2" "c 3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 @' {
  local cmd='fun() { argv.py "-$@-"; }
fun "a 1" "b 2" "c 3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 empty argv' {
  local cmd='argv.py 1 "$@" 2 $@ 3 "$*" 4 $* 5'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 * with empty IFS' {
  local cmd='set -- "1 2" "3  4"

IFS=
argv.py $*
argv.py "$*"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Word elision with space' {
  local cmd='s1='\'' '\''
argv.py $s1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Word elision with non-whitespace IFS' {
  local cmd='# Treated differently than the default IFS.  What is the rule here?
IFS='\''_'\''
char='\''_'\''
space='\'' '\''
empty='\'''\''
argv.py $char
argv.py $space
argv.py $empty'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Leading/trailing word elision with non-whitespace IFS' {
  local cmd='# This behavior is weird.
IFS=_
s1='\''_a_b_'\''
argv.py $s1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Leading '\'' '\'' vs leading '\'' _ '\''' {
  local cmd='# This behavior is weird, but all shells agree.
IFS='\''_ '\''
s1='\''_ a  b _ '\''
s2='\''  a  b _ '\''
argv.py $s1
argv.py $s2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Multiple non-whitespace IFS chars.' {
  local cmd='IFS=_-
s1='\''a__b---c_d'\''
argv.py $s1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 IFS with whitespace and non-whitepace.' {
  local cmd='# NOTE: Three delimiters means two empty words in the middle.  No elision.
IFS='\''_ '\''
s1='\''a_b _ _ _ c  _d e'\''
argv.py $s1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 empty @ and * is elided' {
  local cmd='fun() { argv.py 1 $@ $* 2; }
fun'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 unquoted empty arg is elided' {
  local cmd='empty=""
argv.py 1 $empty 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 unquoted whitespace arg is elided' {
  local cmd='space=" "
argv.py 1 $space 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 empty literals are not elided' {
  local cmd='space=" "
argv.py 1 $space"" 2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 no splitting when IFS is empty' {
  local cmd='IFS=""
foo="a b"
argv.py $foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 default value can yield multiple words' {
  local cmd='argv.py 1 ${undefined:-"2 3" "4 5"} 6'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 default value can yield multiple words with part joining' {
  local cmd='argv.py 1${undefined:-"2 3" "4 5"}6'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 default value with unquoted IFS char' {
  local cmd='IFS=_
argv.py 1${undefined:-"2_3"x_x"4_5"}6'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 IFS empty doesn'\''t do splitting' {
  local cmd='IFS='\'''\''
x=$(python2 -c '\''print(" a b\tc\n")'\'')
argv.py $x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 IFS unset behaves like '\'' tn'\''' {
  local cmd='unset IFS
x=$(python2 -c '\''print(" a b\tc\n")'\'')
argv.py $x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 IFS='\'''\''' {
  local cmd='# NOTE: OSH fails this because of double backslash escaping issue!
IFS='\''\'\''
s='\''a\b'\''
argv.py $s'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 IFS='\'' '\''' {
  local cmd='# NOTE: OSH fails this because of double backslash escaping issue!
# When IFS is \, then you'\''re no longer using backslash escaping.
IFS='\''\ '\''
s='\''a\b \\ c d\'\''
argv.py $s'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 IFS characters are glob metacharacters' {
  local cmd='IFS='\''* '\''
s='\''a*b c'\''
argv.py $s

IFS='\''?'\''
s='\''?x?y?z?'\''
argv.py $s

IFS='\''['\''
s='\''[x[y[z['\''
argv.py $s'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 Trailing space' {
  local cmd='argv.py '\''Xec  ho '\''
argv.py X'\''ec  ho '\''
argv.py X"ec  ho "'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 Empty IFS (regression for bug)' {
  local cmd='IFS=
echo ["$*"]
set a b c
echo ["$*"]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Unset IFS (regression for bug)' {
  local cmd='set a b c
unset IFS
echo ["$*"]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 IFS=o (regression for bug)' {
  local cmd='IFS=o
echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 IFS and joining arrays' {
  local cmd='IFS=:
set -- x '\''y z'\''
argv.py "$@"
argv.py $@
argv.py "$*"
argv.py $*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 IFS and joining arrays by assignments' {
  local cmd='IFS=:
set -- x '\''y z'\''

s="$@"
argv.py "$s"

s=$@
argv.py "$s"

s="$*"
argv.py "$s"

s=$*
argv.py "$s"

# bash and mksh agree, but this doesn'\''t really make sense to me.
# In OSH, "$@" is the only real array, so that'\''s why it behaves differently.'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 TODO' {
  local cmd='empty=""
space=" "
AB="A B"
X="X"
Yspaces=" Y "'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 IFS='\'''\'' with @ and * (bug #627)' {
  local cmd='set -- a '\''b c'\''
IFS='\'''\''
argv.py at $@
argv.py star $*

# zsh agrees'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 IFS='\'''\'' with @ and * and printf (bug #627)' {
  local cmd='set -- a '\''b c'\''
IFS='\'''\''
printf '\''[%s]\n'\'' $@
printf '\''[%s]\n'\'' $*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 IFS='\'''\'' with {a[@]} and {a[*]} (bug #627)' {
  local cmd='case $SH in dash | ash) exit 0 ;; esac

myarray=(a '\''b c'\'')
IFS='\'''\''
argv.py at ${myarray[@]}
argv.py star ${myarray[*]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 IFS='\'''\'' with {!prefix@} and {!prefix*} (bug #627)' {
  local cmd='case $SH in dash | mksh | ash | yash) exit 0 ;; esac

gLwbmGzS_var1=1
gLwbmGzS_var2=2
IFS='\'''\''
argv.py at ${!gLwbmGzS_@}
argv.py star ${!gLwbmGzS_*}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 IFS='\'''\'' with {!a[@]} and {!a[*]} (bug #627)' {
  local cmd='case $SH in dash | mksh | ash | yash) exit 0 ;; esac

IFS='\'''\''
a=(v1 v2 v3)
argv.py at ${!a[@]}
argv.py star ${!a[*]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 Bug #628 split on : with : in literal word' {
  local cmd='# 2025-03: What'\''s the cause of this bug?
#
# OSH is very wrong here
#   ['\''a'\'', '\''\\'\'', '\''b'\'']
# Is this a fundamental problem with the IFS state machine?
# It definitely relates to the use of backslashes.
# So we have at least 4 backslash bugs

IFS='\'':'\''
word='\''a:'\''
argv.py ${word}:b
argv.py ${word}:

echo ---

# Same thing happens for '\''z'\''
IFS='\''z'\''
word='\''az'\''
argv.py ${word}zb
argv.py ${word}z'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 Bug #698, similar crash' {
  local cmd='var='\''\'\''
set -f
echo $var'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 Bug #1664,  with noglob' {
  local cmd='# Note that we'\''re not changing IFS

argv.py [\\]_
argv.py "[\\]_"

# TODO: no difference observed here, go back to original bug

#argv.py [\\_
#argv.py "[\\_"

echo noglob

# repeat cases with -f, noglob
set -f

argv.py [\\]_
argv.py "[\\]_"

#argv.py [\\_
#argv.py "[\\_"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 Empty IFS bug #2141 (from pnut)' {
  local cmd='res=0
sum() {
  # implement callee-save calling convention using `set`
  # here, we save the value of $res after the function parameters
  set $@ $res           # $1 $2 $3 are now set
  res=$(($1 + $2))
  echo "$1 + $2 = $res"
  res=$3                # restore the value of $res
}

unset IFS
sum 12 30 # outputs "12 + 30 = 42"

IFS='\'' '\''
sum 12 30 # outputs "12 + 30 = 42"

IFS=
sum 12 30 # outputs "1230 + 0 = 1230"

# I added this
IFS='\'''\''
sum 12 30

set -u
IFS=
sum 12 30 # fails with "fatal: Undefined variable '\''2'\''" on res=$(($1 + $2))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '046 Unicode in IFS' {
  local cmd='# bash, zsh, and yash support unicode in IFS, but dash/mksh/ash don'\''t.

# for zsh, though we'\''re not testing it here
setopt SH_WORD_SPLIT

x=çx IFS=ç
printf "<%s>\n" $x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '047 4 x 3 table: (default IFS, IFS='\'''\'', IFS=zx) x ( * * @ @ )' {
  local cmd='setopt SH_WORD_SPLIT  # for zsh

set -- '\''a b'\'' c '\'''\''

# default IFS
argv.py '\''  $*  '\''  $*
argv.py '\'' "$*" '\'' "$*"
argv.py '\''  $@  '\''  $@
argv.py '\'' "$@" '\'' "$@"
echo

IFS='\'''\''
argv.py '\''  $*  '\''  $*
argv.py '\'' "$*" '\'' "$*"
argv.py '\''  $@  '\''  $@
argv.py '\'' "$@" '\'' "$@"
echo

IFS=zx
argv.py '\''  $*  '\''  $*
argv.py '\'' "$*" '\'' "$*"
argv.py '\''  $@  '\''  $@
argv.py '\'' "$@" '\'' "$@"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 4 x 3 table - with for loop' {
  local cmd='case $SH in yash) exit ;; esac  # no echo -n

setopt SH_WORD_SPLIT  # for zsh

set -- '\''a b'\'' c '\'''\''

# default IFS
echo -n '\''  $*  '\'';  for i in  $*;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$*" '\'';  for i in "$*"; do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\''  $@  '\'';  for i in  $@;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$@" '\'';  for i in "$@"; do echo -n '\'' '\''; echo -n -$i-; done; echo
echo

IFS='\'''\''
echo -n '\''  $*  '\'';  for i in  $*;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$*" '\'';  for i in "$*"; do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\''  $@  '\'';  for i in  $@;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$@" '\'';  for i in "$@"; do echo -n '\'' '\''; echo -n -$i-; done; echo
echo

IFS=zx
echo -n '\''  $*  '\'';  for i in  $*;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$*" '\'';  for i in "$*"; do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\''  $@  '\'';  for i in  $@;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$@" '\'';  for i in "$@"; do echo -n '\'' '\''; echo -n -$i-; done; echo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '049 IFS=x and '\'''\'' and @ - same bug as spec/toysh-posix case #12' {
  local cmd='case $SH in yash) exit ;; esac  # no echo -n

setopt SH_WORD_SPLIT  # for zsh

set -- one '\'''\'' two

IFS=zx
echo -n '\''  $*  '\'';  for i in  $*;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$*" '\'';  for i in "$*"; do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\''  $@  '\'';  for i in  $@;  do echo -n '\'' '\''; echo -n -$i-; done; echo
echo -n '\'' "$@" '\'';  for i in "$@"; do echo -n '\'' '\''; echo -n -$i-; done; echo

argv.py '\''  $*  '\''  $*
argv.py '\'' "$*" '\'' "$*"
argv.py '\''  $@  '\''  $@
argv.py '\'' "$@" '\'' "$@"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '050 IFS=x and '\'''\'' and @ (#2)' {
  local cmd='setopt SH_WORD_SPLIT  # for zsh

set -- "" "" "" "" ""
argv.py =$@=
argv.py =$*=
echo

IFS=
argv.py =$@=
argv.py =$*=
echo

IFS=x
argv.py =$@=
argv.py =$*='
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '051 IFS=x and '\'''\'' and @ (#3)' {
  local cmd='setopt SH_WORD_SPLIT  # for zsh

IFS=x
set -- "" "" "" "" ""

argv.py $*
set -- $*
argv.py $*
set -- $*
argv.py $*
set -- $*
argv.py $*
set -- $*
argv.py $*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '052 A - empty string on both sides - derived from spec/toysh-posix #15' {
  local cmd='A="   abc   def   "

argv.py $A
argv.py ""$A""

unset IFS

argv.py $A
argv.py ""$A""

echo

# Do the same thing in a for loop - this is IDENTICAL behavior

for i in $A; do echo =$i=; done
echo

for i in ""$A""; do echo =$i=; done
echo

unset IFS

for i in $A; do echo =$i=; done
echo

for i in ""$A""; do echo =$i=; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '053 Regression: {!v*}x should not be split' {
  local cmd='case $SH in dash|mksh|ash|yash) exit 99;; esac
IFS=x
axb=1
echo "${!axb*}"
echo "${!axb*}"x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '054 Regression: {!v} should be split' {
  local cmd='v=hello
IFS=5
echo ${#v}
echo "${#v}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '055 Regression: {v:-AxBxC}x should not be split' {
  local cmd='IFS=x
v=
echo "${v:-AxBxC}"
echo "${v:-AxBxC}"x  # <-- osh failed this
echo ${v:-AxBxC}
echo ${v:-AxBxC}x
echo ${v:-"AxBxC"}
echo ${v:-"AxBxC"}x
echo "${v:-"AxBxC"}"
echo "${v:-"AxBxC"}"x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

