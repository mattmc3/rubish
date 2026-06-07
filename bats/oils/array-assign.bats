#!/usr/bin/env bats
# Generated from oils-for-unix spec/array-assign.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Indexed LHS without spaces, and +=' {
  local cmd='a[1]=x
echo status=$?
argv.py "${a[@]}"

a[0+2]=y
#a[2|3]=y  # zsh doesn'\''t allow this
argv.py "${a[@]}"

# += does appending
a[0+2]+=z
argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Indexed LHS with spaces' {
  local cmd='a[1 * 1]=x
a[ 1 + 2 ]=z
echo status=$?

argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Nested a[i[0]]=0' {
  local cmd='i=(0 1 2)

a[i[0]]=0
a[ i[1] ]=1
a[ i[2] ]=2
a[ i[1]+i[2] ]=3

argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Multiple LHS array words' {
  local cmd='a=(0 1 2)
b=(3 4 5)

#declare -p a b

HOME=/home/spec-test

# empty string, and tilde sub
a[0 + 1]=  b[2 + 0]=~/src

typeset -p a b

echo ---

# In bash, this bad prefix binding prints an error, but nothing fails
a[0 + 1]='\''foo'\'' argv.py b[2 + 0]='\''bar'\''
echo status=$?

typeset -p a b'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 LHS array is protected with shopt -s eval_unsafe_arith, e.g. '\''a[(echo 2)]'\''' {
  local cmd='a=(0 1 2)
b=(3 4 5)
typeset -p b

expr='\''a[$(echo 2)]'\'' 

echo '\''get'\'' "${b[expr]}"

b[expr]=zzz

echo '\''set'\'' "${b[expr]}"
typeset -p b'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 file named a[ is  not executed' {
  local cmd='PATH=".:$PATH"

for name in '\''a['\'' '\''a[5'\''; do
  echo "echo hi from $name: \$# args: \$@" > "$name"
  chmod +x "$name"
done

# this does not executed a[5
a[5 + 1]=
a[5 / 1]=y
echo len=${#a[@]}

# Not detected as assignment because there'\''s a non-arith character
# bash and mksh both give a syntax error
a[5 # 1]='
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 More fragments like a[  a[5  a[5 +  a[5 + 3]' {
  local cmd='for name in '\''a['\'' '\''a[5'\''; do
  echo "echo hi from $name: \$# args: \$@" > "$name"
  chmod +x "$name"
done

# syntax error in bash
$SH -c '\''a['\''
echo "a[ status=$?"

$SH -c '\''a[5'\''
echo "a[5 status=$?"

# 1 arg +
$SH -c '\''a[5 +'\''
echo "a[5 + status=$?"

# 2 args
$SH -c '\''a[5 + 3]'\''
echo "a[5 + 3] status=$?"

$SH -c '\''a[5 + 3]='\''
echo "a[5 + 3]= status=$?"

$SH -c '\''a[5 + 3]+'\''
echo "a[5 + 3]+ status=$?"

$SH -c '\''a[5 + 3]+='\''
echo "a[5 + 3]+= status=$?"

# mksh doesn'\''t issue extra parse errors
# and it doesn'\''t turn a[5 + 3] and a[5 + 3]+ into commands!'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Are quotes allowed?' {
  local cmd='# double quotes allowed in bash
a["1"]=2
echo status=$? len=${#a[@]}

a['\''2'\'']=3
echo status=$? len=${#a[@]}

# allowed in bash
a[2 + "3"]=5
echo status=$? len=${#a[@]}

a[3 + '\''4'\'']=5
echo status=$? len=${#a[@]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Tricky parsing - a[ a[0]=1 ]=X  a[ a[0]+=1 ]+=X' {
  local cmd='# the nested [] means we can'\''t use regular language lookahead?

echo assign=$(( z[0] = 42 ))

a[a[0]=1]=X
declare -p a

a[ a[2]=3 ]=Y
declare -p a

echo ---

a[ a[0]+=1 ]+=X
declare -p a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 argv.py a[1 + 2]=' {
  local cmd='# This tests that the worse parser doesn'\''t unconditinoally treat a[ as special

a[1 + 2]= argv.py a[1 + 2]=
echo status=$?

a[1 + 2]+= argv.py a[1 + 2]+=
echo status=$?

argv.py a[3 + 4]=

argv.py a[3 + 4]+='
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 declare builtin doesn'\''t allow spaces' {
  local cmd='# OSH doesn'\''t allow this
declare a[a[0]=1]=X
declare -p a

# neither bash nor OSH allow this
declare a[ a[2]=3 ]=Y
declare -p a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

