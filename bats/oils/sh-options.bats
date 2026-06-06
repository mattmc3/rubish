#!/usr/bin/env bats
# Generated from oils-for-unix spec/sh-options.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 - with -c' {
  local cmd='# dash'\''s behavior seems most sensible here?
$SH -o nounset -c '\''echo $-'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 - with pipefail' {
  local cmd='set -o pipefail -o nounset
echo $-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 - and more options' {
  local cmd='set -efuC
o=$-
[[ $o == *e* ]]; echo yes
[[ $o == *f* ]]; echo yes
[[ $o == *u* ]]; echo yes
[[ $o == *C* ]]; echo yes'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 - with interactive shell' {
  local cmd='$SH -c '\''echo $-'\'' | grep i || echo FALSE
$SH -i -c '\''echo $-'\'' | grep -q i && echo TRUE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 pass short options like sh -e' {
  local cmd='$SH -e -c '\''false; echo status=$?'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 pass long options like sh -o errexit' {
  local cmd='$SH -o errexit -c '\''false; echo status=$?'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 pass shopt options like sh -O nullglob' {
  local cmd='$SH +O nullglob -c '\''echo foo *.nonexistent bar'\''
$SH -O nullglob -c '\''echo foo *.nonexistent bar'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 set -o vi/emacs' {
  local cmd='set -o vi
echo $?
set -o emacs
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 vi and emacs are mutually exclusive' {
  local cmd='show() {
  shopt -o -p | egrep '\''emacs$|vi$'\''
  echo ___
};
show

set -o emacs
show

set -o vi
show'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 interactive shell starts with emacs mode on' {
  local cmd='case $SH in dash) exit ;; esac
case $SH in bash|*osh) flag='\''--rcfile /dev/null'\'' ;; esac

code='\''test -o emacs; echo $?; test -o vi; echo $?'\''

echo non-interactive
$SH $flag -c "$code"

echo interactive
$SH $flag -i -c "$code"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 nounset' {
  local cmd='echo "[$unset]"
set -o nounset
echo "[$unset]"
echo end  # never reached'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 -u is nounset' {
  local cmd='echo "[$unset]"
set -u
echo "[$unset]"
echo end  # never reached'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 -n for no execution (useful with --ast-output)' {
  local cmd='# NOTE: set +n doesn'\''t work because nothing is executed!
echo 1
set -n
echo 2
set +n
echo 3
# osh doesn'\''t work because it only checks -n in bin/oil.py?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 pipefail' {
  local cmd='# NOTE: the sleeps are because osh can fail non-deterministically because of a
# bug.  Same problem as PIPESTATUS.
{ sleep 0.01; exit 9; } | { sleep 0.02; exit 2; } | { sleep 0.03; }
echo $?
set -o pipefail
{ sleep 0.01; exit 9; } | { sleep 0.02; exit 2; } | { sleep 0.03; }
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 shopt -p -o prints '\''set'\'' options' {
  local cmd='case $SH in dash|mksh) exit ;; esac

shopt -po nounset
set -o nounset
shopt -po nounset

echo --

shopt -po | egrep -o '\''errexit|noglob|nounset'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 shopt -o prints '\''set'\'' options' {
  local cmd='case $SH in dash|mksh) exit ;; esac

shopt -o | egrep -o '\''errexit|noglob|nounset'\''
echo --'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 shopt -p prints '\''shopt'\'' options' {
  local cmd='shopt -p nullglob
shopt -s nullglob
shopt -p nullglob'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 shopt with no flags prints options' {
  local cmd='cd $TMP

# print specific options.  OSH does it in a different format.
shopt nullglob failglob > one.txt
wc -l one.txt
grep -o nullglob one.txt
grep -o failglob one.txt

# print all options
shopt | grep nullglob | wc -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 noclobber off' {
  local cmd='set -o errexit

echo foo > can-clobber
echo status=$?
set +C

echo foo > can-clobber
echo status=$?
set +o noclobber

echo foo > can-clobber
echo status=$?
cat can-clobber'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 noclobber on' {
  local cmd='rm -f no-clobber
set -C

echo foo > no-clobber
echo create=$?

echo overwrite > no-clobber
echo overwrite=$?

echo force >| no-clobber
echo force=$?

cat no-clobber'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 noclobber on <>' {
  local cmd='set -C
echo foo >| $TMP/no-clobber
exec 3<> $TMP/no-clobber
read -n 1 <&3
echo -n . >&3
exec 3>&-
cat $TMP/no-clobber'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 noclobber on >>' {
  local cmd='rm -f $TMP/no-clobber

set -C
echo foo >> $TMP/no-clobber
echo status=$?

cat $TMP/no-clobber'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 noclobber on &> >' {
  local cmd='case $SH in dash) exit ;; esac

set -C

rm -f $TMP/no-clobber
echo foo > $TMP/no-clobber
echo stdout=$?
echo bar > $TMP/no-clobber
echo again=$?
cat $TMP/no-clobber

rm -f $TMP/no-clobber
echo baz &> $TMP/no-clobber
echo both=$?
echo foo &> $TMP/no-clobber
echo again=$?
cat $TMP/no-clobber'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 noclobber on &>> >>' {
  local cmd='case $SH in dash) echo '\''flaky'\''; exit ;; esac

set -C

rm -f $TMP/no-clobber
echo foo >> $TMP/no-clobber
echo stdout=$?
echo bar >> $TMP/no-clobber
echo again=$?
cat $TMP/no-clobber

rm -f $TMP/no-clobber
echo baz &>> $TMP/no-clobber
echo both=$?
echo foo &>> $TMP/no-clobber
echo again=$?
cat $TMP/no-clobber'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 set without args lists variables' {
  local cmd='__GLOBAL=g
f() {
  local __mylocal=L
  local __OTHERLOCAL=L
  __GLOBAL=mutated
  set | grep '\''^__'\''
}
g() {
  local __var_in_parent_scope=D
  f
}
g'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 set without args and array variables' {
  local cmd='declare -a __array
__array=(1 2 '\''3 4'\'')
set | grep '\''^__'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 set without args and assoc array variables (not in OSH)' {
  local cmd='typeset -A __assoc
__assoc['\''k e y'\'']='\''v a l'\''
__assoc[a]=b
set | grep '\''^__'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 shopt -q' {
  local cmd='shopt -q nullglob
echo nullglob=$?

# set it
shopt -s nullglob

shopt -q nullglob
echo nullglob=$?

shopt -q nullglob failglob
echo nullglob,failglob=$?

# set it
shopt -s failglob
shopt -q nullglob failglob
echo nullglob,failglob=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 shopt -q invalid' {
  local cmd='shopt -q invalidZZ
echo invalidZZ=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 shopt -s strict:all' {
  local cmd='n=2

show-strict() {
  shopt -p | grep '\''strict_'\'' | head -n $n
  echo -
}

show-strict
shopt -s strict:all
show-strict
shopt -u strict_argv
show-strict'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 shopt allows for backward compatibility like bash' {
  local cmd='# doesn'\''t have to be on, but just for testing
set -o errexit

shopt -p nullglob || true  # bash returns 1 here?  Like -q.

# This should set nullglob, and return 1, which can be ignored
shopt -s nullglob strict_OPTION_NOT_YET_IMPLEMENTED 2>/dev/null || true
echo status=$?

shopt -p nullglob || true'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 shopt -p validates option names' {
  local cmd='shopt -p nullglob invalid failglob
echo status=$?
# same thing as -p, slightly different format in bash
shopt nullglob invalid failglob > $TMP/out.txt
status=$?
sed --regexp-extended '\''s/\s+/ /'\'' $TMP/out.txt  # make it easier to assert
echo status=$status'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 shopt -p -o validates option names' {
  local cmd='shopt -p -o errexit invalid nounset
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 stubbed out bash options' {
  local cmd='shopt -s ignore_shopt_not_impl
for name in foo autocd cdable_vars checkwinsize; do
  shopt -s $name
  echo $?
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 shopt -s nounset works in YSH, not in bash' {
  local cmd='case $SH in
  *dash|*mksh)
    echo N-I
    exit
    ;;
esac
shopt -s nounset
echo status=$?

# get rid of extra space in bash output
set -o | grep nounset | sed '\''s/[ \t]\+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 Unimplemented options - print, query, set, unset' {
  local cmd='case $SH in dash|mksh) exit ;; esac

opt_name=xpg_echo

shopt -p xpg_echo
shopt -q xpg_echo; echo q=$?

shopt -s xpg_echo
shopt -p xpg_echo

shopt -u xpg_echo
shopt -p xpg_echo
echo p=$?  # weird, bash also returns a status

shopt xpg_echo >/dev/null
echo noflag=$?

shopt -o errexit >/dev/null
echo set=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 Unimplemented options - OSH shopt -s ignore_shopt_not_impl' {
  local cmd='case $SH in dash|mksh) exit ;; esac

shopt -s ignore_shopt_not_impl

opt_name=xpg_echo

shopt -p xpg_echo
shopt -q xpg_echo; echo q=$?

shopt -s xpg_echo
shopt -p xpg_echo

shopt -u xpg_echo
shopt -p xpg_echo
echo p=$?  # weird, bash also returns a status

shopt xpg_echo >/dev/null
echo noflag=$?

shopt -o errexit >/dev/null
echo set=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 shopt -p exit code (regression)' {
  local cmd='case $SH in dash|mksh) exit ;; esac

shopt -p > /dev/null
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 no-ops not shown by shopt -p' {
  skip 'straggler: does not report cleanly under bats'
  local cmd='shopt -p | grep xpg
echo --'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

