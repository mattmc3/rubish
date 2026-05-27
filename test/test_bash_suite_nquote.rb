# frozen_string_literal: true

# Tests sourced from .bash/tests/nquote.tests -- $'...' ANSI C quoting
require_relative 'test_helper'

class TestBash_Nquote < Test::Unit::TestCase
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

  # echo $'abc'  ->  abc
  def test_nquote_basic_string
    omit "$'...' ANSI C quoting not yet supported"
    execute("echo $'abc' > #{outf}")
    assert_equal "abc\n", File.read(outf)
  end

  # echo $'\n\n\n'  ->  (3 newlines)
  def test_nquote_newlines
    omit "$'...' ANSI C quoting not yet supported"
    execute("echo $'\\n\\n\\n' > #{outf}")
    assert_equal "\n\n\n\n", File.read(outf)
  end

  # f=$'\n'; echo "++$f++"  ->  ++\n++
  def test_nquote_newline_in_var
    omit "$'...' ANSI C quoting not yet supported"
    execute("f=$'\\n'; echo \"++$f++\" > #{outf}")
    assert_equal "++\n++\n", File.read(outf)
  end

  # z1=$''; echo "$z1"  ->  (empty)
  def test_nquote_empty_string
    omit "$'...' ANSI C quoting not yet supported"
    execute("z1=$''; echo \"$z1\" > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # ZIFS=$'\n'$'\t'$' '; echo "$ZIFS"  ->  \n\t<space>
  def test_nquote_combined
    omit "$'...' ANSI C quoting not yet supported"
    execute("ZIFS=$'\\n'$'\\t'$' '; echo \"$ZIFS\" > #{outf}")
    assert_equal "\n\t \n", File.read(outf)
  end

  # case "$z" in $'\v\f\a\b') echo ok;; esac
  def test_nquote_in_case
    omit "$'...' ANSI C quoting not yet supported"
    execute("z=$'\\v\\f\\a\\b'; case \"$z\" in $'\\v\\f\\a\\b') echo ok > #{outf};; *) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # echo $'\'abcd\''  ->  'abcd'
  def test_nquote_escaped_single_quotes
    omit "$'...' ANSI C quoting not yet supported"
    execute("echo $'\\'abcd\\'' > #{outf}")
    assert_equal "'abcd'\n", File.read(outf)
  end

  # echo "$(echo $'\t\t\101\104\n\105')"  ->  \t\tAD\nE
  def test_nquote_octal_escape
    omit "$'...' ANSI C quoting not yet supported"
    execute("echo \"$(echo $'\\t\\t\\101\\104\\n\\105')\" > #{outf}")
    assert_equal "\t\tAD\nE\n", File.read(outf)
  end
end
