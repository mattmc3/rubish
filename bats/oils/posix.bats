#!/usr/bin/env bats
# Generated from oils-for-unix spec/posix.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Empty for loop is allowed' {
  local cmd='set -- a b
for x in; do
  echo hi
  echo $x
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Empty for loop without in.  Do can be on the same line I guess.' {
  local cmd='set -- a b
for x do
  echo hi
  echo $x
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Empty case statement' {
  local cmd='case foo in
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Last case without ;;' {
  local cmd='foo=a
case $foo in
  a) echo A ;;
  b) echo B  
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Only case without ;;' {
  local cmd='foo=a
case $foo in
  a) echo A
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Case with optional (' {
  local cmd='foo=a
case $foo in
  (a) echo A ;;
  (b) echo B  
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Empty action for case is syntax error' {
  local cmd='# POSIX grammar seems to allow this, but bash and dash don'\''t.  Need ;;
foo=a
case $foo in
  a)
  b)
    echo A ;;
  d)
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Empty action is allowed for last case' {
  local cmd='foo=b
case $foo in
  a) echo A ;;
  b)
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Case with | pattern' {
  local cmd='foo=a
case $foo in
  a|b) echo A ;;
  c)
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Bare semi-colon not allowed' {
  local cmd='# This is disallowed by the grammar; bash and dash don'\''t accept it.
;'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Command substitution in default' {
  local cmd='echo ${x:-$(ls -d /bin)}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Arithmetic expansion' {
  local cmd='x=3
while [ $x -gt 0 ]
do
  echo $x
  x=$(($x-1))
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Newlines in compound lists' {
  local cmd='x=3
while
  # a couple of <newline>s

  # a list
  date && ls -d /bin || echo failed; cat tests/hello.txt
  # a couple of <newline>s

  # another list
  wc tests/hello.txt > _tmp/posix-compound.txt & true

do
  # 2 lists
  ls -d /bin
  cat tests/hello.txt
  x=$(($x-1))
  [ $x -eq 0 ] && break
done
# Not testing anything but the status since output is complicated'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Multiple here docs on one line' {
  local cmd='cat <<EOF1; cat <<EOF2
one
EOF1
two
EOF2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 cat here doc; echo; cat here doc' {
  local cmd='cat <<EOF1; echo two; cat <<EOF2
one
EOF1
three
EOF2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

