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
execute("echo $'abc' > #{outf}")
    assert_equal "abc\n", File.read(outf)
  end

  # echo $'\n\n\n'  ->  (3 newlines)
  def test_nquote_newlines
    omit "$'...' trailing newlines are stripped incorrectly"
    execute("echo $'\\n\\n\\n' > #{outf}")
    assert_equal "\n\n\n\n", File.read(outf)
  end

  # f=$'\n'; echo "++$f++"  ->  ++\n++
  def test_nquote_newline_in_var
execute("f=$'\\n'; echo \"++$f++\" > #{outf}")
    assert_equal "++\n++\n", File.read(outf)
  end

  # z1=$''; echo "$z1"  ->  (empty)
  def test_nquote_empty_string
execute("z1=$''; echo \"$z1\" > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # ZIFS=$'\n'$'\t'$' '; echo "$ZIFS"  ->  \n\t<space>
  def test_nquote_combined
execute("ZIFS=$'\\n'$'\\t'$' '; echo \"$ZIFS\" > #{outf}")
    assert_equal "\n\t \n", File.read(outf)
  end

  # case "$z" in $'\v\f\a\b') echo ok;; esac
  def test_nquote_in_case
execute("z=$'\\v\\f\\a\\b'; case \"$z\" in $'\\v\\f\\a\\b') echo ok > #{outf};; *) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # echo $'\'abcd\''  ->  'abcd'
  def test_nquote_escaped_single_quotes
execute("echo $'\\'abcd\\'' > #{outf}")
    assert_equal "'abcd'\n", File.read(outf)
  end

  # echo "$(echo $'\t\t\101\104\n\105')"  ->  \t\tAD\nE
  def test_nquote_octal_escape
execute("echo \"$(echo $'\\t\\t\\101\\104\\n\\105')\" > #{outf}")
    assert_equal "\t\tAD\nE\n", File.read(outf)
  end

  # echo $'\r\e\aabc'  ->  CR ESC BEL abc
  def test_nquote_cr_esc_bel
    execute("echo $'\\r\\e\\aabc' > #{outf}")
    assert_equal "\r\e\aabc\n", File.read(outf)
  end

  # $ is literal inside $'...' -- no variable expansion
  # echo $'ab$cde'  ->  ab$cde
  def test_nquote_dollar_literal
    execute("echo $'ab$cde' > #{outf}")
    assert_equal "ab$cde\n", File.read(outf)
  end

  # $"..." text is literal inside $'...'
  # echo $'hello, $"world"'  ->  hello, $"world"
  def test_nquote_dollar_dquote_literal
    execute("echo $'hello, $\"world\"' > #{outf}")
    assert_equal "hello, $\"world\"\n", File.read(outf)
  end

  # \$ inside $'...' stays as \$ (backslash is kept for unrecognized sequences)
  # echo $'hello, \$"world"'  ->  hello, \$"world"
  def test_nquote_escaped_dollar_literal
    execute("echo $'hello, \\$\"world\"' > #{outf}")
    assert_equal "hello, \\$\"world\"\n", File.read(outf)
  end

  # $\" inside $'...' gives $" (backslash-escaped double quote)
  # echo $'hello, $\"world"'  ->  hello, $"world"
  def test_nquote_escaped_dquote_in_ansi
    execute("echo $'hello, $\\\"world\"' > #{outf}")
    assert_equal "hello, $\"world\"\n", File.read(outf)
  end

  # semicolons are literal inside $'...' -- no command splitting
  # echo "$(echo $';foo')"  ->  ;foo
  def test_nquote_semicolon_literal
    execute("echo \"$(echo $';foo')\" > #{outf}")
    assert_equal ";foo\n", File.read(outf)
  end

  # $'...' inside double quotes is NOT expanded (treated as literal text)
  # echo "$'a\tb\tc'"  ->  $'a\tb\tc'
  def test_nquote_no_expand_in_dquotes
    omit '$\'...\' inside double quotes is incorrectly expanded'
    execute("echo \"$'a\\tb\\tc'\" > #{outf}")
    assert_equal "$'a\\tb\\tc'\n", File.read(outf)
  end

  # $'...' in command substitution expands normally
  # echo $(set -- $'a b'; echo $#)  ->  1
  def test_nquote_in_command_substitution
    execute("echo $(set -- $'a b'; echo $#) > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # $'...' with \t as argument keeps word intact (no word-splitting on tab)
  # args $'A\tB'  ->  'A\tB' as single argument
  def test_nquote_tab_no_word_split
    omit '$\'...\' result is incorrectly word-split on tab'
    execute("args() { for a in \"$@\"; do echo \"'$a'\"; done; }; args $'A\\tB' > #{outf}")
    assert_equal "'A\tB'\n", File.read(outf)
  end

  # $'...' as default value in parameter expansion
  # unset mytab; echo "${mytab:-$'\t'}"  ->  tab
  def test_nquote_in_default_value
    execute("unset mytab; echo \"${mytab:-$'\\t'}\" > #{outf}")
    assert_equal "\t\n", File.read(outf)
  end
end
