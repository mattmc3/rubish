#!/usr/bin/env bats
# Generated from oils-for-unix spec/vars-special.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 PWD is set' {
  local cmd='# Just test that it has a slash for now.
echo $PWD | grep -q /
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 PWD is not only set, but exported' {
  local cmd='env | grep -q PWD
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 PATH is set if unset at startup' {
  local cmd='# WORKAROUND for Python version of bin/osh -- we can'\''t run bin/oils_for_unix.py
# because it a shebang #!/usr/bin/env python2
# This test is still useful for the C++ oils-for-unix.

case $SH in
  */bin/osh)
    echo yes
    echo yes
    exit
    ;;
esac

# Get absolute path before changing PATH
sh=$(which $SH)

old_path=$PATH
unset PATH

$sh -c '\''echo $PATH'\'' > path.txt

PATH=$old_path

# looks like PATH=/usr/bin:/bin for mksh, but more complicated for others
# cat path.txt

# should contain /usr/bin
if egrep -q '\''(^|:)/usr/bin($|:)'\'' path.txt; then
  echo yes
fi

# should contain /bin
if egrep -q '\''(^|:)/bin($|:)'\'' path.txt ; then
  echo yes
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 HOME is NOT set' {
  local cmd='case $SH in *zsh) echo '\''zsh sets HOME'\''; exit ;; esac

home=$(echo $HOME)
test "$home" = ""
echo status=$?

env | grep HOME
echo status=$?

# not in interactive shell either
$SH -i -c '\''echo $HOME'\'' | grep /
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Vars set interactively only: HISTFILE' {
  local cmd='case $SH in dash|mksh|zsh) exit ;; esac

$SH --norc --rcfile /dev/null -c '\''echo histfile=${HISTFILE:+yes}'\''
$SH --norc --rcfile /dev/null -i -c '\''echo histfile=${HISTFILE:+yes}'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Some vars are set, even without startup file, or env: PATH, PWD' {
  local cmd='flags='\'''\''
case $SH in
  dash) exit ;;
  bash*)
    flags='\''--noprofile --norc --rcfile /devnull'\''
    ;;
  osh)
    flags='\''--rcfile /devnull'\''
    ;;
esac

sh_path=$(which $SH)

case $sh_path in
  */bin/osh)
    # Hack for running with Python2
    export PYTHONPATH="$REPO_ROOT:$REPO_ROOT/vendor"
    sh_prefix="$(which python2) $REPO_ROOT/bin/oils_for_unix.py osh"
    ;;
  *)
    sh_prefix=$sh_path
    ;;
esac

#echo PATH=$PATH


# mksh has typeset, not declare
# bash exports PWD, but not PATH PS4

/usr/bin/env -i PYTHONPATH=$PYTHONPATH $sh_prefix $flags -c '\''typeset -p PATH PWD PS4'\'' >&2
echo path pwd ps4 $?

/usr/bin/env -i PYTHONPATH=$PYTHONPATH $sh_prefix $flags -c '\''typeset -p SHELLOPTS'\'' >&2
echo shellopts $?

# bash doesn'\''t set HOME, mksh and zsh do
/usr/bin/env -i PYTHONPATH=$PYTHONPATH $sh_prefix $flags -c '\''typeset -p HOME PS1'\'' >&2
echo home ps1 $?

# IFS is set, but not exported
/usr/bin/env -i PYTHONPATH=$PYTHONPATH $sh_prefix $flags -c '\''typeset -p IFS'\'' >&2
echo ifs $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 UID EUID PPID can'\''t be changed' {
  local cmd='# bash makes these 3 read-only
{
  UID=xx $SH -c '\''echo uid=$UID'\''

  EUID=xx $SH -c '\''echo euid=$EUID'\''

  PPID=xx $SH -c '\''echo ppid=$PPID'\''

} > out.txt

# bash shows that vars are readonly
# zsh shows other errors
# cat out.txt
#echo

grep '\''=xx'\'' out.txt
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 HOSTNAME OSTYPE can be changed' {
  local cmd='case $SH in zsh) exit ;; esac

#$SH -c '\''echo hostname=$HOSTNAME'\''

HOSTNAME=x $SH -c '\''echo hostname=$HOSTNAME'\''
OSTYPE=x $SH -c '\''echo ostype=$OSTYPE'\''
echo

#PS4=x $SH -c '\''echo ps4=$PS4'\''

# OPTIND is special
#OPTIND=xx $SH -c '\''echo optind=$OPTIND'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 1 .. 9 are scoped, while 0 is not' {
  local cmd='fun() {
  case $0 in
    *sh)
      echo '\''sh'\''
      ;;
    *sh-*)  # bash-4.4 is OK
      echo '\''sh'\''
      ;;
  esac

  echo $1 $2
}
fun a b'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 ?' {
  local cmd='echo $?  # starts out as 0
sh -c '\''exit 33'\''
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 #' {
  local cmd='set -- 1 2 3 4
echo $#'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012  looks like a PID' {
  local cmd='echo $$ | egrep -q '\''[0-9]+'\''  # Test that it has decimal digits
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013  doesn'\''t change with subshell or command sub' {
  local cmd='# Just test that it has decimal digits
set -o errexit
die() {
  echo 1>&2 "$@"; exit 1
}
parent=$$
test -n "$parent" || die "empty PID in parent"
( child=$$
  test -n "$child" || die "empty PID in subshell"
  test "$parent" = "$child" || die "should be equal: $parent != $child"
  echo '\''subshell OK'\''
)
echo $( child=$$
        test -n "$child" || die "empty PID in command sub"
        test "$parent" = "$child" || die "should be equal: $parent != $child"
        echo '\''command sub OK'\''
      )
exit 3  # make sure we got here'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 BASHPID DOES change with subshell and command sub' {
  local cmd='set -o errexit
die() {
  echo 1>&2 "$@"; exit 1
}
parent=$BASHPID
test -n "$parent" || die "empty BASHPID in parent"
( child=$BASHPID
  test -n "$child" || die "empty BASHPID in subshell"
  test "$parent" != "$child" || die "should not be equal: $parent = $child"
  echo '\''subshell OK'\''
)
echo $( child=$BASHPID
        test -n "$child" || die "empty BASHPID in command sub"
        test "$parent" != "$child" ||
          die "should not be equal: $parent = $child"
        echo '\''command sub OK'\''
      )
exit 3  # make sure we got here

# mksh also implements BASHPID!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Background PID ! looks like a PID' {
  local cmd='sleep 0.01 &
pid=$!
wait
echo $pid | egrep '\''[0-9]+'\'' >/dev/null
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 PPID' {
  local cmd='echo $PPID | egrep '\''[0-9]+'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 PIPESTATUS' {
  local cmd='echo hi | sh -c '\''cat; exit 33'\'' | wc -l >/dev/null
argv.py "${PIPESTATUS[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 RANDOM' {
  local cmd='expr $0 : '\''.*/osh$'\'' && exit 99  # Disabled because of spec-runner.sh issue
echo $RANDOM | egrep '\''[0-9]+'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 UID and EUID' {
  local cmd='# These are both bash-specific.
set -o errexit
echo $UID | egrep -o '\''[0-9]+'\'' >/dev/null
echo $EUID | egrep -o '\''[0-9]+'\'' >/dev/null
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 OSTYPE is non-empty' {
  local cmd='test -n "$OSTYPE"
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 HOSTNAME' {
  local cmd='test "$HOSTNAME" = "$(hostname)"
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 LINENO is the current line, not line of function call' {
  local cmd='echo $LINENO  # first line
g() {
  argv.py $LINENO  # line 3
}
f() {
  argv.py $LINENO  # line 6
  g
  argv.py $LINENO  # line 8
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 LINENO in bare redirect arg (bug regression)' {
  local cmd='filename=$TMP/bare3
rm -f $filename
> $TMP/bare$LINENO
test -f $filename && echo written
echo $LINENO'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 LINENO in redirect arg (bug regression)' {
  local cmd='filename=$TMP/lineno_regression3
rm -f $filename
echo x > $TMP/lineno_regression$LINENO
test -f $filename && echo written
echo $LINENO'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 LINENO in [[' {
  local cmd='echo one
[[ $LINENO -eq 2 ]] && echo OK'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 LINENO in ((' {
  local cmd='echo one
(( x = LINENO ))
echo $x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 LINENO in for loop' {
  local cmd='# hm bash doesn'\''t take into account the word break.  That'\''s OK; we won'\''t either.
echo one
for x in \
  $LINENO zzz; do
  echo $x
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 LINENO in other for loops' {
  local cmd='set -- a b c
for x; do
  echo $LINENO $x
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 LINENO in for (( loop' {
  local cmd='# This is a real edge case that I'\''m not sure we care about.  We would have to
# change the span ID inside the loop to make it really correct.
echo one
for (( i = 0; i < $LINENO; i++ )); do
  echo $i
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 LINENO for assignment' {
  local cmd='a1=$LINENO a2=$LINENO
b1=$LINENO b2=$LINENO
echo $a1 $a2
echo $b1 $b2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 LINENO in case' {
  local cmd='case $LINENO in
  1) echo '\''got line 1'\'' ;;
  *) echo line=$LINENO
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 _ with simple command and evaluation' {
  local cmd='name=world
echo "hi $name"
echo "$_"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 _ and {_}' {
  local cmd='case $SH in dash|mksh) exit ;; esac

_var=value

: 42
echo $_ $_var ${_}var

: '\''foo'\''"bar"
echo $_'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 _ with word splitting' {
  local cmd='case $SH in dash|mksh) exit ;; esac

setopt shwordsplit  # for ZSH

x='\''with spaces'\''
: $x
echo $_'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 _ with pipeline and subshell' {
  local cmd='case $SH in dash|mksh) exit ;; esac

shopt -s lastpipe

seq 3 | echo last=$_

echo pipeline=$_

( echo subshell=$_ )
echo done=$_'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 _ with && and ||' {
  local cmd='case $SH in dash|mksh) exit ;; esac

echo hi && echo last=$_
echo and=$_

echo hi || echo last=$_
echo or=$_'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 _ is not reset with (( and [[' {
  local cmd='# bash is inconsistent because it does it for pipelines and assignments, but
# not (( and [[

case $SH in dash|mksh) exit ;; esac

echo simple
(( a = 2 + 3 ))
echo "(( $_"

[[ a == *.py ]]
echo "[[ $_"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 _ with assignments, arrays, etc.' {
  local cmd='case $SH in dash|mksh) exit ;; esac

: foo
echo "colon [$_]"

s=bar
echo "bare assign [$_]"

# zsh uses declare; bash uses s=bar
declare s=bar
echo "declare [$_]"

# zsh remains s:declare, bash resets it
a=(1 2)
echo "array [$_]"

# zsh sets it to declare, bash uses the LHS a
declare a=(1 2)
echo "declare array [$_]"

declare -g d=(1 2)
echo "declare flag [$_]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 _ with loop' {
  local cmd='case $SH in dash|mksh) exit ;; esac

# zsh resets it when in a loop

echo init
echo begin=$_
for x in 1 2 3; do
  echo prev=$_
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 _ is not undefined on first use' {
  local cmd='set -e

x=$($SH -u -c '\''echo prev=$_'\'')
echo status=$?

# bash and mksh set $_ to $0 at first; zsh is empty
#echo "$x"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '041 BASH_VERSION / OILS_VERSION' {
  local cmd='case $SH in
  bash*)
    # BASH_VERSION=zz

    echo $BASH_VERSION | egrep -o '\''4\.4\.0'\'' > /dev/null
    echo matched=$?
    ;;
  *osh)
    # note: version string is mutable like in bash.  I guess that'\''s useful for
    # testing?  We might want a strict mode to eliminate that?

    echo $OILS_VERSION | egrep -o '\''[0-9]+\.[0-9]+\.'\'' > /dev/null
    echo matched=$?
    ;;
  *)
    echo '\''no version'\''
    ;;
esac'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '042 SECONDS' {
  local cmd='# most likely 0 seconds, but in CI I'\''ve seen 1 second
echo $SECONDS | awk '\''/[0-9]+/ { print "ok" }'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

