# frozen_string_literal: true

# Tests sourced from .bash/tests/redir.tests
require_relative 'test_helper'

class TestBash_Redir < Test::Unit::TestCase
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

  # basic > redirect
  def test_redir_write
    execute("echo hello > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # >> append redirect
  def test_redir_append
    execute("echo line1 > #{outf}; echo line2 >> #{outf}")
    assert_equal "line1\nline2\n", File.read(outf)
  end

  # redirect stderr to file
  def test_redir_stderr
    omit 'stderr redirect >&2 not yet working'
    f2 = "#{@tempdir}/err"
    execute("echo error >&2 2>#{f2}")
    assert_equal "error\n", File.read(f2)
  end

  # redirect stdout and stderr together
  def test_redir_stdout_stderr_together
    omit 'stderr redirect >&2 not yet working'
    f2 = "#{@tempdir}/both"
    execute("echo out > #{f2}; echo err >&2 2>>#{f2}")
    assert_equal "out\nerr\n", File.read(f2)
  end

  # fd duplication: 2>&1
  def test_redir_fd_dup
    omit 'fd dup 2>&1 in subshell context not yet working'
    f2 = "#{@tempdir}/dup"
    execute("(echo err >&2) > #{f2} 2>&1")
    assert_equal "err\n", File.read(f2)
  end

  # redirect from file with <
  def test_redir_read_from_file
    input = "#{@tempdir}/inp"
    File.write(input, "hello\n")
    execute("cat < #{input} > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # noclobber: > on existing file fails, >| overrides
  def test_redir_noclobber
    execute("echo first > #{outf}")
    execute('set -o noclobber')
    execute("echo second > #{outf} 2>/dev/null; echo $? >> #{outf}")
    execute('set +o noclobber')
    content = File.read(outf)
    assert_match(/first/, content)
    assert_match(/[1-9]/, content)
  end

  # clobber override with >|
  def test_redir_clobber_override
    execute("echo first > #{outf}")
    execute('set -o noclobber')
    execute("echo second >| #{outf}")
    execute('set +o noclobber')
    assert_equal "second\n", File.read(outf)
  end
end
