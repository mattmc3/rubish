#!/usr/bin/env bats
# Generated from oils-for-unix spec/globignore.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

RUBISH="bundle exec exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Don'\''t glob flags on file system with GLOBIGNORE' {
  local cmd='touch _tmp/-n _tmp/zzzzz
cd _tmp
GLOBIGNORE=-*:zzzzz  # colon-separated pattern list
echo -* hello zzzz?'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '002 Ignore *.txt' {
  local cmd='touch one.md one.txt
mkdir -p foo
touch foo/{two.md,two.txt}
GLOBIGNORE=*.txt
echo *.* foo/*.*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '003 Ignore ?.txt' {
  local cmd='touch {1,10}.txt
mkdir -p foo
touch foo/{2,20}.txt
GLOBIGNORE=?.txt
echo *.* foo/*.*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '004 Ignore *.o:*.h' {
  local cmd='touch {hello.c,hello.h,hello.o,hello}
GLOBIGNORE=*.o:*.h
echo hello*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '005 Ignore single file src/__main__.py' {
  local cmd='mkdir src
touch src/{__init__.py,__main__.py}
GLOBIGNORE='\''src/__init__.py'\''
echo src/*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '006 Ignore dirs dist/*:node_modules/*' {
  local cmd='mkdir {src,compose,dist,node_modules}
touch src/{a.js,b.js}
touch compose/{base.compose.yaml,dev.compose.yaml}
touch dist/index.js
touch node_modules/package.js
GLOBIGNORE=dist/*:node_modules/*
echo */*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '007 find files in subdirectory but not the ignored pattern' {
  local cmd='mkdir {dir1,dir2}
touch dir1/{a.txt,ignore.txt}
touch dir2/{a.txt,ignore.txt}
GLOBIGNORE=*/ignore*
echo */*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '008 Ignore globs with char patterns like [!ab]' {
  local cmd='rm -rf _tmp
touch {a,b,c,d,A,B,C,D}
GLOBIGNORE=*[ab]*
echo *
GLOBIGNORE=*[ABC]*
echo *
GLOBIGNORE=*[!ab]*
echo *'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '009 Ignore globs with char classes like [[:alnum:]]' {
  local cmd='touch {_testing.py,pyproject.toml,20231114.log,.env}
touch '\''has space.docx'\''
GLOBIGNORE=[[:alnum:]]*
echo *.*
GLOBIGNORE=[![:alnum:]]*
echo *.*
GLOBIGNORE=*[[:space:]]*
echo *.*
GLOBIGNORE=[[:digit:]_.]*
echo *.*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '010 Ignore *' {
  local cmd='# This pattern appears in public repositories
touch {1.txt,2.log,3.md}
GLOBIGNORE=*
echo *'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '011 treat escaped patterns literally' {
  local cmd='touch {escape-10.txt,escape*.txt}
GLOBIGNORE="escape\*.txt"
echo *.*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '012 resetting globignore reverts to default behaviour' {
  local cmd='touch reset.txt
GLOBIGNORE=*.txt
echo *.*
GLOBIGNORE=
echo *.*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '013 Ignore .:..' {
  local cmd='# globskipdots is enabled by default in bash >=5.2
# for bash <5.2 this pattern is a common way to match dotfiles but not . or ..
shopt -u globskipdots
touch .env
GLOBIGNORE=.:..
echo .*
GLOBIGNORE=
echo .* | sort'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '014 Quoting GLOBIGNORE' {
  local cmd='# each style of "ignore everything" spotted in a public repo
touch image.jpeg
GLOBIGNORE=*
echo *
GLOBIGNORE='\''*'\''
echo *
GLOBIGNORE="*"
echo *
GLOBIGNORE=\*
echo *'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '015 . and .. always filtered when GLOBIGNORE is set' {
  local cmd='# When GLOBIGNORE is set to any non-null value, . and .. are always filtered
touch .hidden
GLOBIGNORE=*.txt

echo .*
shopt -u globskipdots
echo .*'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '016 When GLOBIGNORE is set, glob may become empty (nullglob too)' {
  local cmd='touch -- foo.txt -foo.txt

echo *t

GLOBIGNORE=*.txt
echo *t

shopt -s nullglob
echo nullglob *t'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '017 When GLOBIGNORE is set, no_dash_glob isn'\''t respected' {
  local cmd='case $SH in bash) exit ;; esac

touch -- foo.txt -foo.txt

shopt -s no_dash_glob  # YSH option

echo *  # expansion does NOT include -foo.txt

GLOBIGNORE=f*.txt
echo *  # expansion includes -foo.txt, because it doesn'\''t match GLOBIGNORE'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

@test '018 Extended glob expansion combined with GLOBIGNORE' {
  local cmd='shopt -s extglob

touch foo.cc foo.h bar.cc bar.h 
echo @(*.cc|*.h)
GLOBIGNORE=foo.*
echo @(*.cc|*.h)'
  expected=$(bash -c "$cmd" 2>/dev/null)
  actual=$($RUBISH -c "$cmd" 2>/dev/null)
  [ "$actual" = "$expected" ]
}

