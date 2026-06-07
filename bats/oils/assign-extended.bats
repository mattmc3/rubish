#!/usr/bin/env bats
# Generated from oils-for-unix spec/assign-extended.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 local -a' {
  local cmd='# nixpkgs setup.sh uses this (issue #26)
f() {
  local -a array=(x y z)
  argv.py "${array[@]}"
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 declare -a' {
  local cmd='# nixpkgs setup.sh uses this (issue #26)
declare -a array=(x y z)
argv.py "${array[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 declare -f exit code indicates function existence' {
  local cmd='func2=x  # var names are NOT found
declare -f myfunc func2
echo $?

myfunc() { echo myfunc; }
declare -f myfunc func2 > /dev/null
echo $?

func2() { echo func2; }
declare -f myfunc func2 > /dev/null
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 declare -F prints function names' {
  local cmd='add () { expr 4 + 4; }
div () { expr 6 / 2; }
ek () { echo hello; }
__ec () { echo hi; }
_ab () { expr 10 % 3; }

declare -F'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 declare -F with shopt -s extdebug prints more info' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='source $REPO_ROOT/spec/testdata/bash-source-2.sh

shopt -s extdebug

add () { expr 4 + 4; }

declare -F 
echo

declare -F add
# in bash-source-2
declare -F g | sed "s;$REPO_ROOT;ROOT;g"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 declare -F with shopt -s extdebug and main file' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='$SH $REPO_ROOT/spec/testdata/extdebug.sh | sed "s;$REPO_ROOT;ROOT;g"'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 declare -p var (exit status)' {
  local cmd='var1() { echo func; }  # function names are NOT found.
declare -p var1 var2 >/dev/null
echo $?

var1=x
declare -p var1 var2 >/dev/null
echo $?

var2=y
declare -p var1 var2 >/dev/null
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 declare' {
  local cmd='test_var1=111
readonly test_var2=222
export test_var3=333
declare -n test_var4=test_var1
f1() {
  local test_var5=555
  {
    echo '\''[declare]'\''
    declare
    echo '\''[readonly]'\''
    readonly
    echo '\''[export]'\''
    export
    echo '\''[local]'\''
    local
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 declare -p' {
  local cmd='# BUG: bash doesn'\''t output flags with "local -p", which seems to contradict
#   with manual.
test_var1=111
readonly test_var2=222
export test_var3=333
declare -n test_var4=test_var1
f1() {
  local test_var5=555
  {
    echo '\''[declare]'\''
    declare -p
    echo '\''[readonly]'\''
    readonly -p
    echo '\''[export]'\''
    export -p
    echo '\''[local]'\''
    local -p
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 declare -p doesn'\''t print binary data, but can be loaded into bash' {
  local cmd='# bash prints binary data!

unquoted='\''foo'\''
sq='\''foo bar'\''
bash1=$'\''\x1f'\''  # ASCII control char
bash2=$'\''\xfe\xff'\''  # Invalid UTF-8

s1=$unquoted
s2=$sq
s3=$bash1
s4=$bash2

declare -a a=("$unquoted" "$sq" "$bash1" "$bash2")
declare -A A=(["$unquoted"]="$sq" ["$bash1"]="$bash2")

#echo lengths ${#s1} ${#s2} ${#s3} ${#s4} ${#a[@]} ${#A[@]}

declare -p s1 s2 s3 s4 a A | tee tmp.bash

echo ---

bash -c '\''source tmp.bash; echo "$s1 $s2"; echo -n "$s3" "$s4" | od -A n -t x1'\''
echo bash=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 declare -p var' {
  local cmd='# BUG? bash doesn'\''t output anything for '\''local/readonly -p var'\'', which seems to
#   contradict with manual.  Besides, '\''export -p var'\'' is not described in
#   manual
test_var1=111
readonly test_var2=222
export test_var3=333
declare -n test_var4=test_var1
f1() {
  local test_var5=555
  {
    echo '\''[declare]'\''
    declare -p test_var{0..5}
    echo '\''[readonly]'\''
    readonly -p test_var{0..5}
    echo '\''[export]'\''
    export -p test_var{0..5}
    echo '\''[local]'\''
    local -p test_var{0..5}
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 declare -p arr' {
  local cmd='test_arr1=()
declare -a test_arr2=()
declare -A test_arr3=()
test_arr4=(1 2 3)
declare -a test_arr5=(1 2 3)
declare -A test_arr6=(['\''a'\'']=1 ['\''b'\'']=2 ['\''c'\'']=3)
test_arr7=()
test_arr7[3]=foo
declare -p test_arr{1..7}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 declare -p foo=bar doesn'\''t make sense' {
  local cmd='declare -p foo=bar
echo status=$?

a=b
declare -p a foo=bar > tmp.txt
echo status=$?
sed '\''s/"//g'\'' tmp.txt  # don'\''t care about quotes'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 declare -pnrx' {
  local cmd='test_var1=111
readonly test_var2=222
export test_var3=333
declare -n test_var4=test_var1
f1() {
  local test_var5=555
  {
    echo '\''[declare -pn]'\''
    declare -pn
    echo '\''[declare -pr]'\''
    declare -pr
    echo '\''[declare -px]'\''
    declare -px
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 declare -paA' {
  local cmd='declare -a test_var6=()
declare -A test_var7=()
f1() {
  {
    echo '\''[declare -pa]'\''
    declare -pa
    echo '\''[declare -pA]'\''
    declare -pA
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 declare -pnrx var' {
  local cmd='# Note: Bash ignores other flags (-nrx) when variable names are supplied while
#   OSH uses other flags to select variables.  Bash'\''s behavior is documented.
test_var1=111
readonly test_var2=222
export test_var3=333
declare -n test_var4=test_var1
f1() {
  local test_var5=555
  {
    echo '\''[declare -pn]'\''
    declare -pn test_var{0..5}
    echo '\''[declare -pr]'\''
    declare -pr test_var{0..5}
    echo '\''[declare -px]'\''
    declare -px test_var{0..5}
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 declare -pg' {
  local cmd='test_var1=global
f1() {
  local test_var1=local
  {
    declare -pg
  } | grep -E '\''^\[|^\b[^"]*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 declare -pg var' {
  local cmd='test_var1=global
f1() {
  local test_var1=local
  {
    declare -pg test_var1
  } | grep -E '\''^\[|^\b.*test_var.\b'\''
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 ble.sh: eval -- (declare -p var arr)' {
  local cmd='# This illustrates an example usage of "eval & declare" for exporting
# multiple variables from $().
eval -- "$(
  printf '\''%s\n'\'' a{1..10} | {
    sum=0 i=0 arr=()
    while read line; do
      ((sum+=${#line},i++))
      arr[$((i/3))]=$line
    done
    declare -p sum arr
  })"
echo sum=$sum
for ((i=0;i<${#arr[@]};i++)); do
  echo "arr[$i]=${arr[i]}"
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 declare -p and value.Undef' {
  local cmd='# This is a regression for a crash
# But actually there is also an incompatibility -- we don'\''t print anything

declare x
declare -p x

function f { local x; declare -p x; }
x=1
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 eval -- (declare -p arr) (restore arrays w/ unset elements)' {
  local cmd='arr=(1 2 3)
eval -- "$(arr=(); arr[3]= arr[4]=foo; declare -p arr)"
for i in {0..4}; do
  echo "arr[$i]: ${arr[$i]+set ... [}${arr[$i]-unset}${arr[$i]+]}"
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 declare -p UNDEF (and typeset) -- prints something to stderr' {
  local cmd='x=42
readonly x
export x

declare -p x undef1 undef2 2> de

typeset -p x undef1 undef2 2> ty

# readonly -p and export -p don'\''t accept args!  They only print all
#
# These do not accept args
# readonly -p x undef1 undef2 2> re
# export -p x undef1 undef2 2> ex

f() {
  # it behaves weird with x
  #local -p undef1 undef2 2>lo
  local -p a b b>lo
  #local -p x undef1 undef2 2> lo
}
# local behaves differently in bash 4.4 and bash 5, not specifying now
# f
# files='\''de ty lo'\''

files='\''de ty'\''

wc -l $files
#cat $files'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 typeset -f' {
  local cmd='# mksh implement typeset but not declare
typeset  -f myfunc func2
echo $?

myfunc() { echo myfunc; }
# This prints the source code.
typeset  -f myfunc func2 > /dev/null
echo $?

func2() { echo func2; }
typeset  -f myfunc func2 > /dev/null
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 typeset -p' {
  local cmd='var1() { echo func; }  # function names are NOT found.
typeset -p var1 var2 >/dev/null
echo $?

var1=x
typeset -p var1 var2 >/dev/null
echo $?

var2=y
typeset -p var1 var2 >/dev/null
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 typeset -r makes a string readonly' {
  local cmd='typeset -r s1='\''12'\''
typeset -r s2='\''34'\''

s1='\''c'\''
echo status=$?
s2='\''d'\''
echo status=$?

s1+='\''e'\''
echo status=$?
s2+='\''f'\''
echo status=$?

unset s1
echo status=$?
unset s2
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 typeset -ar makes it readonly' {
  local cmd='typeset -a -r array1=(1 2)
typeset -ar array2=(3 4)

array1=('\''c'\'')
echo status=$?
array2=('\''d'\'')
echo status=$?

array1+=('\''e'\'')
echo status=$?
array2+=('\''f'\'')
echo status=$?

unset array1
echo status=$?
unset array2
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 typeset -x makes it exported' {
  local cmd='typeset -rx PYTHONPATH=lib/
printenv.py PYTHONPATH'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 Multiple assignments / array assignments on a line' {
  local cmd='a=1 b[0+0]=2 c=3
echo $a ${b[@]} $c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 Env bindings shouldn'\''t contain array assignments' {
  local cmd='a=1 b[0]=2 c=3 printenv.py a b c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 syntax error in array assignment' {
  local cmd='a=x b[0+]=y c=z
echo $a $b $c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 declare -g (bash-specific; bash-completion uses it)' {
  local cmd='f() {
  declare -g G=42
  declare L=99

  declare -Ag dict
  dict["foo"]=bar

  declare -A localdict
  localdict["spam"]=Eggs

  # For bash-completion
  eval '\''declare -Ag ev'\''
  ev["ev1"]=ev2
}
f
argv.py "$G" "$L"
argv.py "${dict["foo"]}" "${localdict["spam"]}"
argv.py "${ev["ev1"]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 myvar=typeset (another form of dynamic assignment)' {
  local cmd='myvar=typeset
x='\''a b'\''
$myvar x=$x
echo $x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 dynamic array parsing is not allowed' {
  local cmd='code='\''x=(1 2 3)'\''
typeset -a "$code"  # note: -a flag is required
echo status=$?
argv.py "$x"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 dynamic flag in array in assign builtin' {
  local cmd='typeset b
b=(unused1 unused2)  # this works in mksh

a=(x '\''foo=F'\'' '\''bar=B'\'')
typeset -"${a[@]}"
echo foo=$foo
echo bar=$bar
printenv.py foo
printenv.py bar

# syntax error in mksh!  But works in bash and zsh.
#typeset -"${a[@]}" b=(spam eggs)
#echo "length of b = ${#b[@]}"
#echo "b[0]=${b[0]}"
#echo "b[1]=${b[1]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 typeset +x' {
  local cmd='export e=E
printenv.py e
typeset +x e=E2
printenv.py e  # no longer exported'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 typeset +r removes read-only attribute (TODO: documented in bash to do nothing)' {
  local cmd='readonly r=r1
echo r=$r

# clear the readonly flag.  Why is this accepted in bash, but doesn'\''t do
# anything?
typeset +r r=r2 
echo r=$r

r=r3
echo r=$r'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 function name with /' {
  local cmd='ble/foo() { echo hi; }
declare -F ble/foo
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 invalid var name' {
  local cmd='typeset foo/bar'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 unset and shell funcs' {
  local cmd='foo() {
  echo bar
}

foo

declare -F
unset foo
declare -F

foo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

