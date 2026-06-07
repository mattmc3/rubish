#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-printf.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 printf with no args' {
  local cmd='printf'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 printf -v %s' {
  local cmd='var=foo
printf -v $var %s '\''hello there'\''
argv.py "$foo"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 printf -v %q' {
  local cmd='val='\''"quoted" with spaces and \'\''

# quote '\''val'\'' and store it in foo
printf -v foo %q "$val"
# then round trip back to eval
eval "bar=$foo"

# debugging:
#echo foo="$foo"
#echo bar="$bar"
#echo val="$val"

test "$bar" = "$val" && echo OK'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 printf -v a[1]' {
  local cmd='a=(a b c)
printf -v '\''a[1]'\'' %s '\''foo'\''
echo status=$?
argv.py "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 printf -v syntax error' {
  local cmd='printf -v '\''a['\'' %s '\''foo'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 dynamic declare instead of %s' {
  local cmd='var=foo
declare $var='\''hello there'\''
argv.py "$foo"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 dynamic declare instead of %q' {
  local cmd='var=foo
val='\''"quoted" with spaces and \'\''
# I think this is bash 4.4 only.
declare $var="${val@Q}"
echo "$foo"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 printf -v dynamic scope' {
  local cmd='# OK so printf is like assigning to a var.
# printf -v foo %q "$bar" is like
# foo=${bar@Q}
dollar='\''dollar'\''
f() {
  local mylocal=foo
  printf -v dollar %q '\''$'\''  # assign foo to a quoted dollar
  printf -v mylocal %q '\''mylocal'\''
  echo dollar=$dollar
  echo mylocal=$mylocal
}
echo dollar=$dollar
echo --
f
echo --
echo dollar=$dollar
echo mylocal=$mylocal'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 printf with too few arguments' {
  local cmd='printf -- '\''-%s-%s-%s-\n'\'' '\''a b'\'' '\''x y'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 printf with too many arguments' {
  local cmd='printf -- '\''-%s-%s-\n'\'' a b c d e'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 printf width strings' {
  local cmd='printf '\''[%5s]\n'\'' abc
printf '\''[%-5s]\n'\'' abc'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 printf integer' {
  local cmd='printf '\''%d\n'\'' 42
printf '\''%i\n'\'' 42  # synonym
printf '\''%d\n'\'' \'\''a # if first character is a quote, use character code
printf '\''%d\n'\'' \"a # double quotes work too
printf '\''[%5d]\n'\'' 42
printf '\''[%-5d]\n'\'' 42
printf '\''[%05d]\n'\'' 42
#printf '\''[%-05d]\n'\'' 42  # the leading 0 is meaningless
#[42   ]'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 printf %6.4d -- precision does padding for integers' {
  local cmd='printf '\''[%6.4d]\n'\'' 42
printf '\''[%.4d]\n'\'' 42
printf '\''[%6.d]\n'\'' 42
echo --
printf '\''[%6.4d]\n'\'' -42
printf '\''[%.4d]\n'\'' -42
printf '\''[%6.d]\n'\'' -42'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 printf %6.4x X o' {
  local cmd='printf '\''[%6.4x]\n'\'' 42
printf '\''[%.4x]\n'\'' 42
printf '\''[%6.x]\n'\'' 42
echo --
printf '\''[%6.4X]\n'\'' 42
printf '\''[%.4X]\n'\'' 42
printf '\''[%6.X]\n'\'' 42
echo --
printf '\''[%6.4o]\n'\'' 42
printf '\''[%.4o]\n'\'' 42
printf '\''[%6.o]\n'\'' 42'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 %06d zero padding vs. %6.6d' {
  local cmd='printf '\''[%06d]\n'\'' 42
printf '\''[%06d]\n'\'' -42  # 6 TOTAL
echo --
printf '\''[%6.6d]\n'\'' 42
printf '\''[%6.6d]\n'\'' -42  # 6 + 1 for the - sign!!!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 %06x %06X %06o' {
  local cmd='printf '\''[%06x]\n'\'' 42
printf '\''[%06X]\n'\'' 42
printf '\''[%06o]\n'\'' 42'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 %06s is no-op' {
  local cmd='printf '\''(%6s)\n'\'' 42
printf '\''(%6s)\n'\'' -42
printf '\''(%06s)\n'\'' 42
printf '\''(%06s)\n'\'' -42
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 printf %6.4s does both truncation and padding' {
  local cmd='printf '\''[%6s]\n'\'' foo
printf '\''[%6.4s]\n'\'' foo
printf '\''[%-6.4s]\n'\'' foo
printf '\''[%6s]\n'\'' spam-eggs
printf '\''[%6.4s]\n'\'' spam-eggs
printf '\''[%-6.4s]\n'\'' spam-eggs'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 printf %6.0s and %0.0s' {
  local cmd='printf '\''[%6.0s]\n'\'' foo
printf '\''[%0.0s]\n'\'' foo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 printf %6.s and %0.s' {
  local cmd='printf '\''[%6.s]\n'\'' foo
printf '\''[%0.s]\n'\'' foo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 printf %*.*s (width/precision from args)' {
  local cmd='printf '\''[%*s]\n'\'' 9 hello
printf '\''[%.*s]\n'\'' 3 hello
printf '\''[%*.3s]\n'\'' 9 hello
printf '\''[%9.*s]\n'\'' 3 hello
printf '\''[%*.*s]\n'\'' 9 3 hello'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 unsigned / octal / hex' {
  local cmd='printf '\''[%u]\n'\'' 42
printf '\''[%o]\n'\'' 42
printf '\''[%x]\n'\'' 42
printf '\''[%X]\n'\'' 42
echo

printf '\''[%X]\n'\'' \'\''a  # if first character is a quote, use character code
printf '\''[%X]\n'\'' \'\''ab # extra chars ignored'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 unsigned / octal / hex big' {
  local cmd='for big in $(( 1 << 32 )) $(( (1 << 63) - 1 )); do
  printf '\''[%u]\n'\'' $big
  printf '\''[%o]\n'\'' $big
  printf '\''[%x]\n'\'' $big
  printf '\''[%X]\n'\'' $big
  echo
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 empty string (osh is more strict)' {
  local cmd='printf '\''%d\n'\'' '\'''\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 No char after '\'' => zero code point' {
  local cmd='# most shells use 0 here
printf '\''%d\n'\'' \'\''
printf '\''%d\n'\'' \"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 Unicode char with '\''' {
  local cmd='# the mu character is U+03BC

printf '\''%x\n'\'' \'\''μ
printf '\''%u\n'\'' \'\''μ
printf '\''%o\n'\'' \'\''μ
echo

u3=三
# u4=😘

printf '\''%x\n'\'' \'\''$u3
printf '\''%u\n'\'' \'\''$u3
printf '\''%o\n'\'' \'\''$u3
echo

# mksh DOES respect unicode on the new Debian bookworm.
# but even building the SAME SOURCE from scratch, somehow it doesn'\''t on Ubuntu 8.
# TBH I should probably just upgrade the mksh version.
#
# $ ./mksh -c '\''printf "%u\n" \"$1'\'' dummy $'\''\u03bc'\''
# printf: warning: : character(s) following character constant have been ignored
# 206
# 
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ cat /etc/os-release
# NAME="Ubuntu"
# VERSION="18.04.5 LTS (Bionic Beaver)"
# ID=ubuntu
# ID_LIKE=debian
# PRETTY_NAME="Ubuntu 18.04.5 LTS"
# VERSION_ID="18.04"
# HOME_URL="https://www.ubuntu.com/"
# SUPPORT_URL="https://help.ubuntu.com/"
# BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
# PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
# VERSION_CODENAME=bionic
# UBUNTU_CODENAME=bionic
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ env|egrep '\''LC|LANG'\''
# LANG=en_US.UTF-8
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ LC_CTYPE=C.UTF-8 ./mksh -c '\''printf "%u\n" \"$1'\'' dummy $'\''\u03bc'\''
# printf: warning: : character(s) following character constant have been ignored
# 206
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ LANG=C.UTF-8 ./mksh -c '\''printf "%u\n" \"$1'\'' dummy $'\''\u03bc'\''
# printf: warning: : character(s) following character constant have been ignored
# 206
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ LC_ALL=C.UTF-8 ./mksh -c '\''printf "%u\n" \"$1'\'' dummy $'\''\u03bc'\''
# printf: warning: : character(s) following character constant have been ignored
# 206
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ LC_ALL=en_US.UTF-8 ./mksh -c '\''printf "%u\n" \"$1'\'' dummy $'\''\u03bc'\''
# printf: warning: : character(s) following character constant have been ignored
# 206
# andy@lenny:~/wedge/oils-for-unix.org/pkg/mksh/R52c$ LC_ALL=en_US.utf-8 ./mksh -c '\''printf "%u\n" \"$1'\'' dummy $'\''\u03bc'\''
# printf: warning: : character(s) following character constant have been ignored
# 206'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 Invalid UTF-8' {
  local cmd='echo bytes1
not_utf8=$(python2 -c '\''print("\xce\xce")'\'')

printf '\''%x\n'\'' \'\''$not_utf8
printf '\''%u\n'\'' \'\''$not_utf8
printf '\''%o\n'\'' \'\''$not_utf8
echo

echo bytes2
not_utf8=$(python2 -c '\''print("\xbc\xbc")'\'')
printf '\''%x\n'\'' \'\''$not_utf8
printf '\''%u\n'\'' \'\''$not_utf8
printf '\''%o\n'\'' \'\''$not_utf8
echo

# Copied from data_lang/utf8_test.cc

echo overlong2
overlong2=$(python2 -c '\''print("\xC1\x81")'\'')
printf '\''%x\n'\'' \'\''$overlong2
printf '\''%u\n'\'' \'\''$overlong2
printf '\''%o\n'\'' \'\''$overlong2
echo

echo overlong3
overlong3=$(python2 -c '\''print("\xE0\x81\x81")'\'')
printf '\''%x\n'\'' \'\''$overlong3
printf '\''%u\n'\'' \'\''$overlong3
printf '\''%o\n'\'' \'\''$overlong3
echo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 Too large' {
  local cmd='echo too large
too_large=$(python2 -c '\''print("\xF4\x91\x84\x91")'\'')
printf '\''%x\n'\'' \'\''$too_large
printf '\''%u\n'\'' \'\''$too_large
printf '\''%o\n'\'' \'\''$too_large
echo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 negative numbers with unsigned / octal / hex' {
  local cmd='printf '\''[%u]\n'\'' -42
echo status=$?

printf '\''[%o]\n'\'' -42
echo status=$?

printf '\''[%x]\n'\'' -42
echo status=$?

printf '\''[%X]\n'\'' -42
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 printf floating point (not required, but they all implement it)' {
  local cmd='printf '\''[%f]\n'\'' 3.14159
printf '\''[%.2f]\n'\'' 3.14159
printf '\''[%8.2f]\n'\'' 3.14159
printf '\''[%-8.2f]\n'\'' 3.14159
printf '\''[%-f]\n'\'' 3.14159
printf '\''[%-f]\n'\'' 3.14'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 printf floating point with - and 0' {
  local cmd='printf '\''[%8.4f]\n'\'' 3.14
printf '\''[%08.4f]\n'\'' 3.14
printf '\''[%8.04f]\n'\'' 3.14  # meaning less 0
printf '\''[%08.04f]\n'\'' 3.14
echo ---
# these all boil down to the same thing.  The -, 8, and 4 are respected, but
# none of the 0 are.
printf '\''[%-8.4f]\n'\'' 3.14
printf '\''[%-08.4f]\n'\'' 3.14
printf '\''[%-8.04f]\n'\'' 3.14
printf '\''[%-08.04f]\n'\'' 3.14'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 printf eE fF gG' {
  local cmd='printf '\''[%e]\n'\'' 3.14
printf '\''[%E]\n'\'' 3.14
printf '\''[%f]\n'\'' 3.14
# bash is the only one that implements %F?  Is it a synonym?
#printf '\''[%F]\n'\'' 3.14
printf '\''[%g]\n'\'' 3.14
printf '\''[%G]\n'\'' 3.14'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 printf backslash escapes' {
  local cmd='argv.py "$(printf '\''a\tb'\'')"
argv.py "$(printf '\''\xE2\x98\xA0'\'')"
argv.py "$(printf '\''\044e'\'')"
argv.py "$(printf '\''\0377'\'')"  # out of range'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 printf octal backslash escapes' {
  local cmd='argv.py "$(printf '\''\0377'\'')"
argv.py "$(printf '\''\377'\'')"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 printf unicode backslash escapes' {
  local cmd='argv.py "$(printf '\''\u2620'\'')"
argv.py "$(printf '\''\U0000065f'\'')"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 printf invalid backslash escape (is ignored)' {
  local cmd='printf '\''[\Z]\n'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 printf % escapes' {
  local cmd='printf '\''[%%]\n'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '038 printf %c ASCII' {
  local cmd='printf '\''%c\n'\'' a
printf '\''%c\n'\'' ABC
printf '\''%cZ\n'\'' ABC'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '039 printf %c unicode - prints the first BYTE of a string - it does not respect UTF-8' {
  local cmd='# TODO: in YSH, this should be deprecated

show_bytes() {
  od -A n -t x1
}
twomu=$'\''\u03bc\u03bc'\''
printf '\''[%s]\n'\'' "$twomu"

# Hm this cuts off a UTF-8 character?
printf '\''%c'\'' "$twomu" | show_bytes'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '040 printf invalid format' {
  local cmd='printf '\''%z'\'' 42
echo status=$?
printf '\''%-z'\'' 42
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '041 printf %q' {
  local cmd='x='\''a b'\''
printf '\''[%q]\n'\'' "$x"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '042 printf %6q (width)' {
  local cmd='# NOTE: coreutils /usr/bin/printf does NOT implement this %6q !!!
x='\''a b'\''
printf '\''[%6q]\n'\'' "$x"
printf '\''[%1q]\n'\'' "$x"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '043 printf negative numbers' {
  local cmd='printf '\''[%d] '\'' -42
echo status=$?
printf '\''[%i] '\'' -42
echo status=$?

# extra LEADING space too
printf '\''[%d] '\'' '\'' -42'\''
echo status=$?
printf '\''[%i] '\'' '\'' -42'\''
echo status=$?

# extra TRAILING space too
printf '\''[%d] '\'' '\'' -42 '\''
echo status=$?
printf '\''[%i] '\'' '\'' -42 '\''
echo status=$?

# extra TRAILING chars
printf '\''[%d] '\'' '\'' -42z'\''
echo status=$?
printf '\''[%i] '\'' '\'' -42z'\''
echo status=$?

exit 0  # ok'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '044 printf + and space flags' {
  local cmd='# I didn'\''t know these existed -- I only knew about - and 0 !
printf '\''[%+d]\n'\'' 42
printf '\''[%+d]\n'\'' -42
printf '\''[% d]\n'\'' 42
printf '\''[% d]\n'\'' -42'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '045 printf # flag' {
  local cmd='# I didn'\''t know these existed -- I only knew about - and 0 !
# Note: '\''#'\'' flag for integers outputs a prefix ONLY WHEN the value is non-zero
printf '\''[%#o][%#o]\n'\'' 0 42
printf '\''[%#x][%#x]\n'\'' 0 42
printf '\''[%#X][%#X]\n'\'' 0 42
echo ---
# Note: '\''#'\'' flag for %f, %g always outputs the decimal point.
printf '\''[%.0f][%#.0f]\n'\'' 3 3
# Note: In addition, '\''#'\'' flag for %g does not omit zeroes in fraction
printf '\''[%g][%#g]\n'\'' 3 3'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '046 Runtime error for invalid integer' {
  local cmd='x=3abc
printf '\''%d\n'\'' $x
echo status=$?
printf '\''%d\n'\'' xyz
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '047 %(strftime format)T' {
  local cmd='# The result depends on timezone
export TZ=Asia/Tokyo
printf '\''%(%Y-%m-%d)T\n'\'' 1557978599
export TZ=US/Eastern
printf '\''%(%Y-%m-%d)T\n'\'' 1557978599
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '048 %(strftime format)T doesn'\''t respect TZ if not exported' {
  local cmd='# note: this test leaks!  It assumes that /etc/localtime is NOT Portugal.

TZ=Portugal  # NOT exported
localtime=$(printf '\''%(%Y-%m-%d %H:%M:%S)T\n'\'' 1557978599)

# TZ is respected
export TZ=Portugal
tz=$(printf '\''%(%Y-%m-%d %H:%M:%S)T\n'\'' 1557978599)

#echo $localtime
#echo $tz

if ! test "$localtime" = "$tz"; then
  echo '\''not equal'\''
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '049 %(strftime format)T TZ in environ but not in shell'\''s memory' {
  local cmd='# note: this test leaks!  It assumes that /etc/localtime is NOT Portugal.

# TZ is respected
export TZ=Portugal
tz=$(printf '\''%(%Y-%m-%d %H:%M:%S)T\n'\'' 1557978599)

unset TZ  # unset in the shell, but still in the environment

localtime=$(printf '\''%(%Y-%m-%d %H:%M:%S)T\n'\'' 1557978599)

if ! test "$localtime" = "$tz"; then
  echo '\''not equal'\''
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '050 %10.5(strftime format)T' {
  local cmd='# The result depends on timezone
export TZ=Asia/Tokyo
printf '\''[%10.5(%Y-%m-%d)T]\n'\'' 1557978599
export TZ=US/Eastern
printf '\''[%10.5(%Y-%m-%d)T]\n'\'' 1557978599
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '051 Regression for '\''printf x y'\''' {
  local cmd='printf x y
printf '\''%s\n'\'' z'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '052 bash truncates long strftime string at 128' {
  local cmd='strftime-format() {
  local n=$1

  # Prints increasingly long format strings:
  # %(%Y)T %(%Y)T %(%Y%Y)T ...

  echo -n '\''%('\''
  for i in $(seq $n); do
    echo -n '\''%Y'\''
  done
  echo -n '\'')T'\''
}

printf $(strftime-format 1) | wc --bytes
printf $(strftime-format 10) | wc --bytes
printf $(strftime-format 30) | wc --bytes
printf $(strftime-format 31) | wc --bytes
printf $(strftime-format 32) | wc --bytes

'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '053 printf positive integer overflow' {
  local cmd='# %i seems like a synonym for %d

for fmt in '\''%u\n'\'' '\''%d\n'\''; do
  # bash considers this in range for %u
  # same with mksh
  # zsh cuts everything off after 19 digits
  # ash truncates everything
  printf "$fmt" '\''18446744073709551615'\''
  echo status=$?
  printf "$fmt" '\''18446744073709551616'\''
  echo status=$?
  echo
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '054 printf negative integer overflow' {
  local cmd='# %i seems like a synonym for %d

for fmt in '\''%u\n'\'' '\''%d\n'\''; do

  printf "$fmt" '\''-18446744073709551615'\''
  echo status=$?
  printf "$fmt" '\''-18446744073709551616'\''
  echo status=$?
  echo
done'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '055 printf %b does backslash escaping' {
  local cmd='printf '\''[%s]\n'\'' '\''\044'\''  # escapes not evaluated
printf '\''[%b]\n'\'' '\''\044'\''  # YES, escapes evaluated
echo

printf '\''[%s]\n'\'' '\''\x7e'\''  # escapes not evaluated
printf '\''[%b]\n'\'' '\''\x7e'\''  # YES, escapes evaluated
echo

# not a valid escape
printf '\''[%s]\n'\'' '\''\A'\''
printf '\''[%b]\n'\'' '\''\A'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '056 printf %b unicode escapes' {
  local cmd='printf '\''[%s]\n'\'' '\''\u03bc'\''  # escapes not evaluated
printf '\''[%b]\n'\'' '\''\u03bc'\''  # YES, escapes evaluated'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '057 printf %b respects c early return' {
  local cmd='printf '\''[%b]\n'\'' '\''ab\ncd\cxy'\''
echo $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '058 printf %b supports octal escapes, both 141 and 0141' {
  local cmd='printf '\''three %b\n'\'' '\''\141'\''  # di
printf '\''four  %b\n'\'' '\''\0141'\''
echo

# trailing 9
printf '\''%b\n'\'' '\''\1419'\''
printf '\''%b\n'\'' '\''\01419'\''

# Notes:
#
# - echo -e: 
#   - NO  3 digit octal  - echo -e '\''\141'\'' does not work
#   - YES 4 digit octal
# - printf %b
#   - YES 3 digit octal
#   - YES 4 digit octal
# - printf string (outer)
#   - YES 3 digit octal
#   - NO  4 digit octal
# - $'\'''\'' and $PS1
#   - YES 3 digit octal
#   - NO  4 digit octal'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '059 printf %b with truncated octal escapes' {
  local cmd='# 8 is not a valid octal digit

printf '\''%b\n'\'' '\''\558'\''
printf '\''%b\n'\'' '\''\0558'\''
echo

show_bytes() {
  od -A n -t x1
}
printf '\''%b'\'' '\''\7'\'' | show_bytes
printf '\''%b'\'' '\''\07'\'' | show_bytes
printf '\''%b'\'' '\''\007'\'' | show_bytes
printf '\''%b'\'' '\''\0007'\'' | show_bytes'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '060 printf %d %X support hex 0x5 and octal 055' {
  local cmd='echo hex
printf '\''%d\n'\'' 0x55
printf '\''%X\n'\'' 0x55

echo hex CAPS
printf '\''%d\n'\'' 0X55
printf '\''%X\n'\'' 0X55

echo octal 3
printf '\''%d\n'\'' 055
printf '\''%X\n'\'' 055

echo octal 4
printf '\''%d\n'\'' 0055
printf '\''%X\n'\'' 0055

echo octal 5
printf '\''%d\n'\'' 00055
printf '\''%X\n'\'' 00055'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '061 printf %d with + prefix (positive sign)' {
  local cmd='echo decimal
printf '\''%d\n'\'' +42

echo octal
printf '\''%d\n'\'' +077

echo hex lowercase
printf '\''%d\n'\'' +0xab

echo hex uppercase
printf '\''%d\n'\'' +0XAB'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '062 leading spaces are accepted in value given to %d %X, but not trailing spaces' {
  local cmd='# leading space is allowed
printf '\''%d\n'\'' '\'' -123'\''
echo status=$?
printf '\''%d\n'\'' '\'' -123 '\''
echo status=$?

echo ---

printf '\''%d\n'\'' '\'' +077'\''
echo status=$?

printf '\''%d\n'\'' '\'' +0xff'\''
echo status=$?

printf '\''%X\n'\'' '\'' +0xff'\''
echo status=$?

printf '\''%x\n'\'' '\'' +0xff'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '063 Arbitrary base 64#a is rejected (unlike in shell arithmetic)' {
  local cmd='printf '\''%d\n'\'' '\''64#a'\''
echo status=$?

# bash, dash, and mksh print 64 and return status 1
# zsh and ash print 0 and return status 1
# OSH rejects it completely (prints nothing) and returns status 1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

