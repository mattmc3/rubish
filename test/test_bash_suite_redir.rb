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
    omit 'noclobber does not return non-zero exit status on failure'
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

  # noclobber: > on a new file succeeds
  def test_redir_noclobber_new_file_ok
    f2 = "#{@tempdir}/new"
    execute('set -o noclobber')
    execute("echo hello > #{f2}")
    execute('set +o noclobber')
    assert_equal "hello\n", File.read(f2)
  end

  # >| on a new file (no pre-existing file)
  def test_redir_clobber_override_new_file
    execute("echo newfile >| #{outf}")
    assert_equal "newfile\n", File.read(outf)
  end

  # null redirect: > file creates empty file
  def test_redir_null_creates_empty_file
    omit 'bare null redirect does not create file'
    execute("> #{outf}")
    assert File.exist?(outf)
    assert_equal '', File.read(outf)
  end

  # block redirect: { cmds } > file captures output
  def test_redir_block_to_file
    omit 'block redirect { } > file not supported'
    f2 = "#{@tempdir}/blk"
    execute("{ echo before; echo after; } > #{f2}")
    assert_equal "before\nafter\n", File.read(f2)
  end

  # exec N>file opens fd for writing
  def test_redir_exec_fd_write
    omit 'exec FD-only redirect not supported'
    fa = "#{@tempdir}/a"
    execute("exec 4>#{fa}")
    execute('echo to4 1>&4')
    execute('exec 4>&-')
    assert_equal "to4\n", File.read(fa)
  end

  # exec N>file and exec M>file open two fds simultaneously
  def test_redir_exec_two_fds
    omit 'exec FD-only redirect not supported'
    fa = "#{@tempdir}/a"
    fb = "#{@tempdir}/b"
    execute("exec 4>#{fa}; exec 5>#{fb}")
    execute('echo toa 1>&4; echo tob 1>&5')
    execute('exec 4>&- 5>&-')
    assert_equal "toa\n", File.read(fa)
    assert_equal "tob\n", File.read(fb)
  end

  # exec N<>file opens fd for read/write
  def test_redir_exec_fd_readwrite
    omit 'exec FD-only redirect not supported'
    f2 = "#{@tempdir}/rw"
    execute("exec 6<>#{f2}")
    execute('echo torw 1>&6')
    execute('exec 6<&-')
    assert_equal "torw\n", File.read(f2)
  end

  # exec N<file opens fd for reading
  def test_redir_exec_fd_read
    omit 'exec FD-only redirect not supported'
    src = "#{@tempdir}/src"
    File.write(src, "srcline\n")
    execute("exec 3<#{src}")
    execute("read line <&3; echo $line > #{outf}")
    execute('exec 3<&-')
    assert_equal "srcline\n", File.read(outf)
  end

  # while read line; done << EOF passes lines from heredoc
  def test_redir_while_read_heredoc
    omit 'while read loop with heredoc input not supported'
    execute("while read line; do echo $line >> #{outf}; done <<EOF\nab\ncd\nEOF")
    assert_equal "ab\ncd\n", File.read(outf)
  end

  # while read loop: variable set inside loop persists after loop ends
  def test_redir_while_read_heredoc_var_persists
    omit 'while read loop variable does not persist after loop'
    execute("while read line; do l2=$line; done <<EOF\nab\ncd\nEOF\necho $l2 > #{outf}")
    assert_equal "cd\n", File.read(outf)
  end
end
