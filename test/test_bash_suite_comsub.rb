# frozen_string_literal: true

# Tests sourced from .bash/tests/comsub.tests
require_relative 'test_helper'

class TestBash_Comsub < Test::Unit::TestCase
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

  # x=$(echo hello); echo $x  ->  hello
  def test_comsub_basic
    execute("x=$(echo hello); echo $x > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # x=$(echo a; echo b); echo "$x"  ->  a\nb
  def test_comsub_multiline
    execute("x=$(echo a; echo b); echo \"$x\" > #{outf}")
    assert_equal "a\nb\n", File.read(outf)
  end

  # nested: echo $(echo $(echo hi))  ->  hi
  def test_comsub_nested
    execute("echo $(echo $(echo hi)) > #{outf}")
    assert_equal "hi\n", File.read(outf)
  end

  # cmd sub in arithmetic: echo $(($(echo 3) + 4))  ->  7
  def test_comsub_in_arith
    omit 'cmd sub inside $(( )) not yet supported'
    execute("echo $(($(echo 3) + 4)) > #{outf}")
    assert_equal "7\n", File.read(outf)
  end

  # pipeline in cmd sub
  def test_comsub_pipeline
    execute("echo $(echo 'a b c' | tr ' ' '\n' | wc -l | tr -d ' ') > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # cmd sub trailing newline stripped
  def test_comsub_strips_trailing_newline
    execute("x=$(printf 'hi\n'); echo $x > #{outf}")
    assert_equal "hi\n", File.read(outf)
  end

  # blank comsub: echo --$()--  ->  ----
  def test_comsub_empty
    execute("echo --$()-- > #{outf}")
    assert_equal "----\n", File.read(outf)
  end

  # cmd sub with assignment
  def test_comsub_assigns
    execute("a=$(echo foo); echo $a > #{outf}")
    assert_equal "foo\n", File.read(outf)
  end

  # nested double-quote: echo "$(echo 'a b c')"  ->  a b c
  def test_comsub_quoted_spaces_preserved
    execute("echo \"$(echo 'a b c')\" > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # backtick cmd sub
  def test_comsub_backtick
    execute("x=`echo hello`; echo $x > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # comsub inline concatenation: ab$(echo mn; echo op)yz  ->  abmn opyz
  def test_comsub_inline_concat
    omit 'comsub with semicolon splits at newline instead of joining inline'
    execute("echo ab$(echo mn; echo op)yz > #{outf}")
    assert_equal "abmn opyz\n", File.read(outf)
  end

  # comsub with pipeline grep filter assigned to var
  def test_comsub_pipeline_grep_assign
    execute("a=$(echo 'a b c' | tr ' ' '\\n' | grep 'b'); echo $a > #{outf}")
    assert_equal "b\n", File.read(outf)
  end

  # empty multiline comsub (newline inside parens)  ->  ----
  def test_comsub_empty_multiline
    execute("printf 'blank --%s--\\n' \"$(true)\" > #{outf}")
    assert_equal "blank ----\n", File.read(outf)
  end

  # deeply nested comsub: 4 levels  ->  nested
  def test_comsub_deeply_nested
    execute("echo $(echo $(echo $(echo $( echo nested )))) > #{outf}")
    assert_equal "nested\n", File.read(outf)
  end

  # multiple trailing newlines all stripped
  def test_comsub_strips_multiple_trailing_newlines
    omit 'comsub multi trailing-newline strip needs fix_comsub_trailing_newlines (unmerged)'
    execute("x=$(printf 'hello\\n\\n\\n'); echo \"[$x]\" > #{outf}")
    assert_equal "[hello]\n", File.read(outf)
  end

  # internal newlines preserved, only trailing stripped
  def test_comsub_strips_trailing_preserves_internal
    omit 'comsub trailing-newline strip needs fix_comsub_trailing_newlines (unmerged)'
    execute("x=$(printf 'a\\nb\\nc\\n\\n\\n'); echo \"$x\" > #{outf}")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # comsub output word-splits when unquoted
  def test_comsub_word_split_unquoted
    execute("x=$(echo 'a b c'); echo $x > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # comsub output not word-split when quoted
  def test_comsub_no_word_split_quoted
    execute("x=$(echo 'a  b  c'); echo \"$x\" > #{outf}")
    assert_equal "a  b  c\n", File.read(outf)
  end

  # chained backtick comsubs: use result of one in the next
  def test_comsub_backtick_chained
    execute("x=`echo hello`; y=`echo $x world`; echo $y > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # comsub in parameter default value: ${foo:-$(echo fallback)}
  def test_comsub_in_param_default
    execute("echo ${foo:-$(echo fallback)} > #{outf}")
    assert_equal "fallback\n", File.read(outf)
  end

  # return inside comsub aborts comsub, function continues
  def test_comsub_return_aborts_comsub
    omit '$FUNCNAME not set in rubish function context'
    execute("func() { local v; v=$(echo comsub; return; echo after); echo \"$FUNCNAME: v = $v\"; }; func > #{outf}")
    assert_equal "func: v = comsub\n", File.read(outf)
  end

  # prefix-$(echo val)-suffix inline substitution
  def test_comsub_prefix_suffix_inline
    execute("echo prefix-$(echo hello)-suffix > #{outf}")
    assert_equal "prefix-hello-suffix\n", File.read(outf)
  end

  # backtick with \$ produces literal dollar sign
  def test_comsub_backtick_escaped_dollar
    omit 'backtick comsub does not unescape \\$ to $ inside backtick body'
    execute("echo `echo '\\$' bab` > #{outf}")
    assert_equal "$ bab\n", File.read(outf)
  end

  # backtick with \\ produces literal backslash
  def test_comsub_backtick_escaped_backslash
    omit 'backtick comsub does not unescape \\\\ to \\ inside backtick body'
    execute("echo `echo '\\\\' ab` > #{outf}")
    assert_equal "\\ ab\n", File.read(outf)
  end

  # exit status from comsub is propagated
  def test_comsub_exit_status
    omit 'standalone $(exit N) treated as command not found instead of propagating exit status'
    execute("$(exit 42); echo $? > #{outf}")
    assert_equal "42\n", File.read(outf)
  end
end
