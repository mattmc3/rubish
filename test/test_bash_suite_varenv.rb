# frozen_string_literal: true

# Tests sourced from .bash/tests/varenv.tests
require_relative 'test_helper'

class TestBash_Varenv < Test::Unit::TestCase
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

  # d=$c c=$d with c=1 d=2 -> both become 1
  def test_varenv_swap_not_atomic
    execute("c=1; d=2; d=$c; c=$d; echo $c $d > #{outf}")
    assert_equal "1 1\n", File.read(outf)
  end

  # unset d; echo ${d-unset}  ->  unset
  def test_varenv_unset_default
    execute("unset d; echo ${d-unset} > #{outf}")
    assert_equal "unset\n", File.read(outf)
  end

  # a=bcde; echo ${#a}  ->  4
  def test_varenv_length
    execute("a=bcde; echo ${#a} > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # HOME=/usr/chet; echo $HOME  ->  /usr/chet
  def test_varenv_export_visible
    execute("export HOME=/usr/chet; echo $HOME > #{outf}")
    assert_equal "/usr/chet\n", File.read(outf)
  end

  # local env assignment: HOME=/a/b/c printenv HOME  ->  /a/b/c
  def test_varenv_local_env_assign
    execute("HOME=/a/b/c printenv HOME > #{outf}")
    assert_equal "/a/b/c\n", File.read(outf)
  end

  # c=1; d=2; echo $c $d  ->  1 2
  def test_varenv_basic_assign
    execute("c=1; d=2; echo $c $d > #{outf}")
    assert_equal "1 2\n", File.read(outf)
  end

  # readonly x=5
  def test_varenv_readonly
    execute("readonly RO_VAR=5; echo $RO_VAR > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # export makes var visible to child process
  def test_varenv_export_child
    execute("export MYVAR=hello; echo $(printenv MYVAR) > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # unset removes var
  def test_varenv_unset
    execute("x=foo; unset x; echo ${x:-gone} > #{outf}")
    assert_equal "gone\n", File.read(outf)
  end

  # local var assignment in subshell doesn't affect parent
  def test_varenv_subshell_not_affect_parent
    execute("x=parent; (x=child); echo $x > #{outf}")
    assert_equal "parent\n", File.read(outf)
  end

  # a=5; a+=3; echo $a  ->  53  (string append, not arithmetic)
  def test_varenv_string_append
    execute("a=5; a+=3; echo $a > #{outf}")
    assert_equal "53\n", File.read(outf)
  end

  # a=1; b=2; c=3; echo $a $b $c  ->  1 2 3
  def test_varenv_multiple_assign
    execute("a=1; b=2; c=3; echo $a $b $c > #{outf}")
    assert_equal "1 2 3\n", File.read(outf)
  end

  # command-local env: VAR=val cmd
  def test_varenv_command_local
    execute("X=old; X=new printenv X > #{outf}")
    assert_equal "new\n", File.read(outf)
  end
end
