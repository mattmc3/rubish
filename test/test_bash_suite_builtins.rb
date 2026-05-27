# frozen_string_literal: true

# Tests sourced from .bash/tests/builtins.tests
require_relative 'test_helper'

class TestBash_Builtins < Test::Unit::TestCase
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

  # echo -n foo  ->  foo (no newline)
  def test_echo_n
    execute("echo -n foo > #{outf}")
    assert_equal "foo", File.read(outf)
  end

  # read from here-string
  def test_read_basic_herestr
    execute("read x <<<hello; echo $x > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # read two vars
  def test_read_two_vars
    execute("read x y <<<'hello world'; echo $x $y > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # read -r preserves backslash
  def test_read_r_backslash
    execute("read -r x <<<'a\\\\b'; echo $x > #{outf}")
    assert_equal "a\\\\b\n", File.read(outf)
  end

  # true; echo $?  ->  0
  def test_true_exit_code
    execute("true; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # false; echo $?  ->  1
  def test_false_exit_code
    execute("false; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # : (colon) is no-op, exits 0
  def test_colon_noop
    execute(": ; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # (exit 42); echo $?  ->  42
  def test_exit_code_in_subshell
    omit 'subshell exit code not propagated to $?'
    execute("(exit 42); echo $? > #{outf}")
    assert_equal "42\n", File.read(outf)
  end

  # if true; then echo yes; else echo no; fi  ->  yes
  def test_if_true
    execute("if true; then echo yes; else echo no; fi > #{outf}")
    assert_equal "yes\n", File.read(outf)
  end

  # if false; then echo yes; else echo no; fi  ->  no
  def test_if_false
    execute("if false; then echo yes; else echo no; fi > #{outf}")
    assert_equal "no\n", File.read(outf)
  end

  # elif: if false; elif true; then echo yes; fi  ->  yes
  def test_if_elif
    execute("if false; then echo no; elif true; then echo yes; fi > #{outf}")
    assert_equal "yes\n", File.read(outf)
  end

  # nested if
  def test_if_nested
    execute("if true; then if false; then echo inner; else echo outer; fi; fi > #{outf}")
    assert_equal "outer\n", File.read(outf)
  end

  # if with [ ] test
  def test_if_bracket_test
    execute("x=5; if [ $x -gt 3 ]; then echo big; else echo small; fi > #{outf}")
    assert_equal "big\n", File.read(outf)
  end
end
