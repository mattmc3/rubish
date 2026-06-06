#!/usr/bin/env bats
# Generated from oils-for-unix spec/temp-binding.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 More eval '\''local v='\''' {
  local cmd='case $SH in mksh) exit ;; esac

set -u

f() {
  # The temp env messes it up
  tmp1= local x=x
  tmp2= eval '\''local y=y'\''

  # similar to eval
  tmp3= . $REPO_ROOT/spec/testdata/define-local-var-z.sh

  # Bug does not appear with only eval
  #eval '\''local v=hello'\''

  #declare -p v
  echo x=$x
  echo y=$y
  echo z=$z
}

f '
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Temp bindings with local' {
  local cmd='f() {
  local x=x
  tmp='\'''\'' local tx=tx

  # Hm both y and ty persist in bash/zsh
  eval '\''local y=y'\''
  tmp='\'''\'' eval '\''local ty=ty'\''

  # Why does this have an effect in OSH?  Oh because '\''unset'\'' is a special
  # builtin
  if true; then
    x='\''X'\'' unset x
    tx='\''TX'\'' unset tx
    y='\''Y'\'' unset y
    ty='\''TY'\'' unset ty
  fi

  #unset y
  #unset ty

  echo x=$x
  echo tx=$tx
  echo y=$y
  echo ty=$ty
}

f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Temp bindings with unset' {
  local cmd='# key point:
# unset looks up the stack
# local doesn'\''t though

x=42
unset x
echo x=$x

echo ---

x=42
tmp= unset x
echo x=$x

x=42
tmp= eval '\''unset x'\''
echo x=$x

echo ---

shadow() {
  x=42
  x=tmp unset x
  echo x=$x
  
  x=42
  x=tmp eval '\''unset x'\''
  echo x=$x
}

shadow

echo ---

case $SH in
  bash) set -o posix ;;
esac
shadow

# Now shadow

# unset is a special builtin
# type unset'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 FOO=bar unset - temp binding, then empty argv from unquoted unset var (#2411)' {
  local cmd='foo=alive! $unset
echo $foo'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

