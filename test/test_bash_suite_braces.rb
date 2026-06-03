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

  # echo {abc\,def}  ->  {abc,def}  (escaped comma prevents expansion)
  def test_brace_escaped_comma
    omit 'escaped comma in brace not handled correctly'
    execute("echo {abc\\,def} > #{outf}")
    assert_equal "{abc,def}\n", File.read(outf)
  end

  # echo { }  ->  { }  (brace with space, not expanded)
  def test_brace_space_inside
    omit 'brace with space not passed through as literal'
    execute("echo { } > #{outf}")
    assert_equal "{ }\n", File.read(outf)
  end

  # echo {  ->  {  (lone open brace)
  def test_brace_lone_open
    omit 'lone open brace not passed through as literal'
    execute("echo { > #{outf}")
    assert_equal "{\n", File.read(outf)
  end

  # echo {x,y,\{a,b,c}}  ->  x} y} {a} b} c}
  def test_brace_escaped_open_in_list
    omit 'escaped open brace in list not handled correctly'
    execute("echo {x,y,\\{a,b,c}} > #{outf}")
    assert_equal "x} y} {a} b} c}\n", File.read(outf)
  end

  # echo {x\,y,\{abc\},trie}  ->  x,y {abc} trie
  def test_brace_escaped_comma_and_brace
    omit 'escaped comma and brace in list not handled correctly'
    execute("echo {x\\,y,\\{abc\\},trie} > #{outf}")
    assert_equal "x,y {abc} trie\n", File.read(outf)
  end

  # echo {0..10,braces}  ->  0..10 braces  (dotdot in list item, not seq)
  def test_brace_dotdot_in_list_not_seq
    execute("echo {0..10,braces} > #{outf}")
    assert_equal "0..10 braces\n", File.read(outf)
  end

  # echo x{{0..10},braces}y  ->  x0y x1y x2y x3y x4y x5y x6y x7y x8y x9y x10y xbracesy
  def test_brace_seq_and_word_with_prefix_suffix
    execute("echo x{{0..10},braces}y > #{outf}")
    assert_equal "x0y x1y x2y x3y x4y x5y x6y x7y x8y x9y x10y xbracesy\n", File.read(outf)
  end

  # echo x{3..3}y  ->  x3y
  def test_brace_seq_single_with_prefix_suffix
    execute("echo x{3..3}y > #{outf}")
    assert_equal "x3y\n", File.read(outf)
  end

  # echo {10..1}y  ->  10y 9y 8y 7y 6y 5y 4y 3y 2y 1y
  def test_brace_seq_descending_with_suffix
    execute("echo {10..1}y > #{outf}")
    assert_equal "10y 9y 8y 7y 6y 5y 4y 3y 2y 1y\n", File.read(outf)
  end

  # echo {a..A}  ->  a ` _ ^ ] \ [ Z Y X W V U T S R Q P O N M L K J I H G F E D C B A
  def test_brace_seq_lower_to_upper_cross
    omit 'cross-case alpha seq output differs from bash'
    execute("echo {a..A} > #{outf}")
    assert_equal "a \` _ ^ ]  [ Z Y X W V U T S R Q P O N M L K J I H G F E D C B A\n", File.read(outf)
  end

  # echo {A..a}  ->  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a
  def test_brace_seq_upper_to_lower_cross
    omit 'cross-case alpha seq output differs from bash'
    execute("echo {A..a} > #{outf}")
    assert_equal "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [  ] ^ _ \` a\n", File.read(outf)
  end

  # echo {f..f}  ->  f
  def test_brace_seq_alpha_single_same
    execute("echo {f..f} > #{outf}")
    assert_equal "f\n", File.read(outf)
  end

  # echo {f..1}  ->  {f..1}  (invalid mixed type)
  def test_brace_seq_invalid_alpha_to_num
    execute("echo {f..1} > #{outf}")
    assert_equal "{f..1}\n", File.read(outf)
  end

  # echo 0{1..9} {10..20}  ->  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20
  def test_brace_seq_prefix_and_adjacent
    execute("echo 0{1..9} {10..20} > #{outf}")
    assert_equal "01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20\n", File.read(outf)
  end

  # echo {-20..0}  ->  -20 -19 ... 0
  def test_brace_seq_negative_to_zero
    execute("echo {-20..0} > #{outf}")
    assert_equal "-20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0\n", File.read(outf)
  end

  # echo a-{b{d,e}}-c  ->  a-{bd}-c a-{be}-c
  def test_brace_nested_unmatched_outer
    omit 'weirdly-formed brace with nested expansion errors'
    execute("echo a-{b{d,e}}-c > #{outf}")
    assert_equal "a-{bd}-c a-{be}-c\n", File.read(outf)
  end

  # echo a-{bdef-{g,i}-c  ->  a-{bdef-g-c a-{bdef-i-c
  def test_brace_unclosed_with_inner_expansion
    omit 'unclosed outer brace with inner expansion not handled'
    execute("echo a-{bdef-{g,i}-c > #{outf}")
    assert_equal "a-{bdef-g-c a-{bdef-i-c\n", File.read(outf)
  end

  # echo {"klklkl"}{1,2,3}  ->  {klklkl}1 {klklkl}2 {klklkl}3
  def test_brace_quoted_single_element_with_list
    omit 'quoted single-element brace with adjacent list not handled'
    execute("echo {\"klklkl\"}{1,2,3} > #{outf}")
    assert_equal "{klklkl}1 {klklkl}2 {klklkl}3\n", File.read(outf)
  end

  # echo {"x,x"}  ->  {x,x}
  def test_brace_quoted_comma_literal
    omit 'quoted comma inside braces not handled'
    execute("echo {\"x,x\"} > #{outf}")
    assert_equal "{x,x}\n", File.read(outf)
  end

  # echo {-1..-10..2}  ->  -1 -3 -5 -7 -9
  def test_brace_seq_neg_descend_pos_step
    execute("echo {-1..-10..2} > #{outf}")
    assert_equal "-1 -3 -5 -7 -9\n", File.read(outf)
  end

  # echo {-1..-10..-2}  ->  -1 -3 -5 -7 -9
  def test_brace_seq_neg_descend_neg_step
    execute("echo {-1..-10..-2} > #{outf}")
    assert_equal "-1 -3 -5 -7 -9\n", File.read(outf)
  end

  # echo {10..1..2}  ->  10 8 6 4 2
  def test_brace_seq_descend_pos_step
    execute("echo {10..1..2} > #{outf}")
    assert_equal "10 8 6 4 2\n", File.read(outf)
  end

  # echo {1..20..2}  ->  1 3 5 7 9 11 13 15 17 19
  def test_brace_seq_ascend_step2
    execute("echo {1..20..2} > #{outf}")
    assert_equal "1 3 5 7 9 11 13 15 17 19\n", File.read(outf)
  end

  # echo {1..20..20}  ->  1  (step exceeds range)
  def test_brace_seq_step_exceeds_range
    execute("echo {1..20..20} > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo {100..0..5}  ->  100 95 90 ... 0
  def test_brace_seq_descend_step5
    execute("echo {100..0..5} > #{outf}")
    assert_equal "100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0\n", File.read(outf)
  end

  # echo {100..0..-5}  ->  100 95 90 ... 0  (negative step, same result)
  def test_brace_seq_descend_neg_step5
    execute("echo {100..0..-5} > #{outf}")
    assert_equal "100 95 90 85 80 75 70 65 60 55 50 45 40 35 30 25 20 15 10 5 0\n", File.read(outf)
  end

  # echo {a..z}  ->  a b c d e f g h i j k l m n o p q r s t u v w x y z
  def test_brace_seq_full_alpha
    execute("echo {a..z} > #{outf}")
    assert_equal "a b c d e f g h i j k l m n o p q r s t u v w x y z\n", File.read(outf)
  end

  # echo {z..a..-2}  ->  z x v t r p n l j h f d b
  def test_brace_seq_alpha_neg_step
    execute("echo {z..a..-2} > #{outf}")
    assert_equal "z x v t r p n l j h f d b\n", File.read(outf)
  end

  # echo {2147483645..2147483649}
  def test_brace_seq_large_ints
    execute("echo {2147483645..2147483649} > #{outf}")
    assert_equal "2147483645 2147483646 2147483647 2147483648 2147483649\n", File.read(outf)
  end

  # echo {00..10..2}  ->  00 02 04 06 08 10  (zero-padded with step)
  def test_brace_seq_zero_padded_step
    execute("echo {00..10..2} > #{outf}")
    assert_equal "00 02 04 06 08 10\n", File.read(outf)
  end

  # echo {10..0..2}  ->  10 8 6 4 2 0  (no unwanted zero-padding)
  def test_brace_seq_no_pad_descend_step2
    execute("echo {10..0..2} > #{outf}")
    assert_equal "10 8 6 4 2 0\n", File.read(outf)
  end

  # echo {10..0..-2}  ->  10 8 6 4 2 0
  def test_brace_seq_no_pad_descend_neg_step2
    execute("echo {10..0..-2} > #{outf}")
    assert_equal "10 8 6 4 2 0\n", File.read(outf)
  end

  # echo {-50..-0..5}  ->  -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0
  def test_brace_seq_neg_to_neg_zero
    execute("echo {-50..-0..5} > #{outf}")
    assert_equal "-50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0\n", File.read(outf)
  end

  # echo {{1,2,3}..{7,8,9}}  ->  {1..7} {1..8} {1..9} {2..7} {2..8} {2..9} {3..7} {3..8} {3..9}
  def test_brace_outer_invalid_inner_num_seqs
    omit 'outer invalid seq with inner expansions not handled'
    execute("echo {{1,2,3}..{7,8,9}} > #{outf}")
    assert_equal "{1..7} {1..8} {1..9} {2..7} {2..8} {2..9} {3..7} {3..8} {3..9}\n", File.read(outf)
  end

  # echo {{a..c}..{1..3}}  ->  {a..1} {a..2} {a..3} {b..1} {b..2} {b..3} {c..1} {c..2} {c..3}
  def test_brace_outer_invalid_alpha_seq_num_seq
    omit 'outer invalid seq with inner expansions not handled'
    execute("echo {{a..c}..{1..3}} > #{outf}")
    assert_equal "{a..1} {a..2} {a..3} {b..1} {b..2} {b..3} {c..1} {c..2} {c..3}\n", File.read(outf)
  end

  # echo {{a..c}..{1,10}}  ->  {a..1} {a..10} {b..1} {b..10} {c..1} {c..10}
  def test_brace_outer_invalid_alpha_seq_num_list
    omit 'outer invalid seq with inner expansions not handled'
    execute("echo {{a..c}..{1,10}} > #{outf}")
    assert_equal "{a..1} {a..10} {b..1} {b..10} {c..1} {c..10}\n", File.read(outf)
  end

  # echo {{a,c}..{1..4}}  ->  {a..1} {a..2} {a..3} {a..4} {c..1} {c..2} {c..3} {c..4}
  def test_brace_outer_invalid_list_num_seq
    omit 'outer invalid seq with inner expansions not handled'
    execute("echo {{a,c}..{1..4}} > #{outf}")
    assert_equal "{a..1} {a..2} {a..3} {a..4} {c..1} {c..2} {c..3} {c..4}\n", File.read(outf)
  end

  # echo {{1,2,3}..4}  ->  {1..4} {2..4} {3..4}
  def test_brace_outer_invalid_list_single_num
    omit 'outer invalid seq with inner expansions not handled'
    execute("echo {{1,2,3}..4} > #{outf}")
    assert_equal "{1..4} {2..4} {3..4}\n", File.read(outf)
  end

  # echo {6..{7,8,9}}  ->  {6..7} {6..8} {6..9}
  def test_brace_outer_invalid_single_num_list
    omit 'outer invalid seq with inner expansions not handled'
    execute("echo {6..{7,8,9}} > #{outf}")
    assert_equal "{6..7} {6..8} {6..9}\n", File.read(outf)
  end

  # echo {a,../a.cfg}  ->  a ../a.cfg  (dotdot as path, valid brace expansion)
  def test_brace_dotdot_as_path
    execute("echo {a,../a.cfg} > #{outf}")
    assert_equal "a ../a.cfg\n", File.read(outf)
  end

  # echo {a..,/a.cfg}  ->  a.. /a.cfg
  def test_brace_dotdot_trailing_in_item
    execute("echo {a..,/a.cfg} > #{outf}")
    assert_equal "a.. /a.cfg\n", File.read(outf)
  end

  # echo {a..b,/a.cfg}  ->  a..b /a.cfg  (invalid seq, valid brace)
  def test_brace_invalid_seq_valid_brace_with_path
    execute("echo {a..b,/a.cfg} > #{outf}")
    assert_equal "a..b /a.cfg\n", File.read(outf)
  end

  # echo {a,b../a.cfg}  ->  a b../a.cfg
  def test_brace_dotdot_in_second_item
    execute("echo {a,b../a.cfg} > #{outf}")
    assert_equal "a b../a.cfg\n", File.read(outf)
  end

  # echo {1..4,5..8}  ->  1..4 5..8  (both items are dotdot but not seq)
  def test_brace_two_dotdot_items
    execute("echo {1..4,5..8} > #{outf}")
    assert_equal "1..4 5..8\n", File.read(outf)
  end

  # echo {1..4,8}  ->  1..4 8
  def test_brace_dotdot_item_and_num
    execute("echo {1..4,8} > #{outf}")
    assert_equal "1..4 8\n", File.read(outf)
  end

  # echo {1,5..8}  ->  1 5..8
  def test_brace_num_and_dotdot_item
    execute("echo {1,5..8} > #{outf}")
    assert_equal "1 5..8\n", File.read(outf)
  end

  # echo {abcde.f}  ->  {abcde.f}  (single element with dot, no expansion)
  def test_brace_invalid_single_with_dot
    omit 'single-element brace with dot causes parse error'
    execute("echo {abcde.f} > #{outf}")
    assert_equal "{abcde.f}\n", File.read(outf)
  end

  # echo X{..a}Z  ->  X{..a}Z  (empty start, invalid seq)
  def test_brace_invalid_empty_start_seq
    execute("echo X{..a}Z > #{outf}")
    assert_equal "X{..a}Z\n", File.read(outf)
  end

  # echo 0{1..}2  ->  0{1..}2  (empty end, invalid seq)
  def test_brace_invalid_empty_end_seq
    execute("echo 0{1..}2 > #{outf}")
    assert_equal "0{1..}2\n", File.read(outf)
  end

  # echo {a..1..5}  ->  {a..1..5}  (mixed alpha/num with step, invalid)
  def test_brace_invalid_alpha_to_num_step
    execute("echo {a..1..5} > #{outf}")
    assert_equal "{a..1..5}\n", File.read(outf)
  end

  # echo {x,y}{1..a}{0,1,2}  ->  x{1..a}0 x{1..a}1 x{1..a}2 y{1..a}0 y{1..a}1 y{1..a}2
  def test_brace_invalid_seq_within_valid_expansion
    omit 'invalid seq in middle of valid expansions not preserved'
    execute("echo {x,y}{1..a}{0,1,2} > #{outf}")
    assert_equal "x{1..a}0 x{1..a}1 x{1..a}2 y{1..a}0 y{1..a}1 y{1..a}2\n", File.read(outf)
  end

  # echo {1..10.f}  ->  {1..10.f}
  def test_brace_invalid_bad_dotf
    execute("echo {1..10.f} > #{outf}")
    assert_equal "{1..10.f}\n", File.read(outf)
  end

  # echo {1..ff}  ->  {1..ff}
  def test_brace_invalid_bad_ff
    execute("echo {1..ff} > #{outf}")
    assert_equal "{1..ff}\n", File.read(outf)
  end

  # echo {1..10..ff}  ->  {1..10..ff}
  def test_brace_invalid_bad_step_ff
    execute("echo {1..10..ff} > #{outf}")
    assert_equal "{1..10..ff}\n", File.read(outf)
  end

  # echo {1.20..2}  ->  {1.20..2}
  def test_brace_invalid_bad_1dot20
    execute("echo {1.20..2} > #{outf}")
    assert_equal "{1.20..2}\n", File.read(outf)
  end

  # echo {1..20..f2}  ->  {1..20..f2}
  def test_brace_invalid_bad_step_f2
    execute("echo {1..20..f2} > #{outf}")
    assert_equal "{1..20..f2}\n", File.read(outf)
  end

  # echo {1..20..2f}  ->  {1..20..2f}
  def test_brace_invalid_bad_step_2f
    execute("echo {1..20..2f} > #{outf}")
    assert_equal "{1..20..2f}\n", File.read(outf)
  end

  # echo {1..2f..2}  ->  {1..2f..2}
  def test_brace_invalid_bad_2f_range
    execute("echo {1..2f..2} > #{outf}")
    assert_equal "{1..2f..2}\n", File.read(outf)
  end

  # echo {1..ff..2}  ->  {1..ff..2}
  def test_brace_invalid_bad_ff_range
    execute("echo {1..ff..2} > #{outf}")
    assert_equal "{1..ff..2}\n", File.read(outf)
  end

  # echo {1..0f}  ->  {1..0f}
  def test_brace_invalid_bad_0f
    execute("echo {1..0f} > #{outf}")
    assert_equal "{1..0f}\n", File.read(outf)
  end

  # echo {1..10f}  ->  {1..10f}
  def test_brace_invalid_bad_10f
    execute("echo {1..10f} > #{outf}")
    assert_equal "{1..10f}\n", File.read(outf)
  end

  # var=baz; echo foo{bar,${var}.}  ->  foobar foobaz.
  def test_brace_var_expand_with_trailing_dot
    omit 'var expansion inside brace list not yet supported'
    execute("var=baz; echo foo{bar,${var}.} > #{outf}")
    assert_equal "foobar foobaz.\n", File.read(outf)
  end

  # var=baz; echo "${var}"{x,y}  ->  bazx bazy
  def test_brace_quoted_var_as_prefix
    omit 'var expansion inside brace list not yet supported'
    execute("var=baz; echo \"${var}\"{x,y} > #{outf}")
    assert_equal "bazx bazy\n", File.read(outf)
  end

  # varx=vx; vary=vy; var=baz; echo $var{x,y}  ->  vx vy
  def test_brace_var_name_suffix_expansion
    omit 'var expansion inside brace list not yet supported'
    execute("varx=vx; vary=vy; var=baz; echo $var{x,y} > #{outf}")
    assert_equal "vx vy\n", File.read(outf)
  end

  # var=baz; echo ${var}{x,y}  ->  bazx bazy
  def test_brace_param_expand_as_prefix
    omit 'var expansion inside brace list not yet supported'
    execute("var=baz; echo ${var}{x,y} > #{outf}")
    assert_equal "bazx bazy\n", File.read(outf)
  end
end
