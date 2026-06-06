#!/usr/bin/env bats
# Generated from oils-for-unix spec/assign.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Env value doesn'\''t persist' {
  local cmd='FOO=foo printenv.py FOO
echo -$FOO-'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Env value with equals' {
  local cmd='FOO=foo=foo printenv.py FOO'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Env binding can use preceding bindings, but not subsequent ones' {
  local cmd='# This means that for ASSIGNMENT_WORD, on the RHS you invoke the parser again!
# Could be any kind of quoted string.
FOO="foo" BAR="[$FOO][$BAZ]" BAZ=baz printenv.py FOO BAR BAZ'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Env value with two quotes' {
  local cmd='FOO='\''foo'\''"adjacent" printenv.py FOO'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Env value with escaped <' {
  local cmd='FOO=foo\<foo printenv.py FOO'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 FOO=foo echo [foo]' {
  local cmd='FOO=foo echo "[$foo]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 FOO=foo fun' {
  local cmd='fun() {
  echo "[$FOO]"
}
FOO=foo fun'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Multiple temporary envs on the stack' {
  local cmd='g() {
  echo "$F" "$G1" "$G2"
  echo '\''--- g() ---'\''
  P=p printenv.py F G1 G2 A P
}
f() {
  # NOTE: G1 doesn'\''t pick up binding f, but G2 picks up a.
  # I don'\''t quite understand why this is, but bash and OSH agree!
  G1=[$f] G2=[$a] g
  echo '\''--- f() ---'\''
  printenv.py F G1 G2 A P
}
a=A
F=f f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Escaped = in command name' {
  local cmd='# foo=bar is in the '\''spec/bin'\'' dir.
foo\=bar'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Env binding not allowed before compound command' {
  local cmd='# bash gives exit code 2 for syntax error, because of '\''do'\''.
# dash gives 0 because there is stuff after for?  Should really give an error.
# mksh gives acceptable error of 1.
FOO=bar for i in a b; do printenv.py $FOO; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Trying to run keyword '\''for'\''' {
  local cmd='FOO=bar for'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Empty env binding' {
  local cmd='EMPTY= printenv.py EMPTY'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Assignment doesn'\''t do word splitting' {
  local cmd='words='\''one two'\''
a=$words
argv.py "$a"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Assignment doesn'\''t do glob expansion' {
  local cmd='touch _tmp/z.Z _tmp/zz.Z
a=_tmp/*.Z
argv.py "$a"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Env binding in readonly/declare is NOT exported!  (pitfall)' {
  local cmd='# All shells agree on this, but it'\''s very confusing behavior.
FOO=foo readonly v=$(printenv.py FOO)
echo "v=$v"

# bash has probems here:
FOO=foo readonly v2=$FOO
echo "v2=$v2"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 assignments / array assignments not interpreted after '\''echo'\''' {
  local cmd='a=1 echo b[0]=2 c=3'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 dynamic local variables (and splitting)' {
  local cmd='f() {
  local "$1"  # Only x is assigned here
  echo x=\'\''$x\'\''
  echo a=\'\''$a\'\''

  local $1  # x and a are assigned here
  echo x=\'\''$x\'\''
  echo a=\'\''$a\'\''
}
f '\''x=y a=b'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 readonly x= gives empty string (regression)' {
  local cmd='readonly x=
argv.py "$x"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 '\''local x'\'' does not set variable' {
  local cmd='set -o nounset
f() {
  local x
  echo $x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 '\''local -a x'\'' does not set variable' {
  local cmd='set -o nounset
f() {
  local -a x
  echo $x
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 '\''local x'\'' and then array assignment' {
  local cmd='f() {
  local x
  x[3]=foo
  echo ${x[3]}
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 '\''declare -A'\'' and then dict assignment' {
  local cmd='declare -A foo
key=bar
foo["$key"]=value
echo ${foo["bar"]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 declare in an if statement' {
  local cmd='# bug caught by my feature detection snippet in bash-completion
if ! foo=bar; then
  echo BAD
fi
echo $foo
if ! eval '\''spam=eggs'\''; then
  echo BAD
fi
echo $spam'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Modify a temporary binding' {
  local cmd='# (regression for bug found by Michael Greenberg)
f() {
  echo "x before = $x"
  x=$((x+1))
  echo "x after  = $x"
}
x=5 f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Reveal existence of temp frame (All shells disagree here!!!)' {
  local cmd='f() {
  echo "x=$x"

  x=mutated-temp  # mutate temp frame
  echo "x=$x"

  # Declare a new local
  local x='\''local'\''
  echo "x=$x"

  # Unset it
  unset x
  echo "x=$x"
}

x=global
x=temp-binding f
echo "x=$x"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Test above without '\''local'\'' (which is not POSIX)' {
  local cmd='f() {
  echo "x=$x"

  x=mutated-temp  # mutate temp frame
  echo "x=$x"

  # Unset it
  unset x
  echo "x=$x"
}

x=global
x=temp-binding f
echo "x=$x"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Using {x-default} after unsetting local shadowing a global' {
  local cmd='f() {
  echo "x=$x"
  local x='\''local'\''
  echo "x=$x"
  unset x
  echo "- operator = ${x-default}"
  echo ":- operator = ${x:-default}"
}
x=global
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Using {x-default} after unsetting a temp binding shadowing a global' {
  local cmd='f() {
  echo "x=$x"
  local x='\''local'\''
  echo "x=$x"
  unset x
  echo "- operator = ${x-default}"
  echo ":- operator = ${x:-default}"
}
x=global
x=temp-binding f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 static assignment doesn'\''t split' {
  local cmd='words='\''a b c'\''
export ex=$words
glo=$words
readonly ro=$words
argv.py "$ex" "$glo" "$ro"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 aliased assignment doesn'\''t split' {
  local cmd='shopt -s expand_aliases || true
words='\''a b c'\''
alias e=export
alias r=readonly
e ex=$words
r ro=$words
argv.py "$ex" "$ro"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 assignment using dynamic keyword (splits in most shells, not in zsh/osh)' {
  local cmd='words='\''a b c'\''
e=export
r=readonly
$e ex=$words
$r ro=$words
argv.py "$ex" "$ro"

# zsh and OSH are smart'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 assignment using dynamic var names doesn'\''t split' {
  local cmd='words='\''a b c'\''
arg_ex=ex=$words
arg_ro=ro=$words

# no quotes, this is split of course
export $arg_ex
readonly $arg_ro

argv.py "$ex" "$ro"

arg_ex2=ex2=$words
arg_ro2=ro2=$words

# quotes, no splitting
export "$arg_ex2"
readonly "$arg_ro2"

argv.py "$ex2" "$ro2"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 assign and glob' {
  local cmd='cd $TMP
touch foo=a foo=b
foo=*
argv.py "$foo"
unset foo

export foo=*
argv.py "$foo"
unset foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 declare and glob' {
  local cmd='cd $TMP
touch foo=a foo=b
typeset foo=*
argv.py "$foo"
unset foo'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 readonly x where x='\''b c'\''' {
  local cmd='one=a
two='\''b c'\''
readonly $two $one
a=new
echo status=$?
b=new
echo status=$?
c=new
echo status=$?

# in OSH and zsh, this is an invalid variable name'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 readonly a=(1 2) no_value c=(3 4) makes '\''no_value'\'' readonly' {
  local cmd='readonly a=(1 2) no_value c=(3 4)
no_value=x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 export a=1 no_value c=2' {
  local cmd='no_value=foo
export a=1 no_value c=2
printenv.py no_value'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 local a=loc var c=loc' {
  local cmd='var='\''b'\''
b=global
echo $b
f() {
  local a=loc $var c=loc
  argv.py "$a" "$b" "$c"
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 redirect after assignment builtin (eval redirects after evaluating arguments)' {
  local cmd='# See also: spec/redir-order.test.sh (#2307)
# The $(stdout_stderr.py) is evaluated *before* the 2>/dev/null redirection

readonly x=$(stdout_stderr.py) 2>/dev/null
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 redirect after command sub (like case above but without assignment builtin)' {
  local cmd='echo stdout=$(stdout_stderr.py) 2>/dev/null'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 redirect after bare assignment' {
  local cmd='x=$(stdout_stderr.py) 2>/dev/null
echo done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 redirect after declare -p' {
  local cmd='case $SH in *dash) exit 99 ;; esac  # stderr unpredictable

foo=bar
typeset -p foo 1>&2

# zsh and mksh agree on exact output, which we don'\''t really care about'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 declare -a arr does not remove existing arrays (OSH regression)' {
  local cmd='case $SH in dash) exit 99 ;; esac # dash does not support arrays

declare -a arr
arr=(foo bar baz)
declare -a arr
echo arr:${#arr[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 declare -A dict does not remove existing arrays (OSH regression)' {
  local cmd='case $SH in dash|mksh) exit 99 ;; esac # dash/mksh does not support associative arrays

declare -A dict
dict['\''foo'\'']=hello
dict['\''bar'\'']=oil
dict['\''baz'\'']=world
declare -A dict
echo dict:${#dict[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 readonly -a arr and readonly -A dict should not not remove existing arrays' {
  local cmd='# mksh'\''s readonly does not support the -a option.
# dash/mksh does not support associative arrays.
case $SH in dash|mksh) exit 99 ;; esac

declare -a arr
arr=(foo bar baz)
declare -A dict
dict['\''foo'\'']=hello
dict['\''bar'\'']=oil
dict['\''baz'\'']=world

readonly -a arr
echo arr:${#arr[@]}
readonly -A dict
echo dict:${#dict[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '046 declare -a arr and readonly -a a creates an empty array (OSH)' {
  local cmd='case $SH in dash|mksh) exit 99 ;; esac # dash/mksh does not support associative arrays

declare -a arr1
readonly -a arr2
declare -A dict1
readonly -A dict2

declare -p arr1 arr2 dict1 dict2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '047 var d = {}; declare -p d does not print anything (OSH)' {
  local cmd='case $SH in bash-4.4|dash|mksh|zsh) exit 99 ;; esac

# We pretend that the variable does not exist when the variable is not
# representable with the "declare -p" format.

var d = {}
declare -p d'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 readonly array should not be modified by a+=(1)' {
  local cmd='case $SH in dash) exit 99 ;; esac # dash/mksh does not support associative arrays

a=(1 2 3)
readonly -a a
eval '\''a+=(4)'\''
argv.py "${a[@]}"
eval '\''declare -n r=a; r+=(4)'\''
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

