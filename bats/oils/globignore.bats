#!/usr/bin/env bats
# Generated from oils-for-unix spec/globignore.test.sh
# Live bash vs rubish (bash/OSH layer); oils' own expected output is not used.

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() { export BATS_TEST_TIMEOUT=2; }

setup() { cd "$BATS_TEST_TMPDIR" || return 1; export HOME="$BATS_TEST_TMPDIR"; PATH="$BATS_TEST_DIRNAME/bin:$PATH"; }

@test '001 Don'\''t glob flags on file system with GLOBIGNORE' {
  local cmd='touch _tmp/-n _tmp/zzzzz
cd _tmp
GLOBIGNORE=-*:zzzzz  # colon-separated pattern list
echo -* hello zzzz?'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '002 Ignore *.txt' {
  local cmd='touch one.md one.txt
mkdir -p foo
touch foo/{two.md,two.txt}
GLOBIGNORE=*.txt
echo *.* foo/*.*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '003 Ignore ?.txt' {
  local cmd='touch {1,10}.txt
mkdir -p foo
touch foo/{2,20}.txt
GLOBIGNORE=?.txt
echo *.* foo/*.*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '004 Ignore *.o:*.h' {
  local cmd='touch {hello.c,hello.h,hello.o,hello}
GLOBIGNORE=*.o:*.h
echo hello*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '005 Ignore single file src/__main__.py' {
  local cmd='mkdir src
touch src/{__init__.py,__main__.py}
GLOBIGNORE='\''src/__init__.py'\''
echo src/*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '006 Ignore dirs dist/*:node_modules/*' {
  local cmd='mkdir {src,compose,dist,node_modules}
touch src/{a.js,b.js}
touch compose/{base.compose.yaml,dev.compose.yaml}
touch dist/index.js
touch node_modules/package.js
GLOBIGNORE=dist/*:node_modules/*
echo */*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '007 find files in subdirectory but not the ignored pattern' {
  local cmd='mkdir {dir1,dir2}
touch dir1/{a.txt,ignore.txt}
touch dir2/{a.txt,ignore.txt}
GLOBIGNORE=*/ignore*
echo */*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
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
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
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
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '010 Ignore *' {
  local cmd='# This pattern appears in public repositories
touch {1.txt,2.log,3.md}
GLOBIGNORE=*
echo *'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '011 treat escaped patterns literally' {
  local cmd='touch {escape-10.txt,escape*.txt}
GLOBIGNORE="escape\*.txt"
echo *.*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '012 resetting globignore reverts to default behaviour' {
  local cmd='touch reset.txt
GLOBIGNORE=*.txt
echo *.*
GLOBIGNORE=
echo *.*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
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
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
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
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '015 . and .. always filtered when GLOBIGNORE is set' {
  local cmd='# When GLOBIGNORE is set to any non-null value, . and .. are always filtered
touch .hidden
GLOBIGNORE=*.txt

echo .*
shopt -u globskipdots
echo .*'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '016 When GLOBIGNORE is set, glob may become empty (nullglob too)' {
  local cmd='touch -- foo.txt -foo.txt

echo *t

GLOBIGNORE=*.txt
echo *t

shopt -s nullglob
echo nullglob *t'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '017 When GLOBIGNORE is set, no_dash_glob isn'\''t respected' {
  local cmd='case $SH in bash) exit ;; esac

touch -- foo.txt -foo.txt

shopt -s no_dash_glob  # YSH option

echo *  # expansion does NOT include -foo.txt

GLOBIGNORE=f*.txt
echo *  # expansion includes -foo.txt, because it doesn'\''t match GLOBIGNORE'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

@test '018 Extended glob expansion combined with GLOBIGNORE' {
  local cmd='shopt -s extglob

touch foo.cc foo.h bar.cc bar.h 
echo @(*.cc|*.h)
GLOBIGNORE=foo.*
echo @(*.cc|*.h)'
  bash_out=$(bash -c "$cmd" 2>&1); bash_exit=$?
  rubish_out=$($RUBISH -c "$cmd" 2>&1); rubish_exit=$?
  [ "$bash_exit" = "$rubish_exit" ] && [ "$bash_out" = "$rubish_out" ]
}

