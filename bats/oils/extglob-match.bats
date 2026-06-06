#!/usr/bin/env bats
# Generated from oils-for-unix spec/extglob-match.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 @ matches exactly one' {
  local cmd='[[ --verbose == --@(help|verbose) ]] && echo TRUE
[[ --oops == --@(help|verbose) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 @() with variable arms' {
  local cmd='choice1='\''help'\''
choice2='\''verbose'\''
[[ --verbose == --@($choice1|$choice2) ]] && echo TRUE
[[ --oops == --@($choice1|$choice2) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 extglob in variable' {
  local cmd='shopt -s extglob

# this syntax requires extglob in bash!!
# OSH never allows it
g=--@(help|verbose)

quoted='\''--@(help|verbose)'\''

[[ --help == $g ]] && echo TRUE
[[ --verbose == $g ]] && echo TRUE
[[ -- == $g ]] || echo FALSE
[[ --help == $q ]] || echo FALSE
[[ -- == $q ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Matching literal '\''@(cc)'\''' {
  local cmd='# extglob is OFF.  Doesn'\''t affect bash or mksh!
[[ cc == @(cc) ]] 
echo status=$?
[[ cc == '\''@(cc)'\'' ]]
echo status=$?

shopt -s extglob

[[ cc == @(cc) ]]
echo status=$?
[[ cc == '\''@(cc)'\'' ]]
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 nested @()' {
  local cmd='shopt -s extglob
pat='\''--@(help|verbose|no-@(long|short)-option)'\''
[[ --no-long-option == $pat ]] && echo TRUE
[[ --no-short-option == $pat ]] && echo TRUE
[[ --help == $pat ]] && echo TRUE
[[ --oops == $pat ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 nested @() with quotes and vars' {
  local cmd='shopt -s extglob
prefix=no
[[ --no-long-option == --@(help|verbose|$prefix-@(long|short)-'\''option'\'') ]] &&
  echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 ? matches 0 or 1' {
  local cmd='[[ -- == --?(help|verbose) ]] && echo TRUE
[[ --oops == --?(help|verbose) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 + matches 1 or more' {
  local cmd='[[ --helphelp == --+(help|verbose) ]] && echo TRUE
[[ -- == --+(help|verbose) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 * matches 0 or more' {
  local cmd='[[ -- == --*(help|verbose) ]] && echo TRUE
[[ --oops == --*(help|verbose) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 simple repetition with *(foo) and +(Foo)' {
  local cmd='[[ foofoo == *(foo) ]] && echo TRUE
[[ foofoo == +(foo) ]] && echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 ! matches none' {
  local cmd='[[ --oops == --!(help|verbose) ]] && echo TRUE
[[ --help == --!(help|verbose) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 match is anchored' {
  local cmd='[[ foo_ == @(foo) ]] || echo FALSE
[[ _foo == @(foo) ]] || echo FALSE
[[ foo == @(foo) ]] && echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 repeated match is anchored' {
  local cmd='[[ foofoo_ == +(foo) ]] || echo FALSE
[[ _foofoo == +(foo) ]] || echo FALSE
[[ foofoo == +(foo) ]] && echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 repetition with glob' {
  local cmd='# NOTE that * means two different things here
[[ foofoo_foo__foo___ == *(foo*) ]] && echo TRUE
[[ Xoofoo_foo__foo___ == *(foo*) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 No brace expansion in ==' {
  local cmd='[[ --X{a,b}X == --@(help|X{a,b}X) ]] && echo TRUE
[[ --oops == --@(help|X{a,b}X) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 adjacent extglob' {
  local cmd='[[ --help == @(--|++)@(help|verbose) ]] && echo TRUE
[[ ++verbose == @(--|++)@(help|verbose) ]] && echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 nested extglob' {
  local cmd='[[ --help == --@(help|verbose=@(1|2)) ]] && echo TRUE
[[ --verbose=1 == --@(help|verbose=@(1|2)) ]] && echo TRUE
[[ --verbose=2 == --@(help|verbose=@(1|2)) ]] && echo TRUE
[[ --verbose == --@(help|verbose=@(1|2)) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 extglob empty string' {
  local cmd='shopt -s extglob
[[ '\'''\'' == @(foo|bar) ]] || echo FALSE
[[ '\'''\'' == @(foo||bar) ]] && echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 extglob empty pattern' {
  local cmd='shopt -s extglob
[[ '\'''\'' == @() ]] && echo TRUE
[[ '\'''\'' == @(||) ]] && echo TRUE
[[ X == @() ]] || echo FALSE
[[ '\''|'\'' == @(||) ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 case with extglob' {
  local cmd='shopt -s extglob
for word in --help --verbose --unmatched -- -zxzx -; do
  case $word in
    --@(help|verbose) )
      echo A
      continue
      ;;
    ( --?(b|c) )
      echo B
      continue
      ;;
    ( -+(x|z) )
      echo C
      continue
      ;;
    ( -*(x|z) )
      echo D
      continue
      ;;
    *)
      echo U
      continue
      ;;
  esac
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 [[ x == !(str) ]]' {
  local cmd='shopt -s extglob
empty='\'''\''
str='\''x'\''
[[ $empty == !($str) ]] && echo TRUE  # test glob match
[[ $str == !($str) ]]   || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Turning extglob on changes the meaning of [[ !(str) ]] in bash' {
  local cmd='empty='\'''\''
str='\''x'\''
[[ !($empty) ]]  && echo TRUE   # test if $empty is empty
[[ !($str) ]]    || echo FALSE  # test if $str is empty
shopt -s extglob  # mksh doesn'\''t have this
[[ !($empty) ]]  && echo TRUE   # negated glob
[[ !($str) ]]    && echo TRUE   # negated glob'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 With extglob on, !(str) on the left or right of == has different meanings' {
  local cmd='shopt -s extglob
str='\''x'\''
[[ 1 == !($str) ]]  && echo TRUE   # glob match'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 extglob inside arg word' {
  local cmd='shopt -s extglob
[[ foo == @(foo|bar) ]] && echo rhs
[[ foo == ${unset:-@(foo|bar)} ]] && echo '\''rhs arg'\''
[[ fo == ${unset:-@(foo|bar)} ]] || echo nope'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 extglob is not detected in regex!' {
  local cmd='shopt -s extglob
[[ foo =~ ^@(foo|bar)$ ]] || echo FALSE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 regular glob of single unicode char' {
  local cmd='shopt -s extglob
[[ __a__ == __?__ ]]
echo $?
[[ __μ__ == __?__ ]]
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 extended glob of single unicode char' {
  local cmd='shopt -s extglob
[[ __a__ == @(__?__) ]]
echo $?
[[ __μ__ == @(__?__) ]]
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Extended glob in {x//pat/replace}' {
  local cmd='# not supported in OSH due to GlobToERE() strategy for positional info

shopt -s extglob
x=foo.py
echo ${x//@(?.py)/Z}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 Extended glob in {x%PATTERN}' {
  local cmd='shopt -s extglob
x=foo.py
echo '\''strip % '\'' ${x%.@(py|cc)}
echo '\''strip %%'\'' ${x%%.@(py|cc)}
echo '\''strip # '\'' ${x#@(foo)}
echo '\''strip ##'\'' ${x##@(foo)}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

