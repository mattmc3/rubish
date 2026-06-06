#!/usr/bin/env bats
# Generated from oils-for-unix spec/quote.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Unquoted words' {
  local cmd='echo unquoted    words'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Single-quoted' {
  local cmd='echo '\''single   quoted'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Two single-quoted parts' {
  local cmd='echo '\''two single-quoted pa'\'''\''rts in one token'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Unquoted and single quoted' {
  local cmd='echo unquoted'\'' and single-quoted'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 newline inside single-quoted string' {
  local cmd='echo '\''newline
inside single-quoted string'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Double-quoted' {
  local cmd='echo "double   quoted"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Mix of quotes in one word' {
  local cmd='echo unquoted'\''  single-quoted'\''"  double-quoted  "unquoted'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Var substitution' {
  local cmd='FOO=bar
echo "==$FOO=="'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Var substitution with braces' {
  local cmd='FOO=bar
echo foo${FOO}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Var substitution with braces, quoted' {
  local cmd='FOO=bar
echo "foo${FOO}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Var length' {
  local cmd='FOO=bar
echo "foo${#FOO}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Storing backslashes and then echoing them' {
  local cmd='# This is a bug fix; it used to cause problems with unescaping.
one='\''\'\''
two='\''\\'\''
echo $one $two
echo "$one" "$two"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Backslash escapes' {
  local cmd='echo \$ \| \a \b \c \d \\'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Backslash escapes inside double quoted string' {
  local cmd='echo "\$ \\ \\ \p \q"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 C-style backslash escapes inside double quoted string' {
  local cmd='# mksh and dash implement POSIX incompatible extensions.  $ ` " \ <newline>
# are the only special ones
echo "\a \b"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Literal ' {
  local cmd='echo $'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Quoted Literal ' {
  local cmd='echo $ "$" $'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Line continuation' {
  local cmd='echo foo\
$'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Line continuation inside double quotes' {
  local cmd='echo "foo\
$"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 ? split over multiple lines' {
  local cmd='# Same with $$, etc.  OSH won'\''t do this because $? is a single token.
echo $\
?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Semicolon' {
  local cmd='echo separated; echo by semi-colon'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 No tab escapes within single quotes' {
  local cmd='# dash and mksh allow this, which is a BUG.
# POSIX says: "Enclosing characters in single-quotes ( '\'''\'' ) shall preserve the
# literal value of each character within the single-quotes. A single-quote
# cannot occur within single-quotes"
echo '\''a\tb'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 '\'''\''' {
  local cmd='echo $'\''foo'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 '\'''\'' with quotes' {
  local cmd='echo $'\''single \'\'' double \"'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 '\'''\'' with newlines' {
  local cmd='echo $'\''col1\ncol2\ncol3'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 '\'''\'' octal escapes don'\''t have leading 0' {
  local cmd='# echo -e syntax is echo -e \0377
echo -n $'\''\001'\'' $'\''\377'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 '\'''\'' octal escapes with fewer than 3 chars' {
  local cmd='echo $'\''\1 \11 \11 \111'\'' | od -A n -c | sed '\''s/ \+/ /g'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 OSH allows invalid backslashes' {
  local cmd='case $SH in dash|mksh) exit ;; esac

w=$'\''\uZ'\''
x=$'\''\u{03bc'\''
y=$'\''\z'\''
echo $w $x $y'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 YSH allows unquoted foo bar too' {
  local cmd='shopt -s ysh:all
touch foo\ bar
ls foo\ bar'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030  is a synonym for ' {
  local cmd='echo $"foo"
x=x
echo $"foo $x"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 printf supports tabs' {
  local cmd='# This accepts \t by itself, hm.
printf "c1\tc2\nc3\tc4\n"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 '\'''\'' supports cA escape for Ctrl-A - mask with 0x1f' {
  local cmd='# note: AT&T ksh supports this too

case $SH in dash|ash) exit ;; esac

show_bytes() {
  # -A n - no file offset
  od -A n -t c -t x1
}

# this isn'\''t special
# mksh doesn'\''t like it
#echo -n $'\''\c'\'' | show_bytes

echo -n $'\''\c0\c9-'\'' | show_bytes
echo

# control chars are case insensitive
echo -n $'\''\ca\cz'\'' | show_bytes
echo

echo -n $'\''\cA\cZ'\'' | show_bytes
echo

echo -n $'\''\c-\c+\c"'\'' | show_bytes'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 c'\'' is an escape, unlike bash' {
  local cmd='# mksh and ksh agree this is an esacpe

case $SH in dash|ash) exit ;; esac

show_bytes() {
  # -A n - no file offset
  od -A n -t c -t x1
}

# this isn'\''t special
# mksh doesn'\''t like it
echo -n $'\''\c'\'''\'' | show_bytes'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

