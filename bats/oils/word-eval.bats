#!/usr/bin/env bats
# Generated from oils-for-unix spec/word-eval.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Evaluation of constant parts' {
  local cmd='argv.py bare '\''sq'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Evaluation of each part' {
  local cmd='#set -o noglob
HOME=/home/bob
str=s
array=(a1 a2)
argv.py bare '\''sq'\'' ~ $str "-${str}-" "${array[@]}" $((1+2)) $(echo c) `echo c`'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Word splitting' {
  local cmd='s1='\''1 2'\''
s2='\''3 4'\''
s3='\''5 6'\''
argv.py $s1$s2 "$s3"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Word joining' {
  local cmd='set -- x y z
s1='\''1 2'\''
array=(a1 a2)
argv.py $s1"${array[@]}"_"$@"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Word elision' {
  local cmd='s1='\'''\''
argv.py $s1 - "$s1"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Default values -- more cases' {
  local cmd='argv.py ${undef:-hi} ${undef:-'\''a b'\''} "${undef:-c d}" "${un:-"e f"}" "${un:-'\''g h'\''}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Globbing after splitting' {
  local cmd='mkdir -p _tmp
touch _tmp/foo.gg _tmp/bar.gg _tmp/foo.hh
pat='\''_tmp/*.hh _tmp/*.gg'\''
argv.py $pat'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Globbing escaping' {
  local cmd='mkdir -p _tmp
touch '\''_tmp/[bc]ar.mm'\'' # file that looks like a glob pattern
touch _tmp/bar.mm _tmp/car.mm
argv.py '\''_tmp/[bc]'\''*.mm - _tmp/?ar.mm'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

