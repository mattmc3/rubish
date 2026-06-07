#!/usr/bin/env bats
# Generated from oils-for-unix spec/case_.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Case statement' {
  local cmd='case a in
  a) echo A ;;
  *) echo star ;;
esac

for x in a b; do
  case $x in
    # the pattern is DYNAMIC and evaluated on every iteration
    $x) echo loop ;;
    *) echo star ;;
  esac
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Case statement with ;;&' {
  local cmd='# ;;& keeps testing conditions
# NOTE: ;& and ;;& are bash 4 only, not on Mac
case a in
  a) echo A ;;&
  *) echo star ;;&
  *) echo star2 ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Case statement with ;&' {
  local cmd='# ;& ignores the next condition.  Why would that be useful?

for x in aa bb cc dd zz; do
  case $x in
    aa) echo aa ;&
    bb) echo bb ;&
    cc) echo cc ;;
    dd) echo dd ;;
  esac
  echo --
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Case with empty condition' {
  local cmd='case $empty in
  '\'''\''|foo) echo match ;;
  *) echo no ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Match a literal with a glob character' {
  local cmd='x='\''*.py'\''
case "$x" in
  '\''*.py'\'') echo match ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Match a literal with a glob character with a dynamic pattern' {
  local cmd='x='\''b.py'\''
pat='\''[ab].py'\''
case "$x" in
  $pat) echo match ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Quoted literal in glob pattern' {
  local cmd='x='\''[ab].py'\''
pat='\''[ab].py'\''
case "$x" in
  "$pat") echo match ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Multiple Patterns Match' {
  local cmd='x=foo
result='\''-'\''
case "$x" in
  f*|*o) result="$result X"
esac
echo $result'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Pattern ? matches 1 code point (many bytes), but not multiple code points' {
  local cmd='# These two code points form a single character.
two_code_points="__$(echo $'\''\u0061\u0300'\'')__"

# U+0061 is A, and U+0300 is an accent.  
#
# (Example taken from # https://blog.golang.org/strings)
#
# However ? in bash/zsh only counts CODE POINTS.  They do NOT take into account
# this case.

for s in '\''__a__'\'' '\''__μ__'\'' "$two_code_points"; do
  case $s in
    __?__)
      echo yes
      ;;
    *)
      echo no
  esac
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 matching the byte 0xff against empty string - DISABLED - CI only bug?' {
  local cmd='# This doesn'\''t make a difference on my local machine?
# Is the underlying issue how libc fnmatch() respects Unicode?

#LC_ALL=C
#LC_ALL=C.UTF-8

c=$(printf \\377)

# OSH prints -1 here
#echo "${#c}"

case $c in
  '\'''\'')   echo a ;;
  "$c") echo b ;;
esac

case "$c" in
  '\'''\'')   echo a ;;
  "$c") echo b ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 matching every byte against itself' {
  local cmd='# Why does OSH on the CI machine behave differently?  Probably a libc bug fix
# I'\''d guess?

sum=0

# note: NUL byte crashes OSH!
for i in $(seq 1 255); do
  hex=$(printf '\''%x'\'' "$i")
  c="$(printf "\\x$hex")"  # command sub quirk: \n or \x0a turns into empty string

  #echo -n $c | od -A n -t x1
  #echo ${#c}

  case "$c" in
    # Newline matches empty string somehow.  All shells agree.  I guess
    # fnmatch() ignores trailing newline?
    #'\'''\'')   echo "[empty i=$i hex=$hex c=$c]" ;;
    "$c") sum=$(( sum + 1 )) ;;
    *)   echo "[bug i=$i hex=$hex c=$c]" ;;
  esac
done

echo sum=$sum'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 () in pattern (regression)' {
  local cmd='s='\''foo()'\''

case $s in
  *\(\)) echo '\''match'\''
esac

shopt -s extglob

case $s in
  *(foo|bar)'\''()'\'') echo '\''extglob'\''
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 case n bug regression' {
  local cmd='case
in esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

