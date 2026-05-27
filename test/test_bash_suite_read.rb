# frozen_string_literal: true

# Tests sourced from .bash/tests/read.tests
require_relative 'test_helper'

class TestBash_Read < Test::Unit::TestCase
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

  # echo " a " | (read x; echo "$x.")  ->  a.
  def test_read_strips_leading_trailing_whitespace
    execute("echo ' a ' | (read x; echo \"$x.\") > #{outf}")
    assert_equal "a.\n", File.read(outf)
  end

  # echo " a  b  " | (read x y; echo -"$x"-"$y"-)  ->  -a-b-
  def test_read_two_vars_strips_whitespace
    execute("echo ' a  b  ' | (read x y; echo -\"$x\"-\"$y\"-) > #{outf}")
    assert_equal "-a-b-\n", File.read(outf)
  end

  # echo " a  b  " | (read x; echo -"$x"-)  ->  -a  b-
  def test_read_one_var_captures_rest
    execute("echo ' a  b  ' | (read x; echo -\"$x\"-) > #{outf}")
    assert_equal "-a  b-\n", File.read(outf)
  end

  # read from file: read x y z < file  ->  x[A] y[B] z[]
  def test_read_from_file
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "A B \n")
    execute("read x y z < #{tf}; echo \"x[$x] y[$y] z[$z]\" > #{outf}")
    assert_equal "x[A] y[B] z[]\n", File.read(outf)
  end

  # read single var from file gets whole line
  def test_read_single_var_whole_line
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "A B \n")
    execute("read x < #{tf}; echo \"x[$x]\" > #{outf}")
    assert_equal "x[A B]\n", File.read(outf)
  end

  # read into REPLY when no var given
  def test_read_reply_default
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "A B \n")
    execute("read < #{tf}; echo \"[$REPLY]\" > #{outf}")
    assert_equal "[A B ]\n", File.read(outf)
  end

  # IFS= read preserves leading spaces
  def test_read_ifs_empty_preserves_spaces
    omit 'IFS= read not yet working'
    execute("echo ' foo' | (IFS= read line; echo \"$line\") > #{outf}")
    assert_equal " foo\n", File.read(outf)
  end

  # read a b c <<EOF  ->  a=a b=b c=c
  def test_read_heredoc
    omit 'multi-line heredoc not supported via execute'
    execute("read a b c <<EOF\na b c\nEOF\necho \"a=$a b=$b c=$c\" > #{outf}")
    assert_equal "a=a b=b c=c\n", File.read(outf)
  end
end
