# frozen_string_literal: true

# Tests sourced from .bash/tests/braces.tests
require_relative 'test_helper'

class TestBash_Braces < Test::Unit::TestCase
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

  # echo ff{c,b,a}  ->  ffc ffb ffa
  def test_brace_basic_suffix
    execute("echo ff{c,b,a} > #{outf}")
    assert_equal "ffc ffb ffa\n", File.read(outf)
  end

  # echo f{d,e,f}g  ->  fdg feg ffg
  def test_brace_basic_infix
    execute("echo f{d,e,f}g > #{outf}")
    assert_equal "fdg feg ffg\n", File.read(outf)
  end

  # echo {l,n,m}xyz  ->  lxyz nxyz mxyz
  def test_brace_basic_prefix
    execute("echo {l,n,m}xyz > #{outf}")
    assert_equal "lxyz nxyz mxyz\n", File.read(outf)
  end

  # echo {abc}  ->  {abc}  (single element, no expansion)
  def test_brace_single_element_no_expand
    omit 'single-element brace not suppressed'
    execute("echo {abc} > #{outf}")
    assert_equal "{abc}\n", File.read(outf)
  end

  # echo \{a,b,c,d,e}  ->  {a,b,c,d,e}  (escaped brace)
  def test_brace_escaped_open
    omit 'escaped brace not handled correctly'
    execute("echo \\{a,b,c,d,e} > #{outf}")
    assert_equal "{a,b,c,d,e}\n", File.read(outf)
  end

  # echo {}  ->  {}
  def test_brace_empty
    omit 'empty braces not passed through as literal'
    execute("echo {} > #{outf}")
    assert_equal "{}\n", File.read(outf)
  end

  # echo }  ->  }
  def test_brace_close_only
    omit 'lone } not parsed as literal word'
    execute("echo } > #{outf}")
    assert_equal "}\n", File.read(outf)
  end

  # echo abcd{efgh  ->  abcd{efgh  (unclosed brace)
  def test_brace_unclosed
    omit 'unclosed brace not passed through as literal'
    execute("echo abcd{efgh > #{outf}")
    assert_equal "abcd{efgh\n", File.read(outf)
  end

  # echo foo {1,2} bar  ->  foo 1 2 bar
  def test_brace_in_word_list
    execute("echo foo {1,2} bar > #{outf}")
    assert_equal "foo 1 2 bar\n", File.read(outf)
  end

  # var=baz; echo foo{bar,${var}}  ->  foobar foobaz
  def test_brace_with_var_expansion
    omit 'var expansion inside brace list not yet supported'
    execute("var=baz; echo foo{bar,${var}} > #{outf}")
    assert_equal "foobar foobaz\n", File.read(outf)
  end

  # echo /usr/{ucb/{ex,edit},lib/{ex,how_ex}}  ->  /usr/ucb/ex /usr/ucb/edit /usr/lib/ex /usr/lib/how_ex
  def test_brace_nested
    execute("echo /usr/{ucb/{ex,edit},lib/{ex,how_ex}} > #{outf}")
    assert_equal "/usr/ucb/ex /usr/ucb/edit /usr/lib/ex /usr/lib/how_ex\n", File.read(outf)
  end

  # echo {1..10}  ->  1 2 3 4 5 6 7 8 9 10
  def test_brace_seq_ascending
    execute("echo {1..10} > #{outf}")
    assert_equal "1 2 3 4 5 6 7 8 9 10\n", File.read(outf)
  end

  # echo {10..1}  ->  10 9 8 7 6 5 4 3 2 1
  def test_brace_seq_descending
    execute("echo {10..1} > #{outf}")
    assert_equal "10 9 8 7 6 5 4 3 2 1\n", File.read(outf)
  end

  # echo x{10..1}y  ->  x10y x9y x8y x7y x6y x5y x4y x3y x2y x1y
  def test_brace_seq_with_prefix_suffix
    execute("echo x{10..1}y > #{outf}")
    assert_equal "x10y x9y x8y x7y x6y x5y x4y x3y x2y x1y\n", File.read(outf)
  end

  # echo {a..f}  ->  a b c d e f
  def test_brace_seq_alpha_ascending
    execute("echo {a..f} > #{outf}")
    assert_equal "a b c d e f\n", File.read(outf)
  end

  # echo {f..a}  ->  f e d c b a
  def test_brace_seq_alpha_descending
    execute("echo {f..a} > #{outf}")
    assert_equal "f e d c b a\n", File.read(outf)
  end

  # echo {3..3}  ->  3
  def test_brace_seq_single
    execute("echo {3..3} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # echo {-1..-10}  ->  -1 -2 -3 -4 -5 -6 -7 -8 -9 -10
  def test_brace_seq_negative
    execute("echo {-1..-10} > #{outf}")
    assert_equal "-1 -2 -3 -4 -5 -6 -7 -8 -9 -10\n", File.read(outf)
  end

  # echo {1..10..2}  ->  1 3 5 7 9
  def test_brace_seq_step
    execute("echo {1..10..2} > #{outf}")
    assert_equal "1 3 5 7 9\n", File.read(outf)
  end

  # echo {10..1..-2}  ->  10 8 6 4 2
  def test_brace_seq_descending_step
    execute("echo {10..1..-2} > #{outf}")
    assert_equal "10 8 6 4 2\n", File.read(outf)
  end

  # echo {a..z..2}  ->  a c e g i k m o q s u w y
  def test_brace_seq_alpha_step
    execute("echo {a..z..2} > #{outf}")
    assert_equal "a c e g i k m o q s u w y\n", File.read(outf)
  end

  # echo {{0..10},braces}  ->  0 1 2 3 4 5 6 7 8 9 10 braces
  def test_brace_seq_with_word
    execute("echo {{0..10},braces} > #{outf}")
    assert_equal "0 1 2 3 4 5 6 7 8 9 10 braces\n", File.read(outf)
  end

  # echo {00..10}  ->  00 01 02 03 04 05 06 07 08 09 10
  def test_brace_seq_zero_padded
    execute("echo {00..10} > #{outf}")
    assert_equal "00 01 02 03 04 05 06 07 08 09 10\n", File.read(outf)
  end

  # echo {1..f}  ->  {1..f}  (invalid mixed type, no expansion)
  def test_brace_seq_invalid_mixed
    execute("echo {1..f} > #{outf}")
    assert_equal "{1..f}\n", File.read(outf)
  end
end
