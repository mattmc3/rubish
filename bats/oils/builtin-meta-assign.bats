#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-meta-assign.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 builtin declare a=(x y) is allowed' {
  local cmd='case $SH in dash|zsh|mksh|ash) exit ;; esac

$SH -c '\''declare a=(x y); declare -p a'\''
if test $? -ne 0; then
  echo '\''fail'\''
fi

$SH -c '\''builtin declare a=(x y); declare -p a'\''
if test $? -ne 0; then
  echo '\''fail'\''
fi

$SH -c '\''builtin declare -a a=(x y); declare -p a'\''
if test $? -ne 0; then
  echo '\''fail'\''
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 command export,readonly' {
  local cmd='case $SH in zsh) exit ;; esac

# dash doesn'\''t have declare typeset

command export c=export
echo c=$c

command readonly c=readonly
echo c=$c

echo --

command command export cc=export
echo cc=$cc

command command readonly cc=readonly
echo cc=$cc'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 command local' {
  local cmd='f() {
  command local s=local
  echo s=$s
}

f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 export, builtin export' {
  local cmd='x='\''a b'\''

export y=$x
echo $y

builtin export z=$x
echo $z'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 builtin declare - ble.sh relies on it' {
  local cmd='case $SH in dash|mksh|ash) exit ;; esac

x='\''a b'\''

builtin declare c=$x
echo $c

\builtin declare d=$x
echo $d

'\''builtin'\'' declare e=$x
echo $e

b=builtin
$b declare f=$x
echo $f

b=b
${b}uiltin declare g=$x
echo $g'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 command readonly - similar issue' {
  local cmd='case $SH in zsh) exit ;; esac

# \command readonly is equivalent to \builtin declare
# except dash implements it

x='\''a b'\''

readonly b=$x
echo $b

command readonly c=$x
echo $c

\command readonly d=$x
echo $d

'\''command'\'' readonly e=$x
echo $e

# The issue here is that we have a heuristic in EvalWordSequence2:
# fs len(part_vals) == 1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Dynamic c readonly - bash and dash change behavior, mksh bug' {
  local cmd='case $SH in zsh) exit ;; esac

x='\''a b'\''

z=command
$z readonly c=$x
echo $c

z=c
${z}ommand readonly d=$x
echo $d'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 static builtin command ASSIGN, command builtin ASSIGN' {
  local cmd='case $SH in dash|ash|zsh) exit ;; esac

# dash doesn'\''t have declare typeset

builtin command export bc=export
echo bc=$bc

builtin command readonly bc=readonly
echo bc=$bc

echo --

command builtin export cb=export
echo cb=$cb

command builtin readonly cb=readonly
echo cb=$cb'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 dynamic builtin command ASSIGN, command builtin ASSIGN' {
  local cmd='case $SH in dash|ash|zsh) exit ;; esac

b=builtin
c=command
e=export
r=readonly

$b $c export bc=export
echo bc=$bc

$b $c readonly bc=readonly
echo bc=$bc

echo --

$c $b export cb=export
echo cb=$cb

$c $b readonly cb=readonly
echo cb=$cb

echo --

$b $c $e bce=export
echo bce=$bce

$b $c $r bcr=readonly
echo bcr=$bcr

echo --

$c $b $e cbe=export
echo cbe=$cbe

$c $b $r cbr=readonly
echo cbr=$cbr'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 builtin typeset, export,readonly' {
  local cmd='case $SH in dash|ash) exit ;; esac

builtin typeset s=typeset
echo s=$s

builtin export s=export
echo s=$s

builtin readonly s=readonly
echo s=$s

echo --

builtin builtin typeset s2=typeset
echo s2=$s2

builtin builtin export s2=export
echo s2=$s2

builtin builtin readonly s2=readonly
echo s2=$s2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 builtin declare,local' {
  local cmd='case $SH in dash|ash|mksh) exit ;; esac

builtin declare s=declare
echo s=$s

f() {
  builtin local s=local
  echo s=$s
}

f'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

