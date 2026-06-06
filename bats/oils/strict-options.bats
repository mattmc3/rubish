#!/usr/bin/env bats
# Generated from oils-for-unix spec/strict-options.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 strict_arith option' {
  local cmd='shopt -s strict_arith'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Sourcing a script that returns at the top level' {
  local cmd='echo one
. $REPO_ROOT/spec/testdata/return-helper.sh
echo $?
echo two'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 top level control flow' {
  local cmd='$SH $REPO_ROOT/spec/testdata/top-level-control-flow.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 errexit and top-level control flow' {
  local cmd='$SH -o errexit $REPO_ROOT/spec/testdata/top-level-control-flow.sh'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 shopt -s strict_control_flow' {
  local cmd='shopt -s strict_control_flow || true
echo break
break
echo hi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 return at top level is an error' {
  local cmd='return
echo "status=$?"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 continue at top level is NOT an error' {
  local cmd='# NOTE: bash and mksh both print warnings, but don'\''t exit with an error.
continue
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 break at top level is NOT an error' {
  local cmd='break
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 empty argv WITHOUT strict_argv' {
  local cmd='x='\'''\''
$x
echo status=$?

if $x; then
  echo VarSub
fi

if $(echo foo >/dev/null); then
  echo CommandSub
fi

if "$x"; then
  echo VarSub
else
  echo VarSub FAILED
fi

if "$(echo foo >/dev/null)"; then
  echo CommandSub
else
  echo CommandSub FAILED
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 empty argv WITH strict_argv' {
  local cmd='shopt -s strict_argv || true
echo empty
x='\'''\''
$x
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Arrays are incorrectly compared, but strict_array prevents it' {
  local cmd='# NOTE: from spec/dbracket has a test case like this
# sane-array should turn this ON.
# bash and mksh allow this because of decay

a=('\''a b'\'' '\''c d'\'')
b=('\''a'\'' '\''b'\'' '\''c'\'' '\''d'\'')
echo ${#a[@]}
echo ${#b[@]}
[[ "${a[@]}" == "${b[@]}" ]] && echo EQUAL

shopt -s strict_array || true
[[ "${a[@]}" == "${b[@]}" ]] && echo EQUAL'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 automatically creating arrays WITHOUT strict_array' {
  local cmd='undef[2]=x
undef[3]=y
argv.py "${undef[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 automatically creating arrays are INDEXED, not associative' {
  local cmd='shopt -u strict_arith || true

undef[2]=x
undef[3]=y
x='\''bad'\''
# bad gets coerced to zero, but this is part of the RECURSIVE arithmetic
# behavior, which we want to disallow.  Consider disallowing in OSH.

undef[$x]=zzz
argv.py "${undef[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 simple_eval_builtin' {
  local cmd='for i in 1 2; do
  eval  # zero args
  echo status=$?
  eval echo one
  echo status=$?
  eval '\''echo two'\''
  echo status=$?
  shopt -s simple_eval_builtin
  echo ---
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 strict_parse_slice means you need explicit  length' {
  local cmd='case $SH in bash*|dash|mksh) exit ;; esac

$SH -c '\''
a=(1 2 3); echo /${a[@]::}/
'\''
echo status=$?

$SH -c '\''
shopt --set strict_parse_slice

a=(1 2 3); echo /${a[@]::}/
'\''
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Control flow must be static in YSH (strict_control_flow)' {
  local cmd='case $SH in bash*|dash|mksh) exit ;; esac

shopt --set ysh:all

for x in a b c { 
  echo $x
  if (x === '\''a'\'') {
    break
  }
}

echo ---

for keyword in break continue return exit {
  try {
    $[ENV.SH] -o ysh:all -c '\''
    var k = $1
    for x in a b c { 
      echo $x
      if (x === "a") {
        $k
      }
    }
    '\'' unused $keyword
  }
  echo code=$[_error.code]
  echo '\''==='\''
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 shopt -s strict_binding: Persistent prefix bindings not allowed on special builtins' {
  local cmd='shopt --set strict:all

# This differs from what it means in a process
FOO=bar eval '\''echo FOO=$FOO'\''
echo FOO=$FOO'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

