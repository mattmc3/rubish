# frozen_string_literal: true

require_relative 'test_helper'

class TestTrailingNewlineStrip < Test::Unit::TestCase
  def setup
    @repl = Rubish::REPL.new
    @tempdir = Dir.mktmpdir('rubish_strip_test')
  end

  def teardown
    FileUtils.rm_rf(@tempdir)
  end

  def outf
    File.join(@tempdir, 'out')
  end

  def test_dollar_paren_strips_all_trailing_newlines
    execute("x=$(printf 'a\n\n\n'); echo \"$x\" > #{outf}")
    assert_equal "a\n", File.read(outf)
  end

  def test_backtick_strips_all_trailing_newlines
    execute("x=`printf 'a\n\n\n'`; echo \"$x\" > #{outf}")
    assert_equal "a\n", File.read(outf)
  end
end
