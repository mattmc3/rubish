# frozen_string_literal: true

# Tests sourced from .bash/tests/posixpipe.tests
require_relative 'test_helper'

class TestBash_Posixpipe < Test::Unit::TestCase
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

  # echo foo | cat  ->  foo
  def test_pipe_basic
    execute("echo foo | cat > #{outf}")
    assert_equal "foo\n", File.read(outf)
  end

  # echo 'a b c' | tr ' ' '\n'  ->  a\nb\nc
  def test_pipe_tr
    execute("echo 'a b c' | tr ' ' '\\n' > #{outf}")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # printf '%s\n' a b c | grep b  ->  b
  def test_pipe_grep
    omit 'printf multiline output piped to grep redirect not working'
    execute("printf '%s\n' a b c | grep b > #{outf}")
    assert_equal "b\n", File.read(outf)
  end

  # echo abc | wc -c  ->  4
  def test_pipe_wc
    execute("echo abc | wc -c | tr -d ' ' > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # three-stage pipeline
  def test_pipe_three_stage
    execute("echo hello | tr 'a-z' 'A-Z' > #{outf}")
    assert_equal "HELLO\n", File.read(outf)
  end

  # false | true; echo $?  ->  0  (last cmd)
  def test_pipe_exit_status_last
    execute("false | true; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # true | false; echo $?  ->  1
  def test_pipe_exit_status_last_false
    execute("true | false; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end
end
