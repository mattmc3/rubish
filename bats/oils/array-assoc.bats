#!/usr/bin/env bats
# Generated from oils-for-unix spec/array-assoc.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Literal syntax ([x]=y)' {
  local cmd='declare -A a
a=([aa]=b [foo]=bar ['\''a+1'\'']=c)
echo ${a["aa"]}
echo ${a["foo"]}
echo ${a["a+1"]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 set associative array to indexed array literal (very surprising bash behavior)' {
  local cmd='declare -A assoc=([k1]=foo [k2]='\''spam eggs'\'')
declare -p assoc

# Bash 5.1 assoc=(key value). Bash 5.0 (including the currently tested 4.4)
# does not implement this.

assoc=(foo '\''spam eggs'\'')
declare -p assoc'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Can initialize assoc array with the (key value ...) sequence' {
  local cmd='declare -A A=(1 2 3)
echo status=$?
declare -p A'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 create empty assoc array, put, then get' {
  local cmd='declare -A A  # still undefined
argv.py "${A[@]}"
argv.py "${!A[@]}"
A['\''foo'\'']=bar
echo ${A['\''foo'\'']}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Empty value (doesn'\''t use EmptyWord?)' {
  local cmd='declare -A A=(["k"]= )
argv.py "${A["k"]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 retrieve keys with !' {
  local cmd='declare -A a
var='\''x'\''
a["$var"]=b
a['\''foo'\'']=bar
a['\''a+1'\'']=c
for key in "${!a[@]}"; do
  echo $key
done | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 retrieve values with {A[@]}' {
  local cmd='declare -A A
var='\''x'\''
A["$var"]=b
A['\''foo'\'']=bar
A['\''a+1'\'']=c
for val in "${A[@]}"; do
  echo $val
done | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 coerce to string with {A[*]}, etc.' {
  local cmd='declare -A A
A['\''X X'\'']=xx
A['\''Y Y'\'']=yy
argv.py "${A[*]}"
argv.py "${!A[*]}"

argv.py ${A[@]}
argv.py ${!A[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 {A[@]/b/B}' {
  local cmd='# but ${!A[@]/b/B} doesn'\''t work
declare -A A
A['\''aa'\'']=bbb
A['\''bb'\'']=ccc
A['\''cc'\'']=ddd
for val in "${A[@]//b/B}"; do
  echo $val
done | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 {A[@]#prefix}' {
  local cmd='declare -A A
A['\''aa'\'']=one
A['\''bb'\'']=two
A['\''cc'\'']=three
for val in "${A[@]#t}"; do
  echo $val
done | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 {assoc} is like {assoc[0]}' {
  local cmd='declare -A a

a=([aa]=b [foo]=bar ['\''a+1'\'']=c)
echo a="${a}"

a=([0]=zzz)
echo a="${a}"

a=(['\''0'\'']=yyy)
echo a="${a}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 length {#a[@]}' {
  local cmd='declare -A a
a["x"]=1
a["y"]=2
a["z"]=3
echo "${#a[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 lookup with {a[0]} -- 0 is a string' {
  local cmd='declare -A a
a["0"]=a
a["1"]=b
a["2"]=c
echo 0 "${a[0]}" 1 "${a[1]}" 2 "${a[2]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 lookup with double quoted strings mykey' {
  local cmd='declare -A a
a["aa"]=b
a["foo"]=bar
a['\''a+1'\'']=c
echo "${a["aa"]}" "${a["foo"]}" "${a["a+1"]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 lookup with single quoted string' {
  local cmd='declare -A a
a["aa"]=b
a["foo"]=bar
a['\''a+1'\'']=c
echo "${a['\''a+1'\'']}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 lookup with unquoted key and quoted ii' {
  local cmd='declare -A A
A["aa"]=b
A["foo"]=bar

key=foo
echo ${A[$key]}
i=a
echo ${A["$i$i"]}   # note: ${A[$i$i]} doesn'\''t work in OSH'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 lookup by unquoted string doesn'\''t work in OSH because it'\''s a variable' {
  local cmd='declare -A a
a["aa"]=b
a["foo"]=bar
a['\''a+1'\'']=c
echo "${a[a+1]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 bash bug: i+1 and i+1 are the same key' {
  local cmd='i=1
array=(5 6 7)
echo array[i]="${array[i]}"
echo array[i+1]="${array[i+1]}"

# arithmetic does NOT work here in bash.  These are unquoted strings!
declare -A assoc
assoc[i]=$i
assoc[i+1]=$i+1

assoc["i"]=string
assoc["i+1"]=string+1

echo assoc[i]="${assoc[i]}" 
echo assoc[i+1]="${assoc[i+1]}"

echo assoc[i]="${assoc["i"]}" 
echo assoc[i+1]="${assoc["i+1"]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Array stored in associative array gets converted to string (without strict_array)' {
  local cmd='array=('\''1 2'\'' 3)
declare -A d
d['\''key'\'']="${array[@]}"
argv.py "${d['\''key'\'']}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Indexed array as key of associative array coerces to string (without shopt -s strict_array)' {
  local cmd='declare -a array=(1 2 3)
declare -A assoc
assoc[42]=43
assoc["${array[@]}"]=foo

echo "${assoc["${array[@]}"]}"
for entry in "${!assoc[@]}"; do
  echo $entry
done | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Append to associative array value A['\''x'\'']+='\''suffix'\''' {
  local cmd='declare -A A
A['\''x'\'']='\''foo'\''
A['\''x'\'']+='\''bar'\''
A['\''x'\'']+='\''bar'\''
argv.py "${A["x"]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Slice of associative array doesn'\''t make sense in bash' {
  local cmd='declare -A a
a[xx]=1
a[yy]=2
a[zz]=3
a[aa]=4
a[bb]=5
#argv.py ${a["xx"]}
argv.py ${a[@]: 0: 3}
argv.py ${a[@]: 1: 3}
argv.py ${a[@]: 2: 3}
argv.py ${a[@]: 3: 3}
argv.py ${a[@]: 4: 3}
argv.py ${a[@]: 5: 3}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 bash variable can have an associative array part and a string part' {
  local cmd='# and $assoc is equivalent to ${assoc[0]}, just like regular arrays
declare -A assoc
assoc[1]=1
assoc[2]=2
echo ${assoc[1]} ${assoc[2]} ${assoc}
assoc[0]=zero
echo ${assoc[1]} ${assoc[2]} ${assoc}
assoc=string
echo ${assoc[1]} ${assoc[2]} ${assoc}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Associative array expressions inside (( )) with keys that look like numbers' {
  local cmd='declare -A assoc
assoc[0]=42
(( var = ${assoc[0]} ))
echo $var
(( var = assoc[0] ))
echo $var'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 (( A[5] += 42 ))' {
  local cmd='declare -A A
(( A[5] = 10 ))
(( A[5] += 6 ))
echo ${A[5]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 (( A[5] += 42 )) with empty cell' {
  local cmd='shopt -u strict_arith  # default zero cell
declare -A A
(( A[5] += 6 ))
echo ${A[5]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 setting key to itself (from bash-bug mailing list)' {
  local cmd='declare -A foo
foo=(["key"]="value1")
echo ${foo["key"]}
foo=(["key"]="${foo["key"]} value2")
echo ${foo["key"]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 readonly associative array can'\''t be modified' {
  local cmd='declare -Ar A
A['\''x'\'']=1
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 associative array and brace expansion' {
  local cmd='declare -A A=([k1]=v [k2]=-{a,b}-)
echo ${A["k1"]}
echo ${A["k2"]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 declare -A A=() allowed' {
  local cmd='set -o nounset
shopt -s strict_arith || true

declare -A ASSOC=()
echo len=${#ASSOC[@]}

# Check that it really can be used like an associative array
ASSOC['\''k'\'']='\''32'\''
echo len=${#ASSOC[@]}

# bash allows a variable to be an associative array AND unset, while OSH
# doesn'\''t
set +o nounset
declare -A u
echo unset len=${#u[@]}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 unset -v and assoc array' {
  local cmd='shopt -s eval_unsafe_arith || true

show-len() {
  echo len=${#assoc[@]}
}

declare -A assoc=(['\''K'\'']=val)
show-len

unset -v '\''assoc["K"]'\''
show-len

declare -A assoc=(['\''K'\'']=val)
show-len
key=K
unset -v '\''assoc[$key]'\''
show-len

declare -A assoc=(['\''K'\'']=val)
show-len
unset -v '\''assoc[$(echo K)]'\''
show-len

# ${prefix} doesn'\''t work here, even though it does in arithmetic
#declare -A assoc=(['\''K'\'']=val)
#show-len
#prefix=as
#unset -v '\''${prefix}soc[$key]'\''
#show-len'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 nameref and assoc array' {
  local cmd='show-values() {
  echo values: ${A[@]}
}

declare -A A=(['\''K'\'']=val)
show-values

declare -n ref='\''A["K"]'\''
echo before $ref
ref='\''val2'\''
echo after $ref
show-values

echo ---

key=K
declare -n ref='\''A[$key]'\''
echo before $ref
ref='\''val3'\''
echo after $ref
show-values'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 {!ref} and assoc array' {
  local cmd='show-values() {
  echo values: ${A[@]}
}

declare -A A=(['\''K'\'']=val)
show-values

declare ref='\''A["K"]'\''
echo ref ${!ref}

key=K
declare ref='\''A[$key]'\''
echo ref ${!ref}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 printf -v and assoc array' {
  local cmd='show-values() {
  echo values: ${assoc[@]}
}

declare -A assoc=(['\''K'\'']=val)
show-values

printf -v '\''assoc["K"]'\'' '\''/%s/'\'' val2
show-values

key=K
printf -v '\''assoc[$key]'\'' '\''/%s/'\'' val3
show-values

# Somehow bash doesn'\''t allow this
#prefix=as
#printf -v '\''${prefix}soc[$key]'\'' '\''/%s/'\'' val4
#show-values'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 bash bug: (( A[key] = 1 )) doesn'\''t work' {
  local cmd='key='\''\'\''
declare -A A
#A["$key"]=1

# Works in both
#A["$key"]=42

# Works in bash only
#(( A[\$key] = 42 ))

(( A["$key"] = 42 ))

argv.py "${!A[@]}"
argv.py "${A[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 Implicit increment of keys' {
  local cmd='declare -a arr=( [30]=a b [40]=x y)
argv.py "${!arr[@]}"
argv.py "${arr[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 test -v assoc[key]' {
  local cmd='typeset -A assoc
assoc=([empty]='\'''\'' [k]=v)

echo '\''no quotes'\''

test -v assoc[empty]
echo empty=$?

test -v assoc[k]
echo k=$?

test -v assoc[nonexistent]
echo nonexistent=$?

echo

# Now with quotes
echo '\''quotes'\''

test -v assoc["empty"]
echo empty=$?

test -v assoc['\''k'\'']
echo k=$?

test -v assoc['\''nonexistent'\''] 
echo nonexistent=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 test -v with dynamic parsing' {
  local cmd='typeset -A assoc
assoc=([empty]='\'''\'' [k]=v)

key=empty
test -v '\''assoc[$key]'\''
echo empty=$?

key=k
test -v '\''assoc[$key]'\''
echo k=$?

key=nonexistent
test -v '\''assoc[$key]'\''
echo nonexistent=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 [[ -v assoc[key] ]]' {
  local cmd='typeset -A assoc
assoc=([empty]='\'''\'' [k]=v)

echo '\''no quotes'\''

[[ -v assoc[empty] ]]
echo empty=$?

[[ -v assoc[k] ]]
echo k=$?

[[ -v assoc[nonexistent] ]]
echo nonexistent=$?

echo

# Now with quotes
echo '\''quotes'\''

[[ -v assoc["empty"] ]]
echo empty=$?

[[ -v assoc['\''k'\''] ]]
echo k=$?

[[ -v assoc['\''nonexistent'\''] ]]
echo nonexistent=$?

echo

echo '\''vars'\''

key=empty
[[ -v assoc[$key] ]]
echo empty=$?

key=k
[[ -v assoc[$key] ]]
echo k=$?

key=nonexistent
[[ -v assoc[$key] ]]
echo nonexistent=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 [[ -v assoc[key] ]] syntax errors' {
  local cmd='typeset -A assoc
assoc=([empty]='\'''\'' [k]=v)

[[ -v assoc[empty] ]]
echo empty=$?

[[ -v assoc[k] ]]
echo k=$?

[[ -v assoc[k]z ]]
echo typo=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 BashAssoc a+=()' {
  local cmd='declare -A a=([apple]=red [orange]=orange)
a+=([lemon]=yellow [banana]=yellow)
echo "apple is ${a['\''apple'\'']}"
echo "orange is ${a['\''orange'\'']}"
echo "lemon is ${a['\''lemon'\'']}"
echo "banana is ${a['\''banana'\'']}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 BashAssoc {a[@]@Q}' {
  local cmd='declare -A a=()
a['\''symbol1'\'']=\'\''\'\''
a['\''symbol2'\'']='\''"'\''
a['\''symbol3'\'']='\''()<>&|'\''
a['\''symbol4'\'']='\''[]*?'\''
echo "[${a[@]@Q}]"
echo "[${a[*]@Q}]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

