#!/usr/bin/env bats
# Generated from oils-for-unix spec/unicode.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 OSH source code doesn'\''t have to be valid Unicode (like other shells)' {
  local cmd='# Should YSH be different?  It would be nice.
# We would have to validate all Lit_Chars tokens, and the like.
#
# The logical place to put that would be in osh/word_parse.py where we read
# single and double quoted strings.  Although there might be a global lexer
# hack for Id.Lit_Chars tokens.  Would that catch here docs though?

# Test all the lexing contexts
cat >unicode.sh << '\''EOF'\''
echo μ '\''μ'\'' "μ" $'\''μ'\''
EOF

# Show that all lexer modes recognize unicode sequences
#
# Oh I guess we need to check here docs too?

#$SH -n unicode.sh

$SH unicode.sh

# Trim off the first byte of mu
sed '\''s/\xce//g'\'' unicode.sh > not-unicode.sh

echo --
$SH not-unicode.sh | od -A n -t x1'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Unicode escapes u03bc U000003bc in '\'''\'', echo -e, printf' {
  local cmd='echo $'\''\u03bc \U000003bc'\''

echo -e '\''\u03bc \U000003bc'\''

printf '\''\u03bc \U000003bc\n'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Max code point U+10ffff can escaped with '\'''\''  printf  echo -e' {
  local cmd='py-repr() {
  python2 -c '\''import sys; print repr(sys.argv[1])'\''  "$@"
}

py-repr $'\''\U0010ffff'\''
py-repr $(echo -e '\''\U0010ffff'\'')
py-repr $(printf '\''\U0010ffff'\'')'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 '\'''\'' does NOT check that 0x110000 is too big at parse time' {
  local cmd='py-repr() {
  python2 -c '\''import sys; print repr(sys.argv[1])'\''  "$@"
}

py-repr $'\''\U00110000'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 '\'''\'' does not check for surrogate range at parse time' {
  local cmd='py-repr() {
  python2 -c '\''import sys; print repr(sys.argv[1])'\''  "$@"
}

py-repr $'\''\udc00'\''

py-repr $'\''\U0000dc00'\'' '
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 printf / echo -e do NOT check max code point at runtime' {
  local cmd='py-repr() {
  python2 -c '\''import sys; print repr(sys.argv[1])'\''  "$@"
}

e="$(echo -e '\''\U00110000'\'')"
echo status=$?
py-repr "$e"

p="$(printf '\''\U00110000'\'')"
echo status=$?
py-repr "$p"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 printf / echo -e do NOT check surrogates at runtime' {
  local cmd='py-repr() {
  python2 -c '\''import sys; print repr(sys.argv[1])'\''  "$@"
}

e="$(echo -e '\''\udc00'\'')"
echo status=$?
py-repr "$e"

e="$(echo -e '\''\U0000dc00'\'')"
echo status=$?
py-repr "$e"

p="$(printf '\''\udc00'\'')"
echo status=$?
py-repr "$p"

p="$(printf '\''\U0000dc00'\'')"
echo status=$?
py-repr "$p"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

