#!/usr/bin/env bats
# Generated from oils-for-unix spec/type-compat.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 declare -i -l -u errors can be silenced - ignore_flags_not_impl' {
  local cmd='declare -i foo=2+3
echo status=$?
echo foo=$foo
echo

shopt -s ignore_flags_not_impl
declare -i bar=2+3
echo status=$?
echo bar=$bar'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 declare -i with +=' {
  local cmd='declare s
s='\''1 '\''
s+='\'' 2 '\''  # string append

declare -i i
i='\''1 '\''
i+='\'' 2 '\''  # arith add

declare -i j
j=x  # treated like zero
j+='\'' 2 '\''  # arith add

echo "[$s]"
echo [$i]
echo [$j]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 declare -i with arithmetic inside strings (Nix, issue 864)' {
  local cmd='# example
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/stdenv/generic/setup.sh#L379

declare -i s
s='\''1 + 2'\''
echo s=$s

declare -a array=(1 2 3)
declare -i item
item='\''array[1+1]'\''
echo item=$item'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 append in arith context' {
  local cmd='declare s
(( s='\''1 '\''))
(( s+='\'' 2 '\''))  # arith add
declare -i i
(( i='\''1 '\'' ))
(( i+='\'' 2 '\'' ))
declare -i j
(( j='\''x '\'' ))  # treated like zero
(( j+='\'' 2 '\'' ))
echo "$s|$i|$j"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 declare array vs. string: mixing -a +a and () '\'''\''' {
  local cmd='# dynamic parsing of first argument.
declare +a '\''xyz1=1'\''
declare +a '\''xyz2=(2 3)'\''
declare -a '\''xyz3=4'\''
declare -a '\''xyz4=(5 6)'\''
argv.py "${xyz1}" "${xyz2}" "${xyz3[@]}" "${xyz4[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 declare array vs. associative array' {
  local cmd='# Hm I don'\''t understand why the array only has one element.  I guess because
# index 0 is used twice?
declare -a '\''array=([a]=b [c]=d)'\''
declare -A '\''assoc=([a]=b [c]=d)'\''
argv.py "${#array[@]}" "${!array[@]}" "${array[@]}"
argv.py "${#assoc[@]}" "${!assoc[@]}" "${assoc[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 declare -l -u' {
  local cmd='declare -l lower=FOO
declare -u upper=foo

echo $lower
echo $upper

# other:
# -t trace
# -I inherit attributes'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

