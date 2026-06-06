#!/usr/bin/env bats
# Generated from oils-for-unix spec/var-op-patsub.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Pattern replacement' {
  local cmd='v=abcde
echo ${v/c*/XX}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Pattern replacement on unset variable' {
  local cmd='echo -${v/x/y}-
echo status=$?
set -o nounset  # make sure this fails
echo -${v/x/y}-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Global Pattern replacement with /' {
  local cmd='s=xx_xx_xx
echo ${s/xx?/yy_} ${s//xx?/yy_}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Left Anchored Pattern replacement with #' {
  local cmd='s=xx_xx_xx
echo ${s/?xx/_yy} ${s/#?xx/_yy}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Right Anchored Pattern replacement with %' {
  local cmd='s=xx_xx_xx
echo ${s/?xx/_yy} ${s/%?xx/_yy}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Replace fixed strings' {
  local cmd='s=xx_xx
echo ${s/xx/yy} ${s//xx/yy} ${s/#xx/yy} ${s/%xx/yy}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Replace is longest match' {
  local cmd='# If it were shortest, then you would just replace the first <html>
s='\''begin <html></html> end'\''
echo ${s/<*>/[]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Replace char class' {
  local cmd='s=xx_xx_xx
echo ${s//[[:alpha:]]/y} ${s//[^[:alpha:]]/-}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Replace hard glob' {
  local cmd='s='\''aa*bb+cc'\''
echo ${s//\**+/__}  # Literal *, then any sequence of characters, then literal +'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 {v/} is empty search and replacement' {
  local cmd='v=abcde
echo -${v/}-
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 {v//} is empty search and replacement' {
  local cmd='v='\''a/b/c'\''
echo -${v//}-
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Confusing unquoted slash matches bash (and ash)' {
  local cmd='x='\''/_/'\''
echo ${x////c}

echo ${x//'\''/'\''/c}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Synthesized {x///} bug (similar to above)' {
  local cmd='# found via test/parse-errors.sh

x='\''slash / brace } hi'\''
echo '\''ambiguous:'\'' ${x///}

echo '\''quoted:   '\'' ${x//'\''/'\''}

# Wow we have all combination here -- TERRIBLE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 {v/a} is the same as {v/a/}  -- no replacement string' {
  local cmd='v='\''aabb'\''
echo ${v/a}
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Replacement with special chars (bug fix)' {
  local cmd='v=xx
echo ${v/x/"?"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Replace backslash' {
  local cmd='v='\''[\f]'\''
x='\''\f'\''
echo ${v/"$x"/_}

# mksh and zsh differ on this case, but this is consistent with the fact that
# \f as a glob means '\''f'\'', not '\''\f'\''.  TODO: Warn that it'\''s a bad glob?
# The canonical form is '\''f'\''.
echo ${v/$x/_}

echo ${v/\f/_}
echo ${v/\\f/_}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Replace right ]' {
  local cmd='v='\''--]--'\''
x='\'']'\''
echo ${v/"$x"/_}
echo ${v/$x/_}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Substitute glob characters in pattern, quoted and unquoted' {
  local cmd='# INFINITE LOOP in ash!
case $SH in ash) exit ;; esac

g='\''*'\''
v='\''a*b'\''
echo ${v//"$g"/-}
echo ${v//$g/-}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Substitute one unicode character (UTF-8)' {
  local cmd='export LANG='\''en_US.UTF-8'\''

s='\''_μ_ and _μ_'\''

# ? should match one char

echo ${s//_?_/foo}  # all
echo ${s/#_?_/foo}  # left
echo ${s/%_?_/foo}  # right'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 When LC_ALL=C, pattern ? doesn'\''t match multibyte character' {
  local cmd='export LC_ALL='\''C'\''

s='\''_μ_ and _μ_'\''

# ? should match one char

echo ${s//_?_/foo}  # all
echo ${s/#_?_/foo}  # left
echo ${s/%_?_/foo}  # right
echo

a='\''_x_ and _y_'\''

echo ${a//_?_/foo}  # all
echo ${a/#_?_/foo}  # left
echo ${a/%_?_/foo}  # right'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 {x/^} regression' {
  local cmd='x=abc
echo ${x/^}
echo ${x/!}

y=^^^
echo ${y/^}
echo ${y/!}

z=!!!
echo ${z/^}
echo ${z/!}

s=a^b!c
echo ${s/a^}
echo ${s/b!}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 () in pattern (regression)' {
  local cmd='# Not extended globs
x='\''foo()'\'' 
echo 1 ${x//*\(\)/z}
echo 2 ${x//*\(\)/z}
echo 3 ${x//\(\)/z}
echo 4 ${x//*\(\)/z}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 patsub with single quotes and hyphen in character class (regression)' {
  local cmd='# from Crestwave'\''s bf.bash

program='\''^++--hello.,world<>[]'\''
program=${program//[^'\''><+-.,[]'\'']} 
echo $program'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 patsub with [^]]' {
  local cmd='# This is a PARSING divergence.  In OSH we match [], rather than using POSIX
# rules!

pat='\''[^]]'\''
s='\''ab^cd^'\''
echo ${s//$pat/z}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 [a-z] Invalid range end is syntax error' {
  local cmd='x=fooz
pat='\''[z-a]'\''  # Invalid range.  Other shells don'\''t catch it!
#pat='\''[a-y]'\''
echo ${x//$pat}
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Pattern is empty foobar -- regression for infinite loop' {
  local cmd='x=-foo-

echo ${x//$foo$bar/bar}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Chromium from http://www.oilshell.org/blog/2016/11/07.html' {
  local cmd='case $SH in zsh) exit ;; esac

HOST_PATH=/foo/bar/baz
echo ${HOST_PATH////\\/}

# The way bash parses it
echo ${HOST_PATH//'\''/'\''/\\/}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 {x//~homedir/}' {
  local cmd='path=~/git/oilshell

# ~ expansion occurs
#echo path=$path

echo ${path//~/z}

echo ${path/~/z}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

