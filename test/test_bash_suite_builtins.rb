# frozen_string_literal: true

# Tests sourced from .bash/tests/builtins.tests
require_relative 'test_helper'

class TestBash_Builtins < Test::Unit::TestCase
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

  # echo -n foo  ->  foo (no newline)
  def test_echo_n
    execute("echo -n foo > #{outf}")
    assert_equal "foo", File.read(outf)
  end

  # read from here-string
  def test_read_basic_herestr
    execute("read x <<<hello; echo $x > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # read two vars
  def test_read_two_vars
    execute("read x y <<<'hello world'; echo $x $y > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # read -r preserves backslash
  def test_read_r_backslash
    execute("read -r x <<<'a\\\\b'; echo $x > #{outf}")
    assert_equal "a\\\\b\n", File.read(outf)
  end

  # true; echo $?  ->  0
  def test_true_exit_code
    execute("true; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # false; echo $?  ->  1
  def test_false_exit_code
    execute("false; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # : (colon) is no-op, exits 0
  def test_colon_noop
    execute(": ; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # (exit 42); echo $?  ->  42
  def test_exit_code_in_subshell
    omit 'subshell exit code not propagated to $?'
    execute("(exit 42); echo $? > #{outf}")
    assert_equal "42\n", File.read(outf)
  end

  # if true; then echo yes; else echo no; fi  ->  yes
  def test_if_true
    execute("if true; then echo yes; else echo no; fi > #{outf}")
    assert_equal "yes\n", File.read(outf)
  end

  # if false; then echo yes; else echo no; fi  ->  no
  def test_if_false
    execute("if false; then echo yes; else echo no; fi > #{outf}")
    assert_equal "no\n", File.read(outf)
  end

  # elif: if false; elif true; then echo yes; fi  ->  yes
  def test_if_elif
    execute("if false; then echo no; elif true; then echo yes; fi > #{outf}")
    assert_equal "yes\n", File.read(outf)
  end

  # nested if
  def test_if_nested
    execute("if true; then if false; then echo inner; else echo outer; fi; fi > #{outf}")
    assert_equal "outer\n", File.read(outf)
  end

  # if with [ ] test
  def test_if_bracket_test
    execute("x=5; if [ $x -gt 3 ]; then echo big; else echo small; fi > #{outf}")
    assert_equal "big\n", File.read(outf)
  end

  # break stops loop at first iteration
  def test_break_stops_loop
    execute("for i in a b c; do echo $i; break; echo bad-$i; done > #{outf}")
    assert_equal "a\n", File.read(outf)
  end

  # break 1 is the same as plain break
  def test_break_1_stops_loop
    execute("for i in a b c; do echo $i; break 1; echo bad-$i; done > #{outf}")
    assert_equal "a\n", File.read(outf)
  end

  # break in inner loop only exits inner; outer continues
  def test_break_inner_loop_only
    script = "for i in a b c; do for j in x y z; do echo $i:$j; break; echo bad-$i; done; echo end-$i; done"
    execute("#{script} > #{outf}")
    expected = "a:x\nend-a\nb:x\nend-b\nc:x\nend-c\n"
    assert_equal expected, File.read(outf)
  end

  # break 2 exits both inner and outer loop
  def test_break_2_nested_loops
    script = "for i in a b c; do for j in x y z; do echo $i:$j; break 2; echo bad-$i; done; echo end-$i; done"
    execute("#{script} > #{outf}")
    assert_equal "a:x\n", File.read(outf)
  end

  # continue skips rest of iteration
  def test_continue_skips_rest
    execute("for i in a b c; do echo $i; continue; echo bad-$i; done > #{outf}")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # continue 1 is the same as plain continue
  def test_continue_1_skips_rest
    execute("for i in a b c; do echo $i; continue 1; echo bad-$i; done > #{outf}")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # continue in inner loop runs all inner iterations then outer continues
  def test_continue_inner_loop
    script = "for i in a b c; do for j in x y z; do echo $i:$j; continue; echo bad-$i-$j; done; echo end-$i; done"
    execute("#{script} > #{outf}")
    expected = "a:x\na:y\na:z\nend-a\nb:x\nb:y\nb:z\nend-b\nc:x\nc:y\nc:z\nend-c\n"
    assert_equal expected, File.read(outf)
  end

  # continue 2 skips rest of inner loop AND rest of current outer iteration
  def test_continue_2_nested_loops
    script = "for i in a b c; do for j in x y z; do echo $i:$j; continue 2; echo bad-$i-$j; done; echo end-$i; done"
    execute("#{script} > #{outf}")
    assert_equal "a:x\nb:x\nc:x\n", File.read(outf)
  end

  # eval re-evaluates its argument (double-expanding variables)
  def test_eval_double_expands
    omit 'eval double-expansion not yet working'
    execute("AVAR='$BVAR'; BVAR=foo; eval echo $AVAR > #{outf}")
    assert_equal "foo\n", File.read(outf)
  end

  # builtin does NOT double-expand variables
  def test_builtin_no_double_expand
    omit 'builtin keyword not yet implemented'
    execute("AVAR='$BVAR'; BVAR=foo; builtin echo $AVAR > #{outf}")
    assert_equal "$BVAR\n", File.read(outf)
  end

  # command does NOT double-expand variables
  def test_command_no_double_expand
    omit 'command builtin not yet implemented'
    execute("AVAR='$BVAR'; BVAR=foo; command echo $BVAR > #{outf}")
    assert_equal "foo\n", File.read(outf)
  end

  # eval with escaped $: eval echo \$AVAR prints literal AVAR value, not double-expanded
  def test_eval_escaped_var
    omit 'eval with escaped vars not yet working'
    execute("AVAR='$BVAR'; BVAR=foo; eval echo \\$AVAR > #{outf}")
    assert_equal "$BVAR\n", File.read(outf)
  end

  # temporary env for eval: AVAR=bar eval echo \$AVAR prints bar
  def test_eval_temp_env
    omit 'temp env prefix for eval not yet working'
    execute("AVAR=bar eval echo \\$AVAR > #{outf}")
    assert_equal "bar\n", File.read(outf)
  end

  # umask with no args prints current mask in octal
  def test_umask_print_octal
    execute("umask 022; umask > #{outf}")
    assert_equal "0022\n", File.read(outf)
  end

  # umask -S prints symbolic form
  def test_umask_symbolic
    execute("umask 022; umask -S > #{outf}")
    assert_equal "u=rwx,g=rx,o=rx\n", File.read(outf)
  end

  # umask -p prints reusable octal form
  def test_umask_p_reusable
    execute("umask 002; umask -p > #{outf}")
    assert_equal "umask 0002\n", File.read(outf)
  end

  # umask -p -S prints reusable symbolic form
  def test_umask_p_symbolic
    execute("umask 002; umask -p -S > #{outf}")
    assert_equal "umask -S u=rwx,g=rwx,o=rx\n", File.read(outf)
  end

  # umask 0 sets all bits to 0
  def test_umask_zero
    execute("umask 0; umask -S > #{outf}")
    assert_equal "u=rwx,g=rwx,o=rwx\n", File.read(outf)
  end

  # unset -v removes a variable
  def test_unset_v_removes_var
    execute("MYVAR=hello; unset -v MYVAR; echo ${MYVAR:-unset} > #{outf}")
    assert_equal "unset\n", File.read(outf)
  end

  # unset removes a variable (no flag)
  def test_unset_removes_var
    execute("MYVAR=hello; unset MYVAR; echo ${MYVAR:-gone} > #{outf}")
    assert_equal "gone\n", File.read(outf)
  end

  # shift 0 succeeds without changing positional params
  def test_shift_zero
    execute("set -- a b c; shift 0; echo $# > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # shift 1 removes first positional param
  def test_shift_one
    execute("set -- a b c; shift; echo $@ > #{outf}")
    assert_equal "b c\n", File.read(outf)
  end

  # shift N removes first N positional params
  def test_shift_n
    execute("set -- a b c d; shift 2; echo $@ > #{outf}")
    assert_equal "c d\n", File.read(outf)
  end

  # export sets variable in environment
  def test_export_sets_env
    execute("export TESTVAR=hello; echo $TESTVAR > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # readonly marks variable as readonly
  def test_readonly_marks_var
    omit 'readonly error output goes to stderr and stdout capture needs work'
    execute("readonly RO=42; RO=99; echo $RO > #{outf}")
    assert_equal "42\n", File.read(outf)
  end

  # source a zero-length file succeeds with exit code 0
  def test_source_zero_length_file
    zf = File.join(@tempdir, 'zero')
    File.write(zf, '')
    execute(". #{zf}; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # source a file without trailing newline works
  def test_source_no_trailing_newline
    omit 'sourcing file without trailing newline not yet working'
    sf = File.join(@tempdir, 'nonewline.sh')
    File.write(sf, 'echo no-newline')
    execute(". #{sf} > #{outf}")
    assert_equal "no-newline\n", File.read(outf)
  end

  # exit with non-numeric arg: bash treats it as an error (exit status 2)
  def test_exit_non_numeric_arg
    omit 'non-numeric exit arg error handling not yet implemented'
    execute("(exit status); echo $? > #{outf}")
    assert_equal "2\n", File.read(outf)
  end

  # declare -p shows variable declaration
  def test_declare_p_shows_var
    omit 'declare -p output format not matching bash'
    execute("FOO=bar; declare -p FOO > #{outf}")
    assert_equal "declare -- FOO=\"bar\"\n", File.read(outf)
  end

  # declare -x exports a variable
  def test_declare_x_exports_var
    execute("declare -x MYEXPORT=hello; echo $MYEXPORT > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # pwd prints current directory
  def test_pwd_prints_cwd
    execute("pwd > #{outf}")
    assert_equal "#{Dir.pwd}\n", File.read(outf)
  end

  # alias defines a command alias
  def test_alias_define_and_list
    omit 'alias output format not matching bash'
    execute("alias mygreet='echo hi'; alias mygreet > #{outf}")
    assert_equal "alias mygreet='hi'\n", File.read(outf)
  end

  # unalias removes an alias
  def test_unalias_removes_alias
    omit 'unalias error message format not matching bash'
    execute("alias foo='bar'; unalias foo; alias foo > #{outf}")
    assert_equal "alias: foo: not found\n", File.read(outf)
  end
end
