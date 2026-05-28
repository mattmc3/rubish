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

  # single-quoted string with embedded literal newline
  # echo 'foo<LF>bar'  ->  foo<LF>bar  (single quotes preserve newline)
  def test_quote_single_embedded_newline
    execute("echo 'foo\nbar' > #{outf}")
    assert_equal "foo\nbar\n", File.read(outf)
  end

  # single-quoted string with backslash-newline: both chars are literal
  # echo 'foo\<LF>bar'  ->  foo\<LF>bar
  def test_quote_single_backslash_newline_literal
    execute("echo 'foo\\\nbar' > #{outf}")
    assert_equal "foo\\\nbar\n", File.read(outf)
  end

  # double-quoted string with embedded literal newline
  # echo "foo<LF>bar"  ->  foo<LF>bar
  def test_quote_double_embedded_newline
    execute("echo \"foo\nbar\" > #{outf}")
    assert_equal "foo\nbar\n", File.read(outf)
  end

  # double-quoted backslash-newline is a line continuation (removes both)
  # echo "foo\<LF>bar"  ->  foobar
  def test_quote_double_backslash_newline_continuation
    omit 'double-quoted backslash-newline continuation not implemented'
    execute("echo \"foo\\\nbar\" > #{outf}")
    assert_equal "foobar\n", File.read(outf)
  end

  # backtick: output with embedded newline is word-split, joins with space
  # echo `echo 'foo<LF>bar'`  ->  foo bar
  def test_quote_backtick_newline_word_splits
    omit 'backtick output not word-split on embedded newlines'
    execute("echo `echo 'foo\nbar'` > #{outf}")
    assert_equal "foo bar\n", File.read(outf)
  end

  # dollar-paren: output with embedded newline is word-split, joins with space
  # echo $(echo 'foo<LF>bar')  ->  foo bar
  def test_quote_dollar_paren_newline_word_splits
    execute("echo $(echo 'foo\nbar') > #{outf}")
    assert_equal "foo bar\n", File.read(outf)
  end

  # dollar-paren double-quoted: backslash-newline inside $() is line continuation
  # echo $(echo "foo\<LF>bar")  ->  foobar
  def test_quote_dollar_paren_double_backslash_newline_continuation
    omit 'double-quoted backslash-newline continuation not implemented inside $()'
    execute("echo $(echo \"foo\\\nbar\") > #{outf}")
    assert_equal "foobar\n", File.read(outf)
  end

  # quoted backtick: output preserved with newline, no word split
  # echo "`echo 'foo<LF>bar'`"  ->  foo<LF>bar
  def test_quote_double_backtick_preserves_newline
    execute("echo \"`echo 'foo\nbar'`\" > #{outf}")
    assert_equal "foo\nbar\n", File.read(outf)
  end

  # quoted dollar-paren: output preserved with newline, no word split
  # echo "$(echo 'foo<LF>bar')"  ->  foo<LF>bar
  def test_quote_double_dollar_paren_preserves_newline
    execute("echo \"$(echo 'foo\nbar')\" > #{outf}")
    assert_equal "foo\nbar\n", File.read(outf)
  end

  # dollar-paren single-quoted: \<LF> is literal (no line continuation in $())
  # echo $(echo 'foo\<LF>bar')  ->  foo\ bar  (word split on embedded newline)
  def test_quote_dollar_paren_single_backslash_newline_literal
    execute("echo $(echo 'foo\\\nbar') > #{outf}")
    assert_equal "foo\\ bar\n", File.read(outf)
  end

  # quoted dollar-paren single-quoted: \<LF> preserved, no word split
  # echo "$(echo 'foo\<LF>bar')"  ->  foo\<LF>bar
  def test_quote_double_dollar_paren_single_backslash_newline
    execute("echo \"$(echo 'foo\\\nbar')\" > #{outf}")
    assert_equal "foo\\\nbar\n", File.read(outf)
  end

  # echo "string \\"  ->  string \  (double-quoted \\ is a single backslash)
  def test_quote_double_escaped_backslash
    execute('echo "string \\\\" > ' + outf)
    assert_equal "string \\\n", File.read(outf)
  end

  # echo string\ \\  ->  string \  (unquoted: escaped space then escaped backslash)
  def test_quote_unquoted_backslash_escape
    execute("echo string\\ \\\\ > #{outf}")
    assert_equal "string \\\n", File.read(outf)
  end

  # ${foo:-'string \'}  ->  string \  (default value with single-quoted backslash)
  def test_quote_param_default_single_quoted_backslash
    omit 'single-quoted default value in param expansion not fully parsed'
    execute("unset foo; echo ${foo:-'string \\'} > #{outf}")
    assert_equal "string \\\n", File.read(outf)
  end

  # "${foo:-string \\}"  ->  string \  (quoted default with escaped backslash)
  def test_quote_param_default_double_quoted_backslash
    omit 'double-quoted escaped backslash in param default not handled'
    execute('unset foo; echo "${foo:-string \\\\}" > ' + outf)
    assert_equal "string \\\n", File.read(outf)
  end

  # ${foo:-string \\\}}  ->  string \}  (unquoted default with escaped backslash and brace)
  def test_quote_param_default_unquoted_backslash_brace
    omit 'escaped backslash before closing brace in param expansion not handled'
    execute("unset foo; echo ${foo:-string \\\\\\}} > #{outf}")
    assert_equal "string \\}\n", File.read(outf)
  end
end
