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
end
