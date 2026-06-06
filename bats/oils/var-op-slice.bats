#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-op-slice.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 String slice' {
  local cmd='foo=abcdefg
echo ${foo:1:3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Cannot take length of substring slice' {
  local cmd='# These are runtime errors, but we could make them parse time errors.
v=abcde
echo ${#v:1:3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Out of range string slice: begin' {
  local cmd='# out of range begin doesn'\''t raise error in bash, but in mksh it skips the
# whole thing!
foo=abcdefg
echo _${foo:100:3}
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Out of range string slice: length' {
  local cmd='# OK in both bash and mksh
foo=abcdefg
echo _${foo:3:100}
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Negative start index' {
  local cmd='foo=abcdefg
echo ${foo: -4:3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Negative start index respects unicode' {
  local cmd='foo=abcd-μ-
echo ${foo: -4:3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Negative second arg is position, not length!' {
  local cmd='foo=abcdefg
echo ${foo:3:-1} ${foo: 3: -2} ${foo:3 :-3 }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Negative start index respects unicode' {
  local cmd='foo=abcd-μ-
echo ${foo: -5: -3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 String slice with math' {
  local cmd='# I think this is the $(()) language inside?
i=1
foo=abcdefg
echo ${foo: i+4-2 : i + 2}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Slice undefined' {
  local cmd='echo -${undef:1:2}-
set -o nounset
echo -${undef:1:2}-
echo -done-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Slice UTF-8 String' {
  local cmd='# mksh slices by bytes.
foo='\''--μ--'\''
echo ${foo:1:3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Slice string with invalid UTF-8 results in empty string and warning' {
  local cmd='s=$(echo -e "\xFF")bcdef
echo -${s:1:3}-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Slice string with invalid UTF-8 with strict_word_eval' {
  local cmd='shopt -s strict_word_eval || true
echo slice
s=$(echo -e "\xFF")bcdef
echo -${s:1:3}-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Slice with an index that'\''s an array -- silent a[0] decay' {
  local cmd='i=(3 4 5)
mystr=abcdefg
echo assigned
echo ${mystr:$i:2}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Slice with an assoc array' {
  local cmd='declare -A A=(['\''5'\'']=3 ['\''6'\'']=4)
mystr=abcdefg
echo assigned
echo ${mystr:$A:2}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Simple {@:offset}' {
  local cmd='set -- 4 5 6

result=$(argv.py ${@:0})
echo ${result//"$0"/'\''SHELL'\''}

argv.py ${@:1}
argv.py ${@:2}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 {@:offset} and {*:offset}' {
  local cmd='case $SH in zsh) return ;; esac  # zsh is very different

argv.shell-name-checked () {
  argv.py "${@//$0/SHELL}"
}
fun() {
  argv.shell-name-checked -${*:0}- # include $0
  argv.shell-name-checked -${*:1}- # from $1
  argv.shell-name-checked -${*:3}- # last parameter $3
  argv.shell-name-checked -${*:4}- # empty
  argv.shell-name-checked -${*:5}- # out of boundary
  argv.shell-name-checked -${@:0}-
  argv.shell-name-checked -${@:1}-
  argv.shell-name-checked -${@:3}-
  argv.shell-name-checked -${@:4}-
  argv.shell-name-checked -${@:5}-
  argv.shell-name-checked "-${*:0}-"
  argv.shell-name-checked "-${*:1}-"
  argv.shell-name-checked "-${*:3}-"
  argv.shell-name-checked "-${*:4}-"
  argv.shell-name-checked "-${*:5}-"
  argv.shell-name-checked "-${@:0}-"
  argv.shell-name-checked "-${@:1}-"
  argv.shell-name-checked "-${@:3}-"
  argv.shell-name-checked "-${@:4}-"
  argv.shell-name-checked "-${@:5}-"
}
fun "a 1" "b 2" "c 3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 {@:offset:length} and {*:offset:length}' {
  local cmd='case $SH in zsh) return ;; esac  # zsh is very different

argv.shell-name-checked () {
  argv.py "${@//$0/SHELL}"
}
fun() {
  argv.shell-name-checked -${*:0:2}- # include $0
  argv.shell-name-checked -${*:1:2}- # from $1
  argv.shell-name-checked -${*:3:2}- # last parameter $3
  argv.shell-name-checked -${*:4:2}- # empty
  argv.shell-name-checked -${*:5:2}- # out of boundary
  argv.shell-name-checked -${@:0:2}-
  argv.shell-name-checked -${@:1:2}-
  argv.shell-name-checked -${@:3:2}-
  argv.shell-name-checked -${@:4:2}-
  argv.shell-name-checked -${@:5:2}-
  argv.shell-name-checked "-${*:0:2}-"
  argv.shell-name-checked "-${*:1:2}-"
  argv.shell-name-checked "-${*:3:2}-"
  argv.shell-name-checked "-${*:4:2}-"
  argv.shell-name-checked "-${*:5:2}-"
  argv.shell-name-checked "-${@:0:2}-"
  argv.shell-name-checked "-${@:1:2}-"
  argv.shell-name-checked "-${@:3:2}-"
  argv.shell-name-checked "-${@:4:2}-"
  argv.shell-name-checked "-${@:5:2}-"
}
fun "a 1" "b 2" "c 3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 {@:0:1}' {
  local cmd='set a b c
result=$(echo ${@:0:1})
echo ${result//"$0"/'\''SHELL'\''}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Permutations of implicit begin and length' {
  local cmd='array=(1 2 3)

argv.py ${array[@]}

# *** implicit length of N **
argv.py ${array[@]:0}

# Why is this one not allowed
#argv.py ${array[@]:}

# ** implicit length of ZERO **
#argv.py ${array[@]::}
#argv.py ${array[@]:0:}

argv.py ${array[@]:0:0}
echo

# Same agreed upon permutations
set -- 1 2 3
argv.py ${@}
argv.py ${@:1}
argv.py ${@:1:0}
echo

s='\''123'\''
argv.py "${s}"
argv.py "${s:0}"
argv.py "${s:0:0}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 {array[@]:} vs {array[@]: }  - bash and zsh inconsistent' {
  local cmd='$SH -c '\''array=(1 2 3); argv.py ${array[@]:}'\''
$SH -c '\''array=(1 2 3); argv.py space ${array[@]: }'\''

$SH -c '\''s=123; argv.py ${s:}'\''
$SH -c '\''s=123; argv.py space ${s: }'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 {array[@]::} has implicit length of zero - for ble.sh' {
  local cmd='# https://oilshell.zulipchat.com/#narrow/stream/121540-oil-discuss/topic/.24.7Barr.5B.40.5D.3A.3A.7D.20in.20bash.20-.20is.20it.20documented.3F

array=(1 2 3)
argv.py ${array[@]::}
argv.py ${array[@]:0:}

echo

set -- 1 2 3
argv.py ${@::}
argv.py ${@:0:}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

