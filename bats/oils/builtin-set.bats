#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-set.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 can continue after unknown option' {
  local cmd='#
# TODO: this is the posix special builtin logic?
# dash and mksh make this a fatal error no matter what.

set -o errexit
set -o STRICT || true # unknown option
echo hello'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 set with both options and argv' {
  local cmd='set -o errexit a b c
echo "$@"
false
echo done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 nounset with @' {
  local cmd='set a b c
set -u  # shouldn'\''t touch argv
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 set -u -- clears argv' {
  local cmd='set a b c
set -u -- # shouldn'\''t touch argv
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 set -u -- x y z' {
  local cmd='set a b c
set -u -- x y z
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 set -u with undefined variable exits the interpreter' {
  local cmd='# non-interactive
$SH -c '\''set -u; echo before; echo $x; echo after'\''
if test $? -ne 0; then
  echo OK
fi

# interactive
$SH -i -c '\''set -u; echo before; echo $x; echo after'\''
if test $? -ne 0; then
  echo OK
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 set -u with undefined var in interactive shell does NOT exit the interpreter' {
  local cmd='# In bash, it aborts the LINE only.  The next line is executed!

# non-interactive
$SH -c '\''set -u; echo before; echo $x; echo after
echo line2
'\''
if test $? -ne 0; then
  echo OK
fi

# interactive
$SH -i -c '\''set -u; echo before; echo $x; echo after
echo line2
'\''
if test $? -ne 0; then
  echo OK
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 set -u error can break out of nested evals' {
  local cmd='$SH -c '\''
set -u
test_function_2() {
  x=$blarg
}
test_function() {
  eval "test_function_2"
}

echo before
eval test_function
echo after
'\''
# status must be non-zero: bash uses 1, ash/dash exit 2
if test $? -ne 0; then
  echo OK
fi'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 reset option with long flag' {
  local cmd='set -o errexit
set +o errexit
echo "[$unset]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 reset option with short flag' {
  local cmd='set -u 
set +u
echo "[$unset]"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 set -eu (flag parsing)' {
  local cmd='set -eu 
echo "[$unset]"
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 set -o lists options' {
  local cmd='# NOTE: osh doesn'\''t use the same format yet.
set -o | grep -o noexec'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 '\''set'\'' and '\''eval'\'' round trip' {
  local cmd='# NOTE: not testing arrays and associative arrays!
_space='\''[ ]'\''
_whitespace=$'\''[\t\r\n]'\''
_sq="'\''single quotes'\''"
_backslash_dq="\\ \""
_unicode=$'\''[\u03bc]'\''

# Save the variables
varfile=$TMP/vars-$(basename $SH).txt

set | grep '\''^_'\'' > "$varfile"

# Unset variables
unset _space _whitespace _sq _backslash_dq _unicode
echo [ $_space $_whitespace $_sq $_backslash_dq $_unicode ]

# Restore them

. $varfile
echo "Code saved to $varfile" 1>&2  # for debugging

test "$_space" = '\''[ ]'\'' && echo OK
test "$_whitespace" = $'\''[\t\r\n]'\'' && echo OK
test "$_sq" = "'\''single quotes'\''" && echo OK
test "$_backslash_dq" = "\\ \"" && echo OK
test "$_unicode" = $'\''[\u03bc]'\'' && echo OK'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 set - - and so forth' {
  local cmd='set a b
echo "$@"

set - a b
echo "$@"

set -- a b
echo "$@"

set - -
echo "$@"

set -- --
echo "$@"

# note: zsh is different, and yash is totally different'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 set - leading single dash is ignored, turns off xtrace verbose (#2364)' {
  local cmd='show_options() {
  case $- in
    *v*) echo verbose-on ;;
  esac
  case $- in
    *x*) echo xtrace-on ;;
  esac
}

set -x -v
show_options
echo

set - a b c
echo "$@"
show_options
echo

# dash that'\''s not leading is not special
set x - y z
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 set - stops option processing like set --' {
  local cmd='show_options() {
  case $- in
    *v*) echo verbose-on ;;
  esac
  case $- in
    *x*) echo xtrace-on ;;
  esac
}

set -x - -v

show_options
echo argv "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 A single + is an ignored flag; not an argument' {
  local cmd='show_options() {
  case $- in
    *v*) echo verbose-on ;;
  esac
  case $- in
    *x*) echo xtrace-on ;;
  esac
}

set +
echo plus "$@"

set -x + -v x y
show_options
echo plus "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 set - + and + -' {
  local cmd='set - +
echo "$@"

set + -
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 set -a exports variables' {
  local cmd='set -a
FOO=bar
BAZ=qux
printenv.py FOO BAZ'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 set +a stops exporting' {
  local cmd='set -a
FOO=exported
set +a
BAR=not_exported
printenv.py FOO BAR'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 set -o allexport (long form)' {
  local cmd='set -o allexport
VAR1=value1
set +o allexport
VAR2=value2
printenv.py VAR1 VAR2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 variables set before set -a are not exported' {
  local cmd='BEFORE=before_value
set -a
AFTER=after_value
printenv.py BEFORE AFTER'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 set -a exports local variables' {
  local cmd='set -a
f() {
  local ZZZ=zzz
  printenv.py ZZZ
}
f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 set -a exports declare variables' {
  local cmd='set -a
declare ZZZ=zzz
printenv.py ZZZ'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

