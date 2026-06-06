#!/usr/bin/env bats
# Generated from oils-for-unix spec/array-compat.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Assignment Causes Array Decay' {
  local cmd='set -- x y z
argv.py "[$@]"
var="[$@]"
argv.py "$var"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Array Decay with IFS' {
  local cmd='IFS=x
set -- x y z
var="[$@]"
argv.py "$var"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 User arrays decay' {
  local cmd='declare -a a b
a=(x y z)
b="${a[@]}"  # this collapses to a string
c=("${a[@]}")  # this preserves the array
c[1]=YYY  # mutate a copy -- doesn'\''t affect the original
argv.py "${a[@]}"
argv.py "${b}"
argv.py "${c[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 strict_array: array is not valid in OSH, is {array[0]} in ksh/bash' {
  local cmd='shopt -s strict_array

a=(1 '\''2 3'\'')
echo $a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 strict_array: {array} is not valid in OSH, is {array[0]} in ksh/bash' {
  local cmd='shopt -s strict_array

a=(1 '\''2 3'\'')
echo ${a}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Assign to array index without initialization' {
  local cmd='a[5]=5
a[6]=6
echo "${a[@]}" ${#a[@]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 a[40] grows array' {
  local cmd='a=(1 2 3)
a[1]=5
a[40]=30  # out of order
a[10]=20
echo "${a[@]}" "${#a[@]}"  # length is 1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 array decays to string when comparing with [[ a = b ]]' {
  local cmd='a=('\''1 2'\'' '\''3 4'\'')
s='\''1 2 3 4'\''  # length 2, length 4
echo ${#a[@]} ${#s}
[[ "${a[@]}" = "$s" ]] && echo EQUAL'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 ++ on a whole array increments the first element (disallowed with strict_array)' {
  local cmd='shopt -s strict_array

a=(1 10)
(( a++ ))  # doesn'\''t make sense
echo "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Apply vectorized operations on {a[*]}' {
  local cmd='a=('\''-x-'\'' '\''y-y'\'' '\''-z-'\'')

# This does the prefix stripping FIRST, and then it joins.
argv.py "${a[*]#-}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 value.BashArray internal representation - Indexed' {
  local cmd='case $SH in mksh) exit ;; esac

z=()
declare -a | grep z=

z+=(b c)
declare -a | grep z=

# z[5]= finds the index, or puts it in SORTED order I think
z[5]=d
declare -a | grep z=

z[1]=ZZZ
declare -a | grep z=

# Adds after last index
z+=(f g)
declare -a | grep z=

# This is the equivalent of z[0]+=mystr
z+=-mystr
declare -a | grep z=

z[1]+=-append
declare -a | grep z=

argv.py keys "${!z[@]}"  # 0 1 5 6 7
argv.py values "${z[@]}"

# can'\''t do this conversion
declare -A z
declare -A | grep z=

echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 value.BashArray internal representation - Assoc (ordering is a problem)' {
  local cmd='case $SH in mksh) exit ;; esac

declare -A A=([k]=v)
declare -A | grep A=

argv.py keys "${!A[@]}"
argv.py values "${A[@]}"

exit

# Huh this actually works, we don'\''t support it
# Hm the order here is all messed up, in bash 5.2
A+=([k2]=v2 [0]=foo [9]=9 [9999]=9999)
declare -A | grep A=

A+=-append
declare -A | grep A=

argv.py keys "${!A[@]}"
argv.py values "${A[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

