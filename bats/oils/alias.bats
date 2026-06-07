#!/usr/bin/env bats
# Generated from oils-for-unix spec/alias.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Usage of builtins' {
  local cmd='shopt -s expand_aliases || true
alias -- foo=echo
echo status=$?
foo x
unalias -- foo
foo x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Basic alias' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias hi='\''echo hello world'\''
hi || echo '\''should not run this'\''
echo hi  # second word is not
'\''hi'\'' || echo '\''expected failure'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 define and use alias on a single line' {
  local cmd='shopt -s expand_aliases
alias e=echo; e one  # this is not alias-expanded because we parse lines at once
e two; e three'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 alias can override builtin' {
  local cmd='shopt -s expand_aliases
alias echo='\''echo foo'\''
echo bar'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 defining multiple aliases, then unalias' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
y=y
alias echo-x='\''echo $x'\'' echo-y='\''echo $y'\''
echo status=$?
echo-x X
echo-y Y
unalias echo-x echo-y
echo status=$?
echo-x X || echo undefined
echo-y Y || echo undefined'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 alias not defined' {
  local cmd='alias e='\''echo'\'' nonexistentZ
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 unalias not defined' {
  local cmd='alias e=echo ll='\''ls -l'\''
unalias e nonexistentZ ll
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 unalias -a' {
  local cmd='alias foo=bar
alias spam=eggs

alias | egrep '\''foo|spam'\'' | wc -l

unalias -a

alias
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 List aliases by providing names' {
  local cmd='alias e=echo ll='\''ls -l'\''
alias e ll'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 alias without args lists all aliases' {
  local cmd='alias ex=exit ll='\''ls -l'\''
alias | grep -E '\''ex=|ll='\''  # need to grep because mksh/zsh have builtin aliases
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 unalias without args is a usage error' {
  local cmd='unalias
if test "$?" != 0; then echo usage-error; fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 alias with trailing space causes alias expansion on second word' {
  local cmd='shopt -s expand_aliases  # bash requires this

alias hi='\''echo hello world '\''
alias punct='\''!!!'\''

hi punct

alias hi='\''echo hello world'\''  # No trailing space

hi punct'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Recursive alias expansion of first word' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias hi='\''e_ hello world'\''
alias e_='\''echo __'\''
hi   # first hi is expanded to echo hello world; then echo is expanded.  gah.'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Recursive alias expansion of SECOND word' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias one='\''ONE '\''
alias two='\''TWO '\''
alias e_='\''echo one '\''
e_ two hello world'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Expansion of alias with variable' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
alias echo-x='\''echo $x'\''  # nothing is evaluated here
x=y
echo-x hi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Alias must be an unquoted word, no expansions allowed' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias echo_alias_='\''echo'\''
cmd=echo_alias_
echo_alias_ X  # this works
$cmd X  # this fails because it'\''s quoted
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 first and second word are the same alias, but no trailing space' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
alias echo-x='\''echo $x'\''  # nothing is evaluated here
echo-x echo-x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 first and second word are the same alias, with trailing space' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
alias echo-x='\''echo $x '\''  # nothing is evaluated here
echo-x echo-x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 Invalid syntax of alias' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias echo_alias_= '\''echo --; echo'\''  # bad space here
echo_alias_ x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Dynamic alias definition' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
name='\''echo_alias_'\''
val='\''=echo'\''
alias "$name$val"
echo_alias_ X'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Alias name with punctuation' {
  local cmd='# NOTE: / is not OK in bash, but OK in other shells.  Must less restrictive
# than var names.
shopt -s expand_aliases  # bash requires this
alias e_+.~x='\''echo'\''
e_+.~x X'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 Syntax error after expansion' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias e_='\'';; oops'\''
e_ x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 Loop split across alias and arg works' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias e_='\''for i in 1 2 3; do echo $i;'\''
e_ done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 Loop split across alias in another way' {
  local cmd='shopt -s expand_aliases
alias e_='\''for i in 1 2 3; do echo '\''
e_ $i; done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 Loop split across both iterative and recursive aliases' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias FOR1='\''for '\''
alias FOR2='\''FOR1 '\''
alias eye1='\''i '\''
alias eye2='\''eye1 '\''
alias IN='\''in '\''
alias onetwo='\''$one "2" '\''  # NOTE: this does NOT work in any shell except bash.
one=1
FOR2 eye2 IN onetwo 3; do echo $i; done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 Alias with a quote in the middle is a syntax error' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo "'\''
var=x
e_ '\''${var}"'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 Alias with internal newlines' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo 1
echo 2
echo 3'\''
var='\''echo foo'\''
e_ ${var}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 Alias trailing newline' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo 1
echo 2
echo 3
'\''
var='\''echo foo'\''
e_ ${var}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 Two aliases in pipeline' {
  local cmd='shopt -s expand_aliases
alias SEQ='\''seq '\''
alias THREE='\''3 '\''
alias WC='\''wc '\''
SEQ THREE | WC -l'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 Alias not respected inside ()' {
  local cmd='# This could be parsed correctly, but it is only defined in a child process.
shopt -s expand_aliases
echo $(alias sayhi='\''echo hello'\'')
sayhi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 Alias can be defined and used on a single line' {
  local cmd='shopt -s expand_aliases
alias sayhi='\''echo hello'\''; sayhi same line
sayhi other line'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 Alias is respected inside eval' {
  local cmd='shopt -s expand_aliases
eval "alias sayhi='\''echo hello'\''
sayhi inside"
sayhi outside'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 alias with redirects works' {
  local cmd='shopt -s expand_aliases
alias e_=echo
>$TMP/alias1.txt e_ 1
e_ >$TMP/alias2.txt 2
e_ 3 >$TMP/alias3.txt
cat $TMP/alias1.txt $TMP/alias2.txt $TMP/alias3.txt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 alias with environment bindings works' {
  local cmd='shopt -s expand_aliases
alias p_=printenv.py
FOO=1 printenv.py FOO
FOO=2 p_ FOO'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 alias with line continuation in the middle' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo '\''
alias one='\''ONE '\''
alias two='\''TWO '\''
alias three='\''THREE'\''  # no trailing space
e_ one \
  two one \
  two three two \
  one'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 alias for left brace' {
  local cmd='shopt -s expand_aliases
alias LEFT='\''{'\''
LEFT echo one; echo two; }'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 alias for left paren' {
  local cmd='shopt -s expand_aliases
alias LEFT='\''('\''
LEFT echo one; echo two )'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 alias used in subshell and command sub' {
  local cmd='# This spec seems to be contradictoary?
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_03_01
# "When used as specified by this volume of POSIX.1-2017, alias definitions
# shall not be inherited by separate invocations of the shell or by the utility
# execution environments invoked by the shell; see Shell Execution
# Environment."
shopt -s expand_aliases
alias echo_='\''echo [ '\''
( echo_ subshell; )
echo $(echo_ commandsub)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 alias used in here doc' {
  local cmd='shopt -s expand_aliases
alias echo_='\''echo [ '\''
cat <<EOF
$(echo_ ])
EOF'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 here doc inside alias' {
  local cmd='shopt -s expand_aliases
alias c='\''cat <<EOF
$(echo hi)
EOF
'\''
c'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '041 Corner case: alias inside LHS array arithmetic expression' {
  local cmd='shopt -s expand_aliases
alias zero='\''echo 0'\''
a[$(zero)]=ZERO
a[1]=ONE
argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '042 Alias that is pipeline' {
  local cmd='shopt -s expand_aliases
alias t1='\''echo hi|wc -c'\''
t1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '043 Alias that is && || ;' {
  local cmd='shopt -s expand_aliases
alias t1='\''echo one && echo two && echo 3 | wc -l;
echo four'\''
t1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '044 Alias and command sub (bug regression)' {
  local cmd='cd $TMP
shopt -s expand_aliases
echo foo bar > tmp.txt
alias a=argv.py
a `cat tmp.txt`'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '045 Alias and arithmetic' {
  local cmd='shopt -s expand_aliases
alias a=argv.py
a $((1 + 2))'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '046 Alias and PS4' {
  local cmd='# dash enters an infinite loop!
case $SH in
  dash)
    exit 1
    ;;
esac

set -x
PS4='\''+$(echo trace) '\''
shopt -s expand_aliases
alias a=argv.py
a foo bar'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '047 alias with keywords' {
  local cmd='# from issue #299
shopt -s expand_aliases
alias a=

# both of these fail to parse in OSH
# this is because of our cleaner evaluation model

a (( var = 0 ))
#a case x in x) true ;; esac

echo done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '048 alias with word of multiple lines' {
  local cmd='shopt -s expand_aliases

alias ll='\''ls -l'\''
ll '\''1
  2
  3'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

