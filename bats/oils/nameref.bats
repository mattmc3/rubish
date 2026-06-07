#!/usr/bin/env bats
# Generated from oils-for-unix spec/nameref.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 pass array by reference' {
  local cmd='show_value() {
  local -n array_name=$1
  local idx=$2
  echo "${array_name[$idx]}"
}
shadock=(ga bu zo meu)
show_value shadock 2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 mutate array by reference' {
  local cmd='set1() {
  local -n array_name=$1
  local val=$2
  array_name[1]=$val
}
shadock=(a b c d)
set1 shadock ZZZ
echo ${shadock[@]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 pass assoc array by reference' {
  local cmd='show_value() {
  local -n array_name=$1
  local idx=$2
  echo "${array_name[$idx]}"
}
days=([monday]=eggs [tuesday]=bread [sunday]=jam)
show_value days sunday'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 pass local array by reference, relying on DYNAMIC SCOPING' {
  local cmd='show_value() {
  local -n array_name=$1
  local idx=$2
  echo "${array_name[$idx]}"
}
caller() {
  local shadock=(ga bu zo meu)
  show_value shadock 2
}
caller'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 flag -n and +n' {
  local cmd='x=foo

ref=x

echo ref=$ref

typeset -n ref
echo ref=$ref

# mutate underlying var
x=bar
echo ref=$ref

typeset +n ref
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 mutating through nameref: ref=' {
  local cmd='x=XX
y=YY

ref=x
ref=y
echo 1 ref=$ref

# now it'\''s a reference
typeset -n ref

echo 2 ref=$ref  # prints YY

ref=XXXX
echo 3 ref=$ref  # it actually prints y, which is XXXX

# now Y is mutated!
echo 4 y=$y'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 flag -n combined {!ref} -- bash INVERTS' {
  local cmd='foo=FOO  # should NOT use this

x=foo
ref=x

echo ref=$ref
echo "!ref=${!ref}"

echo '\''NOW A NAMEREF'\''

typeset -n ref
echo ref=$ref
echo "!ref=${!ref}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 named ref with # doesn'\''t work' {
  local cmd='set -- one two three

ref='\''#'\''
echo ref=$ref
typeset -n ref
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 named ref with # and shopt -s strict_nameref' {
  local cmd='shopt -s strict_nameref

ref='\''#'\''
echo ref=$ref
typeset -n ref
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 named ref with 1 1 etc.' {
  local cmd='set -- one two three

x=X

ref='\''1'\''
echo ref=$ref
typeset -n ref
echo ref=$ref

# BUG: This is really assigning '\''1'\'', which is INVALID
# with strict_nameref that degrades!!!
ref2='\''$1'\''
echo ref2=$ref2
typeset -n ref2
echo ref2=$ref2

x=foo

ref3='\''x'\''
echo ref3=$ref3
typeset -n ref3
echo ref3=$ref3'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 assign to invalid ref' {
  local cmd='ref=1   # mksh makes this READ-ONLY!  Because it'\''s not valid.

echo ref=$ref
typeset -n ref
echo ref=$ref

ref=foo
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 assign to invalid ref with strict_nameref' {
  local cmd='case $SH in *bash|*mksh) exit ;; esac

shopt -s strict_nameref

ref=1

echo ref=$ref
typeset -n ref
echo ref=$ref

ref=foo
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 name ref on Undef cell' {
  local cmd='typeset  -n ref

# This is technically incorrect: an undefined name shouldn'\''t evaluate to empty
# string.  mksh doesn'\''t allow it.
echo ref=$ref

echo nounset
set -o nounset
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 assign to empty nameref and invalid nameref' {
  local cmd='typeset -n ref
echo ref=$ref

# this is a no-op in bash, should be stricter
ref=x
echo ref=$ref

typeset -n ref2=undef
echo ref2=$ref2
ref2=x
echo ref2=$ref2'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 -n attribute before it has a value' {
  local cmd='typeset -n ref

echo ref=$ref

# Now that it'\''s a string, it still has the -n attribute
x=XX
ref=x
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 -n attribute on array is hard error, not a warning' {
  local cmd='x=X
typeset -n ref #=x
echo hi

# bash prints warning: REMOVES the nameref attribute here!
ref=(x y)
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 exported nameref' {
  local cmd='x=foo
typeset -n -x ref=x

# hm bash ignores it but mksh doesn'\''t.  maybe disallow it.
printenv.py x ref
echo ---
export x
printenv.py x ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 readonly nameref doesn'\''t prevent assigning through it' {
  local cmd='# hm bash also ignores -r when -n is set

x=XX
typeset -n -r ref=x

echo ref=$ref

# it feels like I shouldn'\''t be able to mutate this?
ref=XXXX
echo ref=$ref

x=X
echo x=$x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 readonly var can'\''t be assigned through nameref' {
  local cmd='x=X
typeset -n -r ref=x

echo ref=$ref

# it feels like I shouldn'\''t be able to mutate this?
ref=XX
echo ref=$ref

# now the underling variable is immutable
typeset -r x

ref=XXX
echo ref=$ref
echo x=$x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 unset nameref' {
  local cmd='x=X
typeset -n ref=x
echo ref=$ref

# this works
unset ref
echo ref=$ref
echo x=$x'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Chain of namerefs' {
  local cmd='x=foo
typeset -n ref=x
typeset -n ref_to_ref=ref
echo ref_to_ref=$ref_to_ref
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 Mutually recursive namerefs detected on READ' {
  local cmd='typeset -n ref1=ref2
typeset -n ref2=ref1
echo defined
echo ref1=$ref1
echo ref2=$ref1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 Mutually recursive namerefs detected on WRITE' {
  local cmd='typeset -n ref1=ref2
typeset -n ref2=ref1  # not detected here
echo defined $?
ref1=z  # detected here
echo mutated $?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 Dynamic scope with namerefs' {
  local cmd='f3() {
  local -n ref=$1
  ref=x
}

f2() {
  f3 "$@"
}

f1() {
  local F1=F1
  echo F1=$F1
  f2 F1
  echo F1=$F1
}
f1'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 change reference itself' {
  local cmd='x=XX
y=YY
typeset -n ref=x
echo ref=$ref
echo x=$x
echo y=$y

echo ----
typeset -n ref=y
echo ref=$ref
echo x=$x
echo y=$y
echo ----
ref=z
echo ref=$ref
echo x=$x
echo y=$y'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 a[2] in nameref' {
  local cmd='typeset -n ref='\''a[2]'\''
a=(zero one two three)
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 a[expr] in nameref' {
  local cmd='# this confuses code and data
typeset -n ref='\''a[$(echo 2) + 1]'\''
a=(zero one two three)
echo ref=$ref'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 a[@] in nameref' {
  local cmd='# this confuses code and data
typeset -n ref='\''a[@]'\''
a=('\''A B'\'' C)
argv.py ref "$ref"  # READ through ref works
ref=(X Y Z)    # WRITE through doesn'\''t work
echo status=$?
argv.py '\''ref[@]'\'' "${ref[@]}"
argv.py ref "$ref"  # JOINING mangles the array?
argv.py '\''a[@]'\'' "${a[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 mutate through nameref: ref[0]=' {
  local cmd='# This is DIFFERENT than the nameref itself being '\''array[0]'\'' !

array=(X Y Z)
typeset -n ref=array
ref[0]=xx
echo ${array[@]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 bad mutation through nameref: ref[0]= where ref is array[0]' {
  local cmd='array=(X Y Z)
typeset -n ref='\''array[0]'\''
ref[0]=foo  # error in bash: '\''array[0]'\'': not a valid identifier
echo status=$?
echo ${array[@]}'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 @ in nameref isn'\''t supported, unlike in {!ref}' {
  local cmd='set -- A B
typeset -n ref='\''@'\''  # bash gives an error here
echo status=$?

echo ref=$ref  # bash doesn'\''t give an error here
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 Unquoted assoc reference on RHS' {
  local cmd='typeset -A bashup_ev_r
bashup_ev_r['\''foo'\'']=bar

p() {
  local s=foo
  local -n e=bashup_ev["$s"] f=bashup_ev_r["$s"]
  # Different!
  #local e=bashup_ev["$s"] f=bashup_ev_r["$s"]
  argv.py "$f"
}
p'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

