#!/usr/bin/env bats
# Generated from oils-for-unix spec/paren-ambiguity.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 (( closed with ) ) after multiple lines is command - #2337' {
  local cmd='(( echo 1
echo 2
(( x ))
: $(( x ))
echo 3
) )'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 (( closed with ) ) after multiple lines is command - #2337' {
  local cmd='echo $(( echo 1
echo 2
(( x ))
: $(( x ))
echo 3
) )'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 (( closed with )) after multiple lines is parse error - #2337' {
  local cmd='$SH -c '\''
(( echo 1
echo 2
(( x ))
: $(( x ))
echo 3
))
'\''
if test $? -ne 0; then
  echo ok
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 (( closed with )) after multiple lines is parse error - #2337' {
  local cmd='$SH -c '\''
echo $(( echo 1
echo 2
(( x ))
: $(( x ))
echo 3
))
'\''
if test $? -ne 0; then
  echo ok
fi'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 (((grep example - 4+ instances in regtest/aports - #2337' {
  local cmd='# https://oilshell.zulipchat.com/#narrow/channel/502349-osh/topic/.28.28.28.20not.20parsed.20like.20bash/with/518874141

# spaces help
good() {
  cputype=`( ( (grep cpu /proc/cpuinfo | cut -d: -f2) ; ($PRTDIAG -v |grep -i sparc) ; grep -i cpu /var/run/dmesg.boot ) | head -n 1) 2> /dev/null`
}

bad() {
  cputype=`(((grep cpu /proc/cpuinfo | cut -d: -f2) ; ($PRTDIAG -v |grep -i sparc) ; grep -i cpu /var/run/dmesg.boot ) | head -n 1) 2> /dev/null`
  #echo cputype=$cputype
}

good
bad'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 ((gzip example - zdiff package - #2337' {
  local cmd='# https://github.com/git-for-windows/git-sdk-64/blob/main/usr/bin/zdiff#L136

gzip_status=$(
  exec 4>&1
  (gzip -cdfq -- "$file1" 4>&-; echo $? >&4) 3>&- |
      ((gzip -cdfq -- "$file2" 4>&-
        echo $? >&4) 3>&- 5<&- </dev/null |
       eval "$cmp" /dev/fd/5 - >&3) 5<&0
)
echo bye'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 ((pkg-config example - postfix package - #2337' {
  local cmd='icu_cppflags=`((pkg-config --cflags icu-uc icu-i18n) ||
                  (pkgconf --cflags icu-uc icu-i18n) ||
                  (icu-config --cppflags)) 2>/dev/null`
echo bye'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 ((test example - liblo package - #2337' {
  local cmd='if ! ((test x"$i" = x-g) || (test x"$i" = x-O2)); then
    CF="$CF $i"
fi
echo bye'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 ((which example - command sub versus arith sub - gnunet-gtk package' {
  local cmd='        gtk_update_icon_cache_bin="$((which gtk-update-icon-cache ||
echo /opt/gnome/bin/gtk-update-icon-cache)2>/dev/null)"

echo bye'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

