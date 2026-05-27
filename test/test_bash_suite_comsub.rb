# frozen_string_literal: true

# Tests sourced from .bash/tests/comsub.tests
require_relative 'test_helper'

class TestBash_Comsub < Test::Unit::TestCase
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

  # x=$(echo hello); echo $x  ->  hello
  def test_comsub_basic
    execute("x=$(echo hello); echo $x > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # x=$(echo a; echo b); echo "$x"  ->  a\nb
  def test_comsub_multiline
    execute("x=$(echo a; echo b); echo \"$x\" > #{outf}")
    assert_equal "a\nb\n", File.read(outf)
  end

  # nested: echo $(echo $(echo hi))  ->  hi
  def test_comsub_nested
    execute("echo $(echo $(echo hi)) > #{outf}")
    assert_equal "hi\n", File.read(outf)
  end

  # cmd sub in arithmetic: echo $(($(echo 3) + 4))  ->  7
  def test_comsub_in_arith
    omit 'cmd sub inside $(( )) not yet supported'
    execute("echo $(($(echo 3) + 4)) > #{outf}")
    assert_equal "7\n", File.read(outf)
  end

  # pipeline in cmd sub
  def test_comsub_pipeline
    execute("echo $(echo 'a b c' | tr ' ' '\n' | wc -l | tr -d ' ') > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # cmd sub trailing newline stripped
  def test_comsub_strips_trailing_newline
    execute("x=$(printf 'hi\n'); echo $x > #{outf}")
    assert_equal "hi\n", File.read(outf)
  end

  # blank comsub: echo --$()--  ->  ----
  def test_comsub_empty
    execute("echo --$()-- > #{outf}")
    assert_equal "----\n", File.read(outf)
  end

  # cmd sub with assignment
  def test_comsub_assigns
    execute("a=$(echo foo); echo $a > #{outf}")
    assert_equal "foo\n", File.read(outf)
  end

  # nested double-quote: echo "$(echo 'a b c')"  ->  a b c
  def test_comsub_quoted_spaces_preserved
    execute("echo \"$(echo 'a b c')\" > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # backtick cmd sub
  def test_comsub_backtick
    execute("x=`echo hello`; echo $x > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end
end
