#!/usr/bin/env bats
# Generated from oils-for-unix spec/array-literal.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Tilde expansions in RHS of [k]=v (BashArray)' {
  local cmd='HOME=/home/user
a=([2]=~ [4]=~:~:~)
echo "${a[2]}"
echo "${a[4]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Tilde expansions in RHS of [k]=v (BashAssoc)' {
  local cmd='# Note: bash-5.2 has a bug that the tilde doesn'\''t expand on the right hand side
# of [key]=value.  This problem doesn'\''t happen in bash-3.1..5.1 and bash-5.3.
HOME=/home/user
declare -A a
declare -A a=(['\''home'\'']=~ ['\''hello'\'']=~:~:~)
echo "${a['\''home'\'']}"
echo "${a['\''hello'\'']}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 index increments without [k]= (BashArray)' {
  local cmd='a=([100]=1 2 3 4)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=([100]=1 2 3 4 [5]=a b c d)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 [k]=v and [k]=@ (BashArray)' {
  local cmd='i=5
v='\''1 2 3'\''
a=($v [i]=$v)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"

x=(3 5 7)
a=($v [i]="${x[*]}")
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=($v [i]="${x[@]}")
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=($v [i]=${x[*]})
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=($v [i]=${x[@]})
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 [k]=v and [k]=@ (BashAssoc)' {
  local cmd='i=5
v='\''1 2 3'\''
declare -A a
a=([i]=$v)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"

x=(3 5 7)
a=([i]="${x[*]}")
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=([i]="${x[@]}")
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=([i]=${x[*]})
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=([i]=${x[@]})
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 append to element (BashArray)' {
  local cmd='hello=100
a=([hello]=1 [hello]+=2)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a+=([hello]+=:34 [hello]+=:56)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 append to element (BashAssoc)' {
  local cmd='declare -A a
hello=100
a=([hello]=1 [hello]+=2)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a+=([hello]+=:34 [hello]+=:56)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 non-index forms of element (BashAssoc)' {
  local cmd='declare -A a
a=([j]=1 2 3 4)
echo "status=$?"
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Evaluation order (1)' {
  local cmd='# RHS of [k]=v are expanded when the initializer list is instanciated.  For the
# indexed array, the array indices are evaluated when the array is modified.
i=1
a=([100+i++]=$((i++)) [200+i++]=$((i++)) [300+i++]=$((i++)))
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Evaluation order (2)' {
  local cmd='# When evaluating the index, the modification to the array by the previous item
# of the initializer list is visible to the current item.
a=([0]=1+2+3 [a[0]]=10 [a[6]]=hello)
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Evaluation order (3)' {
  local cmd='# RHS should be expanded before any modification to the array.
a=(old1 old2 old3)
a=("${a[2]}" "${a[0]}" "${a[1]}" "${a[2]}" "${a[0]}")
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"
a=(old1 old2 old3)
old1=101 old2=102 old3=103
new1=201 new2=202 new3=203
a+=([0]=new1 [1]=new2 [2]=new3 [5]="${a[2]}" [a[0]]="${a[0]}" [a[1]]="${a[1]}")
printf '\''keys: '\''; argv.py "${!a[@]}"
printf '\''vals: '\''; argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 [k1]=v1 (BashArray)' {
  local cmd='# Note: This and next tests have originally been in "spec/assign.test.sh" and
# compared the behavior of OSH'\''s BashAssoc and Bash'\''s indexed array.  After
# supporting "arr=([index]=value)" for indexed arrays, the test was adjusted
# and copied here. See also the corresponding tests in "spec/assign.test.sh"
a=([k1]=v1 [k2]=v2)
echo ${a["k1"]}
echo ${a["k2"]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 [k1]=v1 (BashAssoc)' {
  local cmd='declare -A a
a=([k1]=v1 [k2]=v2)
echo ${a["k1"]}
echo ${a["k2"]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 [k1]=v1 looking like brace expansions (BashAssoc)' {
  local cmd='declare -A a
a=([k2]=-{a,b}-)
echo ${a["k2"]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 [k1]=v1 looking like brace expansions (BashArray)' {
  local cmd='a=([k2]=-{a,b}-)
echo ${a["k2"]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 BashArray cannot be changed to BashAssoc and vice versa' {
  local cmd='declare -a a=(1 2 3 4)
eval '\''declare -A a=([a]=x [b]=y [c]=z)'\''
echo status=$?
argv.py "${a[@]}"

declare -A A=([a]=x [b]=y [c]=z)
eval '\''declare -a A=(1 2 3 4)'\''
echo status=$?
argv.py $(printf '\''%s\n'\'' "${A[@]}" | sort)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 (strict_array) s+=()' {
  local cmd='case $SH in bash) ;; *) shopt --set strict_array ;; esac

s1=hello
s2=world

# Overwriting Str with a new BashArray is allowed
eval '\''s1=(1 2 3 4)'\''
echo status=$?
declare -p s1
# Promoting Str to a BashArray is disallowed
eval '\''s2+=(1 2 3 4)'\''
echo status=$?
declare -p s2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 (strict_array) declare -A s+=()' {
  local cmd='case $SH in bash) ;; *) shopt --set strict_array ;; esac

s1=hello
s2=world

# Overwriting Str with a new BashAssoc is allowed
eval '\''declare -A s1=([a]=x [b]=y)'\''
echo status=$?
declare -p s1
# Promoting Str to a BashAssoc is disallowed
eval '\''declare -A s2+=([a]=x [b]=y)'\''
echo status=$?
declare -p s2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 (strict_array) assoc=(key value ...) is not allowed' {
  local cmd='case $SH in bash) ;; *) shopt --set strict_array ;; esac

declare -A a=([a]=b)
eval "a=(1 2 3 4)"
declare -p a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

