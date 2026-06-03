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

  # deep call chain with return codes and arithmetic (func.tests lines 20-68)
  def test_func_deep_call_chain
    cmd = [
      "a() { x=$((x - 1)); return 5; }",
      "b() { x=$((x - 1)); a; echo \"a returns $?\"; return 4; }",
      "c() { x=$((x - 1)); b; echo \"b returns $?\"; return 3; }",
      "d() { x=$((x - 1)); c; echo \"c returns $?\"; return 2; }",
      "e() { d; echo \"d returns $?\"; echo \"in e\"; x=$((x - 1)); return $x; }",
      "f() { e; echo \"e returned $?\"; echo \"x is $x\"; return 0; }",
      "x=30; f > #{outf}"
    ].join("; ")
    execute(cmd)
    assert_equal "a returns 5\nb returns 4\nc returns 3\nd returns 2\nin e\ne returned 25\nx is 25\n", File.read(outf)
  end

  # function called in subshell returns its exit status to parent
  def test_func_subshell_return_code
    omit 'subshell exit code not propagated to $?'
    execute("f1() { return 5; }; (f1); echo $? > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # temp env var visible inside function when passed as prefix
  def test_func_temp_env_prefix
    omit 'prefix env not applied to direct function calls in rubish'
    execute("f1() { echo $AVAR; }; AVAR=AVAR; AVAR=foo f1 > #{outf}; echo $AVAR >> #{outf}")
    assert_equal "foo\nAVAR\n", File.read(outf)
  end

  # ( return N ) inside function body exits subshell with status N
  def test_func_subshell_return_inside_body
    omit 'subshell exit code not propagated to $?'
    execute("f1() { (return 5); status=$?; echo $status; return $status; }; f1 > #{outf}; echo $? >> #{outf}")
    assert_equal "5\n5\n", File.read(outf)
  end

  # declare -F prints just the function name
  def test_func_declare_capital_f
    omit 'declare -F format differs from bash (rubish prints "declare -f name")'
    execute("f1() { return 5; }; declare -F f1 > #{outf}")
    assert_equal "f1\n", File.read(outf)
  end

  # declare -f prints the function definition
  def test_func_declare_lowercase_f
    omit 'declare -f definition format differs from bash'
    execute("f1() { return 5; }; declare -f f1 > #{outf}")
    expected = "f1 () \n{ \n    return 5\n}\n"
    assert_equal expected, File.read(outf)
  end

  # ${FUNCNAME[0]} holds current function name inside a function
  def test_funcname_array_tracks_current_function
    execute("func2() { echo \"FUNCNAME = ${FUNCNAME[0]}\"; }; func() { echo \"before: FUNCNAME = ${FUNCNAME[0]}\"; func2; echo \"after: FUNCNAME = ${FUNCNAME[0]}\"; }; func > #{outf}")
    assert_equal "before: FUNCNAME = func\nFUNCNAME = func2\nafter: FUNCNAME = func\n", File.read(outf)
  end

  # ${FUNCNAME[0]} is empty outside any function
  def test_funcname_empty_outside_function
    execute("echo \"outside: FUNCNAME = ${FUNCNAME[0]}\" > #{outf}")
    assert_equal "outside: FUNCNAME = \n", File.read(outf)
  end

  # function defined with body-level redirect discards output
  def test_func_body_redirect
    omit 'function body-level redirect not yet working'
    execute("myfunction() { echo \"bad shell function redirection\"; } >> /dev/null; myfunction > #{outf}")
    assert_equal "", File.read(outf)
  end

  # return in a pipeline inside a function sets function exit status
  def test_func_return_in_pipeline
    omit 'return in pipeline inside function not yet working'
    execute("segv() { echo foo | return 5; }; segv > #{outf}; echo $? >> #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # readonly -f marks a function as readonly
  def test_func_readonly_f
    omit 'readonly -f not implemented in rubish'
    execute("rfunc() { echo hi; }; readonly -f rfunc; readonly -f > #{outf}")
    assert_match(/rfunc/, File.read(outf))
  end
end
