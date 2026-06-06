#!/usr/bin/env bats
# Generated from oils-for-unix spec/array.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 nounset / set -u with empty array (bug in bash 4.3, fixed in 4.4)' {
  local cmd='# http://lists.gnu.org/archive/html/help-bash/2017-09/msg00005.html

set -o nounset
empty=()
argv.py "${empty[@]}"
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 local array' {
  local cmd='# mksh support local variables, but not local arrays, oddly.
f() {
  local a=(1 '\''2 3'\'')
  argv.py "${a[0]}"
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Command with with word splitting in array' {
  local cmd='array=('\''1 2'\'' $(echo '\''3 4'\''))
argv.py "${array[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 space before ( in array initialization' {
  local cmd='# NOTE: mksh accepts this, but bash doesn'\''t
a= (1 '\''2 3'\'')
echo $a'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 array over multiple lines' {
  local cmd='a=(
1
'\''2 3'\''
)
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 array with invalid token' {
  local cmd='a=(
1
&
'\''2 3'\''
)
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 array with empty string' {
  local cmd='empty=('\'''\'')
argv.py "${empty[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Retrieve index' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[1]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Retrieve out of bounds index' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[3]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Negative index' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[-1]}" "${a[-2]}" "${a[-5]}"  # last one out of bounds'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Negative index and sparse array' {
  local cmd='a=(0 1 2 3 4)
unset a[1]
unset a[4]
echo "${a[@]}"
echo -1 ${a[-1]}
echo -2 ${a[-2]}
echo -3 ${a[-3]}
echo -4 ${a[-4]}
echo -5 ${a[-5]}

a[-1]+=0  # append 0 on the end
echo ${a[@]}
(( a[-1] += 42 ))
echo ${a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Negative index and sparse array' {
  local cmd='a=(0 1)
unset '\''a[-1]'\''  # remove last element
a+=(2 3)
echo ${a[0]} $((a[0]))
echo ${a[1]} $((a[1]))
echo ${a[2]} $((a[2]))
echo ${a[3]} $((a[3]))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Length after unset' {
  local cmd='a=(0 1 2 3)
unset a[-1]
echo len=${#a[@]}
unset a[-1]
echo len=${#a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Retrieve index that is a variable' {
  local cmd='a=(1 '\''2 3'\'')
i=1
argv.py "${a[$i]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Retrieve index that is a variable without ' {
  local cmd='a=(1 '\''2 3'\'')
i=5
argv.py "${a[i-4]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Retrieve index that is a command sub' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[$(echo 1)]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Retrieve array indices with {!a}' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${!a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Retrieve sparse array indices with {!a}' {
  local cmd='a=()
(( a[99]=1 ))
argv.py "${!a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 {!a[1]} is named ref in bash' {
  local cmd='# mksh ignores it
foo=bar
a=('\''1 2'\'' foo '\''2 3'\'')
argv.py "${!a[1]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 {!a} on array' {
  local cmd='# bash gives empty string because it'\''s like a[0]
# mksh gives the name of the variable with !.  Very weird.

a=(1 '\''2 3'\'')
argv.py "${!a}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 All elements unquoted' {
  local cmd='a=(1 '\''2 3'\'')
argv.py ${a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 All elements quoted' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 *' {
  local cmd='a=(1 '\''2 3'\'')
argv.py ${a[*]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 *' {
  local cmd='a=(1 '\''2 3'\'')
argv.py "${a[*]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Interpolate array into array' {
  local cmd='a=(1 '\''2 3'\'')
a=(0 "${a[@]}" '\''4 5'\'')
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Exporting array doesn'\''t do anything, not even first element' {
  local cmd='# bash parses, but doesn'\''t execute.
# mksh gives syntax error -- parses differently with '\''export'\''
# osh no longer parses this statically.

export PYTHONPATH

PYTHONPATH=mystr  # NOTE: in bash, this doesn'\''t work afterward!
printenv.py PYTHONPATH

PYTHONPATH=(myarray)
printenv.py PYTHONPATH

PYTHONPATH=(a b c)
printenv.py PYTHONPATH'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 strict_array prevents exporting array' {
  local cmd='shopt -s strict_array

export PYTHONPATH
PYTHONPATH=(a b c)
printenv.py PYTHONPATH'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Arrays can'\''t be used as env bindings' {
  local cmd='# Hm bash it treats it as a string!
A=a B=(b b) printenv.py A B'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 Associative arrays can'\''t be used as env bindings either' {
  local cmd='A=a B=([k]=v) printenv.py A B'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 Set element' {
  local cmd='a=(1 '\''2 3'\'')
a[0]=9
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 Set element with var ref' {
  local cmd='a=(1 '\''2 3'\'')
i=0
a[$i]=9
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Set element with array ref' {
  local cmd='# This makes parsing a little more complex.  Anything can be inside [],
# including other [].
a=(1 '\''2 3'\'')
i=(0 1)
a[${i[1]}]=9
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 Set array item to array' {
  local cmd='a=(1 2)
a[0]=(3 4)
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 Slice of array with [@]' {
  local cmd='# mksh doesn'\''t support this syntax!  It'\''s a bash extension.
a=(1 2 3)
argv.py "${a[@]:1:2}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 Negative slice begin' {
  local cmd='# mksh doesn'\''t support this syntax!  It'\''s a bash extension.
# NOTE: for some reason -2) has to be in parens?  Ah that'\''s because it
# conflicts with :-!  That'\''s silly.  You can also add a space.
a=(1 2 3 4 5)
argv.py "${a[@]:(-4)}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 Negative slice length' {
  local cmd='a=(1 2 3 4 5)
argv.py "${a[@]: 1: -3}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 Slice with arithmetic' {
  local cmd='a=(1 2 3)
i=5
argv.py "${a[@]:i-4:2}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 Number of elements' {
  local cmd='a=(1 '\''2 3'\'')
echo "${#a[@]}" ${#a[@]}  # bug fix: also test without quotes'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 Length of an element' {
  local cmd='a=(1 '\''2 3'\'')
echo "${#a[1]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 Iteration' {
  local cmd='a=(1 '\''2 3'\'')
for v in "${a[@]}"; do
  echo $v
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 glob within array yields separate elements' {
  local cmd='touch y.Y yy.Y
a=(*.Y)
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 declare array and then append' {
  local cmd='declare -a array
array+=(a)
array+=(b c)
argv.py "${array[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 Array syntax in wrong place' {
  local cmd='ls foo=(1 2)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 Single array with :-' {
  local cmd='# 2024-06 - bash 5.2 and mksh now match, bash 4.4 differed.
# Could change OSH
# zsh agrees with OSH, but it fails most test cases
# 2025-01 We changed OSH.

single=('\'''\'')
argv.py ${single[@]:-none} x "${single[@]:-none}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 Stripping a whole array unquoted' {
  local cmd='# Problem: it joins it first.
files=('\''foo.c'\'' '\''sp ace.h'\'' '\''bar.c'\'')
argv.py ${files[@]%.c}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '046 Stripping a whole array quoted' {
  local cmd='files=('\''foo.c'\'' '\''sp ace.h'\'' '\''bar.c'\'')
argv.py "${files[@]%.c}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '047 Multiple subscripts not allowed' {
  local cmd='# NOTE: bash 4.3 had a bug where it ignored the bad subscript, but now it is
# fixed.
a=('\''123'\'' '\''456'\'')
argv.py "${a[0]}" "${a[0][0]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 Length op, index op, then transform op is not allowed' {
  local cmd='a=('\''123'\'' '\''456'\'')
echo "${#a[0]}" "${#a[0]/1/xxx}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '049 {mystr[@]} and {mystr[*]} are no-ops' {
  local cmd='s='\''abc'\''
echo ${s[@]}
echo ${s[*]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '050 {mystr[@]} and {mystr[*]} disallowed with strict_array' {
  local cmd='$SH -c '\''shopt -s strict_array; s="abc"; echo ${s[@]}'\''
echo status=$?

$SH -c '\''shopt -s strict_array; s="abc"; echo ${s[*]}'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '051 Create a user array out of the argv array' {
  local cmd='set -- '\''a b'\'' '\''c'\''
array1=('\''x y'\'' '\''z'\'')
array2=("$@")
argv.py "${array1[@]}" "${array2[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '052 Tilde expansion within array' {
  local cmd='HOME=/home/bob
a=(~/src ~/git)
echo "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '053 Brace Expansion within Array' {
  local cmd='a=(-{a,b} {c,d}-)
echo "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '054 array default' {
  local cmd='default=('\''1 2'\'' '\''3'\'')
argv.py "${undef[@]:-${default[@]}}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '055 Singleton Array Copy and Assign.  OSH can'\''t index strings with ints' {
  local cmd='a=( '\''12 3'\'' )
b=( "${a[@]}" )
c="${a[@]}"  # This decays it to a string
d=${a[*]}  # This decays it to a string
echo ${#a[0]} ${#b[0]}
echo ${#a[@]} ${#b[@]}

# osh is intentionally stricter, and these fail.
echo ${#c[0]} ${#d[0]}
echo ${#c[@]} ${#d[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '056 declare -a / local -a is empty array' {
  local cmd='declare -a myarray
argv.py "${myarray[@]}"
myarray+=('\''x'\'')
argv.py "${myarray[@]}"

f() {
  local -a myarray
  argv.py "${myarray[@]}"
  myarray+=('\''x'\'')
  argv.py "${myarray[@]}"
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '057 Create sparse array' {
  local cmd='a=()
(( a[99]=1 )) # osh doesn'\''t parse index assignment outside arithmetic yet
echo len=${#a[@]}
argv.py "${a[@]}"
echo "unset=${a[33]}"
echo len-of-unset=${#a[33]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '058 Create sparse array implicitly' {
  local cmd='(( a[99]=1 ))
echo len=${#a[@]}
argv.py "${a[@]}"
echo "unset=${a[33]}"
echo len-of-unset=${#a[33]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '059 Append sparse arrays' {
  local cmd='a=()
(( a[99]=1 ))
b=()
(( b[33]=2 ))
(( b[66]=3 ))
a+=( "${b[@]}" )
argv.py "${a[@]}"
argv.py "${a[99]}" "${a[100]}" "${a[101]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '060 Slice of sparse array with [@]' {
  local cmd='# mksh doesn'\''t support this syntax!  It'\''s a bash extension.
(( a[33]=1 ))
(( a[66]=2 ))
(( a[99]=2 ))
argv.py "${a[@]:15:2}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '061 Using an array itself as the index on LHS' {
  local cmd='shopt -u strict_arith
a[a]=42
a[a]=99
argv.py "${a[@]}" "${a[0]}" "${a[42]}" "${a[99]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '062 Using an array itself as the index on RHS' {
  local cmd='shopt -u strict_arith
a=(1 2 3)
(( x = a[a] ))
echo $x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '063 a[xy] on LHS and RHS' {
  local cmd='x=1
y=2
a[$x$y]=foo

# not allowed by OSH parsing
#echo ${a[$x$y]}

echo ${a[12]}
echo ${#a[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '064 Dynamic parsing of LHS a[code]=value' {
  local cmd='declare -a array
array[x=1]='\''one'\''

code='\''y=2'\''
#code='\''1+2'\''  # doesn'\''t work either
array[$code]='\''two'\''

argv.py "${array[@]}"
echo x=$x
echo y=$y'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '065 Dynamic parsing of RHS {a[code]}' {
  local cmd='declare -a array
array=(zero one two three)

echo ${array[1+2]}

code='\''1+2'\''
echo ${array[$code]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '066 Is element set?  test -v a[i]' {
  local cmd='# note: modern versions of zsh implement this

array=(1 2 3 '\'''\'')

test -v '\''array[1]'\''
echo set=$?

test -v '\''array[3]'\''
echo empty=$?

test -v '\''array[4]'\''
echo unset=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '067 [[ -v a[i] ]]' {
  local cmd='# note: modern versions of zsh implement this

array=(1 2 3)
[[ -v array[1] ]]
echo status=$?

[[ -v array[4] ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '068 test -v a[i] with arith expressions' {
  local cmd='array=(1 2 3 '\'''\'')

test -v '\''array[1+1]'\''
echo status=$?

test -v '\''array[4+1]'\''
echo status=$?

echo
echo dbracket

[[ -v array[1+1] ]]
echo status=$?

[[ -v array[4+1] ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '069 More arith expressions in [[ -v array[expr]] ]]' {
  local cmd='typeset -a array
array=('\'''\'' nonempty)

# This feels inconsistent with the rest of bash?
zero=0

[[ -v array[zero+0] ]]
echo zero=$?

[[ -v array[zero+1] ]]
echo one=$?

[[ -v array[zero+2] ]]
echo two=$?

echo ---

i='\''0+0'\''
[[ -v array[i] ]]
echo zero=$?

i='\''0+1'\''
[[ -v array[i] ]]
echo one=$?

i='\''0+2'\''
[[ -v array[i] ]]
echo two=$?

echo ---

i='\''0+0'\''
[[ -v array[$i] ]]
echo zero=$?

i='\''0+1'\''
[[ -v array[$i] ]]
echo one=$?

i='\''0+2'\''
[[ -v array[$i] ]]
echo two=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '070 Regression: Assigning with out-of-range negative index' {
  local cmd='a=()
a[-1]=1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '071 Regression: Negative index in [[ -v a[index] ]]' {
  local cmd='a[0]=x
a[5]=y
a[10]=z
[[ -v a[-1] ]] && echo '\''a has -1'\''
[[ -v a[-2] ]] && echo '\''a has -2'\''
[[ -v a[-5] ]] && echo '\''a has -5'\''
[[ -v a[-6] ]] && echo '\''a has -6'\''
[[ -v a[-10] ]] && echo '\''a has -10'\''
[[ -v a[-11] ]] && echo '\''a has -11'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '072 Regression: Negative out-of-range index in [[ -v a[index] ]]' {
  local cmd='e=()
[[ -v e[-1] ]] && echo '\''e has -1'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '073 a+=() modifies existing instance of BashArray' {
  local cmd='case $SH in mksh|bash) exit ;; esac

a=(1 2 3)
var b = a
a+=(4 5)
echo "a=(${a[*]})"
echo "b=(${b[*]})"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '074 Regression: unset a[-2]: out-of-bound negative index should cause error' {
  local cmd='case $SH in mksh) exit ;; esac

a=(1)
unset -v '\''a[-2]'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '075 Regression: Out-of-bound negative offset for {a[@]:offset}' {
  local cmd='case $SH in mksh) exit ;; esac

a=(1 2 3 4)
echo "a=(${a[*]})"
echo "begin=-1 -> (${a[*]: -1})"
echo "begin=-2 -> (${a[*]: -2})"
echo "begin=-3 -> (${a[*]: -3})"
echo "begin=-4 -> (${a[*]: -4})"
echo "begin=-5 -> (${a[*]: -5})"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '076 Regression: Array length after unset' {
  local cmd='case $SH in mksh) exit ;; esac

a=(x)
a[9]=y
echo "len ${#a[@]};"

unset -v '\''a[-1]'\''
echo "len ${#a[@]};"
echo "last ${a[@]: -1};"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '077 Regression: {a[@]@Q} crash with a[0]=x a[2]=y' {
  local cmd='case $SH in mksh) exit ;; esac

a[0]=x
a[2]=y
echo "quoted = (${a[@]@Q})"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '078 Regression: silent out-of-bound negative index in {a[-2]} and ((a[-2]))' {
  local cmd='case $SH in mksh) exit ;; esac

a=(x)
echo "[${a[-2]}]"
echo $?
echo "[$((a[-2]))]"
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

