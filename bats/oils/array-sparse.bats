#!/usr/bin/env bats
# Generated from oils-for-unix spec/array-sparse.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Performance demo' {
  skip 'YSH-only mode (shopt -s ysh:); not bash-applicable'
  local cmd='shopt -s ysh:upgrade

#pp test_ (a)

sp=( foo {25..27} bar )

sp[10]='\''sparse'\''

echo $[type(sp)]

echo len: "${#sp[@]}"

#echo $[len(sp)]

echo subst: "${sp[@]}"
echo keys: "${!sp[@]}"

echo slice: "${sp[@]:2:3}"

sp[0]=set0

echo get0: "${sp[0]}"
echo get1: "${sp[1]}"
echo ---

to_append=(x y)
echo append
sp+=("${to_append[@]}")
echo subst: "${sp[@]}"
echo keys: "${!sp[@]}"
echo ---

echo unset
unset -v '\''sp[11]'\''
echo subst: "${sp[@]}"
echo keys: "${!sp[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 test length' {
  local cmd='sp=(x y z)

sp[5]=z

echo len=${#sp[@]}

sp[10]=z

echo len=${#sp[@]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 test declare -p sp' {
  local cmd='a0=()
a1=(1)
a2=(1 2)
a=(x y z w)
a[500]=100
a[1000]=100

declare -p a0 a1 a2 a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 +=' {
  local cmd='sp1[10]=a
sp1[20]=b
sp1[99]=c
typeset -p sp1 | sed '\''s/"//g'\''
sp1+=(1 2 3)
typeset -p sp1 | sed '\''s/"//g'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 a[i]=v' {
  local cmd='sp1[10]=a
sp1[20]=b
sp1[30]=c
typeset -p sp1 | sed '\''s/"//g'\''
sp1[10]=X
sp1[25]=Y
sp1[90]=Z
typeset -p sp1 | sed '\''s/"//g'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Negative index with a[i]=v' {
  local cmd='sp1[9]=x
typeset -p sp1 | sed '\''s/"//g'\''

sp1[-1]=A
sp1[-4]=B
sp1[-8]=C
sp1[-10]=D
typeset -p sp1 | sed '\''s/"//g'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 a[i]=v with BigInt' {
  local cmd='sp1[1]=x
sp1[5]=y
sp1[9]=z

echo "${#sp1[@]}"
sp1[0x7FFFFFFFFFFFFFFF]=a
echo "${#sp1[@]}"
sp1[0x7FFFFFFFFFFFFFFE]=b
echo "${#sp1[@]}"
sp1[0x7FFFFFFFFFFFFFFD]=c
echo "${#sp1[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Negative out-of-bound index with a[i]=v (1/2)' {
  local cmd='sp1[9]=x
sp1[-11]=E
declare -p sp1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Negative out-of-bound index with a[i]=v (2/2)' {
  local cmd='sp1[9]=x

sp1[-21]=F
declare -p sp1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 xtrace a+=()' {
  local cmd='#
sp1=(1)
set -x
sp1+=(2)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 unset -v a[i]' {
  local cmd='a=(1 2 3 4 5 6 7 8 9)
typeset -p a
unset -v "a[1]"
typeset -p a
unset -v "a[9]"
typeset -p a
unset -v "a[0]"
typeset -p a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 unset -v a[i] with out-of-bound negative index' {
  local cmd='a=(1)

unset -v "a[-2]"
unset -v "a[-3]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 unset -v a[i] for max index' {
  local cmd='a=({1..9})
unset -v '\''a[-1]'\''
a[-1]=x
declare -p a
unset -v '\''a[-1]'\''
a[-1]=x
declare -p a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 [[ -v a[i] ]]' {
  local cmd='sp1=()
[[ -v sp1[0] ]]; echo "$? (expect 1)"
[[ -v sp1[9] ]]; echo "$? (expect 1)"

sp2=({1..9})
[[ -v sp2[0] ]]; echo "$? (expect 0)"
[[ -v sp2[8] ]]; echo "$? (expect 0)"
[[ -v sp2[9] ]]; echo "$? (expect 1)"
[[ -v sp2[-1] ]]; echo "$? (expect 0)"
[[ -v sp2[-2] ]]; echo "$? (expect 0)"
[[ -v sp2[-9] ]]; echo "$? (expect 0)"

sp3=({1..9})
unset -v '\''sp3[4]'\''
[[ -v sp3[3] ]]; echo "$? (expect 0)"
[[ -v sp3[4] ]]; echo "$? (expect 1)"
[[ -v sp3[5] ]]; echo "$? (expect 0)"
[[ -v sp3[-1] ]]; echo "$? (expect 0)"
[[ -v sp3[-4] ]]; echo "$? (expect 0)"
[[ -v sp3[-5] ]]; echo "$? (expect 1)"
[[ -v sp3[-6] ]]; echo "$? (expect 0)"
[[ -v sp3[-9] ]]; echo "$? (expect 0)"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 [[ -v a[i] ]] with invalid negative index' {
  local cmd='sp1=()
([[ -v sp1[-1] ]]; echo "$? (expect 1)")
sp2=({1..9})
([[ -v sp2[-10] ]]; echo "$? (expect 1)")
sp3=({1..9})
unset -v '\''sp3[4]'\''
([[ -v sp3[-10] ]]; echo "$? (expect 1)")'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 ((sp[i])) and ((sp[i]++))' {
  local cmd='a=(1 2 3 4 5 6 7 8 9)
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[7]'\''

echo $((a[0]))
echo $((a[1]))
echo $((a[2]))
echo $((a[3]))
echo $((a[7]))

echo $((a[1]++))
echo $((a[2]++))
echo $((a[3]++))
echo $((a[7]++))

echo $((++a[1]))
echo $((++a[2]))
echo $((++a[3]))
echo $((++a[7]))

echo $((a[1] = 100, a[1]))
echo $((a[2] = 100, a[2]))
echo $((a[3] = 100, a[3]))
echo $((a[7] = 100, a[7]))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 ((sp[i])) and ((sp[i]++)) with invalid negative index' {
  local cmd='a=({1..9})
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[7]'\''

echo $((a[-10]))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 {sp[i]}' {
  local cmd='sp=({1..9})
unset -v '\''sp[2]'\''
unset -v '\''sp[3]'\''
unset -v '\''sp[7]'\''

echo "sp[0]: '\''${sp[0]}'\'', ${sp[0]:-(empty)}, ${sp[0]+set}."
echo "sp[1]: '\''${sp[1]}'\'', ${sp[1]:-(empty)}, ${sp[1]+set}."
echo "sp[8]: '\''${sp[8]}'\'', ${sp[8]:-(empty)}, ${sp[8]+set}."
echo "sp[2]: '\''${sp[2]}'\'', ${sp[2]:-(empty)}, ${sp[2]+set}."
echo "sp[3]: '\''${sp[3]}'\'', ${sp[3]:-(empty)}, ${sp[3]+set}."
echo "sp[7]: '\''${sp[7]}'\'', ${sp[7]:-(empty)}, ${sp[7]+set}."

echo "sp[-1]: '\''${sp[-1]}'\''."
echo "sp[-2]: '\''${sp[-2]}'\''."
echo "sp[-3]: '\''${sp[-3]}'\''."
echo "sp[-4]: '\''${sp[-4]}'\''."
echo "sp[-9]: '\''${sp[-9]}'\''."'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 {sp[i]} with negative invalid index' {
  local cmd='sp=({1..9})
unset -v '\''sp[2]'\''
unset -v '\''sp[3]'\''
unset -v '\''sp[7]'\''

echo "sp[-10]: '\''${sp[-10]}'\''."
echo "sp[-11]: '\''${sp[-11]}'\''."
echo "sp[-19]: '\''${sp[-19]}'\''."'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 {a[@]:offset:length}' {
  local cmd='a=(v{0..9})
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\''

echo '\''==== ${a[@]:offset} ===='\''
echo "[${a[@]:0}][${a[*]:0}]"
echo "[${a[@]:2}][${a[*]:2}]"
echo "[${a[@]:3}][${a[*]:3}]"
echo "[${a[@]:5}][${a[*]:5}]"
echo "[${a[@]:9}][${a[*]:9}]"
echo "[${a[@]:10}][${a[*]:10}]"
echo "[${a[@]:11}][${a[*]:11}]"

echo '\''==== ${a[@]:negative} ===='\''
echo "[${a[@]: -1}][${a[*]: -1}]"
echo "[${a[@]: -2}][${a[*]: -2}]"
echo "[${a[@]: -5}][${a[*]: -5}]"
echo "[${a[@]: -9}][${a[*]: -9}]"
echo "[${a[@]: -10}][${a[*]: -10}]"
echo "[${a[@]: -11}][${a[*]: -11}]"
echo "[${a[@]: -21}][${a[*]: -21}]"

echo '\''==== ${a[@]:offset:length} ===='\''
echo "[${a[@]:0:0}][${a[*]:0:0}]"
echo "[${a[@]:0:1}][${a[*]:0:1}]"
echo "[${a[@]:0:3}][${a[*]:0:3}]"
echo "[${a[@]:2:1}][${a[*]:2:1}]"
echo "[${a[@]:2:4}][${a[*]:2:4}]"
echo "[${a[@]:3:4}][${a[*]:3:4}]"
echo "[${a[@]:5:4}][${a[*]:5:4}]"
echo "[${a[@]:5:0}][${a[*]:5:0}]"
echo "[${a[@]:9:1}][${a[*]:9:1}]"
echo "[${a[@]:9:2}][${a[*]:9:2}]"
echo "[${a[@]:10:1}][${a[*]:10:1}]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 {@:offset:length}' {
  local cmd='set -- v{1..9}

{
  echo '\''==== ${@:offset:length} ===='\''
  echo "[${*:0:3}][${*:0:3}]"
  echo "[${*:1:3}][${*:1:3}]"
  echo "[${*:3:3}][${*:3:3}]"
  echo "[${*:5:10}][${*:5:10}]"

  echo '\''==== ${@:negative} ===='\''
  echo "[${*: -1}][${*: -1}]"
  echo "[${*: -3}][${*: -3}]"
  echo "[${*: -9}][${*: -9}]"
  echo "[${*: -10}][${*: -10}]"
  echo "[${*: -11}][${*: -11}]"
  echo "[${*: -3:2}][${*: -3:2}]"
  echo "[${*: -9:4}][${*: -9:4}]"
  echo "[${*: -10:4}][${*: -10:4}]"
  echo "[${*: -11:4}][${*: -11:4}]"
} | sed "s:$SH:\$SH:g;s:${SH##*/}:\$SH:g"'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 {a[@]:BigInt}' {
  local cmd='a=(1 2 3)
a[0x7FFFFFFFFFFFFFFF]=x
a[0x7FFFFFFFFFFFFFFE]=y
a[0x7FFFFFFFFFFFFFFD]=z

echo "[${a[@]: -1}][${a[*]: -1}]"
echo "[${a[@]: -2}][${a[*]: -2}]"
echo "[${a[@]: -3}][${a[*]: -3}]"
echo "[${a[@]: -4}][${a[*]: -4}]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 {a[@]}' {
  local cmd='a=(v{0,1,2,3,4,5,6,7,8,9})
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\''

argv.py "${a[@]}"
argv.py "abc${a[@]}xyz"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 {a[@]#...}' {
  local cmd='a=(v{0..9})
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\''

argv.py "${a[@]#v}"
argv.py "abc${a[@]#v}xyz"
argv.py "${a[@]%[0-5]}"
argv.py "abc${a[@]%[0-5]}xyz"
argv.py "${a[@]#v?}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 {a[@]/pat/rep}' {
  local cmd='a=(v{0..9})
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\''

argv.py "${a[@]/?}"
argv.py "${a[@]//?}"
argv.py "${a[@]/#?}"
argv.py "${a[@]/%?}"

argv.py "${a[@]/v/x}"
argv.py "${a[@]//v/x}"
argv.py "${a[@]/[0-5]/D}"
argv.py "${a[@]//[!0-5]/_}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 {a[@]@P}, {a[@]@Q}, and {a[@]@a}' {
  local cmd='a=(v{0..9})
unset -v '\''a[2]'\'' '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\''

argv.py "${a[@]@P}"
argv.py "${a[*]@P}"
argv.py "${a[@]@Q}"
argv.py "${a[*]@Q}"
argv.py "${a[@]@a}"
argv.py "${a[*]@a}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 {a[@]-unset}, {a[@]:-empty}, etc.' {
  local cmd='a1=()
a2=("")
a3=("" "")

echo "a1 unset: [${a1[@]-unset}]"
echo "a1 empty: [${a1[@]:-empty}]"
echo "a2 unset: [${a2[@]-unset}]"
echo "a2 empty: [${a2[@]:-empty}]"
echo "a3 unset: [${a3[@]-unset}]"
echo "a3 empty: [${a3[@]:-empty}]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 {a-}' {
  local cmd='a1=()
a2=("" "")
a3=(foo bar)

echo "$a1, ${a1-(unset)}, ${a1:-(empty)};"
echo "$a2, ${a2-(unset)}, ${a2:-(empty)};"
echo "$a3, ${a3-(unset)}, ${a3:-(empty)};"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 {!a[0]}' {
  local cmd='v1=hello v2=world
a=(v1 v2)

echo "${!a[0]}, ${!a[1]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 {!a[@]}' {
  local cmd='a=(v{0..9})
unset -v '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\'' '\''a[9]'\''

argv.py "${!a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 {a[*]}' {
  local cmd='a=(v{0,1,2,3,4,5,6,7,8,9})
unset -v '\''a[3]'\'' '\''a[4]'\'' '\''a[7]'\'' '\''a[9]'\''

echo "${a[*]}"
IFS=
echo "${a[*]}"
IFS=/
echo "${a[*]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 compgen -F _set_COMPREPLY' {
  local cmd='_set_COMPREPLY() {
  COMPREPLY=({0..9})
  unset -v '\''COMPREPLY[2]'\'' '\''COMPREPLY[4]'\'' '\''COMPREPLY[6]'\''
}

compgen -F _set_COMPREPLY'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 compadjust' {
  local cmd='COMP_ARGV=(echo '\''Hello,'\'' '\''Bash'\'' '\''world!'\'')
compadjust cur prev words cword
argv.py "$cur" "$prev" "$cword"
argv.py "${words[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 (YSH) @[sp] and @sp' {
  local cmd='a=({0..5})
unset -v '\''a[1]'\'' '\''a[2]'\'' '\''a[4]'\''

shopt -s parse_at
argv.py @[a]
argv.py @a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 (YSH) [a1 === a2]' {
  skip 'YSH-only mode (shopt -s ysh:); not bash-applicable'
  local cmd='a1=(1 2 3)
unset -v '\''a1[1]'\''
a2=(1 2 3)
unset -v '\''a2[1]'\''
a3=(1 2 4)
unset -v '\''a3[1]'\''
a4=(1 2 3)

shopt -s ysh:upgrade

echo $[a1 === a1]
echo $[a1 === a2]
echo $[a1 === a3]
echo $[a1 === a4]
echo $[a2 === a1]
echo $[a3 === a1]
echo $[a4 === a1]'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 (YSH) append v1 v2... (a)' {
  local cmd='a=(1 2 3)
unset -v '\''a[1]'\''
append '\''x'\'' '\''y'\'' '\''z'\'' (a)
= a'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 (YSH) [bool(a)]' {
  skip "YSH syntax not supported"
  local cmd='a1=()
a2=(0)
a3=(0 1 2)
a4=(0 0)
unset -v '\''a4[0]'\''

shopt -s ysh:upgrade

echo $[bool(a1)]
echo $[bool(a2)]
echo $[bool(a3)]
echo $[bool(a4)]'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 crash dump' {
  local cmd='OILS_CRASH_DUMP_DIR=$TMP $SH -ec '\''a=({0..3}); unset -v "a[2]"; false'\''
json read (&crash_dump) < $TMP/*.json
json write (crash_dump.var_stack[0].a)'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 Regression: a[-1]=1' {
  local cmd='a[-1]=1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 Initializing indexed array with ([index]=value)' {
  local cmd='declare -a a=([xx]=1 [yy]=2 [zz]=3)
echo status=$?
argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

