# frozen_string_literal: true

# Tests sourced from .bash/tests/func.tests
require_relative 'test_helper'

class TestBash_Func < Test::Unit::TestCase
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

  # basic function define and call
  def test_func_define_and_call
    execute("f() { echo hello; }; f > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # function return value
  def test_func_return_value
    execute("f() { return 5; }; f; echo $? > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # function with local variable
  def test_func_local_var
    execute("zz=outer; f() { local zz=inner; echo $zz; }; f > #{outf}; echo $zz >> #{outf}")
    assert_equal "inner\nouter\n", File.read(outf)
  end

  # function local var unset after return
  def test_func_local_var_unset_after_return
    execute("zz=ZZ; f1() { local zz=abcde; echo $zz; unset zz; zz=defghi; echo $zz; }; zz=ZZ; echo $zz > #{outf}; f1 >> #{outf}; echo $zz >> #{outf}")
    assert_equal "ZZ\nabcde\ndefghi\nZZ\n", File.read(outf)
  end

  # chained function return codes
  def test_func_chained_return_codes
    execute("a() { return 5; }; b() { a; echo $?; }; b > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # function with args
  def test_func_with_args
    execute("greet() { echo hello $1; }; greet world > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # function sees global var
  def test_func_sees_global_var
    execute("X=global; f() { echo $X; }; f > #{outf}")
    assert_equal "global\n", File.read(outf)
  end

  # function can modify global var
  def test_func_modifies_global_var
    execute("X=1; f() { X=2; }; f; echo $X > #{outf}")
    assert_equal "2\n", File.read(outf)
  end

  # nested function calls
  def test_func_nested_calls
    execute("inner() { echo inner; }; outer() { echo outer; inner; }; outer > #{outf}")
    assert_equal "outer\ninner\n", File.read(outf)
  end

  # function called in subshell doesn't affect parent
  def test_func_subshell_isolation
    execute("X=orig; f() { X=changed; }; (f); echo $X > #{outf}")
    assert_equal "orig\n", File.read(outf)
  end

  # recursive function
  def test_func_recursive
    execute("count() { if [ $1 -gt 0 ]; then echo $1; count $(($1-1)); fi; }; count 3 > #{outf}")
    assert_equal "3\n2\n1\n", File.read(outf)
  end

  # unset -f removes function
  def test_func_unset
    execute("f() { echo exists; }; unset -f f; f > #{outf} 2>&1; echo $? >> #{outf}")
    refute_equal "0\n", File.read(outf).lines.last
  end
end
