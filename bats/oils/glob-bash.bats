#!/usr/bin/env bats
# Generated from oils-for-unix spec/glob-bash.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 shopt -s nullglob' {
  local cmd='argv.py _tmp/spec-tmp/*.nonexistent
shopt -s nullglob
argv.py _tmp/spec-tmp/*.nonexistent'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 shopt -s failglob in command context' {
  local cmd='argv.py *.ZZ
shopt -s failglob
argv.py *.ZZ  # nothing is printed, not []
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 shopt -s failglob in loop context' {
  local cmd='for x in *.ZZ; do echo $x; done
echo status=$?
shopt -s failglob
for x in *.ZZ; do echo $x; done
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 shopt -s failglob in array literal context' {
  local cmd='myarr=(*.ZZ)
echo "${myarr[@]}"
shopt -s failglob
myarr=(*.ZZ)
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 shopt -s failglob exits properly in command context with set -e' {
  local cmd='set -e
argv.py *.ZZ
shopt -s failglob
argv.py *.ZZ
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 shopt -s failglob exits properly in loop context with set -e' {
  local cmd='set -e
for x in *.ZZ; do echo $x; done
echo status=$?

shopt -s failglob
for x in *.ZZ; do echo $x; done
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 shopt -s failglob behavior on single line with semicolon' {
  local cmd='# bash behaves differently when commands are separated by a semicolon than when
# separated by a newline. This behavior doesn'\''t make sense or seem to be
# intentional, so osh does not mimic it.

shopt -s failglob
echo *.ZZ; echo status=$? # bash doesn'\''t execute the second part!
echo *.ZZ
echo status=$? # bash executes this'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 dotglob (bash option that no_dash_glob is roughly consistent with)' {
  local cmd='mkdir -p $TMP/dotglob
cd $TMP/dotglob
touch .foorc other

echo *
shopt -s dotglob
echo * | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

