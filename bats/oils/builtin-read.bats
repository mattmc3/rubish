#!/usr/bin/env bats
# Generated from oils-for-unix spec/builtin-read.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 read line from here doc' {
  local cmd='# NOTE: there are TABS below
read x <<EOF
A		B C D E
FG
EOF
echo "[$x]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 read from empty file' {
  local cmd='echo -n '\'''\'' > $TMP/empty.txt
read x < $TMP/empty.txt
argv.py "status=$?" "$x"

# No variable name, behaves the same
read < $TMP/empty.txt
argv.py "status=$?" "$REPLY"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 read /dev/null' {
  local cmd='read -n 1 </dev/null
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 read with zero args' {
  local cmd='echo | read
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 read builtin with no newline returns status 1' {
  local cmd='# This is odd because the variable is populated successfully.  OSH/YSH might
# need a separate put reading feature that doesn'\''t use IFS.

echo -n ZZZ | { read x; echo status=$?; echo $x; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 read builtin splits value across multiple vars' {
  local cmd='# NOTE: there are TABS below
read x y z <<EOF
A		B C D E 
FG
EOF
echo "[$x/$y/$z]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 read builtin with too few variables' {
  local cmd='set -o errexit
set -o nounset  # hm this doesn'\''t change it
read x y z <<EOF
A B
EOF
echo /$x/$y/$z/'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 read -n (with REPLY)' {
  local cmd='echo 12345 > $TMP/readn.txt
read -n 4 x < $TMP/readn.txt
read -n 2 < $TMP/readn.txt  # Do it again with no variable
argv.py $x $REPLY'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 IFS= read -n (OSH regression: value saved in tempenv)' {
  local cmd='echo XYZ > "$TMP/readn.txt"
IFS= TMOUT= read -n 1 char < "$TMP/readn.txt"
argv.py "$char"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 read -n doesn'\''t strip whitespace (bug fix)' {
  local cmd='case $SH in dash|zsh) exit ;; esac

echo '\''  a b  '\'' | (read -n 4; echo "[$REPLY]")
echo '\''  a b  '\'' | (read -n 5; echo "[$REPLY]")
echo '\''  a b  '\'' | (read -n 6; echo "[$REPLY]")
echo

echo '\''one var strips whitespace'\''
echo '\''  a b  '\'' | (read -n 4 myvar; echo "[$myvar]")
echo '\''  a b  '\'' | (read -n 5 myvar; echo "[$myvar]")
echo '\''  a b  '\'' | (read -n 6 myvar; echo "[$myvar]")
echo

echo '\''three vars'\''
echo '\''  a b  '\'' | (read -n 4 x y z; echo "[$x] [$y] [$z]")
echo '\''  a b  '\'' | (read -n 5 x y z; echo "[$x] [$y] [$z]")
echo '\''  a b  '\'' | (read -n 6 x y z; echo "[$x] [$y] [$z]")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 read -d -n - respects delimiter and splits' {
  local cmd='case $SH in dash|zsh|ash) exit ;; esac

echo '\''delim c'\''
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 3; echo "[$REPLY]")
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 4; echo "[$REPLY]")
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 5; echo "[$REPLY]")
echo

echo '\''one var'\''
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 3 myvar; echo "[$myvar]")
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 4 myvar; echo "[$myvar]")
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 5 myvar; echo "[$myvar]")
echo

echo '\''three vars'\''
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 3 x y z; echo "[$x] [$y] [$z]")
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 4 x y z; echo "[$x] [$y] [$z]")
echo '\''  a b c '\'' | (read -d '\''c'\'' -n 5 x y z; echo "[$x] [$y] [$z]")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 read -n with invalid arg' {
  local cmd='read -n not_a_number
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 read -n from pipe' {
  local cmd='case $SH in dash|ash|zsh) exit ;; esac

echo abcxyz | { read -n 3; echo reply=$REPLY; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 read without args uses REPLY, no splitting occurs (without -n)' {
  local cmd='# mksh and zsh implement splitting with $REPLY, bash/ash don'\''t

echo '\''  a b  '\'' | (read; echo "[$REPLY]")
echo '\''  a b  '\'' | (read myvar; echo "[$myvar]")

echo '\''  a b  \
  line2'\'' | (read; echo "[$REPLY]")
echo '\''  a b  \
  line2'\'' | (read myvar; echo "[$myvar]")

# Now test with -r
echo '\''  a b  \
  line2'\'' | (read -r; echo "[$REPLY]")
echo '\''  a b  \
  line2'\'' | (read -r myvar; echo "[$myvar]")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 read -n vs. -N' {
  local cmd='# dash, ash and zsh do not implement read -N
# mksh treats -N exactly the same as -n
case $SH in dash|ash|zsh) exit ;; esac

# bash docs: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html

echo '\''a b c'\'' > $TMP/readn.txt

echo '\''read -n'\''
read -n 5 A B C < $TMP/readn.txt; echo "'\''$A'\'' '\''$B'\'' '\''$C'\''"
read -n 4 A B C < $TMP/readn.txt; echo "'\''$A'\'' '\''$B'\'' '\''$C'\''"
echo

echo '\''read -N'\''
read -N 5 A B C < $TMP/readn.txt; echo "'\''$A'\'' '\''$B'\'' '\''$C'\''"
read -N 4 A B C < $TMP/readn.txt; echo "'\''$A'\'' '\''$B'\'' '\''$C'\''"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 read -N ignores delimiters' {
  local cmd='case $SH in dash|ash|zsh) exit ;; esac

echo $'\''a\nb\nc'\'' > $TMP/read-lines.txt

read -N 3 out < $TMP/read-lines.txt
echo "$out"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 read will unset extranous vars' {
  local cmd='echo '\''a b'\'' > $TMP/read-few.txt

c='\''some value'\''
read a b c < $TMP/read-few.txt
echo "'\''$a'\'' '\''$b'\'' '\''$c'\''"

case $SH in dash) exit ;; esac # dash does not implement -n

c='\''some value'\''
read -n 3 a b c < $TMP/read-few.txt
echo "'\''$a'\'' '\''$b'\'' '\''$c'\''"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 read -r ignores backslashes' {
  local cmd='echo '\''one\ two'\'' > $TMP/readr.txt
read escaped < $TMP/readr.txt
read -r raw < $TMP/readr.txt
argv.py "$escaped" "$raw"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '019 read -r with other backslash escapes' {
  local cmd='echo '\''one\ two\x65three'\'' > $TMP/readr.txt
read escaped < $TMP/readr.txt
read -r raw < $TMP/readr.txt
argv.py "$escaped" "$raw"
# mksh respects the hex escapes here, but other shells don'\''t!'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '020 read with line continuation reads multiple physical lines' {
  local cmd='# NOTE: osh failing because of file descriptor issue.  stdin has to be closed!
tmp=$TMP/$(basename $SH)-readr.txt
echo -e '\''one\\\ntwo\n'\'' > $tmp
read escaped < $tmp
read -r raw < $tmp
argv.py "$escaped" "$raw"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '021 read multiple vars spanning many lines' {
  local cmd='read x y << '\''EOF'\''
one-\
two three-\
four five-\
six
EOF
argv.py "$x" "$y" "$z"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '022 read -r with n' {
  local cmd='echo '\''\nline'\'' > $TMP/readr.txt
read escaped < $TMP/readr.txt
read -r raw < $TMP/readr.txt
argv.py "$escaped" "$raw"
# dash/mksh/zsh are bugs because at least the raw mode should let you read a
# literal \n.'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '023 read -s from pipe, not a terminal' {
  local cmd='case $SH in dash|zsh) exit ;; esac

# It'\''s hard to really test this because it requires a terminal.  We hit a
# different code path when reading through a pipe.  There can be bugs there
# too!

echo foo | { read -s; echo $REPLY; }
echo bar | { read -n 2 -s; echo $REPLY; }

# Hm no exit 1 here?  Weird
echo b | { read -n 2 -s; echo $?; echo $REPLY; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '024 read with IFS='\''n'\''' {
  local cmd='# The leading spaces are stripped if they appear in IFS.
IFS=$(echo -e '\''\n'\'')
read var <<EOF
  a b c
  d e f
EOF
echo "[$var]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '025 read multiple lines with IFS=:' {
  local cmd='# The leading spaces are stripped if they appear in IFS.
# IFS chars are escaped with :.
tmp=$TMP/$(basename $SH)-read-ifs.txt
IFS=:
cat >$tmp <<'\''EOF'\''
  \\a :b\: c:d\
  e
EOF
read a b c d < $tmp
# Use printf because echo in dash/mksh interprets escapes, while it doesn'\''t in
# bash.
printf "%s\n" "[$a|$b|$c|$d]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '026 read with IFS='\'''\''' {
  local cmd='IFS='\'''\''
read x y <<EOF
  a b c d
EOF
echo "[$x|$y]"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '027 read does not respect C backslash escapes' {
  local cmd='# bash doesn'\''t respect these, but other shells do.  Gah!  I think bash
# behavior makes more sense.  It only escapes IFS.
echo '\''\a \b \c \d \e \f \g \h \x65 \145 \i'\'' > $TMP/read-c.txt
read line < $TMP/read-c.txt
echo $line'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '028 dynamic scope used to set vars' {
  local cmd='f() {
  read head << EOF
ref: refs/heads/dev/andy
EOF
}
f
echo $head'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '029 read -a reads into array' {
  local cmd='# read -a is used in bash-completion
# none of these shells implement it
case $SH in
  *mksh|*dash|*zsh|*/ash)
    exit 2;
    ;;
esac

read -a myarray <<'\''EOF'\''
a b c\ d
EOF
argv.py "${myarray[@]}"

# arguments are ignored here
read -r -a array2 extra arguments <<'\''EOF'\''
a b c\ d
EOF
argv.py "${array2[@]}"
argv.py "${extra[@]}"
argv.py "${arguments[@]}"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '030 read -d : (colon-separated records)' {
  local cmd='printf a,b,c:d,e,f:g,h,i | {
  IFS=,
  read -d : v1
  echo "v1=$v1"
  read -d : v1 v2
  echo "v1=$v1 v2=$v2"
  read -d : v1 v2 v3
  echo "v1=$v1 v2=$v2 v3=$v3"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '031 read -d '\'''\'' (null-separated records)' {
  local cmd='printf '\''a,b,c\0d,e,f\0g,h,i'\'' | {
  IFS=,
  read -d '\'''\'' v1
  echo "v1=$v1"
  read -d '\'''\'' v1 v2
  echo "v1=$v1 v2=$v2"
  read -d '\'''\'' v1 v2 v3
  echo "v1=$v1 v2=$v2 v3=$v3"
}'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '032 read -rd' {
  local cmd='read -rd '\'''\'' var <<EOF
foo
bar
EOF
echo "$var"'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '033 read -d when there'\''s no delimiter' {
  local cmd='{ read -d : part
  echo $part $?
  read -d : part
  echo $part $?
} <<EOF
foo:bar
EOF'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '034 read -t 0 tests if input is available' {
  local cmd='case $SH in dash|zsh|mksh) exit ;; esac

# is there input available?
read -t 0 < /dev/null
echo $?

# floating point
read -t 0.0 < /dev/null
echo $?

# floating point
echo foo | { read -t 0; echo reply=$REPLY; }
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '035 read -t 0.5' {
  local cmd='case $SH in dash) exit ;; esac

read -t 0.5 < /dev/null
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '036 read -t -0.5 is invalid' {
  local cmd='# bash appears to just take the absolute value?

read -t -0.5 < /dev/null
echo $?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '037 read -u' {
  local cmd='case $SH in dash|mksh) exit ;; esac

# file descriptor
read -u 3 3<<EOF
hi
EOF
echo reply=$REPLY'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '038 read -u syntax error' {
  local cmd='read -u -3
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '039 read -u -s' {
  local cmd='case $SH in dash|mksh) exit ;; esac

# file descriptor
read -s -u 3 3<<EOF
hi
EOF
echo reply=$REPLY'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '040 read -u 3 -d 5' {
  local cmd='case $SH in dash|mksh) exit ;; esac

# file descriptor
read -u 3 -d 5 3<<EOF
123456789
EOF
echo reply=$REPLY'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '041 read -u 3 -d b -N 6' {
  local cmd='case $SH in ash|zsh) exit ;; esac

# file descriptor
read -u 3 -d b -N 4 3<<EOF
ababababa
EOF
echo reply=$REPLY
# test end on EOF
read -u 3 -d b -N 6 3<<EOF
ab
EOF
echo reply=$REPLY'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '042 read -N doesn'\''t respect delimiter, while read -n does' {
  local cmd='case $SH in dash|zsh|ash) exit ;; esac

echo foobar | { read -n 5 -d b; echo $REPLY; }
echo foobar | { read -N 5 -d b; echo $REPLY; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '043 read -p (not fully tested)' {
  local cmd='# hm DISABLED if we'\''re not going to the terminal
# so we'\''re only testing that it accepts the flag here

case $SH in dash|mksh|zsh) exit ;; esac

echo hi | { read -p '\''P'\''; echo $REPLY; }
echo hi | { read -p '\''P'\'' -n 1; echo $REPLY; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '044 read usage' {
  local cmd='read -n -1
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '045 read with smooshed args' {
  local cmd='echo hi | { read -rn1 var; echo var=$var; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '046 read -r -d '\'''\'' for NUL strings, e.g. find -print0' {
  local cmd='case $SH in dash|zsh|mksh) exit ;; esac  # NOT IMPLEMENTED

mkdir -p read0
cd read0
rm -f *

touch a\\b\\c\\d  # -r is necessary!

find . -type f -a -print0 | { read -r -d '\'''\''; echo "[$REPLY]"; }'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '047 read from redirected directory is non-fatal error' {
  local cmd='# This tickles an infinite loop bug in our version of mksh!  TODO: upgrade the
# version and enable this
case $SH in mksh) return ;; esac

cd $TMP
mkdir -p dir
read x < ./dir
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '048 read -n from directory' {
  local cmd='case $SH in dash|ash) return ;; esac  # not implemented

# same hanging bug
case $SH in mksh) return ;; esac

mkdir -p dir
read -n 3 x < ./dir
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '049 mapfile from directory (bash doesn'\''t handle errors)' {
  local cmd='case $SH in dash|ash|mksh|zsh) return ;; esac  # not implemented

mkdir -p dir
mapfile $x < ./dir
echo status=$?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '050 read -n 0' {
  local cmd='case $SH in zsh) exit 99;; esac  # read -n not implemented

echo '\''a\b\c\d\e\f'\'' | (read -n 0; argv.py "$REPLY")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '051 read -n and backslash escape' {
  local cmd='case $SH in zsh) exit 99;; esac  # read -n not implemented

echo '\''a\b\c\d\e\f'\'' | (read -n 5; argv.py "$REPLY")
echo '\''a\ \ \ \ \ '\'' | (read -n 5; argv.py "$REPLY")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '052 read -n 4 with incomplete backslash' {
  local cmd='case $SH in zsh) exit 99;; esac  # read -n not implemented

echo '\''abc\def\ghijklmn'\'' | (read -n 4; argv.py "$REPLY")
echo '\''   \xxx\xxxxxxxx'\'' | (read -n 4; argv.py "$REPLY")

# bash implements "-n NUM" as number of characters'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '053 read -n 4 with backslash + delim' {
  local cmd='case $SH in zsh) exit 99;; esac  # read -n not implemented

echo $'\''abc\\\ndefg'\'' | (read -n 4; argv.py "$REPLY")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '054 backslash + newline should be swallowed regardless of -d <delim>' {
  local cmd='printf '\''%s\n'\'' '\''a b\'\'' '\''c d'\'' | (read; argv.py "$REPLY")
printf '\''%s\n'\'' '\''a b\,c d'\''   | (read; argv.py "$REPLY")
printf '\''%s\n'\'' '\''a b\'\'' '\''c d'\'' | (read -d ,; argv.py "$REPLY")
printf '\''%s\n'\'' '\''a b\,c d'\''   | (read -d ,; argv.py "$REPLY")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '055 empty input and splitting' {
  local cmd='case $SH in mksh|ash|dash|zsh) exit 99; esac
echo '\'''\'' | (read -a a; argv.py "${a[@]}")
IFS=x
echo '\'''\'' | (read -a a; argv.py "${a[@]}")
IFS=
echo '\'''\'' | (read -a a; argv.py "${a[@]}")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '056 IFS='\''x '\'' read -a: trailing spaces (unlimited split)' {
  local cmd='case $SH in mksh|ash|dash|zsh) exit 99; esac
IFS='\''x '\''
echo '\''a b'\''     | (read -a a; argv.py "${a[@]}")
echo '\''a b '\''    | (read -a a; argv.py "${a[@]}")
echo '\''a bx'\''    | (read -a a; argv.py "${a[@]}")
echo '\''a bx '\''   | (read -a a; argv.py "${a[@]}")
echo '\''a b x'\''   | (read -a a; argv.py "${a[@]}")
echo '\''a b x '\''  | (read -a a; argv.py "${a[@]}")
echo '\''a b x x'\'' | (read -a a; argv.py "${a[@]}")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '057 IFS='\''x '\'' read a b: trailing spaces (with max_split)' {
  local cmd='echo '\''hello world  test   '\'' | (read a b; argv.py "$a" "$b")
echo '\''-- IFS=x --'\''
IFS='\''x '\''
echo '\''a ax  x  '\''     | (read a b; argv.py "$a" "$b")
echo '\''a ax  x  x'\''    | (read a b; argv.py "$a" "$b")
echo '\''a ax  x  x  '\''  | (read a b; argv.py "$a" "$b")
echo '\''a ax  x  x  a'\'' | (read a b; argv.py "$a" "$b")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '058 IFS='\''x '\'' read -a: intermediate spaces (unlimited split)' {
  local cmd='case $SH in mksh|ash|dash|zsh) exit 99; esac
IFS='\''x '\''
echo '\''a x b'\''   | (read -a a; argv.py "${a[@]}")
echo '\''a xx b'\''  | (read -a a; argv.py "${a[@]}")
echo '\''a xxx b'\'' | (read -a a; argv.py "${a[@]}")
echo '\''a x xb'\''  | (read -a a; argv.py "${a[@]}")
echo '\''a x x b'\'' | (read -a a; argv.py "${a[@]}")
echo '\''ax b'\''    | (read -a a; argv.py "${a[@]}")
echo '\''ax xb'\''   | (read -a a; argv.py "${a[@]}")
echo '\''ax  xb'\''  | (read -a a; argv.py "${a[@]}")
echo '\''ax x xb'\'' | (read -a a; argv.py "${a[@]}")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '059 IFS='\''x '\'' incomplete backslash' {
  local cmd='echo '\'' a b \'\'' | (read a; argv.py "$a")
echo '\'' a b \'\'' | (read a b; argv.py "$a" "$b")
IFS='\''x '\''
echo $'\''a ax  x    \\\nhello'\'' | (read a b; argv.py "$a" "$b")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '060 IFS='\'' '\'' and backslash escaping' {
  local cmd='IFS='\''\ '\''
echo "hello\ world  test" | (read a b; argv.py "$a" "$b")
IFS='\''\'\''
echo "hello\ world  test" | (read a b; argv.py "$a" "$b")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '061 max_split and backslash escaping' {
  local cmd='echo '\''Aa b \ a\ b'\'' | (read a b; argv.py "$a" "$b")
echo '\''Aa b \ a\ b'\'' | (read a b c; argv.py "$a" "$b" "$c")
echo '\''Aa b \ a\ b'\'' | (read a b c d; argv.py "$a" "$b" "$c" "$d")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '062 IFS=x read a b <<< xxxxxx' {
  local cmd='IFS='\''x '\''
echo x     | (read a b; argv.py "$a" "$b")
echo xx    | (read a b; argv.py "$a" "$b")
echo xxx   | (read a b; argv.py "$a" "$b")
echo xxxx  | (read a b; argv.py "$a" "$b")
echo xxxxx | (read a b; argv.py "$a" "$b")
echo '\''-- spaces --'\''
echo '\''x    '\'' | (read a b; argv.py "$a" "$b")
echo '\''xx   '\'' | (read a b; argv.py "$a" "$b")
echo '\''xxx  '\'' | (read a b; argv.py "$a" "$b")
echo '\''xxxx '\'' | (read a b; argv.py "$a" "$b")
echo '\''xxxxx'\'' | (read a b; argv.py "$a" "$b")
echo '\''-- with char --'\''
echo '\''xa    '\'' | (read a b; argv.py "$a" "$b")
echo '\''xax   '\'' | (read a b; argv.py "$a" "$b")
echo '\''xaxx  '\'' | (read a b; argv.py "$a" "$b")
echo '\''xaxxx '\'' | (read a b; argv.py "$a" "$b")
echo '\''xaxxxx'\'' | (read a b; argv.py "$a" "$b")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '063 read and  ' {
  local cmd='IFS='\''x '\''
check() { echo "$1" | (read a b; argv.py "$a" "$b"); }

echo '\''-- xs... --'\''
check '\''x '\''
check '\''x \ '\''
check '\''x \ \ '\''
check '\''x \ \ \ '\''
echo '\''-- xe... --'\''
check '\''x\ '\''
check '\''x\ \ '\''
check '\''x\ \ \ '\''
check '\''x\  '\''
check '\''x\  '\''
check '\''x\    '\''

# check '\''xx\ '\''
# check '\''xx\ '\'''
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '064 read bash bug' {
  local cmd='IFS='\''x '\''
echo '\''x\  \ '\'' | (read a b; argv.py "$a" "$b")'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

