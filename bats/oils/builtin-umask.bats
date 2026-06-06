#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-umask.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 usage: too many args' {
  local cmd='# most shells don'\''t verify this
umask 1 2
if test $? -ne 0; then
  echo fail
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 usage: empty input, space input' {
  local cmd='umask '\'''\''
case $? in
  1) echo error ;;
  2) echo error ;;
  *) echo status=$? ;;
esac

umask '\'' '\''
case $? in
  1) echo error too ;;
  2) echo error too ;;
  *) echo status=$? ;;
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 symbolic syntax error: b=rwx' {
  local cmd='umask 0124

umask b=rwx
case $? in
  1) echo error ;;
  2) echo error ;;
  *) echo status=$? ;;
esac

umask  # make sure it hasn'\''t changed'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 symbolic syntax error: start with -' {
  local cmd='umask 0124
umask -rwx
if test $? -ne 0; then echo '\''error'\''; fi
umask | tail -c 4

umask 0124
umask -wx
if test $? -ne 0; then echo '\''error'\''; fi
umask | tail -c 4

umask 0124
umask -=+
if test $? -ne 0; then echo '\''error'\''; fi
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 symbolic syntax error: empty clause u-r,,u-r' {
  local cmd='umask 0124
umask '\''u-r,u-r'\''
echo status=$?
umask

# syntax error
umask '\''u+r,,u-r'\''
if test $? -ne 0; then echo '\''error'\''; fi
umask'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 usage: invalid octal digits' {
  local cmd='umask 089
case $? in
  1) echo error ;;
  2) echo error ;;
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 usage: large octal number' {
  local cmd='umask 0022

# osh and other shells treat truncate 0o1234567 as 0o0567
umask 1234567
echo status=$?

umask'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 '\''umask'\'' without args prints the umask' {
  local cmd='umask | tail --bytes 4  # 0022 versus 022
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 '\''umask -S'\'' prints symbolic umask' {
  local cmd='umask -S | grep '\''u=[rwx]*,g=[rwx]*,o=[rwx]*'\'' 
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 '\''umask -p'\'' prints a form that can be eval'\''d' {
  local cmd='umask -p
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 '\''umask 0002'\'' sets the umask' {
  local cmd='umask 0002
echo one > $TMP/umask-one

umask 0022
echo two > $TMP/umask-two

stat -c '\''%a'\'' $TMP/umask-one $TMP/umask-two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 set umask with symbolic mode: g-w,o-w' {
  local cmd='umask 0002  # begin in a known state for the test
# open()s '\''umask-one'\'' with mask 0666, then subtracts 0002 -> 0664
echo one > $TMP/umask-one

umask g-w,o-w
echo two > $TMP/umask-two

stat -c '\''%a'\'' $TMP/umask-one $TMP/umask-two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 set umask with symbolic mode: u-rw  ...  u=,g+,o-  ...' {
  local cmd='umask 0000
umask u-rw
echo status0=$?
umask | tail -c 4

umask 0700
umask u=r
echo status1=$?
umask | tail -c 4

umask 0000
umask u=r,g=w,o=x
echo status2=$?
umask | tail -c 4

umask 0777
umask u+r,g+w,o+x
echo status3=$?
umask | tail -c 4

umask 0000
umask u-r,g-w,o-x
echo status4=$?
umask | tail -c 4

umask 0137
umask u=,g+,o-
echo status5=$?
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 umask with too many arguments (i.e. extra spaces)' {
  local cmd='umask 0111
# spaces are an error in bash
# dash & mksh only interpret the first one
umask u=, g+, o-
if test $? -ne 0; then
  echo ok
fi
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 umask allow overwriting and duplicates' {
  local cmd='umask 0111
umask u=rwx,u=rw,u=r,u=,g=rwx
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 umask a is valid who' {
  local cmd='umask 0732
umask a=rwx
umask | tail -c 4

umask 0124
umask a+r
umask | tail -c 4

umask 0124
umask a-r
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 umask X perm' {
  local cmd='umask 0124
umask a=X
echo ret0 = $?
umask | tail -c 4

umask 0246
umask a=X
echo ret1 = $?
umask | tail -c 4

umask 0246
umask a-X
echo ret2 = $?
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 umask s perm' {
  local cmd='umask 0124
umask a-s
echo ret0 = $?
umask | tail -c 4

umask 0124
umask a+s
echo ret1 = $?
umask | tail -c 4

umask 0124
umask a=s
echo ret2 = $?
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 umask t perm' {
  local cmd='umask 0124
umask a-t
echo ret0 = $?
umask | tail -c 4

umask 0124
umask a+t
echo ret1 = $?
umask | tail -c 4

umask 0124
umask a=t
echo ret2 = $?
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 umask default who' {
  local cmd='umask 0124
umask =
umask | tail -c 4

umask 0124
umask =rx
echo ret = $?
umask | tail -c 4

umask 0124
umask +
umask | tail -c 4

umask 0124
# zsh ALSO treats this as just `umask`
umask - >/dev/null
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 umask bare op' {
  local cmd='umask 0124
umask =+=
umask | tail -c 4

umask 0124
umask +=
umask | tail -c 4

umask 0124
umask =+rwx+rx
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 umask permcopy' {
  local cmd='umask 0124 
umask a=u
umask | tail -c 4

umask 0365
umask a=g
umask | tail -c 4

umask 0124
umask a=o
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 umask permcopy running value' {
  local cmd='umask 0124
umask a=,a=u
umask | tail -c 4

umask 0124
umask a=
umask a=u
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 umask sequential actions' {
  local cmd='umask 0124
umask u+r+w+x
umask | tail -c 4

umask 0124
umask a+r+w+x,o-w
umask | tail -c 4

umask 0124
umask a+x+wr-r
umask | tail -c 4'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

