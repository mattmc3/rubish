# frozen_string_literal: true

# Tests sourced from .bash/tests/strip.tests
require_relative 'test_helper'

class TestBash_Strip < Test::Unit::TestCase
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

  # v=`echo "" ; echo "" ; echo ""`  ->  ''
  def test_strip_all_blank_lines
    omit 'multiple blank-line stripping from cmd sub not fully working'
    execute("v=`echo '' ; echo '' ; echo ''`; echo \"'$v'\" > #{outf}")
    assert_equal "''\n", File.read(outf)
  end

  # v=`echo -n " ab "`  ->  ' ab '
  def test_strip_no_newline_spaces_preserved
    execute("v=`echo -n ' ab '`; echo \"'$v'\" > #{outf}")
    assert_equal "' ab '\n", File.read(outf)
  end

  # v=`echo -n " "`  ->  ' '
  def test_strip_no_newline_space
    execute("v=`echo -n ' '`; echo \"'$v'\" > #{outf}")
    assert_equal "' '\n", File.read(outf)
  end

  # v=`echo -n ""`  ->  ''
  def test_strip_no_newline_empty
    execute("v=`echo -n ''`; echo \"'$v'\" > #{outf}")
    assert_equal "''\n", File.read(outf)
  end

  # v=`echo ""`  ->  ''
  def test_strip_single_blank_line
    execute("v=`echo ''`; echo \"'$v'\" > #{outf}")
    assert_equal "''\n", File.read(outf)
  end

  # v=`echo`  ->  ''
  def test_strip_bare_echo
    execute("v=`echo`; echo \"'$v'\" > #{outf}")
    assert_equal "''\n", File.read(outf)
  end

  # v=`echo ababababababab`  ->  'ababababababab'
  def test_strip_content_stripped_newline
    execute("v=`echo ababababababab`; echo \"'$v'\" > #{outf}")
    assert_equal "'ababababababab'\n", File.read(outf)
  end

  # v=`echo "ababababababab  "`  ->  'ababababababab  '
  def test_strip_trailing_spaces_in_content
    execute("v=`echo 'ababababababab  '`; echo \"'$v'\" > #{outf}")
    assert_equal "'ababababababab  '\n", File.read(outf)
  end

  # v=`echo -n "ababababababab  "`  ->  'ababababababab  '
  def test_strip_no_newline_content_spaces
    execute("v=`echo -n 'ababababababab  '`; echo \"'$v'\" > #{outf}")
    assert_equal "'ababababababab  '\n", File.read(outf)
  end

  # v=`echo -ne "abababa\nbababab  "`  ->  'abababa\nbababab  '
  def test_strip_internal_newline_preserved
    execute("v=`printf 'abababa\nbababab  '`; echo \"'$v'\" > #{outf}")
    assert_equal "'abababa\nbababab  '\n", File.read(outf)
  end
end
