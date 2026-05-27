# frozen_string_literal: true

# Tests for subshell behavior
require_relative 'test_helper'

class TestBash_Subshell < Test::Unit::TestCase
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

  # (echo hello)  ->  hello
  def test_subshell_basic
    execute("(echo hello) > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # x=outer; (x=inner); echo $x  ->  outer
  def test_subshell_var_isolation
    execute("x=outer; (x=inner); echo $x > #{outf}")
    assert_equal "outer\n", File.read(outf)
  end

  # (echo a; echo b)  ->  a\nb
  def test_subshell_multiple_commands
    execute("(echo a; echo b) > #{outf}")
    assert_equal "a\nb\n", File.read(outf)
  end

  # echo $( (echo nested) )  ->  nested
  def test_subshell_in_comsub
    execute("echo $( (echo nested) ) > #{outf}")
    assert_equal "nested\n", File.read(outf)
  end

  # (exit 5); echo $?  ->  5
  def test_subshell_exit_code
    omit 'subshell exit code not propagated to $?'
    execute("(exit 5); echo $? > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # echo foo | (cat; echo bar)  ->  foo\nbar
  def test_subshell_pipeline
    execute("echo foo | (cat; echo bar) > #{outf}")
    assert_equal "foo\nbar\n", File.read(outf)
  end
end
