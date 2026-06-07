#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-getopts.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 getopts empty' {
  local cmd='set -- 
getopts '\''a:'\'' opt
echo "status=$? opt=$opt OPTARG=$OPTARG"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 getopts sees unknown arg' {
  local cmd='set -- -Z
getopts '\''a:'\'' opt
echo "status=$? opt=$opt OPTARG=$OPTARG"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 getopts three invocations' {
  local cmd='set -- -h -c foo
getopts '\''hc:'\'' opt
echo status=$? opt=$opt
getopts '\''hc:'\'' opt
echo status=$? opt=$opt
getopts '\''hc:'\'' opt
echo status=$? opt=$opt'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 getopts resets OPTARG' {
  local cmd='set -- -c foo -h
getopts '\''hc:'\'' opt
echo status=$? opt=$opt OPTARG=$OPTARG
getopts '\''hc:'\'' opt
echo status=$? opt=$opt OPTARG=$OPTARG'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 OPTARG is empty (not unset) after parsing a flag doesn'\''t take an arg' {
  local cmd='set -u
getopts '\''ab'\'' name '\''-a'\''
echo name=$name
echo OPTARG=$OPTARG'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Basic getopts invocation' {
  local cmd='set -- -h -c foo x y z
FLAG_h=0
FLAG_c='\'''\''
while getopts "hc:" opt; do
  case $opt in
    h) FLAG_h=1 ;;
    c) FLAG_c="$OPTARG" ;;
  esac
done
shift $(( OPTIND - 1 ))
echo h=$FLAG_h c=$FLAG_c optind=$OPTIND argv=$@'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 getopts with invalid variable name' {
  local cmd='set -- -c foo -h
getopts '\''hc:'\'' opt-
echo status=$? opt=$opt OPTARG=$OPTARG OPTIND=$OPTIND'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 getopts with invalid flag' {
  local cmd='set -- -h -x
while getopts "hc:" opt; do
  case $opt in
    h) FLAG_h=1 ;;
    c) FLAG_c="$OPTARG" ;;
    '\''?'\'') echo ERROR $OPTIND; exit 2; ;;
  esac
done
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 getopts with with -' {
  local cmd='set -- -h -
echo "$@"
while getopts "hc:" opt; do
  case $opt in
    h) FLAG_h=1 ;;
    c) FLAG_c="$OPTARG" ;;
    '\''?'\'') echo ERROR $OPTIND; exit 2; ;;
  esac
done
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 getopts missing required argument' {
  local cmd='set -- -h -c
while getopts "hc:" opt; do
  case $opt in
    h) FLAG_h=1 ;;
    c) FLAG_c="$OPTARG" ;;
    '\''?'\'') echo ERROR $OPTIND; exit 2; ;;
  esac
done
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 getopts doesn'\''t look for flags after args' {
  local cmd='set -- x -h -c y
FLAG_h=0
FLAG_c='\'''\''
while getopts "hc:" opt; do
  case $opt in
    h) FLAG_h=1 ;;
    c) FLAG_c="$OPTARG" ;;
  esac
done
shift $(( OPTIND - 1 ))
echo h=$FLAG_h c=$FLAG_c optind=$OPTIND argv=$@'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 getopts with explicit args' {
  local cmd='# NOTE: Alpine doesn'\''t appear to use this, but bash-completion does.
FLAG_h=0
FLAG_c='\'''\''
arg='\'''\''
set -- A B C
while getopts "hc:" opt -h -c foo x y z; do
  case $opt in
    h) FLAG_h=1 ;;
    c) FLAG_c="$OPTARG" ;;
  esac
done
echo h=$FLAG_h c=$FLAG_c optind=$OPTIND argv=$@'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 OPTIND' {
  local cmd='echo $OPTIND'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 OPTIND after multiple getopts with same spec' {
  local cmd='while getopts "hc:" opt; do
  echo '\''-'\''
done
echo OPTIND=$OPTIND

set -- -h -c foo x y z
while getopts "hc:" opt; do
  echo '\''-'\''
done
echo OPTIND=$OPTIND

set --
while getopts "hc:" opt; do
  echo '\''-'\''
done
echo OPTIND=$OPTIND'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 OPTIND after multiple getopts with different spec' {
  local cmd='# Wow this is poorly specified!  A fundamental design problem with the global
# variable OPTIND.
set -- -a
while getopts "ab:" opt; do
  echo '\''.'\''
done
echo OPTIND=$OPTIND

set -- -c -d -e foo
while getopts "cde:" opt; do
  echo '\''-'\''
done
echo OPTIND=$OPTIND

set -- -f
while getopts "f:" opt; do
  echo '\''_'\''
done
echo OPTIND=$OPTIND'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 OPTIND narrowed down' {
  local cmd='FLAG_a=
FLAG_b=
FLAG_c=
FLAG_d=
FLAG_e=
set -- -a
while getopts "ab:" opt; do
  case $opt in
    a) FLAG_a=1 ;;
    b) FLAG_b="$OPTARG" ;;
  esac
done
# Bash doesn'\''t reset OPTIND!  It skips over c!  mksh at least warns about this!
# You have to reset OPTIND yourself.

set -- -c -d -e E
while getopts "cde:" opt; do
  case $opt in
    c) FLAG_c=1 ;;
    d) FLAG_d=1 ;;
    e) FLAG_e="$OPTARG" ;;
  esac
done

echo a=$FLAG_a b=$FLAG_b c=$FLAG_c d=$FLAG_d e=$FLAG_e'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 Getopts parses the function'\''s arguments' {
  local cmd='FLAG_h=0
FLAG_c='\'''\''
myfunc() {
  while getopts "hc:" opt; do
    case $opt in
      h) FLAG_h=1 ;;
      c) FLAG_c="$OPTARG" ;;
    esac
  done
}
set -- -h -c foo x y z
myfunc -c bar
echo h=$FLAG_h c=$FLAG_c opt=$opt optind=$OPTIND argv=$@'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 Local OPTIND' {
  local cmd='# minimal test case extracted from bash-completion
min() {
  local OPTIND=1

  while getopts "n:e:o:i:s" flag "$@"; do
    echo "loop $OPTIND";
  done
}
min -s'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 two flags: -ab' {
  local cmd='getopts "ab" opt -ab
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG
getopts "ab" opt -ab
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 flag and arg: -c10' {
  local cmd='getopts "c:" opt -c10
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG
getopts "c:" opt -c10
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 More Smooshing 1' {
  local cmd='getopts "ab:c:" opt -ab hi -c hello
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG
getopts "ab:c:" opt -ab hi -c hello
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG
getopts "ab:c:" opt -ab hi -c hello
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 More Smooshing 2' {
  local cmd='getopts "abc:" opt -abc10
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG
getopts "abc:" opt -abc10
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG
getopts "abc:" opt -abc10
echo OPTIND=$OPTIND opt=$opt OPTARG=$OPTARG'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 OPTIND should be >= 1 (regression)' {
  local cmd='OPTIND=-1
getopts a: foo
echo status=$?

OPTIND=0
getopts a: foo
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 getopts bug #1523' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='$SH $REPO_ROOT/spec/testdata/getopts-1523.sh -abcdef -abcde'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 More regression for #1523' {
  skip 'references oils repo paths ($REPO_ROOT); not available here'
  local cmd='$SH $REPO_ROOT/spec/testdata/getopts-1523.sh -abcdef -xyz'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 getopts silent error reporting - invalid option' {
  local cmd='# Leading : in optspec enables silent mode: OPTARG=option char, no error msg
set -- -Z
getopts '\'':a:'\'' opt 2>&1
echo "status=$? opt=$opt OPTARG=$OPTARG"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 getopts silent error reporting - missing required argument' {
  local cmd='# Silent mode returns '\'':'\'' and sets OPTARG to option char
set -- -a
getopts '\'':a:'\'' opt 2>&1
echo "status=$? opt=$opt OPTARG=$OPTARG"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 getopts normal mode - invalid option (compare with silent)' {
  local cmd='# Normal mode: OPTARG is empty, prints error message
set -- -Z
getopts '\''a:'\'' opt 2>/dev/null
echo "status=$? opt=$opt OPTARG=$OPTARG"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 getopts normal mode - missing required argument (compare with silent)' {
  local cmd='# Normal mode returns '\''?'\'', OPTARG is empty
set -- -a
getopts '\''a:'\'' opt 2>/dev/null
echo "status=$? opt=$opt OPTARG=$OPTARG"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 getopts handles '\''--'\'' #2579' {
  local cmd='set -- "-a" "--"
while getopts "a" name; do
        case "$name" in
                a)
                        echo "a"
                        ;;
                ?)
                        echo "?"
                        ;;
        esac
done
echo "name=$name"
echo "$OPTIND"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 getopts leaves all args after '\''--'\'' as operands #2579' {
  local cmd='set -- "-a" "--" "-c" "operand"
while getopts "a" name; do
    case "$name" in
        a)
            echo "a"
            ;;
        c)
            echo "c"
            ;;
        ?)
            echo "?"
            ;;
    esac
done
shift $((OPTIND - 1))
echo "$#"
echo "$@"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

