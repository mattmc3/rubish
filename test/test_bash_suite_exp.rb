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
    omit '${x/#pat/rep} anchored replacement not yet supported'
    execute("x=hello; echo ${x/#hel/HEL} > #{outf}")
    assert_equal "HELlo\n", File.read(outf)
  end

  # x=hello; echo ${x/%llo/LLO}  ->  heLLO
  def test_param_replace_anchor_end
    omit '${x/%pat/rep} anchored replacement not yet supported'
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
    omit '${v/#pat/rep} anchored replacement not yet supported'
    execute("v=abcde; echo ${v/#a/ab} > #{outf}")
    assert_equal "abbcde\n", File.read(outf)
  end

  # v=abcde; echo ${v/#d/ab}  ->  abcde  (no match at start)
  def test_newexp_replace_anchor_start_no_match
    omit '${v/#pat/rep} anchored replacement not yet supported'
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
    omit '${v/%pat/rep} anchored replacement not yet supported'
    execute("v=abcde; echo ${v/%?/last} > #{outf}")
    assert_equal "abcdlast\n", File.read(outf)
  end

  # v=abcde; echo ${v/%x/last}  ->  abcde  (no match)
  def test_newexp_replace_anchor_end_no_match
    omit '${v/%pat/rep} anchored replacement not yet supported'
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
end
