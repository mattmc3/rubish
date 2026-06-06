#!/usr/bin/env bats
# Generated from oils-for-unix spec/here-doc.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Here string' {
  local cmd='cat <<< '\''hi'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Here string with ' {
  local cmd='cat <<< $'\''one\ntwo\n'\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Here redirect with explicit descriptor' {
  local cmd='# A space between 0 and <<EOF causes it to pass '\''0'\'' as an arg to cat.
cat 0<<EOF
one
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Here doc from another input file descriptor' {
  local cmd='# NOTE: OSH fails on descriptor 9, but not descriptor 8?  Is this because of
# the Python VM?  How  to inspect state?
read_from_fd.py 8  8<<EOF
here doc on descriptor
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Multiple here docs with different descriptors' {
  local cmd='read_from_fd.py 0 3 <<EOF 3<<EOF3
fd0
EOF
fd3
EOF3'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Here doc with bad var delimiter' {
  local cmd='# Most shells accept this, but OSH is stricter.
cat <<${a}
here
${a}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 Here doc with bad comsub delimiter' {
  local cmd='# bash is OK with this; dash isn'\''t.  Should be a parse error.
cat <<$(a)
here
$(a)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Here doc and < redirect -- last one wins' {
  local cmd='echo hello >$TMP/hello.txt

cat <<EOF <$TMP/hello.txt
here
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 < redirect and here doc -- last one wins' {
  local cmd='echo hello >$TMP/hello.txt

cat <$TMP/hello.txt <<EOF
here
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Here doc with var sub, command sub, arith sub' {
  local cmd='var=v
cat <<EOF
var: ${var}
command: $(echo hi)
arith: $((1+2))
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 Here doc in middle.  And redirects in the middle.' {
  local cmd='# This isn'\''t specified by the POSIX grammar, but it'\''s accepted by both dash and
# bash!
echo foo > foo.txt
echo bar > bar.txt
cat <<EOF 1>&2 foo.txt - bar.txt
here
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 Here doc line continuation' {
  local cmd='cat <<EOF \
; echo two
one
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Here doc with quote expansion in terminator' {
  local cmd='cat <<'\''EOF'\''"2"
one
two
EOF2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Here doc with multiline double quoted string' {
  local cmd='cat <<EOF; echo "two
three"
one
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 Two here docs -- first is ignored; second ones wins!' {
  local cmd='<<EOF1 cat <<EOF2
hello
EOF1
there
EOF2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 Here doc with line continuation, then pipe.  Syntax error.' {
  local cmd='cat <<EOF \
1
2
3
EOF
| tac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 Here doc with pipe on first line' {
  local cmd='cat <<EOF | tac
1
2
3
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Here doc with pipe continued on last line' {
  local cmd='cat <<EOF |
1
2
3
EOF
tac'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 Here doc with builtin '\''read'\''' {
  local cmd='# read can'\''t be run in a subshell.
read v1 v2 <<EOF
val1 val2
EOF
echo =$v1= =$v2='
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 Compound command here doc' {
  local cmd='while read line; do
  echo X $line
done <<EOF
1
2
3
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 Here doc in while condition and here doc in body' {
  local cmd='while cat <<E1 && cat <<E2; do cat <<E3; break; done
1
E1
2
E2
3
E3'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 Here doc in while condition and here doc in body on multiple lines' {
  local cmd='while cat <<E1 && cat <<E2
1
E1
2
E2
do
  cat <<E3
3
E3
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 Here doc in while loop split up more' {
  local cmd='while cat <<E1
1
E1

cat <<E2
2
E2

do
  cat <<E3
3
E3
  break
done'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 Mixing << and <<-' {
  local cmd='cat <<-EOF; echo --; cat <<EOF2
	one
EOF
two
EOF2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 Two compound commands with two here docs' {
  local cmd='while read line; do echo X $line; done <<EOF; echo ==;  while read line; do echo Y $line; done <<EOF2
1
2
EOF
3
4
EOF2'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 Function def and execution with here doc' {
  local cmd='fun() { cat; } <<EOF; echo before; fun; echo after 
1
2
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 Here doc as command prefix' {
  local cmd='<<EOF tac
1
2
3
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 Redirect after here doc' {
  local cmd='cat <<EOF 1>&2
out
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 here doc stripping tabs' {
  local cmd='cat <<-EOF
	1
	2
		3  # 2 tabs are both stripped
  4  # spaces are preserved
	EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 Here doc within subshell with boolean' {
  local cmd='[[ $(cat <<EOF
foo
EOF
) == foo ]]; echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 Here Doc in if condition' {
  local cmd='if cat <<EOF; then
here doc in IF CONDITION
EOF
  echo THEN executed
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 Nested here docs which are indented' {
  local cmd='cat <<- EOF
	outside
	$(cat <<- INSIDE
		inside
INSIDE
)
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 Multiple here docs in pipeline' {
  local cmd='case $SH in *osh) exit ;; esac

# The second instance reads its stdin from the pipe, and fd 5 from a here doc.
read_from_fd.py 3 3<<EOF3 | read_from_fd.py 0 5 5<<EOF5
fd3
EOF3
fd5
EOF5

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 Multiple here docs in pipeline on multiple lines' {
  local cmd='case $SH in *osh) exit ;; esac

# SKIPPED: hangs with osh on Debian
# The second instance reads its stdin from the pipe, and fd 5 from a here doc.
read_from_fd.py 3 3<<EOF3 |
fd3
EOF3
read_from_fd.py 0 5 5<<EOF5
fd5
EOF5

echo ok'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 Here doc and backslash double quote' {
  local cmd='cat <<EOF
a \"quote\"
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 Here doc escapes' {
  local cmd='# these are the chars from _DQ_ESCAPED_CHAR
cat <<EOF
\\ \" \$ \`
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

