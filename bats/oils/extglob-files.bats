#!/usr/bin/env bats
# Generated from oils-for-unix spec/extglob-files.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 @() matches exactly one of the patterns' {
  local cmd='shopt -s extglob
mkdir -p 0
cd 0
touch {foo,bar}.cc {foo,bar,baz}.h
echo @(*.cc|*.h)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 ?() matches 0 or 1' {
  local cmd='shopt -s extglob
mkdir -p 1
cd 1
touch {foo,bar}.cc {foo,bar,baz}.h foo. foo.hh
ext=cc
echo foo.?($ext|h)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 *() matches 0 or more' {
  local cmd='shopt -s extglob
mkdir -p eg1
touch eg1/_ eg1/_One eg1/_OneOne eg1/_TwoTwo eg1/_OneTwo
echo eg1/_*(One|Two)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 +() matches 1 or more' {
  local cmd='shopt -s extglob
mkdir -p eg2
touch eg2/_ eg2/_One eg2/_OneOne eg2/_TwoTwo eg2/_OneTwo
echo eg2/_+(One|$(echo Two))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 !(*.h|*.cc) to match everything except C++' {
  local cmd='shopt -s extglob
mkdir -p extglob2
touch extglob2/{foo,bar}.cc extglob2/{foo,bar,baz}.h \
      extglob2/{foo,bar,baz}.py
echo extglob2/!(*.h|*.cc)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Two adjacent alternations' {
  local cmd='shopt -s extglob
mkdir -p 2
touch 2/{aa,ab,ac,ba,bb,bc,ca,cb,cc}
echo 2/!(b)@(b|c)
echo 2/!(b)?@(b|c)  # wildcard in between
echo 2/!(b)a@(b|c)  # constant in between'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Nested extended glob pattern' {
  local cmd='shopt -s extglob
mkdir -p eg6
touch eg6/{ab,ac,ad,az,bc,bd}
echo eg6/a@(!(c|d))
echo eg6/a!(@(ab|b*))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Extended glob patterns with spaces' {
  local cmd='shopt -s extglob
mkdir -p eg4
touch eg4/a '\''eg4/a b'\'' eg4/foo
argv.py eg4/@(a b|foo)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Filenames with spaces' {
  local cmd='shopt -s extglob
mkdir -p eg5
touch eg5/'\''a b'\''{cd,de,ef}
argv.py eg5/'\''a '\''@(bcd|bde|zzz)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 nullglob with extended glob' {
  local cmd='shopt -s extglob
mkdir eg6
argv.py eg6/@(no|matches)  # no matches
shopt -s nullglob  # test this too
argv.py eg6/@(no|matches)  # no matches'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Glob other punctuation chars (lexer mode)' {
  local cmd='shopt -s extglob
mkdir -p eg5
cd eg5
touch __{aa,'\''<>'\'','\''{}'\'','\''#'\'','\''&&'\''}
argv.py @(__aa|'\''__<>'\''|__{}|__#|__&&|)

# mksh sorts them differently'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 More glob escaping' {
  local cmd='shopt -s extglob
mkdir -p eg7
cd eg7
touch '\''_[:]'\'' '\''_*'\'' '\''_?'\''
argv.py @('\''_[:]'\''|'\''_*'\''|'\''_?'\'')
argv.py @(nested|'\''_?'\''|@('\''_[:]'\''|'\''_*'\''))

# mksh sorts them differently'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Escaping of pipe (glibc bug, see demo/glibc_fnmatch.c)' {
  local cmd='shopt -s extglob

mkdir -p extpipe
cd extpipe

touch '\''__|'\'' foo
argv.py @('\''foo'\''|__\||bar)
argv.py @('\''foo'\''|'\''__|'\''|bar)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Extended glob as argument to {undef:-} (dynamic globbing)' {
  local cmd='# This case popped into my mind after inspecting osh/word_eval.py for calls to
# _EvalWordToParts()

shopt -s extglob

mkdir -p eg8
cd eg8
touch {foo,bar,spam}.py

# regular glob
echo ${undef:-*.py}

# extended glob
echo ${undef:-@(foo|bar).py}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Extended glob in assignment builtin' {
  local cmd='# Another invocation of _EvalWordToParts() that OSH should handle

shopt -s extglob
mkdir -p eg9
cd eg9
touch {foo,bar}.py
typeset -@(*.py) myvar
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Extended glob in same word as array' {
  local cmd='shopt -s extglob
mkdir -p eg10
cd eg10

touch {'\''a b c'\'',bee,cee}.{py,cc}
set -- '\''a b'\'' '\''c'\''

argv.py "$@"

# This works!
argv.py star glob "$*"*.py
argv.py star extglob "$*"*@(.py|cc)

# Hm this actually still works!  the first two parts are literal.  And then
# there'\''s something like the simple_word_eval algorithm on the rest.  Gah.
argv.py at extglob "$@"*@(.py|cc)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Extended glob with word splitting' {
  local cmd='shopt -s extglob
mkdir -p 3
cd 3

x='\''a b'\''
touch bar.{cc,h}

# OSH may disallow splitting when there'\''s an extended glob
argv.py $x*.@(cc|h)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 In Array Literal and for loop' {
  local cmd='shopt -s extglob
mkdir -p eg11
cd eg11
touch {foo,bar,spam}.py
for x in @(fo*|bar).py; do
  echo $x
done

echo ---
declare -a A
A=(zzz @(fo*|bar).py)
echo "${A[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 No extended glob with simple_word_eval (YSH evaluation)' {
  local cmd='shopt -s ysh:all
shopt -s extglob
mkdir -p eg12
cd eg12
touch {foo,bar,spam}.py
builtin write -- x@(fo*|bar).py
builtin write -- @(fo*|bar).py'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 no match' {
  local cmd='shopt -s extglob
echo @(__nope__)

# OSH has glob quoting here
echo @(__nope__*|__nope__?|'\''*'\''|'\''?'\''|'\''[:alpha:]'\''|'\''|'\'')

if test $SH != osh; then
  exit
fi

# OSH has this alias for @()
echo ,(osh|style)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 no_dash_glob' {
  local cmd='shopt -s extglob
mkdir -p opts
cd opts

touch -- foo bar -dash
echo @(*)

shopt --set no_dash_glob
echo @(*)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 noglob' {
  local cmd='shopt -s extglob
mkdir -p _noglob
cd _noglob

set -o noglob
echo @(*)
echo @(__nope__*|__nope__?|'\''*'\''|'\''?'\''|'\''[:alpha:]'\''|'\''|'\'')'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 failglob' {
  local cmd='shopt -s extglob

rm -f _failglob/*
mkdir -p _failglob
cd _failglob

shopt -s failglob
echo @(*)
echo status=$?

touch foo
echo @(*)
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

