# frozen_string_literal: true

# Tests sourced from .bash/tests/appendop.tests
require_relative 'test_helper'

class TestBash_Appendop < Test::Unit::TestCase
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

  # a=1; a+=4  ->  14  (string append)
  def test_appendop_string
    execute("a=1; a+=4; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end

  # a+=5 in command env
  def test_appendop_in_env
    execute("a=1; a+=4; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end

  # array append
  def test_appendop_array
    execute("x=(1 2 3); x+=(4 5 6); echo ${x[@]} > #{outf}")
    assert_equal "1 2 3 4 5 6\n", File.read(outf)
  end

  # export a+=4
  def test_appendop_export
    omit 'export with += not yet supported'
    execute("a=1; export a+=4; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end
end
