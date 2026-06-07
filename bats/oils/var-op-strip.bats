#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-op-strip.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Remove const suffix' {
  local cmd='v=abcd
echo ${v%d} ${v%%cd}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Remove const prefix' {
  local cmd='v=abcd
echo ${v#a} ${v##ab}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Remove const suffix is vectorized on user array' {
  local cmd='a=(1a 2a 3a)
argv.py ${a[@]%a}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Remove const suffix is vectorized on @ array' {
  local cmd='set -- 1a 2a 3a
argv.py ${@%a}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Remove const suffix from undefined' {
  local cmd='echo ${undef%suffix}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Remove shortest glob suffix' {
  local cmd='v=aabbccdd
echo ${v%c*}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Remove longest glob suffix' {
  local cmd='v=aabbccdd
echo ${v%%c*}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Remove shortest glob prefix' {
  local cmd='v=aabbccdd
echo ${v#*b}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Remove longest glob prefix' {
  local cmd='v=aabbccdd
echo ${v##*b}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Strip char class' {
  local cmd='v=abc
echo ${v%[[:alpha:]]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Strip unicode prefix' {
  local cmd='show_hex() { od -A n -t c -t x1; }

# NOTE: LANG is set to utf-8.
# ? is a glob that stands for one character

v='\''μ-'\''
echo ${v#?} | show_hex
echo
echo ${v##?} | show_hex
echo

v='\''-μ'\''
echo ${v%?} | show_hex
echo
echo ${v%%?} | show_hex'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Bug fix: Test that you can remove everything with glob' {
  local cmd='s='\''--x--'\''
argv.py "${s%%-*}" "${s%-*}" "${s#*-}" "${s##*-}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Test that you can remove everything with const' {
  local cmd='s='\''abcd'\''
argv.py "${s%%abcd}" "${s%abcd}" "${s#abcd}" "${s##abcd}"
# failure case:
argv.py "${s%%abcde}" "${s%abcde}" "${s#abcde}" "${s##abcde}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Prepend using replacement of #' {
  local cmd='# This case was found in Kubernetes and others
array=(aa bb '\'''\'')
argv.py ${array[@]/#/prefix-}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Append using replacement of %' {
  local cmd='array=(aa bb '\'''\'')
argv.py ${array[@]/%/-suffix}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 strip unquoted and quoted [' {
  local cmd='# I guess dash and mksh treat unquoted [ as an invalid glob?
var='\''[foo]'\''
echo ${var#[}
echo ${var#"["}
echo "${var#[}"
echo "${var#"["}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 strip unquoted and quoted []' {
  local cmd='# LooksLikeGlob('\''[]'\'') is true
# I guess dash, mksh, and zsh treat unquoted [ as an invalid glob?
var='\''[]foo[]'\''
echo ${var#[]}
echo ${var#"[]"}
echo "${var#[]}"
echo "${var#"[]"}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 strip unquoted and quoted ?' {
  local cmd='var='\''[foo]'\''
echo ${var#?}
echo ${var#"?"}
echo "${var#?}"
echo "${var#"?"}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 strip unquoted and quoted [a]' {
  local cmd='var='\''[a]foo[]'\''
echo ${var#[a]}
echo ${var#"[a]"}
echo "${var#[a]}"
echo "${var#"[a]"}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Nested % and # operators (bug reported by Crestwave)' {
  local cmd='var=$'\''\n'\''
argv.py "${var#?}"
argv.py "${var%'\'''\''}"
argv.py "${var%"${var#?}"}"
var='\''a'\''
argv.py "${var#?}"
argv.py "${var%'\'''\''}"
argv.py "${var%"${var#?}"}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 strip * (bug regression)' {
  local cmd='x=abc
argv.py "${x#*}"
argv.py "${x##*}"
argv.py "${x%*}"
argv.py "${x%%*}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 strip ?' {
  local cmd='x=abc
argv.py "${x#?}"
argv.py "${x##?}"
argv.py "${x%?}"
argv.py "${x%%?}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 strip all' {
  local cmd='x=abc
argv.py "${x#abc}"
argv.py "${x##abc}"
argv.py "${x%abc}"
argv.py "${x%%abc}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 strip none' {
  local cmd='x=abc
argv.py "${x#}"
argv.py "${x##}"
argv.py "${x%}"
argv.py "${x%%}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 strip all unicode' {
  local cmd='x=μabcμ
echo "${x#?abc?}"
echo "${x##?abc?}"
echo "${x%?abc?}"
echo "${x%%?abc?}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 strip none unicode' {
  local cmd='x=μabcμ
argv.py "${x#}"
argv.py "${x##}"
argv.py "${x%}"
argv.py "${x%%}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 Strip Right Brace (#702)' {
  local cmd='var='\''$foo'\''
echo 1 "${var#$foo}"
echo 2 "${var#\$foo}"

var='\''}'\''
echo 10 "${var#}}"
echo 11 "${var#\}}"
echo 12 "${var#'\''}'\''}"
echo 13 "${var#"}"}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 () in pattern (regression)' {
  local cmd='x='\''foo()'\'' 
echo 1 ${x%*\(\)}
echo 2 ${x%%*\(\)}
echo 3 ${x#*\(\)}
echo 4 ${x##*\(\)}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 extglob in pattern' {
  local cmd='shopt -s extglob

x='\''foo()'\'' 
echo 1 ${x%*(foo|bar)'\''()'\''}
echo 2 ${x%%*(foo|bar)'\''()'\''}
echo 3 ${x#*(foo|bar)'\''()'\''}
echo 4 ${x##*(foo|bar)'\''()'\''}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

