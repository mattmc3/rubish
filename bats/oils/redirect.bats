#!/usr/bin/env bats
# Generated from oils-for-unix spec/redirect.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 >& and <& are the same' {
  local cmd='echo one 1>&2

echo two 1<&2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 <&' {
  local cmd='# Is there a simpler test case for this?
echo foo51 > $TMP/lessamp.txt

exec 6< $TMP/lessamp.txt
read line <&6

echo "[$line]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 2>&1 with no command' {
  local cmd='( exit 42 )  # status is reset after this
echo status=$?
2>&1
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 2&>1 (is it a redirect or is it like a&>1)' {
  local cmd='2&>1
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Nonexistent file' {
  local cmd='cat <$TMP/nonexistent.txt
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Descriptor redirect with spaces' {
  local cmd='# Hm this seems like a failure of lookahead!  The second thing should look to a
# file-like thing.
# I think this is a posix issue.
# tag: posix-issue
echo one 1>&2
echo two 1 >&2
echo three 1>& 2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Filename redirect with spaces' {
  local cmd='# This time 1 *is* a descriptor, not a word.  If you add a space between 1 and
# >, it doesn'\''t work.
echo two 1> $TMP/file-redir1.txt
cat $TMP/file-redir1.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Quoted filename redirect with spaces' {
  local cmd='# POSIX makes node of this
echo two \1 > $TMP/file-redir2.txt
cat $TMP/file-redir2.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Descriptor redirect with filename' {
  local cmd='# bash/mksh treat this like a filename, not a descriptor.
# dash aborts.
echo one 1>&$TMP/nonexistent-filename__
echo "status=$?"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Redirect echo to stderr, and then redirect all of stdout somewhere.' {
  local cmd='{ echo foo52 1>&2; echo 012345789; } > $TMP/block-stdout.txt
cat $TMP/block-stdout.txt |  wc -c '
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Named file descriptor' {
  local cmd='exec {myfd}> $TMP/named-fd.txt
echo named-fd-contents >& $myfd
cat $TMP/named-fd.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Double digit fd (20> file)' {
  local cmd='exec 20> "$TMP/double-digit-fd.txt"
echo hello20 >&20
cat "$TMP/double-digit-fd.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 : 9> fdleak (OSH regression)' {
  local cmd='true 9> "$TMP/fd.txt"
( echo world >&9 )
cat "$TMP/fd.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 : 3>&3 (OSH regression)' {
  local cmd='# mksh started being flaky on the continuous build and during release.  We
# don'\''t care!  Related to issue #330.
case $SH in mksh) exit ;; esac

: 3>&3
echo hello'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 : 3>&3-' {
  local cmd=': 3>&3-
echo hello'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 3>&- << EOF (OSH regression: fail to restore fds)' {
  local cmd='exec 3> "$TMP/fd.txt"
echo hello 3>&- << EOF
EOF
echo world >&3
exec 3>&-  # close
cat "$TMP/fd.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 Open file on descriptor 3 and write to it many times' {
  local cmd='# different than case below because 3 is the likely first FD of open()

exec 3> "$TMP/fd3.txt"
echo hello >&3
echo world >&3
exec 3>&-  # close
cat "$TMP/fd3.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 Open file on descriptor 4 and write to it many times' {
  local cmd='# different than the case above because because 4 isn'\''t the likely first FD

exec 4> "$TMP/fd4.txt"
echo hello >&4
echo world >&4
exec 4>&-  # close
cat "$TMP/fd4.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 Redirect to empty string' {
  local cmd='f='\'''\''
echo s > "$f"
echo "result=$?"
set -o errexit
echo s > "$f"
echo DONE'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Redirect to file descriptor that'\''s not open' {
  local cmd='# Notes:
# - 7/2021: descriptor 7 seems to work on all CI systems.  The process state
#   isn'\''t clean, but we could probably close it in OSH?
# - dash doesn'\''t allow file descriptors greater than 9.  (This is a good
#   thing, because the bash chapter in AOSA book mentions that juggling user
#   vs.  system file descriptors is a huge pain.)
# - But somehow running in parallel under spec-runner.sh changes whether
#   descriptor 3 is open.  e.g. '\''echo hi 1>&3'\''.  Possibly because of
#   /usr/bin/time.  The _tmp/spec/*.task.txt file gets corrupted!
# - Oh this is because I use time --output-file.  That opens descriptor 3.  And
#   then time forks the shell script.  The file descriptor table is inherited.
#   - You actually have to set the file descriptor to something.  What do
#   configure and debootstrap too?

opened=$(ls /proc/$$/fd)
if echo "$opened" | egrep '\''^7$'\''; then
  echo "FD 7 shouldn'\''t be open"
  echo "OPENED:"
  echo "$opened"
fi

echo hi 1>&7'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Open descriptor with exec' {
  local cmd='# What is the point of this?  ./configure scripts and debootstrap use it.
exec 3>&1
echo hi 1>&3'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 Open multiple descriptors with exec' {
  local cmd='# What is the point of this?  ./configure scripts and debootstrap use it.
exec 3>&1
exec 4>&1
echo three 1>&3
echo four 1>&4'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 >| to clobber' {
  local cmd='echo XX >| $TMP/c.txt

set -o noclobber

echo YY >  $TMP/c.txt  # not clobber
echo status=$?

cat $TMP/c.txt
echo ZZ >| $TMP/c.txt

cat $TMP/c.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 &> redirects stdout and stderr' {
  local cmd='tmp="$(basename $SH)-$$.txt"  # unique name for shell and test case
#echo $tmp

stdout_stderr.py &> $tmp

# order is indeterminate
grep STDOUT $tmp
grep STDERR $tmp'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 >&word redirects stdout and stderr when word is not a number or -' {
  local cmd='# dash, mksh don'\''t implement this bash behaviour.
case $SH in dash|mksh) exit 1 ;; esac

tmp="$(basename $SH)-$$.txt"  # unique name for shell and test case

stdout_stderr.py >&$tmp

# order is indeterminate
grep STDOUT $tmp
grep STDERR $tmp'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 1>&- to close file descriptor' {
  local cmd='exec 5> "$TMP/f.txt"
echo hello >&5
exec 5>&-
echo world >&5
cat "$TMP/f.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 1>&2- to move file descriptor' {
  local cmd='exec 5> "$TMP/f.txt"
echo hello5 >&5
exec 6>&5-
echo world5 >&5
echo world6 >&6
exec 6>&-
cat "$TMP/f.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 1>&2- (Bash bug: fail to restore closed fd)' {
  local cmd='# 7/2021: descriptor 8 is open on Github Actions, so use descriptor 6 instead

# Fix for CI systems where process state isn'\''t clean: Close descriptors 6 and 7.
exec 6>&- 7>&-

opened=$(ls /proc/$$/fd)
if echo "$opened" | egrep '\''^7$'\''; then
  echo "FD 7 shouldn'\''t be open"
  echo "OPENED:"
  echo "$opened"
fi
if echo "$opened" | egrep '\''^6$'\''; then
  echo "FD 6 shouldn'\''t be open"
  echo "OPENED:"
  echo "$opened"
fi

exec 7> "$TMP/f.txt"
: 6>&7 7>&-
echo hello >&7
: 6>&7-
echo world >&7
exec 7>&-
cat "$TMP/f.txt"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 <> for read/write' {
  local cmd='echo first >$TMP/rw.txt
exec 8<>$TMP/rw.txt
read line <&8
echo line=$line
echo second 1>&8
echo CONTENTS
cat $TMP/rw.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 <> for read/write named pipes' {
  local cmd='rm -f "$TMP/f.pipe"
mkfifo "$TMP/f.pipe"
exec 8<> "$TMP/f.pipe"
echo first >&8
echo second >&8
read line1 <&8
read line2 <&8
exec 8<&-
echo line1=$line1 line2=$line2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 &>> appends stdout and stderr' {
  local cmd='# Fix for flaky tests: dash behaves non-deterministically under load!  It
# doesn'\''t implement the behavior anyway so I don'\''t care why.
case $SH in
  *dash)
    exit 1
    ;;
esac

echo "ok" > $TMP/f.txt
stdout_stderr.py &>> $TMP/f.txt
grep ok $TMP/f.txt >/dev/null && echo '\''ok'\''
grep STDOUT $TMP/f.txt >/dev/null && echo '\''ok'\''
grep STDERR $TMP/f.txt >/dev/null && echo '\''ok'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 exec redirect then various builtins' {
  local cmd='exec 5>$TMP/log.txt
echo hi >&5
set -o >&5
echo done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 can'\''t mention big file descriptor' {
  local cmd='echo hi 9>&1
# trivia: 23 is the max descriptor for mksh
#echo hi 24>&1
echo hi 99>&1
echo hi 100>&1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 : >/dev/null 2> / (OSH regression: fail to pop fd frame)' {
  local cmd='# oil 0.8.pre4 fails to restore fds after redirection failure. In the
# following case, the fd frame remains after the redirection failure
# "2> /" so that the effect of redirection ">/dev/null" remains after
# the completion of the command.
: >/dev/null 2> /
echo hello'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 echo foo >&100 (OSH regression: does not fail with invalid fd 100)' {
  local cmd='# oil 0.8.pre4 does not fail with non-existent fd 100.
fd=100
echo foo53 >&$fd'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 echo foo >&N where N is first unused fd' {
  local cmd='# 1. prepare default fd for internal uses
minfd=10
case ${SH##*/} in
(mksh) minfd=24 ;;
(osh) minfd=100 ;;
esac

# 2. prepare first unused fd
fd=$minfd
is_fd_open() { : >&$1; }
while is_fd_open "$fd"; do
  : $((fd+=1))

  # OLD: prevent infinite loop for broken oils-for-unix
  #if test $fd -gt 1000; then
  #  break
  #fi
done

# 3. test
echo foo54 >&$fd'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 exec {fd}>&- (OSH regression: fails to close fd)' {
  local cmd='# mksh, dash do not implement {fd} redirections.
case $SH in mksh|dash) exit 1 ;; esac
# oil 0.8.pre4 fails to close fd by {fd}&-.
exec {fd}>file1
echo foo55 >&$fd
exec {fd}>&-
echo bar >&$fd
cat file1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 noclobber can still write to non-regular files like /dev/null' {
  local cmd='set -C  # noclobber
set -e  # errexit (raise any redirection errors)

# Each redirect to /dev/null should succeed
echo a  >  /dev/null  # trunc, write stdout
echo a &>  /dev/null  # trunc, write stdout and stderr
echo a  >> /dev/null  # append, write stdout
echo a &>> /dev/null  # append, write stdout and stderr
echo a  >| /dev/null  # ignore noclobber, trunc, write stdout'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 Parsing of x=1> and related cases' {
  local cmd='echo x=1>/dev/stdout
echo x=1 >/dev/stdout
echo x= 1>/dev/stdout

echo +1>/dev/stdout
echo +1 >/dev/stdout
echo + 1>/dev/stdout

echo a1>/dev/stdout'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 Parsing of x={myvar} and related cases' {
  local cmd='case $SH in dash) exit ;; esac

echo {myvar}>/dev/stdout
# Bash chooses fds starting with 10 here, osh with 100, and there can already
# be some open fds, so compare further fds against this one
starting_fd=$myvar

echo x={myvar}>/dev/stdout
echo $((myvar-starting_fd))
echo x={myvar} >/dev/stdout
echo $((myvar-starting_fd))
echo x= {myvar}>/dev/stdout
echo $((myvar-starting_fd))

echo +{myvar}>/dev/stdout
echo $((myvar-starting_fd))
echo +{myvar} >/dev/stdout
echo $((myvar-starting_fd))
echo + {myvar}>/dev/stdout
echo $((myvar-starting_fd))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '041 xtrace not affected by redirects' {
  local cmd='set -x
printf '\''aaaa'\'' > /dev/null 2> test_osh
set +x
cat test_osh'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

