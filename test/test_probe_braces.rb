# frozen_string_literal: true
require_relative 'test_helper'

class TestProbe_Braces < Test::Unit::TestCase
  def setup
    @repl = Rubish::REPL.new
    @tempdir = Dir.mktmpdir('rubish_probe')
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

  def test_escaped_comma
    execute("echo {abc\\\\,def} > #{outf}")
    assert_equal "{abc,def}\n", File.read(outf)
  end

  def test_partially_escaped_braces
    execute("echo {x,y,\\\\{a,b,c}} > #{outf}")
    assert_equal "x} y} {a} b} c}\n", File.read(outf)
  end

  def test_comma_escaped_in_list
    execute("echo {x\\\\,y,\\\\{abc\\\\},trie} > #{outf}")
    assert_equal "x,y {abc} trie\n", File.read(outf)
  end

  def test_space_brace
    execute("echo { } > #{outf}")
    assert_equal "{ }\n", File.read(outf)
  end

  def test_bare_open_brace
    execute("echo { > #{outf}")
    assert_equal "{\n", File.read(outf)
  end

  def test_seq_0_10_word
    execute("echo {0..10,braces} > #{outf}")
    assert_equal "0..10 braces\n", File.read(outf)
  end

  def test_x_seq_word_y
    execute("echo x{{0..10},braces}y > #{outf}")
    assert_equal "x0y x1y x2y x3y x4y x5y x6y x7y x8y x9y x10y xbracesy\n", File.read(outf)
  end

  def test_seq_single_pf
    execute("echo x{3..3}y > #{outf}")
    assert_equal "x3y\n", File.read(outf)
  end

  def test_seq_desc_suffix
    execute("echo {10..1}y > #{outf}")
    assert_equal "10y 9y 8y 7y 6y 5y 4y 3y 2y 1y\n", File.read(outf)
  end

  def test_alpha_a_to_A
    execute("echo {a..A} > #{outf}")
    assert_equal "a \` _ ^ ]  [ Z Y X W V U T S R Q P O N M L K J I H G F E D C B A\n", File.read(outf)
  end

  def test_alpha_A_to_a
    execute("echo {A..a} > #{outf}")
    assert_equal "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [  ] ^ _ \` a\n", File.read(outf)
  end

  def test_alpha_single
    execute("echo {f..f} > #{outf}")
    assert_equal "f\n", File.read(outf)
  end

  def test_invalid_mixed2
    execute("echo {f..1} > #{outf}")
    assert_equal "{f..1}\n", File.read(outf)
  end

  def test_digit_preamble_seq
    execute("echo 0{1..9} {10..20} > #{outf}")
    assert_equal "01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20\n", File.read(outf)
  end

  def test_neg_to_zero
    execute("echo {-20..0} > #{outf}")
    assert_equal "-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0\n", File.read(outf)
  end

  def test_weird_nested_close
    execute("echo a-{b{d,e}}-c > #{outf}")
    assert_equal "a-{bd}-c a-{be}-c\n", File.read(outf)
  end

  def test_unclosed_outer_inner_expansion
    execute("echo a-{bdef-{g,i}-c > #{outf}")
    assert_equal "a-{bdef-g-c a-{bdef-i-c\n", File.read(outf)
  end

  def test_quoted_string_as_element
    execute('echo {"klklkl"}{1,2,3}' + " > #{outf}")
    assert_equal "{klklkl}1 {klklkl}2 {klklkl}3\n", File.read(outf)
  end

  def test_quoted_comma
    execute('echo {"x,x"}' + " > #{outf}")
    assert_equal "{x,x}\n", File.read(outf)
  end

  def test_var_expansion_with_dot
    execute("var=baz; echo foo{bar,${var}.} > #{outf}")
    assert_equal "foobar foobaz.\n", File.read(outf)
  end

  def test_quoted_var_preamble
    execute('var=baz; echo "${var}"{x,y}' + " > #{outf}")
    assert_equal "bazx bazy\n", File.read(outf)
  end

  def test_dollar_var_preamble
    execute("var=baz; varx=vx; vary=vy; echo \$var{x,y} > #{outf}")
    assert_equal "vx vy\n", File.read(outf)
  end

  def test_dollar_brace_var_preamble
    execute("var=baz; echo \${var}{x,y} > #{outf}")
    assert_equal "bazx bazy\n", File.read(outf)
  end

  def test_neg_step_abs
    execute("echo {-1..-10..2} > #{outf}")
    assert_equal "-1 -3 -5 -7 -9\n", File.read(outf)
  end

  def test_neg_step_explicit
    execute("echo {-1..-10..-2} > #{outf}")
    assert_equal "-1 -3 -5 -7 -9\n", File.read(outf)
  end

  def test_pos_step_descending
    execute("echo {10..1..2} > #{outf}")
    assert_equal "10 8 6 4 2\n", File.read(outf)
  end

  def test_step_not_reaching_end
    execute("echo {1..20..2} > #{outf}")
    assert_equal "1 3 5 7 9 11 13 15 17 19\n", File.read(outf)
  end

  def test_step_larger_than_range
    execute("echo {1..20..20} > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  def test_large_descending_step
    execute("echo {100..0..5} > #{outf}")
    assert_equal "100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0\n", File.read(outf)
  end

  def test_large_descending_step_neg
    execute("echo {100..0..-5} > #{outf}")
    assert_equal "100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0\n", File.read(outf)
  end

  def test_alpha_full
    execute("echo {a..z} > #{outf}")
    assert_equal "a b c d e f g h i j k l m n o p q r s t u v w x y z\n", File.read(outf)
  end

  def test_alpha_desc_step
    execute("echo {z..a..-2} > #{outf}")
    assert_equal "z x v t r p n l j h f d b\n", File.read(outf)
  end

  def test_large_ints
    execute("echo {2147483645..2147483649} > #{outf}")
    assert_equal "2147483645 2147483646 2147483647 2147483648 2147483649\n", File.read(outf)
  end

  def test_zero_padded_step
    execute("echo {00..10..2} > #{outf}")
    assert_equal "00 02 04 06 08 10\n", File.read(outf)
  end

  def test_no_unwanted_zero_pad
    execute("echo {10..0..2} > #{outf}")
    assert_equal "10 8 6 4 2 0\n", File.read(outf)
  end

  def test_no_unwanted_zero_pad_neg
    execute("echo {10..0..-2} > #{outf}")
    assert_equal "10 8 6 4 2 0\n", File.read(outf)
  end

  def test_neg_to_zero_step
    execute("echo {-50..-0..5} > #{outf}")
    assert_equal "-50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0\n", File.read(outf)
  end

  def test_invalid_outer_inner_expanded
    execute("echo {{1,2,3}..{7,8,9}} > #{outf}")
    assert_equal "{1..7} {1..8} {1..9} {2..7} {2..8} {2..9} {3..7} {3..8} {3..9}\n", File.read(outf)
  end

  def test_invalid_outer_alpha_seq_int
    execute("echo {{a..c}..{1..3}} > #{outf}")
    assert_equal "{a..1} {a..2} {a..3} {b..1} {b..2} {b..3} {c..1} {c..2} {c..3}\n", File.read(outf)
  end

  def test_invalid_outer_alpha_seq_int_list
    execute("echo {{a..c}..{1,10}} > #{outf}")
    assert_equal "{a..1} {a..10} {b..1} {b..10} {c..1} {c..10}\n", File.read(outf)
  end

  def test_invalid_outer_alpha_list_int_seq
    execute("echo {{a,c}..{1..4}} > #{outf}")
    assert_equal "{a..1} {a..2} {a..3} {a..4} {c..1} {c..2} {c..3} {c..4}\n", File.read(outf)
  end

  def test_invalid_outer_int_list_int
    execute("echo {{1,2,3}..4} > #{outf}")
    assert_equal "{1..4} {2..4} {3..4}\n", File.read(outf)
  end

  def test_invalid_outer_int_int_list
    execute("echo {6..{7,8,9}} > #{outf}")
    assert_equal "{6..7} {6..8} {6..9}\n", File.read(outf)
  end

  def test_valid_brace_looks_like_seq1
    execute("echo {a,../a.cfg} > #{outf}")
    assert_equal "a ../a.cfg\n", File.read(outf)
  end

  def test_valid_brace_looks_like_seq2
    execute("echo {a..,/a.cfg} > #{outf}")
    assert_equal "a.. /a.cfg\n", File.read(outf)
  end

  def test_valid_brace_looks_like_seq3
    execute("echo {a..b,/a.cfg} > #{outf}")
    assert_equal "a..b /a.cfg\n", File.read(outf)
  end

  def test_valid_brace_looks_like_seq4
    execute("echo {a,b../a.cfg} > #{outf}")
    assert_equal "a b../a.cfg\n", File.read(outf)
  end

  def test_mixed_list_and_seq1
    execute("echo {1..4,5..8} > #{outf}")
    assert_equal "1..4 5..8\n", File.read(outf)
  end

  def test_mixed_list_and_seq2
    execute("echo {1..4,8} > #{outf}")
    assert_equal "1..4 8\n", File.read(outf)
  end

  def test_mixed_list_and_seq3
    execute("echo {1,5..8} > #{outf}")
    assert_equal "1 5..8\n", File.read(outf)
  end

  def test_invalid_single_dot
    execute("echo {abcde.f} > #{outf}")
    assert_equal "{abcde.f}\n", File.read(outf)
  end

  def test_invalid_missing_start
    execute("echo X{..a}Z > #{outf}")
    assert_equal "X{..a}Z\n", File.read(outf)
  end

  def test_invalid_missing_end
    execute("echo 0{1..}2 > #{outf}")
    assert_equal "0{1..}2\n", File.read(outf)
  end

  def test_invalid_mixed_type_three_part
    execute("echo {a..1..5} > #{outf}")
    assert_equal "{a..1..5}\n", File.read(outf)
  end

  def test_invalid_mixed_with_outer_expansion
    execute("echo {x,y}{1..a}{0,1,2} > #{outf}")
    assert_equal "x{1..a}0 x{1..a}1 x{1..a}2 y{1..a}0 y{1..a}1 y{1..a}2\n", File.read(outf)
  end

  def test_invalid_single_dot_in_seq
    execute("echo {1..10.f} > #{outf}")
    assert_equal "{1..10.f}\n", File.read(outf)
  end

  def test_invalid_hex_end
    execute("echo {1..ff} > #{outf}")
    assert_equal "{1..ff}\n", File.read(outf)
  end

  def test_invalid_hex_step
    execute("echo {1..10..ff} > #{outf}")
    assert_equal "{1..10..ff}\n", File.read(outf)
  end

  def test_invalid_single_dot_start
    execute("echo {1.20..2} > #{outf}")
    assert_equal "{1.20..2}\n", File.read(outf)
  end

  def test_invalid_hex_step2
    execute("echo {1..20..f2} > #{outf}")
    assert_equal "{1..20..f2}\n", File.read(outf)
  end

  def test_invalid_hex_step3
    execute("echo {1..20..2f} > #{outf}")
    assert_equal "{1..20..2f}\n", File.read(outf)
  end

  def test_invalid_hex_end2
    execute("echo {1..2f..2} > #{outf}")
    assert_equal "{1..2f..2}\n", File.read(outf)
  end

  def test_invalid_hex_end3
    execute("echo {1..ff..2} > #{outf}")
    assert_equal "{1..ff..2}\n", File.read(outf)
  end

  def test_invalid_zero_padded_end
    execute("echo {1..0f} > #{outf}")
    assert_equal "{1..0f}\n", File.read(outf)
  end

  def test_invalid_padded_end
    execute("echo {1..10f} > #{outf}")
    assert_equal "{1..10f}\n", File.read(outf)
  end
end
