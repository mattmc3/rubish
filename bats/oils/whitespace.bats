#!/usr/bin/env bats
# Generated from oils-for-unix spec/whitespace.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Parsing shell words r v' {
  local cmd='# frontend/lexer_def.py has rules for this

tab=$(python2 -c '\''print "argv.py -\t-"'\'')
cr=$(python2 -c '\''print "argv.py -\r-"'\'')
vert=$(python2 -c '\''print "argv.py -\v-"'\'')
ff=$(python2 -c '\''print "argv.py -\f-"'\'')

$SH -c "$tab"
$SH -c "$cr"
$SH -c "$vert"
$SH -c "$ff"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 r in arith expression is allowed by some shells, but not most!' {
  local cmd='arith=$(python2 -c '\''print "argv.py $(( 1 +\n2))"'\'')
arith_cr=$(python2 -c '\''print "argv.py $(( 1 +\r\n2))"'\'')

$SH -c "$arith"
if test $? -ne 0; then
  echo '\''failed'\''
fi

$SH -c "$arith_cr"
if test $? -ne 0; then
  echo '\''failed'\''
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 whitespace in string to integer conversion' {
  local cmd='tab=$(python2 -c '\''print "\t42\t"'\'')
cr=$(python2 -c '\''print "\r42\r"'\'')

$SH -c '\''echo $(( $1 + 1 ))'\'' dummy0 "$tab"
if test $? -ne 0; then
  echo '\''failed'\''
fi

$SH -c '\''echo $(( $1 + 1 ))'\'' dummy0 "$cr"
if test $? -ne 0; then
  echo '\''failed'\''
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 r at end of line is not special' {
  local cmd='# hm I wonder if Windows ports have rules for this?

cr=$(python2 -c '\''print "argv.py -\r"'\'')

$SH -c "$cr"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Default IFS does not include r v f' {
  local cmd='# dash and zsh don'\''t have echo -e
tab=$(python2 -c '\''print "-\t-"'\'')
cr=$(python2 -c '\''print "-\r-"'\'')
vert=$(python2 -c '\''print "-\v-"'\'')
ff=$(python2 -c '\''print "-\f-"'\'')

$SH -c '\''argv.py $1'\'' dummy0 "$tab"
$SH -c '\''argv.py $1'\'' dummy0 "$cr"
$SH -c '\''argv.py $1'\'' dummy0 "$vert"
$SH -c '\''argv.py $1'\'' dummy0 "$ff"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

