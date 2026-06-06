#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-op-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Lower Case with , and ,,' {
  local cmd='x='\''ABC DEF'\''
echo ${x,}
echo ${x,,}
echo empty=${empty,}
echo empty=${empty,,}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Upper Case with ^ and ^^' {
  local cmd='x='\''abc def'\''
echo ${x^}
echo ${x^^}
echo empty=${empty^}
echo empty=${empty^^}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Case folding - Unicode characters' {
  local cmd='# https://www.utf8-chartable.de/unicode-utf8-table.pl

x=$'\''\u00C0\u00C8'\''  # upper grave
y=$'\''\u00E1\u00E9'\''  # lower acute

echo u ${x^}
echo U ${x^^}

echo l ${x,}
echo L ${x,,}

echo u ${y^}
echo U ${y^^}

echo l ${y,}
echo L ${y,,}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Case folding - multi code point' {
  local cmd='echo shell
small=$'\''\u00DF'\''
echo u ${small^}
echo U ${small^^}

echo l ${small,}
echo L ${small,,}
echo

echo python2
python2 -c '\''
small = u"\u00DF"
print(small.upper().encode("utf-8"))
print(small.lower().encode("utf-8"))
'\''
echo

# Not in the container images, but python 3 DOES support it!
# This is moved to demo/survey-case-fold.sh

if false; then
echo python3
python3 -c '\''
import sys
small = u"\u00DF"
sys.stdout.buffer.write(small.upper().encode("utf-8") + b"\n")
sys.stdout.buffer.write(small.lower().encode("utf-8") + b"\n")
'\''
fi

if false; then
  # Yes, supported
  echo node.js

  nodejs -e '\''
  var small = "\u00DF"
  console.log(small.toUpperCase())
  console.log(small.toLowerCase())
  '\''
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Case folding that depends on locale (not enabled, requires Turkish locale)' {
  local cmd='# Hm this works in demo/survey-case-fold.sh
# Is this a bash 4.4 thing?

#export LANG='\''tr_TR.UTF-8'\''
#echo $LANG

x='\''i'\''

echo u ${x^}
echo U ${x^^}

echo l ${x,}
echo L ${x,,}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Lower Case with constant string (VERY WEIRD)' {
  local cmd='x='\''AAA ABC DEF'\''
echo ${x,A}
echo ${x,,A}  # replaces every A only?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Lower Case glob' {
  local cmd='# Hm with C.UTF-8, this does no case folding?
export LC_ALL=en_US.UTF-8

x='\''ABC DEF'\''
echo ${x,[d-f]}
echo ${x,,[d-f]}  # bash 4.4 fixed in bash 5.2.21'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 {x@u} U L - upper / lower case (bash 5.1 feature)' {
  local cmd='# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

x='\''abc DEF'\''

echo "${x@u}"

echo "${x@U}"

echo "${x@L}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 {x@Q}' {
  local cmd='x="FOO'\''BAR spam\"eggs"
eval "new=${x@Q}"
test "$x" = "$new" && echo OK'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 {array@Q} and {array[@]@Q}' {
  local cmd='array=(x '\''y\nz'\'')
echo ${array[@]@Q}
echo ${array@Q}
echo ${array@Q}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 {!prefix@} {!prefix*} yields sorted array of var names' {
  local cmd='ZOO=zoo
ZIP=zip
ZOOM='\''one two'\''
Z='\''three four'\''

z=lower

argv.py ${!Z*}
argv.py ${!Z@}
argv.py "${!Z*}"
argv.py "${!Z@}"
for i in 1 2; do argv.py ${!Z*}  ; done
for i in 1 2; do argv.py ${!Z@}  ; done
for i in 1 2; do argv.py "${!Z*}"; done
for i in 1 2; do argv.py "${!Z@}"; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 {!prefix@} matches var name (regression)' {
  local cmd='hello1=1 hello2=2 hello3=3
echo ${!hello@}
hello=()
echo ${!hello@}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 {var@a} for attributes' {
  local cmd='array=(one two)
echo ${array@a}
declare -r array=(one two)
echo ${array@a}
declare -rx PYTHONPATH=hi
echo ${PYTHONPATH@a}

# bash and osh differ here
#declare -rxn x=z
#echo ${x@a}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 {var@a} error conditions' {
  local cmd='echo [${?@a}]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 undef and @P @Q @a' {
  local cmd='$SH -c '\''echo ${undef@P}'\''
echo status=$?
$SH -c '\''echo ${undef@Q}'\''
echo status=$?
$SH -c '\''echo ${undef@a}'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 argv array and @P @Q @a' {
  local cmd='$SH -c '\''echo ${@@P}'\'' dummy a b c
echo status=$?
$SH -c '\''echo ${@@Q}'\'' dummy a '\''b\nc'\''
echo status=$?
$SH -c '\''echo ${@@a}'\'' dummy a b c
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 assoc array and @P @Q @a' {
  local cmd='# note: "y z" causes a bug!
$SH -c '\''declare -A A=(["x"]="y"); echo ${A@P} - ${A[@]@P}'\''
echo status=$?

# note: "y z" causes a bug!
$SH -c '\''declare -A A=(["x"]="y"); echo ${A@Q} - ${A[@]@Q}'\'' | sed '\''s/^- y$/- '\''\'\'''\''y'\''\'\'''\''/'\''
echo status=$?

$SH -c '\''declare -A A=(["x"]=y); echo ${A@a} - ${A[@]@a}'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 {!var[@]@X}' {
  local cmd='# note: "y z" causes a bug!
$SH -c '\''declare -A A=(["x"]="y"); echo ${!A[@]@P}'\''
if test $? -ne 0; then echo fail; fi

# note: "y z" causes a bug!
$SH -c '\''declare -A A=(["x y"]="y"); echo ${!A[@]@Q}'\''
if test $? -ne 0; then echo fail; fi

$SH -c '\''declare -A A=(["x"]=y); echo ${!A[@]@a}'\''
if test $? -ne 0; then echo fail; fi
# STDOUT:



# END'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 {#var@X} is a parse error' {
  local cmd='# note: "y z" causes a bug!
$SH -c '\''declare -A A=(["x"]="y"); echo ${#A[@]@P}'\''
if test $? -ne 0; then echo fail; fi

# note: "y z" causes a bug!
$SH -c '\''declare -A A=(["x"]="y"); echo ${#A[@]@Q}'\''
if test $? -ne 0; then echo fail; fi

$SH -c '\''declare -A A=(["x"]=y); echo ${#A[@]@a}'\''
if test $? -ne 0; then echo fail; fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 {!A@a} and {!A[@]@a}' {
  local cmd='declare -A A=(["x"]=y)
echo x=${!A[@]@a}
echo invalid=${!A@a}

# OSH prints '\''a'\'' for indexed array because the AssocArray with ! turns into
# it.  Disallowing it would be the other reasonable behavior.'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 undef vs. empty string in var ops' {
  local cmd='empty='\'''\''
x=x

echo ${x@Q} ${empty@Q} ${undef@Q} ${x@Q}

echo ${x@K} ${empty@K} ${undef@K} ${x@K}

echo ${x@k} ${empty@k} ${undef@k} ${x@k}

echo ${x@A} ${empty@A} ${undef@A} ${x@A}

declare -r x
echo ${x@a} ${empty@a} ${undef@a} ${x@a}

# x x
#echo ${x@E} ${empty@E} ${undef@E} ${x@E}
# x x
#echo ${x@P} ${empty@P} ${undef@P} ${x@P}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 -o nounset with var ops' {
  local cmd='set -u
(echo ${undef@Q}); echo "stat: $?"
(echo ${undef@P}); echo "stat: $?"
(echo ${undef@a}); echo "stat: $?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 {a[0]@a} and {a@a}' {
  local cmd='a=(1 2 3)
echo "attr = '\''${a[0]@a}'\''"
echo "attr = '\''${a@a}'\''"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 {!r@a} with r='\''a[0]'\'' (attribute for indirect expansion of an array element)' {
  local cmd='a=(1 2 3)
r='\''a'\''
echo ${!r@a}
r='\''a[0]'\''
echo ${!r@a}

declare -A d=([0]=foo [1]=bar)
r='\''d'\''
echo ${!r@a}
r='\''d[0]'\''
echo ${!r@a}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Array expansion with nullary var op @Q' {
  local cmd='declare -a a=({1..9})
declare -A A=(['\''a'\'']=hello ['\''b'\'']=world ['\''c'\'']=osh ['\''d'\'']=ysh)

argv.py "${a[@]@Q}"
argv.py "${a[*]@Q}"
argv.py "${A[@]@Q}"
argv.py "${A[*]@Q}"
argv.py "${u[@]@Q}"
argv.py "${u[*]@Q}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Array expansion with nullary var op @P' {
  local cmd='declare -a a=({1..9})
declare -A A=(['\''a'\'']=hello ['\''b'\'']=world ['\''c'\'']=osh ['\''d'\'']=ysh)

argv.py "${a[@]@P}"
argv.py "${a[*]@P}"
argv.py "${A[@]@P}"
argv.py "${A[*]@P}"
argv.py "${u[@]@P}"
argv.py "${u[*]@P}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Array expansion with nullary var op @a' {
  local cmd='declare -a a=({1..9})
declare -A A=(['\''a'\'']=hello ['\''b'\'']=world ['\''c'\'']=osh ['\''d'\'']=ysh)

argv.py "${a[@]@a}"
argv.py "${a[*]@a}"
argv.py "${A[@]@a}"
argv.py "${A[*]@a}"
argv.py "${u[@]@a}"
argv.py "${u[*]@a}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

