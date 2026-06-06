#!/usr/bin/env bats
# Generated from oils-for-unix spec/alias.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Usage of builtins' {
  local cmd='shopt -s expand_aliases || true
alias -- foo=echo
echo status=$?
foo x
unalias -- foo
foo x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Basic alias' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias hi='\''echo hello world'\''
hi || echo '\''should not run this'\''
echo hi  # second word is not
'\''hi'\'' || echo '\''expected failure'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 define and use alias on a single line' {
  local cmd='shopt -s expand_aliases
alias e=echo; e one  # this is not alias-expanded because we parse lines at once
e two; e three'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 alias can override builtin' {
  local cmd='shopt -s expand_aliases
alias echo='\''echo foo'\''
echo bar'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 alias not defined' {
  local cmd='alias e='\''echo'\'' nonexistentZ
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 unalias not defined' {
  local cmd='alias e=echo ll='\''ls -l'\''
unalias e nonexistentZ ll
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 unalias -a' {
  local cmd='alias foo=bar
alias spam=eggs

alias | egrep '\''foo|spam'\'' | wc -l

unalias -a

alias
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 List aliases by providing names' {
  local cmd='alias e=echo ll='\''ls -l'\''
alias e ll'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 alias without args lists all aliases' {
  local cmd='alias ex=exit ll='\''ls -l'\''
alias | grep -E '\''ex=|ll='\''  # need to grep because mksh/zsh have builtin aliases
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 unalias without args is a usage error' {
  local cmd='unalias
if test "$?" != 0; then echo usage-error; fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 alias with trailing space causes alias expansion on second word' {
  local cmd='shopt -s expand_aliases  # bash requires this

alias hi='\''echo hello world '\''
alias punct='\''!!!'\''

hi punct

alias hi='\''echo hello world'\''  # No trailing space

hi punct'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Recursive alias expansion of first word' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias hi='\''e_ hello world'\''
alias e_='\''echo __'\''
hi   # first hi is expanded to echo hello world; then echo is expanded.  gah.'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Recursive alias expansion of SECOND word' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias one='\''ONE '\''
alias two='\''TWO '\''
alias e_='\''echo one '\''
e_ two hello world'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Expansion of alias with variable' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
alias echo-x='\''echo $x'\''  # nothing is evaluated here
x=y
echo-x hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Alias must be an unquoted word, no expansions allowed' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias echo_alias_='\''echo'\''
cmd=echo_alias_
echo_alias_ X  # this works
$cmd X  # this fails because it'\''s quoted
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 first and second word are the same alias, but no trailing space' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
alias echo-x='\''echo $x'\''  # nothing is evaluated here
echo-x echo-x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 first and second word are the same alias, with trailing space' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
alias echo-x='\''echo $x '\''  # nothing is evaluated here
echo-x echo-x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Invalid syntax of alias' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias echo_alias_= '\''echo --; echo'\''  # bad space here
echo_alias_ x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Dynamic alias definition' {
  local cmd='shopt -s expand_aliases  # bash requires this
x=x
name='\''echo_alias_'\''
val='\''=echo'\''
alias "$name$val"
echo_alias_ X'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Alias name with punctuation' {
  local cmd='# NOTE: / is not OK in bash, but OK in other shells.  Must less restrictive
# than var names.
shopt -s expand_aliases  # bash requires this
alias e_+.~x='\''echo'\''
e_+.~x X'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Syntax error after expansion' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias e_='\'';; oops'\''
e_ x'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 Loop split across alias and arg works' {
  local cmd='shopt -s expand_aliases  # bash requires this
alias e_='\''for i in 1 2 3; do echo $i;'\''
e_ done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Loop split across alias in another way' {
  local cmd='shopt -s expand_aliases
alias e_='\''for i in 1 2 3; do echo '\''
e_ $i; done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Alias with a quote in the middle is a syntax error' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo "'\''
var=x
e_ '\''${var}"'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Alias with internal newlines' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo 1
echo 2
echo 3'\''
var='\''echo foo'\''
e_ ${var}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Alias trailing newline' {
  local cmd='shopt -s expand_aliases
alias e_='\''echo 1
echo 2
echo 3
'\''
var='\''echo foo'\''
e_ ${var}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 Two aliases in pipeline' {
  local cmd='shopt -s expand_aliases
alias SEQ='\''seq '\''
alias THREE='\''3 '\''
alias WC='\''wc '\''
SEQ THREE | WC -l'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 Alias not respected inside ()' {
  local cmd='# This could be parsed correctly, but it is only defined in a child process.
shopt -s expand_aliases
echo $(alias sayhi='\''echo hello'\'')
sayhi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 Alias can be defined and used on a single line' {
  local cmd='shopt -s expand_aliases
alias sayhi='\''echo hello'\''; sayhi same line
sayhi other line'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Alias is respected inside eval' {
  local cmd='shopt -s expand_aliases
eval "alias sayhi='\''echo hello'\''
sayhi inside"
sayhi outside'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 alias with redirects works' {
  local cmd='shopt -s expand_aliases
alias e_=echo
>$TMP/alias1.txt e_ 1
e_ >$TMP/alias2.txt 2
e_ 3 >$TMP/alias3.txt
cat $TMP/alias1.txt $TMP/alias2.txt $TMP/alias3.txt'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 alias with environment bindings works' {
  local cmd='shopt -s expand_aliases
alias p_=printenv.py
FOO=1 printenv.py FOO
FOO=2 p_ FOO'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 alias for left brace' {
  local cmd='shopt -s expand_aliases
alias LEFT='\''{'\''
LEFT echo one; echo two; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 alias for left paren' {
  local cmd='shopt -s expand_aliases
alias LEFT='\''('\''
LEFT echo one; echo two )'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 alias used in here doc' {
  local cmd='shopt -s expand_aliases
alias echo_='\''echo [ '\''
cat <<EOF
$(echo_ ])
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 here doc inside alias' {
  local cmd='shopt -s expand_aliases
alias c='\''cat <<EOF
$(echo hi)
EOF
'\''
c'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 Corner case: alias inside LHS array arithmetic expression' {
  local cmd='shopt -s expand_aliases
alias zero='\''echo 0'\''
a[$(zero)]=ZERO
a[1]=ONE
argv.py "${a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 Alias that is pipeline' {
  local cmd='shopt -s expand_aliases
alias t1='\''echo hi|wc -c'\''
t1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 Alias that is && || ;' {
  local cmd='shopt -s expand_aliases
alias t1='\''echo one && echo two && echo 3 | wc -l;
echo four'\''
t1'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 Alias and command sub (bug regression)' {
  local cmd='cd $TMP
shopt -s expand_aliases
echo foo bar > tmp.txt
alias a=argv.py
a `cat tmp.txt`'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 Alias and arithmetic' {
  local cmd='shopt -s expand_aliases
alias a=argv.py
a $((1 + 2))'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
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
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 alias with word of multiple lines' {
  local cmd='shopt -s expand_aliases

alias ll='\''ls -l'\''
ll '\''1
  2
  3'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

