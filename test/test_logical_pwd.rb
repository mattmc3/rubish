# frozen_string_literal: true

require_relative 'test_helper'

# cd should keep the *logical* path (symlinks preserved), like bash:
# $PWD and `pwd` report the path you cd'd through, while `pwd -P` resolves
# symlinks. rubish currently resolves symlinks for the default case too.
class TestLogicalPwd < Test::Unit::TestCase
  def setup
    @repl = Rubish::REPL.new
    @orig_cwd = Dir.pwd
  end

  def teardown
    Dir.chdir(@orig_cwd) if @orig_cwd && File.directory?(@orig_cwd)
  end

  # Yields (real, link, out): a real dir, a symlink to it, and a scratch file.
  def with_symlink
    Dir.mktmpdir do |d|
      d = File.realpath(d)
      real = File.join(d, 'real')
      link = File.join(d, 'link')
      Dir.mkdir(real)
      File.symlink(real, link)
      yield real, link, File.join(d, 'out')
    end
  end

  def test_pwd_var_is_logical_after_cd_symlink
    with_symlink do |_real, link, out|
      execute("cd #{link}; echo $PWD > #{out}")
      assert_equal "#{link}\n", File.read(out)
    end
  end

  # Capture stdout (not a redirect): a redirected builtin is dispatched as the
  # external /bin/pwd, which is logical on BSD but physical on GNU/Linux.
  def test_pwd_builtin_is_logical_after_cd_symlink
    with_symlink do |_real, link, _out|
      out = capture_output { execute("cd #{link}; pwd") }
      assert_equal "#{link}\n", out
    end
  end

  # pwd -P must still resolve symlinks (physical path), matching bash.
  def test_pwd_dash_p_is_physical_after_cd_symlink
    with_symlink do |real, link, _out|
      out = capture_output { execute("cd #{link}; pwd -P") }
      assert_equal "#{real}\n", out
    end
  end

  # `cd ..` from a symlinked directory should go to the logical parent
  # (the parent of the symlink, not the parent of its target). This
  # exercises the File.expand_path('..', logical_base) path.
  def test_cd_dotdot_from_symlink_is_logical_parent
    with_symlink do |_real, link, _out|
      parent = File.dirname(link)
      out = capture_output { execute("cd #{link}; cd ..; pwd") }
      assert_equal "#{parent}\n", out
    end
  end

  # `~+` resolves to $PWD at command-execution time (PR #38) and $PWD
  # is now logical (PR #39) — together that should make `echo ~+`
  # from a symlinked directory report the symlink, not the target.
  # Lock the cross-PR interaction in with a regression test.
  def test_tilde_plus_is_logical_after_cd_symlink
    with_symlink do |_real, link, out|
      execute("cd #{link}; echo ~+ > #{out}")
      assert_equal "#{link}\n", File.read(out)
    end
  end
end
