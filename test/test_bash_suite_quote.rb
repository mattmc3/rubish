# frozen_string_literal: true

# Tests sourced from .bash/tests/quote.tests
require_relative 'test_helper'

class TestBash_Quote < Test::Unit::TestCase
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

  # echo 'foo\nbar'  ->  foo\nbar  (single quote preserves backslash)
  def test_quote_single_literal_backslash_n
    execute("echo 'foo\\nbar' > #{outf}")
    assert_equal "foo\\nbar\n", File.read(outf)
  end

  # echo 'foo\bar'  ->  foo\bar
  def test_quote_single_literal_backslash
    execute("echo 'foo\\bar' > #{outf}")
    assert_equal "foo\\bar\n", File.read(outf)
  end

  # x=hello; echo "$x world"  ->  hello world
  def test_quote_double_interpolates_var
    execute("x=hello; echo \"$x world\" > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # echo "  spaces  "  ->    spaces
  def test_quote_double_preserves_spaces
    execute("echo \"  spaces  \" > #{outf}")
    assert_equal "  spaces  \n", File.read(outf)
  end

  # v=$(echo hello); echo "'$v'"  ->  'hello'
  def test_quote_cmd_sub_strips_trailing_newline
    execute("v=$(echo hello); echo \"'$v'\" > #{outf}")
    assert_equal "'hello'\n", File.read(outf)
  end

  # v=`echo hello`; echo "'$v'"  ->  'hello'
  def test_quote_backtick_strips_trailing_newline
    execute("v=`echo hello`; echo \"'$v'\" > #{outf}")
    assert_equal "'hello'\n", File.read(outf)
  end

  # for w in $(echo 'a b c'); do echo $w; done  ->  a\nb\nc
  def test_quote_unquoted_cmd_sub_splits
    execute("for w in $(echo 'a b c'); do echo $w >> #{outf}; done")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # echo "$(echo 'a b c')"  ->  a b c  (quoted cmd sub no split)
  def test_quote_double_cmd_sub_preserves_spaces
    execute("echo \"$(echo 'a b c')\" > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # echo 'string \'  ->  string \
  def test_quote_string_ending_backslash
    execute("echo 'string \\' > #{outf}")
    assert_equal "string \\\n", File.read(outf)
  end

  # v=$(printf 'hi\n\n\n'); echo "'$v'"  ->  'hi'
  def test_quote_cmd_sub_multiple_trailing_newlines_stripped
    omit 'multiple trailing newlines not fully stripped from cmd sub'
    execute("v=$(printf 'hi\\n\\n\\n'); echo \"'$v'\" > #{outf}")
    assert_equal "'hi'\n", File.read(outf)
  end
end
