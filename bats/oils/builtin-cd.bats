#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-cd.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 cd and PWD' {
  local cmd='cd /
echo $PWD'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 cd BAD/..' {
  local cmd='# Odd divergence in shells: dash and mksh normalize the path and don'\''t check
# this error.
# TODO: I would like OSH to behave like bash and zsh, but separating chdir_arg
# and pwd_arg breaks case 17.

cd nonexistent_ZZ/..
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 cd with 2 or more args - with strict_arg_parse' {
  local cmd='shopt -s strict_arg_parse

mkdir -p foo
cd foo
echo status=$?
cd ..
echo status=$?


cd foo bar
st=$?
if test $st -ne 0; then
  echo '\''failed with multiple args'\''
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 cd with 2 or more args is allowed (strict_arg_parse disabled)' {
  local cmd='mkdir -p foo
cd foo bar'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 cd - without OLDPWD' {
  local cmd='cd - > /dev/null  # silence dash output
echo status=$?
#pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 OLDPWD' {
  local cmd='cd /
cd $TMP
echo "old: $OLDPWD"
env | grep OLDPWD  # It'\''s EXPORTED too!
cd -'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 pwd' {
  local cmd='cd /
pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 pwd after cd ..' {
  local cmd='dir=$TMP/dir-one/dir-two
mkdir -p $dir
cd $dir
echo $(basename $(pwd))
cd ..
echo $(basename $(pwd))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 pwd with symlink and -P' {
  local cmd='tmp=$TMP/builtins-pwd-1
mkdir -p $tmp/target
ln -s -f $tmp/target $tmp/symlink

cd $tmp/symlink

echo pwd:
basename $(pwd)

echo pwd -P:
basename $(pwd -P)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 setting PWD doesn'\''t affect the value of '\''pwd'\'' builtin' {
  local cmd='dir=/tmp/oil-spec-test/pwd
mkdir -p $dir
cd $dir

PWD=foo
echo before $PWD
pwd
echo after $PWD'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 unset PWD; then pwd' {
  local cmd='dir=/tmp/oil-spec-test/pwd
mkdir -p $dir
cd $dir

unset PWD
echo PWD=$PWD
pwd
echo PWD=$PWD'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 '\''unset PWD; pwd'\'' before any cd (tickles a rare corner case)' {
  local cmd='dir=/tmp/oil-spec-test/pwd-2
mkdir -p $dir
cd $dir

# ensure clean shell process state
$SH -c '\''unset PWD; pwd'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 lie about PWD; pwd before any cd' {
  local cmd='dir=/tmp/oil-spec-test/pwd-3
mkdir -p $dir
cd $dir

# ensure clean shell process state
$SH -c '\''PWD=foo; pwd'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 remove pwd dir' {
  local cmd='dir=/tmp/oil-spec-test/pwd
mkdir -p $dir
cd $dir
pwd
rmdir $dir
echo status=$?
pwd
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 pwd in symlinked dir on shell initialization' {
  local cmd='tmp=$TMP/builtins-pwd-2
mkdir -p $tmp
mkdir -p $tmp/target
ln -s -f $tmp/target $tmp/symlink

cd $tmp/symlink
$SH -c '\''basename $(pwd)'\''
unset PWD
$SH -c '\''basename $(pwd)'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Test the current directory after '\''cd ..'\'' involving symlinks' {
  local cmd='dir=$TMP/symlinktest
mkdir -p $dir
cd $dir
mkdir -p a/b/c
mkdir -p a/b/d
ln -s -f a/b/c c > /dev/null
cd c
cd ..
# Expecting a c/ (since we are in symlinktest) but osh gives c d (thinks we are
# in b/)
ls'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 cd with no arguments' {
  local cmd='HOME=$TMP/home
mkdir -p $HOME
cd
test $(pwd) = "$HOME" && echo OK'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 cd to nonexistent dir' {
  local cmd='cd /nonexistent/dir
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 cd away from dir that was deleted' {
  local cmd='dir=$TMP/cd-nonexistent
mkdir -p $dir
cd $dir
rmdir $dir
cd $TMP
echo $(basename $OLDPWD)
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 cd permits double bare dash' {
  local cmd='cd -- /
echo $PWD'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 cd to symlink with -L and -P' {
  local cmd='targ=$TMP/cd-symtarget
lnk=$TMP/cd-symlink
mkdir -p $targ
ln -s $targ $lnk

# -L behavior is the default
cd $lnk
test $PWD = "$TMP/cd-symlink" && echo OK

cd -L $lnk
test $PWD = "$TMP/cd-symlink" && echo OK

cd -P $lnk
test $PWD = "$TMP/cd-symtarget" && echo OK || echo $PWD'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 cd to relative path with -L and -P' {
  local cmd='die() { echo "$@"; exit 1; }

targ=$TMP/cd-symtarget/subdir
lnk=$TMP/cd-symlink
mkdir -p $targ
ln -s $TMP/cd-symtarget $lnk

# -L behavior is the default
cd $lnk/subdir
test $PWD = "$TMP/cd-symlink/subdir" || die "failed"
cd ..
test $PWD = "$TMP/cd-symlink" && echo OK

cd $lnk/subdir
test $PWD = "$TMP/cd-symlink/subdir" || die "failed"
cd -L ..
test $PWD = "$TMP/cd-symlink" && echo OK

cd $lnk/subdir
test $PWD = "$TMP/cd-symlink/subdir" || die "failed"
cd -P ..
test $PWD = "$TMP/cd-symtarget" && echo OK || echo $PWD'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 unset PWD; cd /tmp is allowed (regression)' {
  local cmd='unset PWD; cd /tmp
pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 CDPATH is respected' {
  local cmd='mkdir -p /tmp/spam/foo /tmp/eggs/foo

CDPATH='\''/tmp/spam:/tmp/eggs'\''

cd foo
echo status=$?
pwd'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Change directory in non-shell parent process (make or Python)' {
  local cmd='# inspired by Perl package bug

old_dir=$(pwd)

mkdir -p cpan/Encode/Byte

# Simulate make changing the dir
wrapped_chdir() {
  #set -- $SH -c '\''echo BEFORE; pwd; echo CD; cd Byte; echo AFTER; pwd'\''

  set -- $SH -c '\''cd Byte; pwd'\''
  # strace comes out the same - one getcwd() and one chdir()
  #set -- strace -e '\''getcwd,chdir'\'' "$@"

  python2 -c '\''
from __future__ import print_function
import os, sys, subprocess

argv = sys.argv[1:]
print("Python PWD = %r" % os.getenv("PWD"), file=sys.stderr)
print("Python argv = %r" % argv, file=sys.stderr)

os.chdir("cpan/Encode")
subprocess.check_call(argv)
'\'' "$@"
}

#wrapped_chdir
new_dir=$(wrapped_chdir)

#echo $old_dir

# Make the test insensitive to absolute paths
echo "${new_dir##$old_dir}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 What happens when inherited PWD and current dir disagree?' {
  local cmd='DIR=/tmp/osh-spec-cd
mkdir -p $DIR
cd $DIR

old_dir=$(pwd)

mkdir -p cpan/Encode/Byte

# Simulate make changing the dir
wrapped_chdir() {
  #set -- $SH -c '\''echo BEFORE; pwd; echo CD; cd Byte; echo AFTER; pwd'\''

  # disagreement before we gert here
  set -- $SH -c '\''
echo "PWD = $PWD"; pwd
cd Byte; echo cd=$?
echo "PWD = $PWD"; pwd
'\''

  # strace comes out the same - one getcwd() and one chdir()
  #set -- strace -e '\''getcwd,chdir'\'' "$@"

  python2 -c '\''
from __future__ import print_function
import os, sys, subprocess

argv = sys.argv[1:]
print("Python argv = %r" % argv, file=sys.stderr)

os.chdir("cpan/Encode")
print("Python PWD = %r" % os.getenv("PWD"), file=sys.stdout)
sys.stdout.flush()

subprocess.check_call(argv)
'\'' "$@"
}

#unset PWD
wrapped_chdir'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Survey of getcwd() syscall' {
  local cmd='# This is not that important -- see core/sh_init.py
# Instead of verifying that stat('\''.'\'') == stat(PWD), which is two sycalls,
# OSH just calls getcwd() unconditionally.

# so C++ leak sanitizer  doesn'\''t print to stderr
export ASAN_OPTIONS='\''detect_leaks=0'\''

strace -e getcwd -- $SH -c '\''echo hi; pwd; echo $PWD'\'' 1> /dev/null 2> err.txt

wc -l err.txt
#cat err.txt'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 chdir is a synonym for cd - busybox ash' {
  local cmd='chdir /tmp

if test $? -ne 0; then
  echo fail
  exit
fi

pwd

# It'\''s the same with no args, but mksh fails because of $HOME
#chdir
#echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 arguments to pwd' {
  local cmd='pwd /'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 pwd errors out on args with strict_arg_parse' {
  local cmd='shopt -s strict_arg_parse || true
pwd / >/dev/null || echo '\''too many args!'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

