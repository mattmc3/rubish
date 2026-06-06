#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-completion.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 complete with no args and complete -p both print completion spec' {
  local cmd='set -e

complete

complete -W '\''foo bar'\'' mycommand

complete -p

complete -F myfunc other

complete'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 complete -F f is usage error' {
  local cmd='#complete -F f cmd

# Alias for complete -p
complete > /dev/null  # ignore OSH output for now
echo status=$?

# But this is an error
complete -F f
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 complete with nonexistent function' {
  local cmd='complete -F invalidZZ -D
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 complete with no action' {
  local cmd='complete foo
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 -A function prints functions' {
  local cmd='add () { expr 4 + 4; }
div () { expr 6 / 2; }
ek () { echo hello; }
__ec () { echo hi; }
_ab () { expr 10 % 3; }
compgen -A function
echo --
compgen -A function _'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Invalid syntax' {
  local cmd='compgen -A foo
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 how compgen calls completion functions' {
  local cmd='foo_complete() {
  # first, cur, prev
  argv.py argv "$@"
  argv.py COMP_WORDS "${COMP_WORDS[@]}"
  argv.py COMP_CWORD "${COMP_CWORD}"
  argv.py COMP_LINE "${COMP_LINE}"
  argv.py COMP_POINT "${COMP_POINT}"
  #return 124
  COMPREPLY=(one two three)
}
compgen -F foo_complete foo a b c'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 complete -o -F (git)' {
  local cmd='foo() { echo foo; }
wrapper=foo
complete -o default -o nospace -F $wrapper git'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 compopt with invalid syntax' {
  local cmd='compopt -o invalid
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 compopt fails when not in completion function' {
  local cmd='# NOTE: Have to be executing a completion function
compopt -o filenames +o nospace'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 compgen -f on invalid  dir' {
  local cmd='compgen -f /non-existing-dir/'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 compgen -f' {
  local cmd='mkdir -p $TMP/compgen
touch $TMP/compgen/{one,two,three}
cd $TMP/compgen
compgen -f | sort
echo --
compgen -f t | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 compgen -v with local vars' {
  local cmd='v1_global=0
f() {
  local v2_local=0	 
  compgen -v v
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 compgen -v on unknown var' {
  local cmd='compgen -v __nonexistent__'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 compgen -v P' {
  local cmd='cd > /dev/null  # for some reason in bash, this makes PIPESTATUS appear!
compgen -v P | grep -E '\''^PATH|PWD'\'' | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 compgen -e with global/local exported vars' {
  local cmd='export v1_global=0
f() {
  local v2_local=0
  export v2_local
  compgen -e v
}
f'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 compgen -e on known, but unexported, var' {
  local cmd='unexported=0
compgen -e unexported'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 compgen -e on unknown var' {
  local cmd='compgen -e __nonexistent__'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 compgen -e P' {
  local cmd='cd > /dev/null  # for some reason in bash, this makes PIPESTATUS appear!
compgen -e P | grep -E '\''^PATH|PWD'\'' | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 compgen with actions: function / variable / file' {
  local cmd='mkdir -p $TMP/compgen2
touch $TMP/compgen2/{PA,Q}_FILE
cd $TMP/compgen2  # depends on previous test above!
PA_FUNC() { echo P; }
Q_FUNC() { echo Q; }
compgen -A function -A variable -A file PA'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 compgen with actions: alias, setopt' {
  local cmd='alias v_alias='\''ls'\''
alias v_alias2='\''ls'\''
alias a1='\''ls'\''
compgen -A alias -A setopt v'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 compgen with actions: shopt' {
  local cmd='compgen -A shopt -P [ -S ] nu'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 compgen with action and suffix: helptopic' {
  local cmd='compgen -A helptopic -S ___ fal'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 compgen -A directory' {
  local cmd='cd $REPO_ROOT
compgen -A directory c | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 compgen -A file' {
  local cmd='cd $REPO_ROOT
compgen -A file o | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 compgen -A user' {
  local cmd='# no assertion because this isn'\''t hermetic
compgen -A user'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 compgen -A command completes external commands' {
  local cmd='# NOTE: this test isn'\''t hermetic
compgen -A command xarg | uniq
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 compgen -A command completes functions and aliases' {
  local cmd='our_func() { echo ; }
our_func2() { echo ; }
alias our_alias=foo

compgen -A command our_
echo status=$?

# Introduce another function.  Note that we'\''re missing test coverage for
# '\''complete'\'', i.e. bug #1064.
our_func3() { echo ; }

compgen -A command our_
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 compgen -A command completes builtins and keywords' {
  local cmd='compgen -A command eva
echo status=$?
compgen -A command whil
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 compgen -k shows the same keywords as bash' {
  local cmd='# bash adds ]] and } and coproc

# Use bash as an oracle
bash -c '\''compgen -k'\'' | sort > bash.txt

# osh vs. bash, or bash vs. bash
$SH -c '\''compgen -k'\'' | sort > this-shell.txt

#comm bash.txt this-shell.txt

# show lines in both files
comm -12 bash.txt this-shell.txt | egrep -v '\''coproc|select'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 compgen -k shows Oils keywords too' {
  local cmd='# YSH has a superset of keywords:
# const var
# setvar setglobal
# proc func typed
# call =   # hm = is not here

compgen -k | sort | egrep '\''^(const|var|setvar|setglobal|proc|func|typed|call|=)$'\''
echo --'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 compgen -k completes reserved shell keywords' {
  local cmd='compgen -k do | sort
echo status=$?
compgen -k el | sort
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 -o filenames and -o nospace have no effect with compgen' {
  local cmd='# they are POSTPROCESSING.
compgen -o filenames -o nospace -W '\''bin build'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 -o plusdirs and -o dirnames with compgen' {
  local cmd='cd $REPO_ROOT
compgen -o plusdirs -W '\''a b1 b2'\'' b | sort
echo ---
compgen -o dirnames b | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 compgen -o default completes files and dirs' {
  local cmd='cd $REPO_ROOT
compgen -o default spec/t | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 compgen doesn'\''t respect -X for user-defined functions' {
  local cmd='# WORKAROUND: wrap in bash -i -c because non-interactive bash behaves
# differently!
case $SH in
  *bash|*osh)
    $SH --rcfile /dev/null -i -c '\''
shopt -s extglob
fun() {
  COMPREPLY=(one two three bin)
}
compgen -X "@(two|bin)" -F fun
echo --
compgen -X "!@(two|bin)" -F fun
'\''
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 compgen -W words -X filter' {
  local cmd='# WORKAROUND: wrap in bash -i -c because non-interactive bash behaves
# differently!
case $SH in
  *bash|*osh)
      $SH --rcfile /dev/null -i -c '\''shopt -s extglob; compgen -X "@(two|bin)" -W "one two three bin"'\''
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 compgen -f -X filter -- cur' {
  local cmd='cd $TMP
touch spam.py spam.sh
compgen -f -- sp | sort
echo --
# WORKAROUND: wrap in bash -i -c because non-interactive bash behaves
# differently!
case $SH in
  *bash|*osh)
      $SH --rcfile /dev/null -i -c '\''shopt -s extglob; compgen -f -X "!*.@(py)" -- sp'\''
esac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 compgen doesn'\''t need shell quoting' {
  local cmd='# There is an obsolete comment in bash_completion that claims the opposite.
cd $TMP
touch '\''foo bar'\''
touch "foo'\''bar"
compgen -f "foo b"
compgen -f "foo'\''"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 compgen -W '\''one two three'\''' {
  local cmd='cd $REPO_ROOT
compgen -W '\''one two three'\''
echo --
compgen -W '\''v1 v2 three'\'' -A directory v
echo --
compgen -A directory -W '\''v1 v2 three'\'' v  # order doesn'\''t matter'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 compgen -W evaluates code in ()' {
  local cmd='IFS='\'':%'\''
compgen -W '\''$(echo "spam:eggs%ham cheese")'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 compgen -W uses IFS, and delimiters are escaped with ' {
  local cmd='IFS='\'':%'\''
compgen -W '\''spam:eggs%ham cheese\:colon'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 Parse errors for compgen -W and complete -W' {
  local cmd='# bash doesn'\''t detect as many errors because it lacks static parsing.
compgen -W '\''${'\''
echo status=$?
complete -W '\''${'\'' foo
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 Runtime errors for compgen -W' {
  local cmd='compgen -W '\''foo $(( 1 / 0 )) bar'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 Runtime errors for compgen -F func' {
  local cmd='_foo() {
  COMPREPLY=( foo bar )
  COMPREPLY+=( $(( 1 / 0 )) )  # FATAL, but we still have candidates
}
compgen -F _foo foo
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '046 compgen -W '\'''\'' cmd is not a usage error' {
  local cmd='# Bug fix due to '\'''\'' being falsey in Python
compgen -W '\'''\'' -- foo
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '047 compgen -A builtin' {
  local cmd='compgen -A builtin g'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 complete -C vs. compgen -C' {
  local cmd='f() { echo foo; echo bar; }

# Bash prints warnings: -C option may not work as you expect
#                       -F option may not work as you expect
#
# https://unix.stackexchange.com/questions/117987/compgen-warning-c-option-not-working-as-i-expected
#
# compexport fixes this problem, because it invokves ShellFuncAction, whcih
# sets COMP_ARGV, COMP_WORDS, etc.
#
# Should we print a warning?

compgen -C f b
echo compgen=$?

complete -C f b
echo complete=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '049 compadjust with empty COMP_ARGV' {
  local cmd='case $SH in bash) exit ;; esac

COMP_ARGV=()
compadjust words
argv.py "${words[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '050 compadjust with sparse COMP_ARGV' {
  local cmd='case $SH in bash) exit ;; esac

COMP_ARGV=({0..9})
unset -v '\''COMP_ARGV['\''{1,3,4,6,7,8}'\'']'\''
compadjust words
argv.py "${words[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '051 compgen -F with scalar COMPREPLY' {
  local cmd='_comp_cmd_test() {
  unset -v COMPREPLY
  COMPREPLY=hello
}
compgen -F _comp_cmd_test'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

