#!/usr/bin/env bats
# Generated from oils-for-unix spec/glob.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 glob double quote escape' {
  local cmd='echo "*.sh"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 glob single quote escape' {
  local cmd='echo "*.sh"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 glob backslash escape' {
  local cmd='echo \*.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 1 char glob' {
  local cmd='cd $REPO_ROOT
echo [b]in'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 0 char glob -- does NOT work' {
  local cmd='echo []bin'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 looks like glob at the start, but isn'\''t' {
  local cmd='echo [bin'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 looks like glob plus negation at the start, but isn'\''t' {
  local cmd='echo [!bin'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 glob can expand to command and arg' {
  local cmd='cd $REPO_ROOT
spec/testdata/echo.s[hz]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 glob after var expansion' {
  local cmd='touch _tmp/a.A _tmp/aa.A _tmp/b.B
f="_tmp/*.A"
g="$f _tmp/*.B"
echo $g'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 quoted var expansion with glob meta characters' {
  local cmd='touch _tmp/a.A _tmp/aa.A _tmp/b.B
f="_tmp/*.A"
echo "[ $f ]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 glob after @ expansion' {
  local cmd='fun() {
  echo "$@"
}
fun '\''_tmp/*.B'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 glob after @ expansion' {
  local cmd='touch _tmp/b.B
fun() {
  echo $@
}
fun '\''_tmp/*.B'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 no glob after ~ expansion' {
  local cmd='HOME=*
echo ~/*.py'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 store literal globs in array then expand' {
  local cmd='touch _tmp/a.A _tmp/aa.A _tmp/b.B
g=("_tmp/*.A" "_tmp/*.B")
echo ${g[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 glob inside array' {
  local cmd='touch _tmp/a.A _tmp/aa.A _tmp/b.B
g=(_tmp/*.A _tmp/*.B)
echo "${g[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 glob with escaped - in char class' {
  local cmd='touch _tmp/foo.-
touch _tmp/c.C
echo _tmp/*.[C-D] _tmp/*.[C\-D]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 glob with char class expression' {
  local cmd='# note: mksh doesn'\''t support [[:punct:]] ?
touch _tmp/e.E _tmp/foo.-
echo _tmp/*.[[:punct:]E]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 glob double quotes' {
  local cmd='# note: mksh doesn'\''t support [[:punct:]] ?
touch _tmp/\"quoted.py\"
echo _tmp/\"*.py\"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 glob escaped' {
  local cmd='# - mksh doesn'\''t support [[:punct:]] ?
# - python shell fails because \[ not supported!
touch _tmp/\[abc\] _tmp/\?
echo _tmp/\[???\] _tmp/\?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 : escaped' {
  local cmd='touch _tmp/foo.-
echo _tmp/*.[[:punct:]] _tmp/*.[[:punct\:]]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Glob after var manipulation' {
  local cmd='touch _tmp/foo.zzz _tmp/bar.zzz
g='\''_tmp/*.zzzZ'\''
echo $g ${g%Z}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Glob after part joining' {
  local cmd='touch _tmp/foo.yyy _tmp/bar.yyy
g='\''_tmp/*.yy'\''
echo $g ${g}y'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 Glob flags on file system' {
  local cmd='touch _tmp/-n _tmp/zzzzz
cd _tmp
echo -* hello zzzz?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 set -o noglob' {
  local cmd='cd $REPO_ROOT
touch _tmp/spec-tmp/a.zz _tmp/spec-tmp/b.zz
echo _tmp/spec-tmp/*.zz
set -o noglob
echo _tmp/spec-tmp/*.zz'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 set -o noglob (bug #698)' {
  local cmd='var='\''\z'\''
set -f
echo $var'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Splitting/Globbing doesn'\''t happen on local assignment' {
  local cmd='cd $REPO_ROOT

f() {
  # Dash splits words and globs before handing it to the '\''local'\'' builtin.  But
  # ash doesn'\''t!
  local foo=$1
  echo "$foo"
}
f '\''void *'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Glob of unescaped [[] and []]' {
  local cmd='touch $TMP/[ $TMP/]
cd $TMP
echo [\[z] [\]z]  # the right way to do it
echo [[z] []z]    # also accepted'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Glob of negated unescaped [[] and []]' {
  local cmd='# osh does this "correctly" because it defers to libc!
touch $TMP/_G
cd $TMP
echo _[^\[z] _[^\]z]  # the right way to do it
echo _[^[z] _[^]z]    # also accepted'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 PatSub of unescaped [[] and []]' {
  local cmd='x='\''[foo]'\''
echo ${x//[\[z]/<}  # the right way to do it
echo ${x//[\]z]/>}
echo ${x//[[z]/<}  # also accepted
echo ${x//[]z]/>}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 PatSub of negated unescaped [[] and []]' {
  local cmd='x='\''[foo]'\''
echo ${x//[^\[z]/<}  # the right way to do it
echo ${x//[^\]z]/>}
echo ${x//[^[z]/<}  # also accepted
#echo ${x//[^]z]/>}  # only busybox ash interprets as ^\]'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 Glob unicode char' {
  local cmd='touch $TMP/__a__
touch $TMP/__μ__
cd $TMP

echo __?__'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Glob ordering respects LC_COLLATE (zsh respects this too)' {
  local cmd='# test/spec-common.sh sets LC_ALL=C.UTF_8
unset LC_ALL

touch hello hello.py hello_preamble.sh hello-test.sh
echo h*

# bash - hello_preamble.h comes first
# But ord('\''_'\'') == 95 
#     ord('\''-'\'') == 45

# https://serverfault.com/questions/122737/in-bash-are-wildcard-expansions-guaranteed-to-be-in-order

#LC_COLLATE=C.UTF-8
LC_COLLATE=en_US.UTF-8  # en_US is necessary
echo h*

LC_COLLATE=en_US.UTF-8 $SH -c '\''echo h*'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033  in unquoted substitutions does not match a backslash' {
  local cmd='mkdir x
touch \
  x/test.ifs.\\.txt \
  x/test.ifs.\'\''.txt \
  x/test.ifs.a.txt \
  x/test.ifs.\\b.txt

v="*\\*.txt"
argv.py x/$v

v="*\'\''.txt"
argv.py x/$v

v='\''*\a.txt'\''
argv.py x/$v

v='\''*\b.txt'\''
argv.py x/$v'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034  in unquoted substitutions is preserved' {
  local cmd='v='\''\*\*.txt'\''
echo $v
echo "$v"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035  in unquoted substitutions is preserved with set -o noglob' {
  local cmd='set -f
v='\''*\*.txt'\''
echo $v'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036  in unquoted substitutions is preserved without glob matching' {
  local cmd='mkdir x
touch \
  '\''x/test.ifs.\.txt'\'' \
  '\''x/test.ifs.*.txt'\''
v='\''*\*.txt'\''
argv.py x/unmatching.$v'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037  in unquoted substitutions escapes globchars' {
  local cmd='mkdir x
touch \
  '\''x/test.ifs.\.txt'\'' \
  '\''x/test.ifs.*.txt'\''

v='\''*\*.txt'\''
argv.py x/$v

v="\\" u='\''*.txt'\''
argv.py x/*$v$u

v="\\" u="*.txt"
argv.py x/*$v*.txt'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 pattern starting with . does not return . and ..' {
  local cmd='echo hi .*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 shopt -u globskipdots shows . and ..' {
  local cmd='case $SH in dash|ash|mksh) exit ;; esac

shopt -u globskipdots
echo hi .*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

