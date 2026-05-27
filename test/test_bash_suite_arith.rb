# frozen_string_literal: true

# Tests sourced from .bash/tests/arith.tests
require_relative 'test_helper'

class TestBash_Arith < Test::Unit::TestCase
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

  # echo $((3 + 5 * 32))  ->  163
  def test_arith_precedence_mul_before_add
    execute("echo $((3 + 5 * 32)) > #{outf}")
    assert_equal "163\n", File.read(outf)
  end

  # echo $((33 & 55))  ->  33
  def test_arith_bitwise_and
    execute("echo $((33 & 55)) > #{outf}")
    assert_equal "33\n", File.read(outf)
  end

  # echo $((33 | 17))  ->  49
  def test_arith_bitwise_or
    execute("echo $((33 | 17)) > #{outf}")
    assert_equal "49\n", File.read(outf)
  end

  # echo $((8 ^ 32))  ->  40
  def test_arith_bitwise_xor
    execute("echo $((8 ^ 32)) > #{outf}")
    assert_equal "40\n", File.read(outf)
  end

  # echo $((~1))  ->  -2
  def test_arith_bitwise_not
    execute("echo $((~1)) > #{outf}")
    assert_equal "-2\n", File.read(outf)
  end

  # echo $((!0))  ->  1
  def test_arith_logical_not
    omit '! operator not yet supported in $(( ))'
    execute("echo $((! 0)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $((4<5 ? 1 : 32))  ->  1
  def test_arith_ternary_true
    execute("echo $((4<5 ? 1 : 32)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $((4>5 ? 1 : 32))  ->  32
  def test_arith_ternary_false
    execute("echo $((4>5 ? 1 : 32)) > #{outf}")
    assert_equal "32\n", File.read(outf)
  end

  # echo $((4>(2+3) ? 1 : 32))  ->  32
  def test_arith_ternary_grouped_false
    execute("echo $((4>(2+3) ? 1 : 32)) > #{outf}")
    assert_equal "32\n", File.read(outf)
  end

  # echo $((4<(2+3) ? 1 : 32))  ->  1
  def test_arith_ternary_grouped_true
    execute("echo $((4<(2+3) ? 1 : 32)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $(((2+2)<(2+3) ? 1 : 32))  ->  1
  def test_arith_ternary_both_grouped_true
    execute("echo $(((2+2)<(2+3) ? 1 : 32)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $(((2+2)>(2+3) ? 1 : 32))  ->  32
  def test_arith_ternary_both_grouped_false
    execute("echo $(((2+2)>(2+3) ? 1 : 32)) > #{outf}")
    assert_equal "32\n", File.read(outf)
  end

  # echo $(((2+2)>(2+3) ? 2**0 : 32))  ->  32  (unevaluated branch)
  def test_arith_ternary_unevaluated_branch
    execute("echo $(((2+2)>(2+3) ? 2**0 : 32)) > #{outf}")
    assert_equal "32\n", File.read(outf)
  end

  # echo $((2**15 - 1))  ->  32767
  def test_arith_exponent
    execute("echo $((2**15 - 1)) > #{outf}")
    assert_equal "32767\n", File.read(outf)
  end

  # echo $((2**(16-1)))  ->  32768
  def test_arith_exponent_in_expr
    execute("echo $((2**(16-1))) > #{outf}")
    assert_equal "32768\n", File.read(outf)
  end

  # echo $((2**16*2))  ->  131072
  def test_arith_exponent_multiply
    execute("echo $((2**16*2)) > #{outf}")
    assert_equal "131072\n", File.read(outf)
  end

  # echo $((2**31-1))  ->  2147483647
  def test_arith_max_signed_32
    execute("echo $((2**31-1)) > #{outf}")
    assert_equal "2147483647\n", File.read(outf)
  end

  # echo $((2**0))  ->  1
  def test_arith_exponent_zero
    execute("echo $((2**0)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $((0xff))  ->  255
  def test_arith_hex_literal
    omit 'hex literals in $(( )) not yet supported'
    execute("echo $((0xff)) > #{outf}")
    assert_equal "255\n", File.read(outf)
  end

  # echo $((0x100 | 007))  ->  263
  def test_arith_hex_or_octal
    omit 'hex/octal literals in $(( )) not yet supported'
    execute("echo $((0x100 | 007)) > #{outf}")
    assert_equal "263\n", File.read(outf)
  end

  # echo $((2147483645 + 4))  ->  2147483649
  def test_arith_large_int
    execute("echo $((2147483645 + 4)) > #{outf}")
    assert_equal "2147483649\n", File.read(outf)
  end

  # echo $((1 << 4))  ->  16
  def test_arith_left_shift
    execute("echo $((1 << 4)) > #{outf}")
    assert_equal "16\n", File.read(outf)
  end

  # echo $((256 >> 4))  ->  16
  def test_arith_right_shift
    execute("echo $((256 >> 4)) > #{outf}")
    assert_equal "16\n", File.read(outf)
  end

  # B=9; (( 0 && (B=42) )); echo $B  ->  9  (right side not evaluated)
  def test_arith_short_circuit_and_skips
    omit 'short-circuit && in (( )) not yet on master'
    execute('B=9')
    execute('(( 0 && (B=42) ))')
    assert_equal '9', get_shell_var('B')
  end

  # B=9; (( 1 || (B=88) )); echo $B  ->  9  (right side not evaluated)
  def test_arith_short_circuit_or_skips
    omit 'short-circuit || in (( )) not yet on master'
    execute('B=9')
    execute('(( 1 || (B=88) ))')
    assert_equal '9', get_shell_var('B')
  end

  # x=4; echo $((x+1))  ->  5
  def test_arith_var_in_expr
    execute("x=4; echo $((x+1)) > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # x=10; y=3; echo $((x*y))  ->  30
  def test_arith_two_vars
    execute("x=10; y=3; echo $((x*y)) > #{outf}")
    assert_equal "30\n", File.read(outf)
  end

  # echo $((10 % 3))  ->  1
  def test_arith_modulo
    execute("echo $((10 % 3)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # x=5; echo $((x+=3))  ->  8
  def test_arith_compound_plus_eq
    omit 'compound assignment += in $(( )) not yet supported'
    execute("x=5; echo $((x+=3)) > #{outf}")
    assert_equal "8\n", File.read(outf)
  end

  # x=10; echo $((x-=3))  ->  7
  def test_arith_compound_minus_eq
    omit 'compound assignment -= in $(( )) not yet supported'
    execute("x=10; echo $((x-=3)) > #{outf}")
    assert_equal "7\n", File.read(outf)
  end

  # x=3; echo $((x*=4))  ->  12
  def test_arith_compound_mul_eq
    omit 'compound assignment *= in $(( )) not yet supported'
    execute("x=3; echo $((x*=4)) > #{outf}")
    assert_equal "12\n", File.read(outf)
  end

  # x=12; echo $((x/=4))  ->  3
  def test_arith_compound_div_eq
    omit 'compound assignment /= in $(( )) not yet supported'
    execute("x=12; echo $((x/=4)) > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # x=7; echo $((x%=3))  ->  1
  def test_arith_compound_mod_eq
    omit 'compound assignment %= in $(( )) not yet supported'
    execute("x=7; echo $((x%=3)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $((4 == 4))  ->  1
  def test_arith_equality_true
    omit '== operator in $(( )) not yet supported'
    execute("echo $((4 == 4)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $((4 == 5))  ->  0
  def test_arith_equality_false
    omit '== operator in $(( )) not yet supported'
    execute("echo $((4 == 5)) > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # echo $((4 != 5))  ->  1
  def test_arith_not_equal
    omit '!= operator in $(( )) not yet supported'
    execute("echo $((4 != 5)) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # x=4; (( x++ )); echo $x  ->  5
  def test_arith_post_increment
    execute("x=4; (( x++ )); echo $x > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # x=4; (( x-- )); echo $x  ->  3
  def test_arith_post_decrement
    execute("x=4; (( x-- )); echo $x > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # x=4; echo $((++x))  ->  5
  def test_arith_pre_increment
    omit 'prefix ++ in $(( )) not yet supported'
    execute("x=4; echo $((++x)) > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # x=4; echo $((--x))  ->  3
  def test_arith_pre_decrement
    omit 'prefix -- in $(( )) not yet supported'
    execute("x=4; echo $((--x)) > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # echo $(( +4 - 8 ))  ->  -4
  def test_arith_unary_plus
    execute("echo $(( +4 - 8 )) > #{outf}")
    assert_equal "-4\n", File.read(outf)
  end

  # echo $(( -4 + 8 ))  ->  4
  def test_arith_unary_minus
    execute("echo $(( -4 + 8 )) > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # S=105; W=$((S>99?4:S>9?3:S>0?2:0)); echo $W  ->  4
  def test_arith_nested_ternary
    execute("S=105; W=$((S>99?4:S>9?3:S>0?2:0)); echo $W > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # until (( x == 4 )) test
  def test_arith_until_loop
    execute("x=7; until (( x == 4 )); do x=4; done; echo $x > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # if (( expr )) then
  def test_arith_if_cond
    execute("if (( 4 + 4 )); then echo ok; fi > #{outf}")
    assert_equal "ok\n", File.read(outf)
  end

  # (()) null expression
  def test_arith_null_expr
    omit '(()) null expression not yet supported'
    execute("(()) ; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # echo $((2**10))  ->  1024
  def test_arith_power_10
    execute("echo $((2**10)) > #{outf}")
    assert_equal "1024\n", File.read(outf)
  end

  # x=3; y=4; echo $((x*x + y*y))  ->  25
  def test_arith_pythagorean
    execute("x=3; y=4; echo $((x*x + y*y)) > #{outf}")
    assert_equal "25\n", File.read(outf)
  end

  # echo $((10/3))  ->  3  (integer division)
  def test_arith_integer_division
    execute("echo $((10/3)) > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # i=5; echo $((i++)); echo $i  ->  5\n6  (post-increment returns old)
  def test_arith_post_increment_return
    omit 'post-increment return value in $(( )) not working'
    execute("i=5; echo $((i++)) > #{outf}; echo $i >> #{outf}")
    assert_equal "5\n6\n", File.read(outf)
  end

  # i=5; echo $((i--)); echo $i  ->  5\n4
  def test_arith_post_decrement_return
    omit 'post-decrement return value in $(( )) not working'
    execute("i=5; echo $((i--)) > #{outf}; echo $i >> #{outf}")
    assert_equal "5\n4\n", File.read(outf)
  end

  # x=0; (( x++ )); (( x++ )); echo $x  ->  2
  def test_arith_double_post_inc
    execute("x=0; (( x++ )); (( x++ )); echo $x > #{outf}")
    assert_equal "2\n", File.read(outf)
  end

  # (( 4 > 3 )); echo $?  ->  0
  def test_arith_cond_gt_true
    execute("(( 4 > 3 )); echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # (( 3 > 4 )); echo $?  ->  1
  def test_arith_cond_gt_false
    execute("(( 3 > 4 )); echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # (( 4 >= 4 )); echo $?  ->  0
  def test_arith_cond_ge
    execute("(( 4 >= 4 )); echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # (( 3 <= 4 )); echo $?  ->  0
  def test_arith_cond_le
    execute("(( 3 <= 4 )); echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # x=1; y=$((x > 0 ? 100 : 200)); echo $y  ->  100
  def test_arith_ternary_var
    execute("x=1; y=$((x > 0 ? 100 : 200)); echo $y > #{outf}")
    assert_equal "100\n", File.read(outf)
  end

  # echo $((4 & 6))  ->  4
  def test_arith_bitand
    execute("echo $((4 & 6)) > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # echo $((4 | 2))  ->  6
  def test_arith_bitor
    execute("echo $((4 | 2)) > #{outf}")
    assert_equal "6\n", File.read(outf)
  end

  # echo $((4 ^ 6))  ->  2
  def test_arith_bitxor
    execute("echo $((4 ^ 6)) > #{outf}")
    assert_equal "2\n", File.read(outf)
  end

  # echo $((~0))  ->  -1
  def test_arith_bitnot_zero
    execute("echo $((~0)) > #{outf}")
    assert_equal "-1\n", File.read(outf)
  end

  # echo $((1 << 8))  ->  256
  def test_arith_lshift_8
    execute("echo $((1 << 8)) > #{outf}")
    assert_equal "256\n", File.read(outf)
  end

  # echo $((1024 >> 2))  ->  256
  def test_arith_rshift
    execute("echo $((1024 >> 2)) > #{outf}")
    assert_equal "256\n", File.read(outf)
  end
end
