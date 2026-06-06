#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-vars.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Export sets a global variable' {
  local cmd='# Even after you do export -n, it still exists.
f() { export GLOBAL=X; }
f
echo $GLOBAL
printenv.py GLOBAL'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Export sets a global variable that persists after export -n' {
  local cmd='f() { export GLOBAL=X; }
f
echo $GLOBAL
printenv.py GLOBAL
export -n GLOBAL
echo $GLOBAL
printenv.py GLOBAL'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 export -n undefined is ignored' {
  local cmd='set -o errexit
export -n undef
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 export -n foo=bar not allowed' {
  local cmd='foo=old
export -n foo=new
echo status=$?
echo $foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Export a global variable and unset it' {
  local cmd='f() { export GLOBAL=X; }
f
echo $GLOBAL
printenv.py GLOBAL
unset GLOBAL
echo g=$GLOBAL
printenv.py GLOBAL'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Export existing global variables' {
  local cmd='G1=g1
G2=g2
export G1 G2
printenv.py G1 G2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Export existing local variable' {
  local cmd='f() {
  local L1=local1
  export L1
  printenv.py L1
}
f
printenv.py L1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Export a local that shadows a global' {
  local cmd='V=global
f() {
  local V=local1
  export V
  printenv.py V
}
f
printenv.py V  # exported local out of scope; global isn'\''t exported yet
export V
printenv.py V  # now it'\''s exported'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Export a variable before defining it' {
  local cmd='export U
U=u
printenv.py U'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Unset exported variable, then define it again.  It'\''s NOT still exported.' {
  local cmd='export U
U=u
printenv.py U
unset U
printenv.py U
U=newvalue
echo $U
printenv.py U'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Exporting a parent func variable (dynamic scope)' {
  local cmd='# The algorithm is to walk up the stack and export that one.
inner() {
  export outer_var
  echo "inner: $outer_var"
  printenv.py outer_var
}
outer() {
  local outer_var=X
  echo "before inner"
  printenv.py outer_var
  inner
  echo "after inner"
  printenv.py outer_var
}
outer'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Dependent export setting' {
  local cmd='# FOO is not respected here either.
export FOO=foo v=$(printenv.py FOO)
echo "v=$v"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Exporting a variable doesn'\''t change it' {
  local cmd='old=$PATH
export PATH
new=$PATH
test "$old" = "$new" && echo "not changed"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 can'\''t export array (strict_array)' {
  local cmd='shopt -s strict_array

typeset -a a
a=(1 2 3)

export a
printenv.py a'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 can'\''t export associative array (strict_array)' {
  local cmd='shopt -s strict_array

typeset -A a
a["foo"]=bar

export a
printenv.py a'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 assign to readonly variable' {
  local cmd='# bash doesn'\''t abort unless errexit!
readonly foo=bar
foo=eggs
echo "status=$?"  # nothing happens'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Make an existing local variable readonly' {
  local cmd='f() {
	local x=local
	readonly x
	echo $x
	eval '\''x=bar'\''  # Wrap in eval so it'\''s not fatal
	echo status=$?
}
x=global
f
echo $x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 assign to readonly variable - errexit' {
  local cmd='set -o errexit
readonly foo=bar
foo=eggs
echo "status=$?"  # nothing happens'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Unset a variable' {
  local cmd='foo=bar
echo foo=$foo
unset foo
echo foo=$foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Unset exit status' {
  local cmd='V=123
unset V
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Unset nonexistent variable' {
  local cmd='unset ZZZ
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Unset readonly variable' {
  local cmd='# dash and zsh abort the whole program.   OSH doesn'\''t?
readonly R=foo
unset R
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 Unset a function without -f' {
  local cmd='f() {
  echo foo
}
f
unset f
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Unset has dynamic scope' {
  local cmd='f() {
  unset foo
}
foo=bar
echo foo=$foo
f
echo foo=$foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Unset and scope (bug #653)' {
  local cmd='unlocal() { unset "$@"; }

level2() {
  local hello=yy

  echo level2=$hello
  unlocal hello
  echo level2=$hello
}

level1() {
  local hello=xx

  level2

  echo level1=$hello
  unlocal hello
  echo level1=$hello

  level2
}

hello=global
level1

# bash, mksh, yash agree here.'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 unset of local reveals variable in higher scope' {
  local cmd='# OSH has a RARE behavior here (matching yash and mksh), but at least it'\''s
# consistent.

x=global
f() {
  local x=foo
  echo x=$x
  unset x
  echo x=$x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Unset invalid variable name' {
  local cmd='unset %
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Unset nonexistent variable' {
  local cmd='unset _nonexistent__
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 Unset -v' {
  local cmd='foo() {
  echo "function foo"
}
foo=bar
unset -v foo
echo foo=$foo
foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 Unset -f' {
  local cmd='foo() {
  echo "function foo"
}
foo=bar
unset -f foo
echo foo=$foo
foo
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 Unset array member' {
  local cmd='a=(x y z)
unset '\''a[1]'\''
echo status=$?
echo "${a[@]}" len="${#a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Unset errors' {
  local cmd='unset undef
echo status=$?

a=(x y z)
unset '\''a[99]'\''  # out of range
echo status=$?

unset '\''not_array[99]'\''  # not an array
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 Unset wrong type' {
  local cmd='case $SH in mksh) exit ;; esac

declare undef
unset -v '\''undef[1]'\''
echo undef $?
unset -v '\''undef["key"]'\''
echo undef $?

declare a=(one two)
unset -v '\''a[1]'\''
echo array $?

#shopt -s strict_arith || true
# In OSH, the string '\''key'\'' is converted to an integer, which is 0, unless
# strict_arith is on, when it fails.
unset -v '\''a["key"]'\''
echo array $?

declare -A A=(['\''key'\'']=val)
unset -v '\''A[1]'\''
echo assoc $?
unset -v '\''A["key"]'\''
echo assoc $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 unset -v assoc (related to issue #661)' {
  local cmd='case $SH in dash|mksh|zsh) return ;; esac

declare -A dict=()
key=1],a[1
dict["$key"]=foo
echo ${#dict[@]}
echo keys=${!dict[@]}
echo vals=${dict[@]}

unset -v '\''dict["$key"]'\''
echo ${#dict[@]}
echo keys=${!dict[@]}
echo vals=${dict[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 unset assoc errors' {
  local cmd='case $SH in dash|mksh) return ;; esac

declare -A assoc=(['\''key'\'']=value)
unset '\''assoc["nonexistent"]'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 Unset array member with dynamic parsing' {
  local cmd='i=1
a=(w x y z)
unset '\''a[ i - 1 ]'\'' a[i+1]  # note: can'\''t have space between a and [
echo status=$?
echo "${a[@]}" len="${#a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 Use local twice' {
  local cmd='f() {
  local foo=bar
  local foo
  echo $foo
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 Local without variable is still unset!' {
  local cmd='set -o nounset
f() {
  local foo
  echo "[$foo]"
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 local after readonly' {
  local cmd='f() { 
  readonly y
  local x=1 y=$(( x ))
  echo y=$y
}
f
echo y=$y'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 unset a[-1] (bf.bash regression)' {
  local cmd='case $SH in dash|zsh) exit ;; esac

a=(1 2 3)
unset a[-1]
echo len=${#a[@]}

echo last=${a[-1]}
(( last = a[-1] ))
echo last=$last

(( a[-1] = 42 ))
echo "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 unset a[-1] in sparse array (bf.bash regression)' {
  local cmd='case $SH in dash|zsh) exit ;; esac

a=(0 1 2 3 4)
unset a[1]
unset a[4]
echo len=${#a[@]} a=${a[@]}
echo last=${a[-1]} second=${a[-2]} third=${a[-3]}

echo ---
unset a[3]
echo len=${#a[@]} a=${a[@]}
echo last=${a[-1]} second=${a[-2]} third=${a[-3]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

