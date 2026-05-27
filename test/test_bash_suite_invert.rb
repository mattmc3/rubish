# frozen_string_literal: true

# Tests sourced from .bash/tests/invert.tests
require_relative 'test_helper'

class TestBash_Invert < Test::Unit::TestCase
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

  # ! true; echo $?  ->  1
  def test_invert_true
    execute("! true; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # ! false; echo $?  ->  0
  def test_invert_false
    execute("! false; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # ! (false); echo $?  ->  0
  def test_invert_subshell_false
    execute("! (false); echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # ! (true); echo $?  ->  1
  def test_invert_subshell_true
    execute("! (true); echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # ! true | false; echo $?  ->  0
  def test_invert_pipeline_true_false
    execute("! true | false; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # ! false | true; echo $?  ->  1
  def test_invert_pipeline_false_true
    execute("! false | true; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end
end
