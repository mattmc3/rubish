# frozen_string_literal: true

# Tests sourced from .bash/tests/heredoc.tests and herestr.tests
require_relative 'test_helper'

class TestBash_Heredoc < Test::Unit::TestCase
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

  # cat <<EOF\na\nb\nc\nEOF  ->  a\nb\nc
  def test_heredoc_basic
    omit 'multi-line heredoc not supported via execute'
    execute("cat <<EOF > #{outf}\na\nb\nc\nEOF")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # quoted heredoc: no variable expansion
  def test_heredoc_quoted_no_expansion
    omit 'multi-line heredoc not supported via execute'
    execute("a=foo; cat <<'EOF' > #{outf}\nthere$a\nstuff\nEOF")
    assert_equal "there$a\nstuff\n", File.read(outf)
  end

  # unquoted heredoc: variable expansion
  def test_heredoc_unquoted_expansion
    omit 'multi-line heredoc not supported via execute'
    execute("a=foo; cat <<EOF > #{outf}\nthere$a\nEOF")
    assert_equal "therefoo\n", File.read(outf)
  end

  # tab-stripped heredoc with <<-
  def test_heredoc_tab_strip
    omit 'heredoc tab-strip (<<-) not tested via execute'
    execute("cat <<- EOF > #{outf}\n\ttab1\n\ttab2\n\tEOF")
    assert_equal "tab1\ntab2\n", File.read(outf)
  end

  # empty heredoc
  def test_heredoc_empty
    execute("cat <<EOF > #{outf}\nEOF")
    assert_equal "", File.read(outf)
  end

  # heredoc with variable in body
  def test_heredoc_var_in_body
    omit 'multi-line heredoc not supported via execute'
    execute("x=hello; cat <<EOF > #{outf}\n$x world\nEOF")
    assert_equal "hello world\n", File.read(outf)
  end

  # here-string: read x <<< "alpha"; echo $x  ->  alpha
  def test_herestr_basic_read
    omit 'here-string with read not yet working'
    execute("read x <<<alpha; echo $x > #{outf}")
    assert_equal "alpha\n", File.read(outf)
  end

  # here-string: cat <<< "hello"  ->  hello
  def test_herestr_cat
    execute("cat <<<hello > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # here-string with variable
  def test_herestr_var
    execute("X=world; cat <<<\"hello $X\" > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # here-string: read x <<< "alpha beta"; echo $x  ->  alpha beta
  def test_herestr_read_spaces
    omit 'here-string with read not yet working'
    execute("read x <<<'alpha beta'; echo $x > #{outf}")
    assert_equal "alpha beta\n", File.read(outf)
  end
end
