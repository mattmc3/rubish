#!/usr/bin/env bats
# Generated from oils-for-unix spec/nul-bytes.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 NUL bytes with echo -e' {
  local cmd='case $SH in dash) exit ;; esac

show_hex() { od -A n -t c -t x1; }

echo -e '\''\0-'\'' | show_hex
#echo -e '\''\x00-'\''
#echo -e '\''\000-'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 printf - literal NUL in format string' {
  local cmd='case $SH in dash|ash) return ;; esac

# Show both printable and hex
show_hex() { od -A n -t c -t x1; }

printf $'\''x\U0z'\'' | show_hex
echo ---

printf $'\''x\U00z'\'' | show_hex
echo ---

printf $'\''\U0z'\'' | show_hex'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 printf - 0 escape shows NUL byte' {
  local cmd='show_hex() { od -A n -t c -t x1; }

printf '\''\0\n'\'' | show_hex'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 printf - NUL byte in value (OSH and zsh agree)' {
  local cmd='case $SH in dash) exit ;; esac
show_hex() { od -A n -t c -t x1; }

nul=$'\''\0'\''
echo "$nul" | show_hex
printf '\''%s\n'\'' "$nul" | show_hex'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 NUL bytes with echo '\''0'\'' (OSH and zsh agree)' {
  local cmd='case $SH in dash) exit ;; esac
show_hex() { od -A n -t c -t x1; }

# OSH agrees with ZSH -- so you have the ability to print NUL bytes without
# legacy echo -e

echo $'\''\0'\'' | show_hex'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 NUL bytes and IFS splitting' {
  local cmd='case $SH in dash) exit ;; esac

argv.py $(echo -e '\''\0'\'')
argv.py "$(echo -e '\''\0'\'')"
argv.py $(echo -e '\''a\0b'\'')
argv.py "$(echo -e '\''a\0b'\'')"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 NUL bytes with test -n' {
  local cmd='case $SH in dash) exit ;; esac

# zsh is buggy here, weird
test -n $'\'''\''
echo status=$?

test -n $'\''\0'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 NUL bytes with test -f' {
  local cmd='case $SH in dash) exit ;; esac


test -f $'\''\0'\''
echo status=$?

touch foo
test -f $'\''foo\0'\''
echo status=$?

test -f $'\''foo\0bar'\''
echo status=$?

test -f $'\''foobar'\''
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 NUL bytes with {#s} (OSH and zsh agree)' {
  local cmd='case $SH in dash) exit ;; esac

empty=$'\'''\''
nul=$'\''\0'\''

echo empty=${#empty}
echo nul=${#nul}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Compare x00 byte versus x01 byte - command sub' {
  local cmd='# https://stackoverflow.com/questions/32722007/is-skipping-ignoring-nul-bytes-on-process-substitution-standardized
# bash contains a warning!

show_bytes() {
  echo -n "$1" | od -A n -t x1
}

s=$(printf '\''.\001.'\'')
echo len=${#s}
show_bytes "$s"

s=$(printf '\''.\000.'\'')
echo len=${#s}
show_bytes "$s"

s=$(printf '\''\000'\'')
echo len=${#s} 
show_bytes "$s"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Compare x00 byte versus x01 byte - read builtin' {
  local cmd='# Hm same odd behavior

show_string() {
  read s
  echo len=${#s}
  echo -n "$s" | od -A n -t x1
}

printf '\''.\001.'\'' | show_string

printf '\''.\000.'\'' | show_string

printf '\''\000'\'' | show_string'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Compare x00 byte versus x01 byte - read -n' {
  local cmd='case $SH in dash) exit ;; esac

show_string() {
  read -n 3 s
  echo len=${#s}
  echo -n "$s" | od -A n -t x1
}


printf '\''.\001.'\'' | show_string

printf '\''.\000.'\'' | show_string

printf '\''\000'\'' | show_string'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Compare x00 byte versus x01 byte - mapfile builtin' {
  local cmd='case $SH in dash|mksh|zsh|ash) exit ;; esac

{ 
  printf '\''.\000.\n'\''
  printf '\''.\000.\n'\''
} |
{ mapfile LINES
  echo len=${#LINES[@]}
  for line in ${LINES[@]}; do
    echo -n "$line" | od -A n -t x1
  done
}

# bash is INCONSISTENT:
# - it TRUNCATES at \0, with '\''mapfile'\''
# - rather than just IGNORING \0, with '\''read'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Strip ops # ## % %% with NUL bytes' {
  local cmd='show_bytes() {
  echo -n "$1" | od -A n -t x1
}

s=$(printf '\''\000.\000'\'')
echo len=${#s}
show_bytes "$s"

echo ---

t=${s#?}
echo len=${#t}
show_bytes "$t"

t=${s##?}
echo len=${#t}
show_bytes "$t"

t=${s%?}
echo len=${#t}
show_bytes "$t"

t=${s%%?}
echo len=${#t}
show_bytes "$t"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Issue 2269 Reduction' {
  local cmd='show_bytes() {
  echo -n "$1" | od -A n -t x1
}

s=$(printf '\''\000x'\'')
echo len=${#s}
show_bytes "$s"

# strip one char from the front
s=${s#?}
echo len=${#s}
show_bytes "$s"

echo ---

s=$(printf '\''\001x'\'')
echo len=${#s}
show_bytes "$s"

# strip one char from the front
s=${s#?}
echo len=${#s}
show_bytes "$s"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Issue 2269 - Do NUL bytes match ? in {a#?}' {
  local cmd='# https://github.com/oils-for-unix/oils/issues/2269

escape_arg() {
	a="$1"
	until [ -z "$a" ]; do
		case "$a" in
		(\'\''*) printf "'\''\"'\''\"'\''";;
		(*) printf %.1s "$a";;
		esac
		a="${a#?}"
    echo len=${#a} >&2
	done
}

# encode
phrase="$(escape_arg "that'\''s it!")"
echo escaped "$phrase"

# decode
eval "printf '\''%s\\n'\'' '\''$phrase'\''"

echo ---

# harder input: NUL surrounded with ::
arg="$(printf '\'':\000:'\'')" 
#echo "arg=$arg"

case $SH in
  zsh) echo '\''writes binary data'\'' ;;
  *) echo escaped "$(escape_arg "$arg")" ;;
esac
#echo "arg=$arg"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

