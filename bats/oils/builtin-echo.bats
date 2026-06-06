#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-echo.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 echo dashes' {
  local cmd='echo -
echo --
echo ---'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 echo backslashes' {
  local cmd='echo \\
echo '\''\'\''
echo '\''\\'\''
echo "\\"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 echo -e backslashes' {
  local cmd='echo -e \\
echo -e '\''\'\''
echo -e '\''\\'\''
echo -e "\\"
echo

# backslash at end of line
echo -e '\''\
line2'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 echo builtin should disallow typed args - literal' {
  local cmd='echo (42)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 echo builtin should disallow typed args - variable' {
  local cmd='var x = 43
echo (x)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 echo -en' {
  local cmd='echo -en '\''abc\ndef\n'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 echo -ez (invalid flag)' {
  local cmd='# bash differs from the other three shells, but its behavior is possibly more
# sensible, if you'\''re going to ignore the error.  It doesn'\''t make sense for
# the '\''e'\'' to mean 2 different things simultaneously: flag and literal to be
# printed.
echo -ez '\''abc\n'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 echo -e with embedded newline' {
  local cmd='flags='\''-e'\''
case $SH in dash) flags='\'''\'' ;; esac

echo $flags '\''foo
bar'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 echo -e line continuation' {
  local cmd='flags='\''-e'\''
case $SH in dash) flags='\'''\'' ;; esac

echo $flags '\''foo\
bar'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 echo -e with C escapes' {
  local cmd='# https://www.gnu.org/software/bash/manual/bashref.html#Bourne-Shell-Builtins
# not sure why \c is like NUL?
# zsh doesn'\''t allow \E for some reason.
echo -e '\''\a\b\d\e\f'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 echo -e with whitespace C escapes' {
  local cmd='echo -e '\''\n\r\t\v'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 0' {
  local cmd='echo -e '\''ab\0cd'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 c stops processing input' {
  local cmd='flags='\''-e'\''
case $SH in dash) flags='\'''\'' ;; esac

echo $flags xy  '\''ab\cde'\''  '\''zzz'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 echo -e with hex escape' {
  local cmd='echo -e '\''abcd\x65f'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 echo -e with octal escape' {
  local cmd='flags='\''-e'\''
case $SH in dash) flags='\'''\'' ;; esac

echo $flags '\''abcd\044e'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 echo -e with 4 digit unicode escape' {
  local cmd='flags='\''-e'\''
case $SH in dash) flags='\'''\'' ;; esac

echo $flags '\''abcd\u0065f'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 echo -e with 8 digit unicode escape' {
  local cmd='flags='\''-e'\''
case $SH in dash) flags='\'''\'' ;; esac

echo $flags '\''abcd\U00000065f'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 0377 is the highest octal byte' {
  local cmd='echo -en '\''\03777'\'' | od -A n -t x1 | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 0400 is one more than the highest octal byte' {
  local cmd='# It is 256 % 256 which gets interpreted as a NUL byte.
echo -en '\''\04000'\'' | od -A n -t x1 | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 0777 is out of range' {
  local cmd='flags='\''-en'\''
case $SH in dash) flags='\''-n'\'' ;; esac

echo $flags '\''\0777'\'' | od -A n -t x1 | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 incomplete hex escape' {
  local cmd='echo -en '\''abcd\x6'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 x' {
  local cmd='# I consider mksh and zsh a bug because \x is not an escape
echo -e '\''\x'\'' '\''\xg'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 incomplete octal escape' {
  local cmd='flags='\''-en'\''
case $SH in dash) flags='\''-n'\'' ;; esac

echo $flags '\''abcd\04'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 incomplete unicode escape' {
  local cmd='echo -en '\''abcd\u006'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 u6' {
  local cmd='flags='\''-en'\''
case $SH in dash) flags='\''-n'\'' ;; esac

echo $flags '\''\u6'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 0 1 8' {
  local cmd='# \0 is special, but \1 isn'\''t in bash
# \1 is special in dash!  geez
flags='\''-en'\''
case $SH in dash) flags='\''-n'\'' ;; esac

echo $flags '\''\0'\'' '\''\1'\'' '\''\8'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 echo to redirected directory is an error' {
  local cmd='mkdir -p dir

echo foo > ./dir
echo status=$?
printf foo > ./dir
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

