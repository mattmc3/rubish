#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-op-test.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Lazy Evaluation of Alternative' {
  local cmd='i=0
x=x
echo ${x:-$((i++))}
echo $i
echo ${undefined:-$((i++))}
echo $i  # i is one because the alternative was only evaluated once'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Default value when empty' {
  local cmd='empty='\'''\''
echo ${empty:-is empty}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Default value when unset' {
  local cmd='echo ${unset-is unset}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Unquoted with array as default value' {
  local cmd='set -- '\''1 2'\'' '\''3 4'\''
argv.py X${unset=x"$@"x}X
argv.py X${unset=x$@x}X  # If you want OSH to split, write this
# osh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Quoted with array as default value' {
  local cmd='set -- '\''1 2'\'' '\''3 4'\''
argv.py "X${unset=x"$@"x}X"
argv.py "X${unset=x$@x}X"  # OSH is the same here'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Assign default with array' {
  local cmd='set -- '\''1 2'\'' '\''3 4'\''
argv.py X${unset=x"$@"x}X
argv.py "$unset"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Assign default value when empty' {
  local cmd='empty='\'''\''
${empty:=is empty}
echo $empty'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Assign default value when unset' {
  local cmd='${unset=is unset}
echo $unset'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 {v:+foo} Alternative value when empty' {
  local cmd='v=foo
empty='\'''\''
echo ${v:+v is not empty} ${empty:+is not empty}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 {v+foo} Alternative value when unset' {
  local cmd='v=foo
echo ${v+v is not unset} ${unset:+is not unset}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 {x+foo} quoted (regression)' {
  local cmd='# Python'\''s configure caught this
argv.py "${with_icc+set}" = set'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 {s+foo} and {s:+foo} when set -u' {
  local cmd='set -u
v=v
echo v=${v:+foo}
echo v=${v+foo}
unset v
echo v=${v:+foo}
echo v=${v+foo}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 {array[@]} with set -u (bash is outlier)' {
  local cmd='case $SH in dash) exit ;; esac

set -u

typeset -a empty
empty=()

echo empty /"${empty[@]}"/
echo undefined /"${undefined[@]}"/'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 {undefined[@]+foo} and {undefined[@]:+foo}, with set -u' {
  local cmd='case $SH in dash) exit ;; esac

set -u

echo plus /"${array[@]+foo}"/
echo plus colon /"${array[@]:+foo}"/'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 {a[@]+foo} and {a[@]:+foo} - operators are equivalent on arrays?' {
  local cmd='case $SH in dash) exit ;; esac

echo '\''+ '\'' /"${array[@]+foo}"/
echo '\''+:'\'' /"${array[@]:+foo}"/
echo

typeset -a array
array=()

echo '\''+ '\'' /"${array[@]+foo}"/
echo '\''+:'\'' /"${array[@]:+foo}"/
echo

array=('\'''\'')

echo '\''+ '\'' /"${array[@]+foo}"/
echo '\''+:'\'' /"${array[@]:+foo}"/
echo

array=(spam eggs)

echo '\''+ '\'' /"${array[@]+foo}"/
echo '\''+:'\'' /"${array[@]:+foo}"/
echo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Nix idiom {!hooksSlice+{!hooksSlice}} - was workaround for obsolete bash 4.3 bug' {
  local cmd='case $SH in dash|mksh|zsh) exit ;; esac

# https://oilshell.zulipchat.com/#narrow/stream/307442-nix/topic/Replacing.20bash.20with.20osh.20in.20Nixpkgs.20stdenv

(argv.py ${!hooksSlice+"${!hooksSlice}"})

hooksSlice=x

argv.py ${!hooksSlice+"${!hooksSlice}"}

declare -a hookSlice=()

argv.py ${!hooksSlice+"${!hooksSlice}"}

foo=42
bar=43

declare -a hooksSlice=(foo bar spam eggs)

argv.py ${!hooksSlice+"${!hooksSlice}"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 {v-foo} and {v:-foo} when set -u' {
  local cmd='set -u
v=v
echo v=${v:-foo}
echo v=${v-foo}
unset v
echo v=${v:-foo}
echo v=${v-foo}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 array and - and +' {
  local cmd='case $SH in dash) exit ;; esac

shopt -s compat_array  # to refer to array as scalar

empty=()
a1=('\'''\'')
a2=('\'''\'' x)
a3=(3 4)
echo empty=${empty[@]-minus}
echo a1=${a1[@]-minus}
echo a1[0]=${a1[0]-minus}
echo a2=${a2[@]-minus}
echo a3=${a3[@]-minus}
echo ---

echo empty=${empty[@]+plus}
echo a1=${a1[@]+plus}
echo a1[0]=${a1[0]+plus}
echo a2=${a2[@]+plus}
echo a3=${a3[@]+plus}
echo ---

echo empty=${empty+plus}
echo a1=${a1+plus}
echo a2=${a2+plus}
echo a3=${a3+plus}
echo ---

# Test quoted arrays too
argv.py "${empty[@]-minus}"
argv.py "${empty[@]+plus}"
argv.py "${a1[@]-minus}"
argv.py "${a1[@]+plus}"
argv.py "${a1[0]-minus}"
argv.py "${a1[0]+plus}"
argv.py "${a2[@]-minus}"
argv.py "${a2[@]+plus}"
argv.py "${a3[@]-minus}"
argv.py "${a3[@]+plus}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 @ (empty) and - and +' {
  local cmd='echo argv=${@-minus}
echo argv=${@+plus}
echo argv=${@:-minus}
echo argv=${@:+plus}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 @ () and - and +' {
  local cmd='set -- ""
echo argv=${@-minus}
echo argv=${@+plus}
echo argv=${@:-minus}
echo argv=${@:+plus}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 @ ( ) and - and +' {
  local cmd='set -- "" ""
echo argv=${@-minus}
echo argv=${@+plus}
echo argv=${@:-minus}
echo argv=${@:+plus}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 * ( ) and - and + (IFS=)' {
  local cmd='set -- "" ""
IFS=
echo argv=${*-minus}
echo argv=${*+plus}
echo argv=${*:-minus}
echo argv=${*:+plus}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 * ( ) and - and + (IFS=)' {
  local cmd='set -- "" ""
IFS=
echo "argv=${*-minus}"
echo "argv=${*+plus}"
echo "argv=${*:-minus}"
echo "argv=${*:+plus}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 assoc array and - and +' {
  local cmd='case $SH in dash|mksh) exit ;; esac

declare -A empty=()
declare -A assoc=(['\''k'\'']=v)

echo empty=${empty[@]-minus}
echo empty=${empty[@]+plus}
echo assoc=${assoc[@]-minus}
echo assoc=${assoc[@]+plus}

echo ---
echo empty=${empty[@]:-minus}
echo empty=${empty[@]:+plus}
echo assoc=${assoc[@]:-minus}
echo assoc=${assoc[@]:+plus}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Error when empty' {
  local cmd='empty='\'''\''
echo ${empty:?'\''is em'\''pty}  # test eval of error
echo should not get here'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Error when unset' {
  local cmd='echo ${unset?is empty}
echo should not get here'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Error when unset' {
  local cmd='v=foo
echo ${v+v is not unset} ${unset:+is not unset}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 {var=x} dynamic scope' {
  local cmd='f() { : "${hello:=x}"; echo $hello; }
f
echo hello=$hello

f() { hello=x; }
f
echo hello=$hello'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 array {arr[0]=x}' {
  local cmd='arr=()
echo ${#arr[@]}
: ${arr[0]=x}
echo ${#arr[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 assoc array {arr[k]=x}' {
  local cmd='# note: this also works in zsh

declare -A arr=()
echo ${#arr[@]}
: ${arr['\''k'\'']=x}
echo ${#arr[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 z as arg' {
  local cmd='echo "${undef-\$}"
echo "${undef-\(}"
echo "${undef-\z}"
echo "${undef-\"}"
echo "${undef-\`}"
echo "${undef-\\}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 e as arg' {
  local cmd='echo "${undef-\e}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 op-test for {a} and {a[0]}' {
  local cmd='case $SH in dash) exit ;; esac

test-hyphen() {
  echo "a   : '\''${a-no-colon}'\'' '\''${a:-with-colon}'\''"
  echo "a[0]: '\''${a[0]-no-colon}'\'' '\''${a[0]:-with-colon}'\''"
}

a=()
test-hyphen
a=("")
test-hyphen
a=("" "")
test-hyphen
IFS=
test-hyphen'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 op-test for {a[@]} and {a[*]}' {
  local cmd='case $SH in dash) exit ;; esac

test-hyphen() {
  echo "a[@]: '\''${a[@]-no-colon}'\'' '\''${a[@]:-with-colon}'\''"
  echo "a[*]: '\''${a[*]-no-colon}'\'' '\''${a[*]:-with-colon}'\''"
}

a=()
test-hyphen
a=("")
test-hyphen
a=("" "")
test-hyphen
IFS=
test-hyphen'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 op-test for {!array} with array=a and array=a[0]' {
  local cmd='case $SH in dash|mksh|zsh) exit ;; esac

test-hyphen() {
  ref='\''a'\''
  echo "ref=a   : '\''${!ref-no-colon}'\'' '\''${!ref:-with-colon}'\''"
  ref='\''a[0]'\''
  echo "ref=a[0]: '\''${!ref-no-colon}'\'' '\''${!ref:-with-colon}'\''"
}

a=()
test-hyphen
a=("")
test-hyphen
a=("" "")
test-hyphen
IFS=
test-hyphen'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 op-test for {!array} with array=a[@] or array=a[*]' {
  local cmd='case $SH in dash|mksh|zsh) exit ;; esac

test-hyphen() {
  ref='\''a[@]'\''
  echo "ref=a[@]: '\''${!ref-no-colon}'\'' '\''${!ref:-with-colon}'\''"
  ref='\''a[*]'\''
  echo "ref=a[*]: '\''${!ref-no-colon}'\'' '\''${!ref:-with-colon}'\''"
}

a=()
test-hyphen
a=("")
test-hyphen
a=("" "")
test-hyphen
IFS=
test-hyphen'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 op-test for unquoted {a[*]:-empty} with IFS=' {
  local cmd='case $SH in dash) exit ;; esac

IFS=
a=("" "")
argv.py ${a[*]:-empty}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

