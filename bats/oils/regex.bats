#!/usr/bin/env bats
# Generated from oils-for-unix spec/regex.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 BASH_REMATCH' {
  local cmd='[[ foo123 =~ ([a-z]+)([0-9]+) ]]
echo status=$?
argv.py "${BASH_REMATCH[@]}"

[[ failed =~ ([a-z]+)([0-9]+) ]]
echo status=$?
argv.py "${BASH_REMATCH[@]}"  # not cleared!'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Match is unanchored at both ends' {
  local cmd='[[ '\''bar'\'' =~ a ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Failed match' {
  local cmd='[[ '\''bar'\'' =~ X ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Regex quoted with  -- preferred in bash' {
  local cmd='[[ '\''a b'\'' =~ ^(a\ b)$ ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Regex quoted with single quotes' {
  local cmd='# bash doesn'\''t like the quotes
[[ '\''a b'\'' =~ '\''^(a b)$'\'' ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Regex quoted with double quotes' {
  local cmd='# bash doesn'\''t like the quotes
[[ '\''a b'\'' =~ "^(a b)$" ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 Fix single quotes by storing in variable' {
  local cmd='pat='\''^(a b)$'\''
[[ '\''a b'\'' =~ $pat ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '008 Fix single quotes by storing in variable' {
  local cmd='pat="^(a b)$"
[[ '\''a b'\'' =~ $pat ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '009 Double quoting pat variable -- again bash doesn'\''t like it.' {
  local cmd='pat="^(a b)$"
[[ '\''a b'\'' =~ "$pat" ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Mixing quoted and unquoted parts' {
  local cmd='[[ '\''a b'\'' =~ '\''a '\''b ]] && echo true
[[ "a b" =~ "a "'\''b'\'' ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 Regex with == and not =~ is parse error, different lexer mode required' {
  local cmd='# They both give a syntax error.  This is lame.
[[ '\''^(a b)$'\'' == ^(a\ b)$ ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 Omitting ( )' {
  local cmd='[[ '\''^a b$'\'' == ^a\ b$ ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '013 Malformed regex' {
  local cmd='# Are they trying to PARSE the regex?  Do they feed the buffer directly to
# regcomp()?
[[ '\''a b'\'' =~ ^)a\ b($ ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '014 Regex with |' {
  local cmd='[[ '\''bar'\'' =~ foo|bar ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 Regex to match literal brackets []' {
  local cmd='# bash-completion relies on this, so we'\''re making it match bash.
# zsh understandably differs.
[[ '\''[]'\'' =~ \[\] ]] && echo true

# Another way to write this.
pat='\''\[\]'\''
[[ '\''[]'\'' =~ $pat ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 Regex to match literals . ^  etc.' {
  local cmd='[[ '\''x'\'' =~ \. ]] || echo false
[[ '\''.'\'' =~ \. ]] && echo true

[[ '\''xx'\'' =~ \^\$ ]] || echo false
[[ '\''^$'\'' =~ \^\$ ]] && echo true

[[ '\''xxx'\'' =~ \+\*\? ]] || echo false
[[ '\''*+?'\'' =~ \*\+\? ]] && echo true

[[ '\''xx'\'' =~ \{\} ]] || echo false
[[ '\''{}'\'' =~ \{\} ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 Unquoted { is a regex parse error' {
  local cmd='[[ { =~ { ]] && echo true
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 Fatal error inside [[ =~ ]]' {
  local cmd='# zsh and osh are stricter than bash.  bash treats [[ like a command.

[[ a =~ $(( 1 / 0 )) ]]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '019 Quoted { and +' {
  local cmd='[[ { =~ "{" ]] && echo '\''yes {'\''
[[ + =~ "+" ]] && echo '\''yes +'\''
[[ * =~ "*" ]] && echo '\''yes *'\''
[[ ? =~ "?" ]] && echo '\''yes ?'\''
[[ ^ =~ "^" ]] && echo '\''yes ^'\''
[[ $ =~ "$" ]] && echo '\''yes $'\''
[[ '\''('\'' =~ '\''('\'' ]] && echo '\''yes ('\''
[[ '\'')'\'' =~ '\'')'\'' ]] && echo '\''yes )'\''
[[ '\''|'\'' =~ '\''|'\'' ]] && echo '\''yes |'\''
[[ '\''\'\'' =~ '\''\'\'' ]] && echo '\''yes \'\''
echo ---

[[ . =~ "." ]] && echo '\''yes .'\''
[[ z =~ "." ]] || echo '\''no .'\''
echo ---

# This rule is weird but all shells agree.  I would expect that the - gets
# escaped?  It'\''s an operator?  but it behaves like a-z.
[[ a =~ ["a-z"] ]]; echo "a $?"
[[ - =~ ["a-z"] ]]; echo "- $?"
[[ b =~ ['\''a-z'\''] ]]; echo "b $?"
[[ z =~ ['\''a-z'\''] ]]; echo "z $?"

echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '020 Escaped {' {
  local cmd='# from bash-completion
[[ '\''$PA'\'' =~ ^(\$\{?)([A-Za-z0-9_]*)$ ]] && argv.py "${BASH_REMATCH[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '021 Escaped { stored in variable first' {
  local cmd='# from bash-completion
pat='\''^(\$\{?)([A-Za-z0-9_]*)$'\''
[[ '\''$PA'\'' =~ $pat ]] && argv.py "${BASH_REMATCH[@]}"'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '022 regex with ?' {
  local cmd='[[ '\''c'\'' =~ c? ]] && echo true
[[ '\'''\'' =~ c? ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '023 regex with unprintable characters' {
  local cmd='# can'\''t have nul byte

# This pattern has literal characters
pat=$'\''^[\x01\x02]+$'\''

[[ $'\''\x01\x02\x01'\'' =~ $pat ]]; echo status=$?
[[ $'\''a\x01'\'' =~ $pat ]]; echo status=$?

# NOTE: There doesn'\''t appear to be any way to escape these!
pat2='\''^[\x01\x02]+$'\'''
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '024 pattern f(x)  -- regression' {
  local cmd='f=fff
[[ fffx =~ $f(x) ]]
echo status=$?
[[ ffx =~ $f(x) ]]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '025 pattern a=(1)' {
  local cmd='[[ a=x =~ a=(x) ]]
echo status=$?
[[ =x =~ a=(x) ]]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '026 pattern @f(x)' {
  local cmd='shopt -s parse_at
[[ @fx =~ @f(x) ]]
echo status=$?
[[ fx =~ @f(x) ]]
echo status=$?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '027 Bug: Nix idiom with closing ) next to pattern' {
  local cmd='if [[ ! (" ${params[*]} " =~ " -shared " || " ${params[*]} " =~ " -static ") ]]; then
  echo one
fi

# Reduced idiom
if [[ (foo =~ foo) ]]; then
  echo two
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '028 unquoted (a  b) as pattern, (a  b|c)' {
  local cmd='if [[ '\''a  b'\'' =~ (a  b) ]]; then
  echo one
fi

if [[ '\''a b'\'' =~ (a  b) ]]; then
  echo BAD
fi

if [[ '\''a b'\'' =~ (a b|c) ]]; then
  echo two
fi

# I think spaces are only allowed within ()

if [[ '\''  c'\'' =~ (a|  c) ]]; then
  echo three
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '029 Multiple adjacent () groups' {
  local cmd='if [[ '\''a-b-c-d'\'' =~ a-(b|  >>)-c-( ;|[de])|ff|gg ]]; then
  argv.py "${BASH_REMATCH[@]}"
fi

if [[ ff =~ a-(b|  >>)-c-( ;|[de])|ff|gg ]]; then
  argv.py "${BASH_REMATCH[@]}"
fi

# empty group ()

if [[ zz =~ ([a-z]+)() ]]; then
  argv.py "${BASH_REMATCH[@]}"
fi

# nested empty group
if [[ zz =~ ([a-z]+)(()z) ]]; then
  argv.py "${BASH_REMATCH[@]}"
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '030 unquoted [a  b] as pattern, [a  b|c]' {
  local cmd='$SH <<'\''EOF'\''
[[ a =~ [ab] ]] && echo yes
EOF
echo "[ab]=$?"

$SH <<'\''EOF'\''
[[ a =~ [a b] ]] && echo yes
EOF
echo "[a b]=$?"

$SH <<'\''EOF'\''
[[ a =~ ([a b]) ]] && echo yes
EOF
echo "[a b]=$?"'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '031 c|a unquoted' {
  local cmd='if [[ a =~ c|a ]]; then
  echo one
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '032 Operator chars ; & but not |' {
  local cmd='# Hm semicolon is still an operator in bash
$SH <<'\''EOF'\''
[[ '\'';'\'' =~ ; ]] && echo semi
EOF
echo semi=$?

$SH <<'\''EOF'\''
[[ '\'';'\'' =~ (;) ]] && echo semi paren
EOF
echo semi paren=$?

echo

$SH <<'\''EOF'\''
[[ '\''&'\'' =~ & ]] && echo amp
EOF
echo amp=$?

# Oh I guess this is not a bug?  regcomp doesn'\''t reject this trivial regex?
$SH <<'\''EOF'\''
[[ '\''|'\'' =~ | ]] && echo pipe1
[[ '\''a'\'' =~ | ]] && echo pipe2
EOF
echo pipe=$?

$SH <<'\''EOF'\''
[[ '\''|'\'' =~ a| ]] && echo four
EOF
echo pipe=$?

# This is probably special because > operator is inside foo [[ a > b ]]
$SH <<'\''EOF'\''
[[ '\''<>'\'' =~ <> ]] && echo angle
EOF
echo angle=$?

# Bug: OSH allowed this!
$SH <<'\''EOF'\''
[[ $'\''a\nb'\'' =~ a
b ]] && echo newline
EOF
echo newline=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '033 Quotes '\'''\''  '\'''\''  in pattern' {
  local cmd='$SH <<'\''EOF'\''
[[ '\''|'\'' =~ '\''|'\'' ]] && echo sq
EOF
echo sq=$?

$SH <<'\''EOF'\''
[[ '\''|'\'' =~ "|" ]] && echo dq
EOF
echo dq=$?

$SH <<'\''EOF'\''
[[ '\''|'\'' =~ $'\''|'\'' ]] && echo dollar-sq
EOF
echo dollar-sq=$?

$SH <<'\''EOF'\''
[[ '\''|'\'' =~ $"|" ]] && echo dollar-dq
EOF
echo dollar-dq=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '034 Unicode in pattern' {
  local cmd='$SH <<'\''EOF'\''
[[ μ =~ μ ]] && echo mu
EOF
echo mu=$?'
  bash_out=$(SH=bash bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$(SH="$_repo/exe/rubish" $RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '035 Parse error with 2 words' {
  local cmd='if [[ a =~ c a ]]; then
  echo one
fi'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '036 make a lisp example' {
  local cmd='str='\''(hi)'\''
[[ "${str}" =~ ^^([][{}\(\)^@])|^(~@)|(\"(\\.|[^\\\"])*\")|^(;[^$'\''\n'\'']*)|^([~\'\''\`])|^([^][ ~\`\'\''\";{}\(\)^@\,]+)|^[,]|^[[:space:]]+ ]]
echo status=$?

m=${BASH_REMATCH[0]}
echo m=$m'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '037 Operators and space lose meaning inside ()' {
  local cmd='[[ '\''< >'\'' =~ (< >) ]] && echo true'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

