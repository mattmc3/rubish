#!/usr/bin/env bats
# Generated from oils-for-unix spec/tilde.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 ~ expansion in assignment' {
  local cmd='HOME=/home/bob
a=~/src
echo $a'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 ~ expansion in readonly assignment' {
  local cmd='# dash fails here!
# http://stackoverflow.com/questions/8441473/tilde-expansion-doesnt-work-when-i-logged-into-gui
HOME=/home/bob
readonly const=~/src
echo $const'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 No ~ expansion in dynamic assignment' {
  local cmd='HOME=/home/bob
binding='\''const=~/src'\''
readonly "$binding"
echo $const'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 No tilde expansion in word that looks like assignment but isn'\''t' {
  local cmd='# bash and mksh mistakenly expand here!
# bash fixes this in POSIX mode (gah).
# http://lists.gnu.org/archive/html/bug-bash/2016-06/msg00001.html
HOME=/home/bob
echo x=~'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 tilde expansion of word after redirect' {
  local cmd='HOME=$TMP
echo hi > ~/tilde1.txt
cat $HOME/tilde1.txt | wc -c'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 other user' {
  local cmd='echo ~nonexistent'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 {undef:-~}' {
  local cmd='HOME=/home/bar
echo ${undef:-~}
echo ${HOME:+~/z}
echo "${undef:-~}"
echo ${undef:-"~"}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 {x//~/~root}' {
  local cmd='HOME=/home/bar
x=~
echo ${x//~/~root}

# gah there is some expansion, what the hell
echo ${HOME//~/~root}

x=[$HOME]
echo ${x//~/~root}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 x=foo:~ has tilde expansion' {
  local cmd='HOME=/home/bar
x=foo:~
echo $x
echo "$x"  # quotes don'\''t matter, the expansion happens on assignment?
x='\''foo:~'\''
echo $x

x=foo:~,  # comma ruins it, must be /
echo $x

x=~:foo
echo $x

# no tilde expansion here
echo foo:~'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 a[x]=foo:~ has tilde expansion' {
  local cmd='case $SH in dash|zsh) exit ;; esac

HOME=/home/bar
declare -a a
a[0]=foo:~
echo ${a[0]}

declare -A A
A['\''x'\'']=foo:~
echo ${A['\''x'\'']}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 tilde expansion an assignment keyword' {
  local cmd='HOME=/home/bar
f() {
  local x=foo:~
  echo $x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 x={undef-~:~}' {
  local cmd='HOME=/home/bar

x=~:${undef-~:~}
echo $x

# Most shells agree on a different behavior, but with the OSH parsing model,
# it'\''s easier to agree with yash.  bash disagrees in a different way'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 strict tilde' {
  local cmd='echo ~nonexistent

shopt -s strict_tilde
echo ~nonexistent

echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 temp assignment x=~ env' {
  local cmd='HOME=/home/bar

xx=~ env | grep xx=

# Does it respect the colon rule too?
xx=~root:~:~ env | grep xx='
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

