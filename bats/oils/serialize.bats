#!/usr/bin/env bats
# Generated from oils-for-unix spec/serialize.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 printf %q newline' {
  local cmd='case $SH in ash) return ;; esac  # yash and ash don'\''t implement this

newline=$'\''one\ntwo'\''
printf '\''%q\n'\'' "$newline"

quoted="$(printf '\''%q\n'\'' "$newline")"
restored=$(eval "echo $quoted")
test "$newline" = "$restored" && echo roundtrip-ok'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 printf %q spaces' {
  local cmd='case $SH in ash) return ;; esac  # yash and ash don'\''t implement this

# bash does a weird thing and uses \

spaces='\''one two'\''
printf '\''%q\n'\'' "$spaces"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 printf %q quotes' {
  local cmd='case $SH in ash) return ;; esac  # yash and ash don'\''t implement %q

quotes=\'\''\"
printf '\''%q\n'\'' "$quotes"

quoted="$(printf '\''%q\n'\'' "$quotes")"
restored=$(eval "echo $quoted")
test "$quotes" = "$restored" && echo roundtrip-ok'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 printf %q unprintable' {
  local cmd='case $SH in ash) return ;; esac  # yash and ash don'\''t implement this

unprintable=$'\''\xff'\''
printf '\''%q\n'\'' "$unprintable"

# bash and zsh agree'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 printf %q unicode' {
  local cmd='case $SH in ash) return ;; esac  # yash and ash don'\''t implement this

unicode=$'\''\u03bc'\''
unicode=$'\''\xce\xbc'\''  # does the same thing

printf '\''%q\n'\'' "$unicode"

# OSH issue: we have quotes.  Isn'\''t that OK?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 printf %q invalid unicode' {
  local cmd='case $SH in ash) return ;; esac

# Hm bash/mksh/zsh understand these.  They are doing decoding and error
# recovery!  inspecting the bash source seems to confirm this.
unicode=$'\''\xce'\''
printf '\''%q\n'\'' "$unicode"

unicode=$'\''\xce\xce\xbc'\''
printf '\''%q\n'\'' "$unicode"

unicode=$'\''\xce\xbc\xce'\''
printf '\''%q\n'\'' "$unicode"

case $SH in mksh) return ;; esac  # it prints unprintable chars here!

unicode=$'\''\xcea'\''
printf '\''%q\n'\'' "$unicode"
unicode=$'\''a\xce'\''
printf '\''%q\n'\'' "$unicode"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 set' {
  local cmd='case $SH in zsh) return ;; esac  # zsh doesn'\''t make much sense

zz=$'\''one\ntwo'\''

set | grep zz'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 declare' {
  local cmd='case $SH in ash|zsh) return ;; esac  # zsh doesn'\''t make much sense

zz=$'\''one\ntwo'\''

typeset | grep zz
typeset -p zz'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 {var@Q}' {
  local cmd='case $SH in zsh|ash) exit ;; esac

zz=$'\''one\ntwo \u03bc'\''

# weirdly, quoted and unquoted aren'\''t different
echo ${zz@Q}
echo "${zz@Q}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 xtrace' {
  local cmd='zz=$'\''one\ntwo'\''
set -x
echo "$zz"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

