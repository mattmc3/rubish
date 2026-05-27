# frozen_string_literal: true

# Tests sourced from .bash/tests/tilde.tests
require_relative 'test_helper'

class TestBash_Tilde < Test::Unit::TestCase
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

  # HOME=/usr/xyz; echo ~/foo  ->  /usr/xyz/foo
  def test_tilde_expands_to_home
    omit 'tilde expansion not yet supported'
    execute("HOME=/usr/xyz; echo ~/foo > #{outf}")
    assert_equal "/usr/xyz/foo\n", File.read(outf)
  end

  # echo "~chet"/"foo"  ->  ~chet/foo  (quoted tilde not expanded)
  def test_tilde_quoted_no_expand
    execute("echo \"~chet\"/\"foo\" > #{outf}")
    assert_equal "~chet/foo\n", File.read(outf)
  end

  # echo abcd~chet  ->  abcd~chet  (tilde not at start of word)
  def test_tilde_not_at_start_no_expand
    execute("echo abcd~chet > #{outf}")
    assert_equal "abcd~chet\n", File.read(outf)
  end

  # HOME=/usr/xyz; SHELL=~/bash; echo $SHELL  ->  /usr/xyz/bash
  def test_tilde_in_assignment
    omit 'tilde expansion in assignment not yet supported'
    execute("HOME=/usr/xyz; SHELL=~/bash; echo $SHELL > #{outf}")
    assert_equal "/usr/xyz/bash\n", File.read(outf)
  end

  # HOME=/usr/xyz; path=...:~/bin:...; echo $path  ->  ...expanded...
  def test_tilde_in_colon_path
    omit 'tilde expansion in assignment not yet supported'
    execute("HOME=/usr/xyz; path=/usr/ucb:/bin:~/bin:~/tmp/bin:/usr/bin; echo $path > #{outf}")
    assert_equal "/usr/ucb:/bin:/usr/xyz/bin:/usr/xyz/tmp/bin:/usr/bin\n", File.read(outf)
  end

  # echo ":~chet/"  ->  :~chet/  (tilde not at start of word)
  def test_tilde_mid_word_no_expand
    execute("echo ':~chet/' > #{outf}")
    assert_equal ":~chet/\n", File.read(outf)
  end

  # case ~ in $HOME) echo ok;; esac  ->  ok
  def test_tilde_in_case
    omit 'tilde expansion not yet supported'
    execute("HOME=/usr/xyz; case ~ in \$HOME) echo ok > #{outf};; *) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # export PPATH=$XPATH:~/bin; echo $PPATH  ->  .../expanded/...
  def test_tilde_in_export
    omit 'tilde expansion in export not yet supported'
    execute("HOME=/usr/xyz; XPATH=/bin:/usr/bin:.; export PPATH=$XPATH:~/bin; echo $PPATH > #{outf}")
    assert_equal "/bin:/usr/bin:.:/usr/xyz/bin\n", File.read(outf)
  end
end
