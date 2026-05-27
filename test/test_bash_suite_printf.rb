# frozen_string_literal: true

# Tests sourced from .bash/tests/printf.tests
require_relative 'test_helper'

class TestBash_Printf < Test::Unit::TestCase
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

  # printf "\tone\n"  ->  \tone\n
  def test_printf_tab
    execute("printf '\\tone\\n' > #{outf}")
    assert_equal "\tone\n", File.read(outf)
  end

  # printf "%%\n"  ->  %\n
  def test_printf_literal_percent
    execute("printf '%%\\n' > #{outf}")
    assert_equal "%\n", File.read(outf)
  end

  # printf "%c\n" ABCD  ->  A\n
  def test_printf_c_format
    execute("printf '%c\\n' ABCD > #{outf}")
    assert_equal "A\n", File.read(outf)
  end

  # printf "%s\n" unquoted  ->  unquoted\n
  def test_printf_s_format
    execute("printf '%s\\n' unquoted > #{outf}")
    assert_equal "unquoted\n", File.read(outf)
  end

  # printf "%d\n" 42  ->  42\n
  def test_printf_d_format
    execute("printf '%d\\n' 42 > #{outf}")
    assert_equal "42\n", File.read(outf)
  end

  # printf "%05d\n" 42  ->  00042\n
  def test_printf_d_zero_pad
    execute("printf '%05d\\n' 42 > #{outf}")
    assert_equal "00042\n", File.read(outf)
  end

  # printf "%x\n" 255  ->  ff\n
  def test_printf_x_format
    execute("printf '%x\\n' 255 > #{outf}")
    assert_equal "ff\n", File.read(outf)
  end

  # printf "%o\n" 8  ->  10\n
  def test_printf_o_format
    execute("printf '%o\\n' 8 > #{outf}")
    assert_equal "10\n", File.read(outf)
  end

  # printf "%e\n" 3.14  ->  3.140000e+00\n
  def test_printf_e_format
    execute("printf '%e\\n' 3.14 > #{outf}")
    assert_equal "3.140000e+00\n", File.read(outf)
  end

  # printf "%f\n" 3.14  ->  3.140000\n
  def test_printf_f_format
    execute("printf '%f\\n' 3.14 > #{outf}")
    assert_equal "3.140000\n", File.read(outf)
  end

  # printf "%10s\n" hi  ->  "        hi\n"
  def test_printf_right_justify
    execute("printf '%10s\\n' hi > #{outf}")
    assert_equal "        hi\n", File.read(outf)
  end

  # printf "%-10s|\n" hi  ->  "hi        |\n"
  def test_printf_left_justify
    execute("printf '%-10s|\\n' hi > #{outf}")
    assert_equal "hi        |\n", File.read(outf)
  end

  # printf "%s %s %s\n" a b c  ->  a b c\n
  def test_printf_multiple_args
    execute("printf '%s %s %s\\n' a b c > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # printf repeats format: printf "%s\n" a b c  ->  a\nb\nc\n
  def test_printf_repeats_format
    execute("printf '%s\\n' a b c > #{outf}")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # printf -v var "%s" hello; echo $var  ->  hello
  def test_printf_v_assigns_var
    execute("printf -v myvar '%s' hello; echo $myvar > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # printf "%b\n" 'a\tb'  ->  a<tab>b
  def test_printf_b_escape
    execute("printf '%b\n' 'a\\tb' > #{outf}")
    assert_equal "a\tb\n", File.read(outf)
  end

  # printf "%04d\n" 7  ->  0007
  def test_printf_d_four_zero_pad
    execute("printf '%04d\n' 7 > #{outf}")
    assert_equal "0007\n", File.read(outf)
  end

  # printf "%.3f\n" 3.14159  ->  3.142
  def test_printf_f_precision
    execute("printf '%.3f\n' 3.14159 > #{outf}")
    assert_equal "3.142\n", File.read(outf)
  end

  # printf "%+d %+d\n" 5 -5  ->  +5 -5
  def test_printf_d_sign
    execute("printf '%+d %+d\n' 5 -5 > #{outf}")
    assert_equal "+5 -5\n", File.read(outf)
  end

  # printf '%s' hello  ->  hello (no newline)
  def test_printf_no_newline
    execute("printf '%s' hello > #{outf}")
    assert_equal "hello", File.read(outf)
  end
end
