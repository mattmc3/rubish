# frozen_string_literal: true

# Tests sourced from .bash/tests/exp.tests, new-exp.tests, more-exp.tests
require_relative 'test_helper'

class TestBash_Exp < Test::Unit::TestCase
  def setup
    @repl = Rubish::REPL.new
    @tempdir = Dir.mktmpdir('rubish_bash_suite_test')
    @saved_env = ENV.to_h
  end

  def teardown
    FileUtils.rm_rf(@tempdir)
    ENV.clear
    @saved_env.each { |k, v| ENV[k] = v }
  end

  def outf
    File.join(@tempdir, 'out')
  end

  # x=hello; echo ${#x}  ->  5
  def test_param_length
    execute("x=hello; echo ${#x} > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # x=''; echo ${#x}  ->  0
  def test_param_length_empty
    execute("x=''; echo ${#x} > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # x=abcdefgh; echo ${x:2:3}  ->  cde
  def test_param_substring_offset_len
    execute("x=abcdefgh; echo ${x:2:3} > #{outf}")
    assert_equal "cde\n", File.read(outf)
  end

  # x=abcdefgh; echo ${x:2}  ->  cdefgh
  def test_param_substring_offset_only
    execute("x=abcdefgh; echo ${x:2} > #{outf}")
    assert_equal "cdefgh\n", File.read(outf)
  end

  # x=hello; echo ${x:-world}  ->  hello
  def test_param_default_when_set
    execute("x=hello; echo ${x:-world} > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # unset x; echo ${x:-world}  ->  world
  def test_param_default_when_unset
    execute("unset x; echo ${x:-world} > #{outf}")
    assert_equal "world\n", File.read(outf)
  end

  # x=''; echo ${x:-default}  ->  default
  def test_param_default_when_empty
    execute("x=''; echo ${x:-default} > #{outf}")
    assert_equal "default\n", File.read(outf)
  end

  # x=hello; echo ${x:+yes}  ->  yes
  def test_param_alternate_when_set
    execute("x=hello; echo ${x:+yes} > #{outf}")
    assert_equal "yes\n", File.read(outf)
  end

  # unset x; echo ${x:+yes}  ->  (empty line)
  def test_param_alternate_when_unset
    execute("unset x; echo ${x:+yes} > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # unset x; echo ${x:=assigned}  ->  assigned; x=assigned
  def test_param_assign_if_unset
    execute("unset x; echo ${x:=assigned} > #{outf}")
    assert_equal "assigned\n", File.read(outf)
    assert_equal 'assigned', get_shell_var('x')
  end

  # x=abcdef; echo ${x#abc}  ->  def
  def test_param_strip_prefix_shortest
    execute("x=abcdef; echo ${x#abc} > #{outf}")
    assert_equal "def\n", File.read(outf)
  end

  # x=abcabcdef; echo ${x##*abc}  ->  def
  def test_param_strip_prefix_longest
    execute("x=abcabcdef; echo ${x##*abc} > #{outf}")
    assert_equal "def\n", File.read(outf)
  end

  # x=abcdef; echo ${x%def}  ->  abc
  def test_param_strip_suffix_shortest
    execute("x=abcdef; echo ${x%def} > #{outf}")
    assert_equal "abc\n", File.read(outf)
  end

  # x=abcdefdef; echo ${x%%def*}  ->  abc
  def test_param_strip_suffix_longest
    execute("x=abcdefdef; echo ${x%%def*} > #{outf}")
    assert_equal "abc\n", File.read(outf)
  end

  # x=/path/to/file.txt; echo ${x##*/}  ->  file.txt
  def test_param_strip_path_prefix
    execute("x=/path/to/file.txt; echo ${x##*/} > #{outf}")
    assert_equal "file.txt\n", File.read(outf)
  end

  # x=/path/to/file.txt; echo ${x%.*}  ->  /path/to/file
  def test_param_strip_extension
    execute("x=/path/to/file.txt; echo ${x%.*} > #{outf}")
    assert_equal "/path/to/file\n", File.read(outf)
  end

  # x=hello; echo ${x/l/L}  ->  heLlo
  def test_param_replace_first
    execute("x=hello; echo ${x/l/L} > #{outf}")
    assert_equal "heLlo\n", File.read(outf)
  end

  # x=hello; echo ${x//l/L}  ->  heLLo
  def test_param_replace_all
    execute("x=hello; echo ${x//l/L} > #{outf}")
    assert_equal "heLLo\n", File.read(outf)
  end

  # x=hello; echo ${x^}  ->  Hello
  def test_param_upcase_first
    execute("x=hello; echo ${x^} > #{outf}")
    assert_equal "Hello\n", File.read(outf)
  end

  # x=hello; echo ${x^^}  ->  HELLO
  def test_param_upcase_all
    execute("x=hello; echo ${x^^} > #{outf}")
    assert_equal "HELLO\n", File.read(outf)
  end

  # x=HELLO; echo ${x,}  ->  hELLO
  def test_param_downcase_first
    execute("x=HELLO; echo ${x,} > #{outf}")
    assert_equal "hELLO\n", File.read(outf)
  end

  # x=HELLO; echo ${x,,}  ->  hello
  def test_param_downcase_all
    execute("x=HELLO; echo ${x,,} > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # foo='abcd   '; echo -${foo%% *}-  ->  -abcd-
  def test_param_strip_trailing_spaces_trim_greedy
    execute("foo='abcd   '; echo -${foo%% *}- > #{outf}")
    assert_equal "-abcd-\n", File.read(outf)
  end

  # var=abcde; echo ${var:-xyz}  ->  abcde
  def test_param_default_set_no_colon
    execute("var=abcde; echo ${var:-xyz} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # var=abcde; echo ${var:=xyz}  ->  abcde  (set, no assign)
  def test_param_assign_already_set
    execute("var=abcde; echo ${var:=xyz} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # var=abcde; echo ${var:+xyz}  ->  xyz
  def test_param_alternate_use_alternate
    execute("var=abcde; echo ${var:+xyz} > #{outf}")
    assert_equal "xyz\n", File.read(outf)
  end

  # x=abcdefghijklmnop; echo ${x:8}  ->  ijklmnop
  def test_param_substring_long
    execute("x=abcdefghijklmnop; echo ${x:8} > #{outf}")
    assert_equal "ijklmnop\n", File.read(outf)
  end

  # x=abcdefghijklmnop; echo ${x:0:4}  ->  abcd
  def test_param_substring_from_zero
    execute("x=abcdefghijklmnop; echo ${x:0:4} > #{outf}")
    assert_equal "abcd\n", File.read(outf)
  end

  # echo ${#PATH} matches length of PATH
  def test_param_length_of_env_var
    len = ENV['PATH'].length.to_s
    execute("echo ${#PATH} > #{outf}")
    assert_equal "#{len}\n", File.read(outf)
  end

  # x=hello; echo ${x/hello/world}  ->  world
  def test_param_replace_whole_word
    execute("x=hello; echo ${x/hello/world} > #{outf}")
    assert_equal "world\n", File.read(outf)
  end

  # x=aabbcc; echo ${x/b*/X}  ->  aaX
  def test_param_replace_glob_pattern
    execute("x=aabbcc; echo ${x/b*/X} > #{outf}")
    assert_equal "aaX\n", File.read(outf)
  end

  # x=hello; echo ${x/#hel/HEL}  ->  HELlo
  def test_param_replace_anchor_start
    execute("x=hello; echo ${x/#hel/HEL} > #{outf}")
    assert_equal "HELlo\n", File.read(outf)
  end

  # x=hello; echo ${x/%llo/LLO}  ->  heLLO
  def test_param_replace_anchor_end
    execute("x=hello; echo ${x/%llo/LLO} > #{outf}")
    assert_equal "heLLO\n", File.read(outf)
  end

  # unset x; echo ${x-unset}  ->  unset
  def test_param_default_no_colon_unset
    execute("unset x; echo ${x-unset} > #{outf}")
    assert_equal "unset\n", File.read(outf)
  end

  # x=''; echo ${x-unset}  ->  (empty) -- empty string is NOT unset for -
  def test_param_default_no_colon_empty_is_set
    execute("x=''; echo ${x-unset} > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # z=abcdefghijklmnop; echo ${z:0:4}  ->  abcd
  def test_newexp_substr_zero_four
    execute("z=abcdefghijklmnop; echo ${z:0:4} > #{outf}")
    assert_equal "abcd\n", File.read(outf)
  end

  # z=abcdefghijklmnop; echo ${z:4:3}  ->  efg
  def test_newexp_substr_four_three
    execute("z=abcdefghijklmnop; echo ${z:4:3} > #{outf}")
    assert_equal "efg\n", File.read(outf)
  end

  # z=abcdefghijklmnop; echo ${z:7:30}  ->  hijklmnop
  def test_newexp_substr_past_end
    execute("z=abcdefghijklmnop; echo ${z:7:30} > #{outf}")
    assert_equal "hijklmnop\n", File.read(outf)
  end

  # z=abcdefghijklmnop; echo ${z:0:100}  ->  abcdefghijklmnop
  def test_newexp_substr_len_exceeds
    execute("z=abcdefghijklmnop; echo ${z:0:100} > #{outf}")
    assert_equal "abcdefghijklmnop\n", File.read(outf)
  end

  # z=abcdefghijklmnop; echo ${z:0:${#z}}  ->  abcdefghijklmnop
  def test_newexp_substr_using_length
    omit 'nested ${#z} in substr length not yet supported'
    execute("z=abcdefghijklmnop; echo ${z:0:${#z}} > #{outf}")
    assert_equal "abcdefghijklmnop\n", File.read(outf)
  end

  # v=abcde; echo ${v/a[a-z]/xx}  ->  xxcde
  def test_newexp_replace_char_class
    execute("v=abcde; echo ${v/a[a-z]/xx} > #{outf}")
    assert_equal "xxcde\n", File.read(outf)
  end

  # v=abcde; echo ${v/a??/axx}  ->  axxde
  def test_newexp_replace_glob_3chars
    execute("v=abcde; echo ${v/a??/axx} > #{outf}")
    assert_equal "axxde\n", File.read(outf)
  end

  # v=abcde; echo ${v/c??/xyz}  ->  abxyz
  def test_newexp_replace_glob_mid
    execute("v=abcde; echo ${v/c??/xyz} > #{outf}")
    assert_equal "abxyz\n", File.read(outf)
  end

  # v=abcde; echo ${v/#a/ab}  ->  abbcde
  def test_newexp_replace_anchor_start
    execute("v=abcde; echo ${v/#a/ab} > #{outf}")
    assert_equal "abbcde\n", File.read(outf)
  end

  # v=abcde; echo ${v/#d/ab}  ->  abcde  (no match at start)
  def test_newexp_replace_anchor_start_no_match
    execute("v=abcde; echo ${v/#d/ab} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # v=abcde; echo ${v/d/ab}  ->  abcabe
  def test_newexp_replace_single
    execute("v=abcde; echo ${v/d/ab} > #{outf}")
    assert_equal "abcabe\n", File.read(outf)
  end

  # v=abcde; echo ${v/%?/last}  ->  abcdlast
  def test_newexp_replace_anchor_end
    execute("v=abcde; echo ${v/%?/last} > #{outf}")
    assert_equal "abcdlast\n", File.read(outf)
  end

  # v=abcde; echo ${v/%x/last}  ->  abcde  (no match)
  def test_newexp_replace_anchor_end_no_match
    execute("v=abcde; echo ${v/%x/last} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # foo='abcd   '; echo -${foo%% *}-  ->  -abcd-
  def test_newexp_strip_trailing_spaces_greedy
    execute("foo='abcd   '; echo -${foo%% *}- > #{outf}")
    assert_equal "-abcd-\n", File.read(outf)
  end

  # s1=abcdefghijkl s2=efgh; first=${s1/$s2*/}; echo $first  ->  abcd
  def test_newexp_strip_from_match
    omit 'variable reference in replacement pattern not yet working'
    execute("s1=abcdefghijkl; s2=efgh; first=\${s1/\$s2*/}; echo \$first > #{outf}")
    assert_equal "abcd\n", File.read(outf)
  end

  # x='abc'; echo ${x/b/B}  ->  aBc
  def test_newexp_replace_single_char
    execute("x=abc; echo ${x/b/B} > #{outf}")
    assert_equal "aBc\n", File.read(outf)
  end

  # x='aabbcc'; echo ${x//b/X}  ->  aaXXcc
  def test_newexp_replace_all_char
    execute("x=aabbcc; echo ${x//b/X} > #{outf}")
    assert_equal "aaXXcc\n", File.read(outf)
  end

  # x=hello; echo ${x/l*/X}  ->  heX  (first match only)
  def test_newexp_replace_glob_first_only
    execute("x=hello; echo ${x/l*/X} > #{outf}")
    assert_equal "heX\n", File.read(outf)
  end

  # x=hello; echo ${x/l/}  ->  helo
  def test_newexp_replace_empty_replacement
    execute("x=hello; echo ${x/l/} > #{outf}")
    assert_equal "helo\n", File.read(outf)
  end

  # x=abcdefghijklmnop; echo ${x: -3:3}  ->  nop
  def test_newexp_substr_negative_offset
    omit 'negative offset in ${x: -N:L} not yet supported'
    execute("x=abcdefghijklmnop; echo ${x: -3:3} > #{outf}")
    assert_equal "nop\n", File.read(outf)
  end

  # echo ${#var} on multi-word var
  def test_param_length_spaces
    execute("x='hello world'; echo ${#x} > #{outf}")
    assert_equal "11\n", File.read(outf)
  end

  # unset var, echo ${var:?msg}  ->  error
  def test_param_error_if_unset
    omit '${var:?msg} with stderr redirect 2>&1 not yet working'
    execute("unset MISS_VAR; (echo ${MISS_VAR:?missing}; echo nope) > #{outf} 2>&1; echo $? >> #{outf}")
    content = File.read(outf)
    assert_match(/missing/, content)
  end

  # x=hello; echo ${x:3}  ->  lo
  def test_param_substr_offset3
    execute("x=hello; echo ${x:3} > #{outf}")
    assert_equal "lo\n", File.read(outf)
  end

  # x=hello; echo ${x:1:3}  ->  ell
  def test_param_substr_offset1_len3
    execute("x=hello; echo ${x:1:3} > #{outf}")
    assert_equal "ell\n", File.read(outf)
  end

  # x=Hello; echo ${x,}  ->  hello
  def test_param_downcase_first_mixed
    execute("x=Hello; echo ${x,} > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # unset x; x=${x:=default}; echo $x  ->  default
  def test_param_assign_if_unset_stores
    execute("unset x; x=${x:=mydefault}; echo $x > #{outf}")
    assert_equal "mydefault\n", File.read(outf)
  end

  # x=foo; echo ${x:+alt}  ->  alt
  def test_param_alternate_nonempty
    execute("x=foo; echo ${x:+alt} > #{outf}")
    assert_equal "alt\n", File.read(outf)
  end

  # x=''; echo ${x:+alt}  ->  (empty)
  def test_param_alternate_empty
    execute("x=''; echo ${x:+alt} > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # exp.tests: arithmetic expansion $((expr))
  # expect '<42>'; recho $((28 + 14))
  def test_arith_expansion_basic
    execute("echo $((28 + 14)) > #{outf}")
    assert_equal "42\n", File.read(outf)
  end

  # exp.tests: arithmetic expansion $[expr]
  # expect '<26>'; recho $[ 13 * 2 ]
  def test_arith_expansion_bracket
    omit '$[...] arithmetic syntax not yet supported'
    execute("echo $[ 13 * 2 ] > #{outf}")
    assert_equal "26\n", File.read(outf)
  end

  # exp.tests: strip suffix then append -- x=file.c; echo ${x%.c}.o  ->  file.o
  # expect '<file.o>'; recho ${x%.c}.o
  def test_param_strip_suffix_then_append
    execute("x=file.c; echo ${x%.c}.o > #{outf}")
    assert_equal "file.o\n", File.read(outf)
  end

  # exp.tests: strip longest leading pattern -- x=posix/src/std; echo ${x%%/*}  ->  posix
  # expect '<posix>'; recho ${x%%/*}
  def test_param_strip_suffix_longest_slash
    execute("x=posix/src/std; echo ${x%%/*} > #{outf}")
    assert_equal "posix\n", File.read(outf)
  end

  # exp.tests: strip prefix using var as pattern -- x=$HOME/src/cmd; echo ${x#$HOME}  ->  /src/cmd
  # expect '</src/cmd>'; recho ${x#$HOME}
  def test_param_strip_prefix_var_pattern
    omit 'var-as-pattern in ${x#$HOME} not yet working'
    execute("HOME=/usr/homes/chet; x=/usr/homes/chet/src/cmd; echo ${x#$HOME} > #{outf}")
    assert_equal "/src/cmd\n", File.read(outf)
  end

  # exp.tests: non-matching pattern removal leaves value unchanged
  # z=abcdef; expect '<abcdef>'; recho ${z#xyz}
  def test_param_strip_prefix_no_match
    execute("z=abcdef; echo ${z#xyz} > #{outf}")
    assert_equal "abcdef\n", File.read(outf)
  end

  # exp.tests: non-matching longest prefix removal
  # z=abcdef; expect '<abcdef>'; recho ${z##xyz}
  def test_param_strip_prefix_longest_no_match
    execute("z=abcdef; echo ${z##xyz} > #{outf}")
    assert_equal "abcdef\n", File.read(outf)
  end

  # exp.tests: non-matching suffix removal
  # z=abcdef; expect '<abcdef>'; recho ${z%xyz}
  def test_param_strip_suffix_no_match
    execute("z=abcdef; echo ${z%xyz} > #{outf}")
    assert_equal "abcdef\n", File.read(outf)
  end

  # exp.tests: non-matching longest suffix removal
  # z=abcdef; expect '<abcdef>'; recho ${z%%xyz}
  def test_param_strip_suffix_longest_no_match
    execute("z=abcdef; echo ${z%%xyz} > #{outf}")
    assert_equal "abcdef\n", File.read(outf)
  end

  # exp.tests: count positional params -- set one two three four five; echo $#  ->  5
  def test_param_count_positional
    execute("set -- one two three four five; echo $# > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # exp.tests: count positional params via ${#}
  def test_param_count_positional_braces
    omit '${#} positional param count not yet supported'
    execute("set -- one two three four five; echo ${#} > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # exp.tests: length of positional param ${#1}
  # set one two three four five; expect '<3>'; recho ${#1}
  def test_param_length_of_positional
    omit '${#N} length of positional param not yet supported'
    execute("set -- one two three four five; echo ${#1} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # exp.tests: count via ${#@} and ${#*} equals number of positional params
  # set one two three four five; expect '<5>'; recho ${#@}
  def test_param_count_via_hash_at
    omit '${#@} param count not yet supported'
    execute("set -- one two three four five; echo ${#@} > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # exp.tests: select specific positional params -- $1 $3 ${5}; skip unset $8 $9
  # set one two three four five; expect '<one> <three> <five>'; recho $1 $3 ${5} $8 ${9}
  def test_positional_params_select
    omit '${N} positional param with braces not yet working'
    execute("set -- one two three four five; echo $1 $3 ${5} > #{outf}")
    assert_equal "one three five\n", File.read(outf)
  end

  # exp.tests: declare assignment does not word-split
  # a="a b c d e"; declare b=$a; recho $b -> <a> <b> <c> <d> <e>
  def test_declare_no_wordsplit_in_assignment
    execute("a='a b c d e'; declare b=$a; echo $b > #{outf}")
    assert_equal "a b c d e\n", File.read(outf)
  end

  # exp.tests: null string concat with bare var -- abcd""efgh -> abcdefgh
  def test_null_string_concat_quoted
    execute("echo abcd\"\"efgh > #{outf}")
    assert_equal "abcdefgh\n", File.read(outf)
  end

  # exp.tests: null string concat with single-quoted empty -- abcd''efgh -> abcdefgh
  def test_null_string_concat_single_quoted
    execute("echo abcd''efgh > #{outf}")
    assert_equal "abcdefgh\n", File.read(outf)
  end

  # exp.tests: ${x:-$(cmd)} with command substitution in default
  # unset x; echo "${x:-$(echo "foo bar")}"  ->  foo bar
  def test_param_default_comsub
    execute("unset x; echo \"${x:-$(echo 'foo bar')}\" > #{outf}")
    assert_equal "foo bar\n", File.read(outf)
  end

  # exp.tests: escape of backslash -- echo "\\\\"  ->  \\
  def test_backslash_escape
    execute("echo \"\\\\\\\\\" > #{outf}")
    assert_equal "\\\\\n", File.read(outf)
  end

  # exp.tests: tilde in single quotes is literal
  # expect '<~>'; recho '~'
  def test_tilde_single_quotes_literal
    execute("echo '~' > #{outf}")
    assert_equal "~\n", File.read(outf)
  end

  # exp.tests: $* unquoted splits on IFS
  # set "abc" "def ghi" "jkl"; echo $*  ->  abc def ghi jkl (word-split)
  def test_dollar_star_unquoted
    execute("set -- \"abc\" \"def ghi\" \"jkl\"; echo $* > #{outf}")
    assert_equal "abc def ghi jkl\n", File.read(outf)
  end

  # exp.tests: "$*" quoted joins with first IFS char (space by default)
  # set "abc" "def ghi" "jkl"; echo "$*"  ->  abc def ghi jkl
  def test_dollar_star_quoted
    execute("set -- \"abc\" \"def ghi\" \"jkl\"; echo \"$*\" > #{outf}")
    assert_equal "abc def ghi jkl\n", File.read(outf)
  end

  # exp.tests: "$@" quoted preserves word boundaries
  # set "abc" "def ghi" "jkl"; echo "$@"  ->  abc def ghi jkl (same in echo, but words differ)
  def test_dollar_at_quoted
    execute("set -- \"abc\" \"def ghi\" \"jkl\"; echo \"$@\" > #{outf}")
    assert_equal "abc def ghi jkl\n", File.read(outf)
  end

  # exp.tests: "$*" with non-default IFS joins with first IFS char
  # IFS=":$IFS"; set "abc" "def ghi" "jkl"; echo "$*"  ->  abc:def ghi:jkl
  def test_dollar_star_quoted_custom_ifs
    execute("OIFS=\"$IFS\"; IFS=\":$IFS\"; set -- \"abc\" \"def ghi\" \"jkl\"; echo \"$*\" > #{outf}")
    assert_equal "abc:def ghi:jkl\n", File.read(outf)
  end

  # exp.tests: ${POSIX} length -- POSIX=/usr/posix; echo ${#POSIX}  ->  10
  def test_param_length_known_value
    execute("POSIX=/usr/posix; echo ${#POSIX} > #{outf}")
    assert_equal "10\n", File.read(outf)
  end

  # exp.tests: ${x##*/} strips longest leading component -- x=/one/two/three; echo ${x##*/}  ->  three
  def test_param_strip_prefix_longest_path
    execute("x=/one/two/three; echo ${x##*/} > #{outf}")
    assert_equal "three\n", File.read(outf)
  end

  # new-exp.tests: ${foo:-"foo bar"} with spaces in default
  # expect '<foo bar>'; recho "${undef-"foo bar"}"
  def test_param_default_quoted_spaces
    execute("unset foo; echo \"${foo:-foo bar}\" > #{outf}")
    assert_equal "foo bar\n", File.read(outf)
  end

  # new-exp.tests: ${z: -3:3} negative offset from end
  # z=abcdefghijklmnop; expect '<nop>'; recho ${z: -3:3}
  def test_newexp_substr_negative_offset_nop
    omit 'negative offset in ${x: -N:L} not yet supported'
    execute("z=abcdefghijklmnop; echo ${z: -3:3} > #{outf}")
    assert_equal "nop\n", File.read(outf)
  end

  # new-exp.tests: out-of-range substring -> empty
  # var=abc; c=${var:3}; echo $c  -> (empty)
  def test_param_substr_out_of_range_empty
    execute("var=abc; c=${var:3}; echo $c > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # new-exp.tests: negative length means offset from end (bash-4.2+)
  # var=abc; c=${var:0:-2}; echo $c  ->  a
  def test_param_substr_negative_length
    omit 'negative length in ${var:offset:-N} not yet supported'
    execute("var=abc; echo ${var:0:-2} > #{outf}")
    assert_equal "a\n", File.read(outf)
  end

  # new-exp.tests: replace first match using var as pattern
  # xxx=endocrine; yyy=n; echo ${xxx/$yyy/*}  ->  e*docrine
  def test_param_replace_var_pattern
    omit 'var-as-pattern in ${x/$yyy/r} not yet working'
    execute("xxx=endocrine; yyy=n; echo ${xxx/$yyy/*} > #{outf}")
    assert_equal "e*docrine\n", File.read(outf)
  end

  # new-exp.tests: replace all matches using var as pattern
  # xxx=endocrine; yyy=n; echo ${xxx//$yyy/*}  ->  e*docri*e
  def test_param_replace_all_var_pattern
    omit 'var-as-pattern in ${x//$yyy/r} not yet working'
    execute("xxx=endocrine; yyy=n; echo ${xxx//$yyy/*} > #{outf}")
    assert_equal "e*docri*e\n", File.read(outf)
  end

  # new-exp.tests: replace with unset-var pattern (empty pattern) replaces each char
  # xxx=endocrine; unset zzz; echo ${xxx/$zzz/*}  ->  *endocrine (inserts before first char)
  def test_param_replace_unset_var_pattern
    omit 'empty pattern behavior (unset var) in substitution not consistent'
    execute("xxx=endocrine; unset zzz; echo ${xxx/$zzz/*} > #{outf}")
    assert_equal "*endocrine\n", File.read(outf)
  end

  # new-exp.tests: prefix insertion -- ${var/#/x} on empty var
  # unset var; var=; echo "${var/#/x}"  ->  x
  def test_param_replace_prefix_insert_empty
    omit '${var/#/x} prefix insert on empty var not yet working'
    execute("var=''; echo \"${var/#/x}\" > #{outf}")
    assert_equal "x\n", File.read(outf)
  end

  # new-exp.tests: replace whole value -- ${var/*/x} on empty var -> x
  # unset var; var=; echo "${var/*/x}"  ->  x
  def test_param_replace_star_empty_var
    omit '${var/*/x} with empty var not yet working'
    execute("var=''; echo \"${var/*/x}\" > #{outf}")
    assert_equal "x\n", File.read(outf)
  end

  # new-exp.tests: replace prefix on non-empty var -- var=abc; echo "${var/#/x}"  ->  xabc
  def test_param_replace_prefix_insert_nonempty
    execute("var=abc; echo \"${var/#/x}\" > #{outf}")
    assert_equal "xabc\n", File.read(outf)
  end

  # new-exp.tests: replace * pattern on non-empty var -- var=abc; echo "${var/*/x}"  ->  x
  def test_param_replace_star_pattern_nonempty
    execute("var=abc; echo \"${var/*/x}\" > #{outf}")
    assert_equal "x\n", File.read(outf)
  end

  # more-exp.tests: ${P%"*"} -- quoted literal asterisk as suffix pattern
  # P='*@*'; echo ${P%"*"}  ->  *@
  def test_param_strip_suffix_quoted_literal_star
    omit 'quoted literal star in suffix pattern not yet working'
    execute("P='*@*'; echo ${P%\"*\"} > #{outf}")
    assert_equal "*@\n", File.read(outf)
  end

  # more-exp.tests: ${P%""} empty pattern strip -> unchanged
  # P='*@*'; echo ${P%""}  ->  *@*
  def test_param_strip_suffix_empty_pattern
    execute("P='*@*'; echo ${P%\"\"} > #{outf}")
    assert_equal "*@*\n", File.read(outf)
  end

  # more-exp.tests: ${P#""} empty pattern prefix strip -> unchanged
  # P='*@*'; echo ${P#""}  ->  *@*
  def test_param_strip_prefix_empty_pattern
    execute("P='*@*'; echo ${P#\"\"} > #{outf}")
    assert_equal "*@*\n", File.read(outf)
  end

  # more-exp.tests: declare a=$zz -- no word splitting in declare
  # zz="a b c d e"; declare a=$zz; echo "$a"  ->  a b c d e
  def test_declare_preserves_spaces_in_value
    execute("zz='a b c d e'; declare a=$zz; echo \"$a\" > #{outf}")
    assert_equal "a b c d e\n", File.read(outf)
  end

  # more-exp.tests: nested ${} -- FOO=${BAR:-${XXX} yyy}
  # XXX=xxx; FOO=${BAR:-${XXX} yyy}; echo $FOO  ->  xxx yyy (two words)
  def test_nested_param_expansion
    omit 'nested ${} in parameter default not yet supported'
    execute("XXX=xxx; unset BAR; FOO=${BAR:-${XXX} yyy}; echo $FOO > #{outf}")
    assert_equal "xxx yyy\n", File.read(outf)
  end

  # exp.tests: escaped backslash in pattern -- a="a?b?c"; echo ${a//\?/ }  ->  a b c
  def test_param_replace_escaped_question
    omit 'escaped \\? in param replace pattern not yet working'
    execute("a='a?b?c'; echo ${a//\\?/ } > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # exp.tests: backslash-question unescaped in pattern -- a="a?b?c"; echo ${a//\\\\?/ }
  # with \\? the backslash is literal, matches literal backslash-then-any -> no match here
  # actual bash output: a?b?c (the \\? matches literal \<char>, but there's no \ in a?b?c)
  def test_param_replace_double_backslash_question
    execute("a='a?b?c'; echo ${a//\\\\?/ } > #{outf}")
    assert_equal "a?b?c\n", File.read(outf)
  end

  # more-exp.tests: ${!-posparams} when $! is unset -> posparams
  def test_param_bang_default_when_unset
    execute("echo ${!:-posparams} > #{outf}")
    assert_equal "posparams\n", File.read(outf)
  end

  # exp.tests: $! expands to nothing when no background job
  def test_param_bang_empty_no_bg_job
    execute("echo ${!} > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # exp.tests: x=''; recho "$xxx"  -> (nothing, empty line after unset var)
  # unset xxx; echo "$xxx"  ->  (empty line)
  def test_param_unset_quoted_empty_line
    execute("unset xxx; echo \"$xxx\" > #{outf}")
    assert_equal "\n", File.read(outf)
  end
end
