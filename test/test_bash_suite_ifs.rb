# frozen_string_literal: true

# Tests sourced from .bash/tests/ifs.tests
require_relative 'test_helper'

class TestBash_IFS < Test::Unit::TestCase
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

  # IFS=:; x=a:b:c; for i in $x; do echo $i; done  ->  a\nb\nc
  def test_ifs_colon_split_var_in_for
    execute('IFS=:')
    execute("x=a:b:c; for i in $x; do echo $i >> #{outf}; done")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # IFS=:; for i in $(echo a:b:c); do echo $i; done  ->  a\nb\nc
  def test_ifs_colon_cmd_sub_split_in_for
    execute('IFS=:')
    execute("for i in $(echo a:b:c); do echo $i >> #{outf}; done")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # x='one two three'; for i in $x; do echo $i; done  ->  one\ntwo\nthree
  def test_ifs_default_splits_spaces_in_for
    execute("x='one two three'; for i in $x; do echo $i >> #{outf}; done")
    assert_equal "one\ntwo\nthree\n", File.read(outf)
  end

  # IFS=; x='one two'; for i in $x; do echo $i; done  ->  one two  (no split)
  def test_ifs_empty_suppresses_split
    execute('IFS=')
    execute("x='one two'; for i in $x; do echo $i >> #{outf}; done")
    assert_equal "one two\n", File.read(outf)
  end

  # x='one two three'; echo "$x"  ->  one two three  (quoted no split)
  def test_ifs_quoted_var_no_split
    execute("x='one two three'; echo \"$x\" > #{outf}")
    assert_equal "one two three\n", File.read(outf)
  end

  # IFS=":$IFS"; eval foo="a:b:c"; IFS=$OIFS; echo $foo  ->  a:b:c
  # eval doesn't word-split the assignment target; restored IFS has no colon
  def test_ifs_eval_assign_no_split_after_restore
    execute("OIFS=\"$IFS\"; IFS=\":$IFS\"; eval foo=\"a:b:c\"; IFS=\"$OIFS\"; echo $foo > #{outf}")
    assert_equal "a:b:c\n", File.read(outf)
  end

  # comsub captured with IFS=: but loop runs with default IFS -> one word
  def test_ifs_comsub_captured_with_colon_ifs_then_default_for
    execute("OIFS=$IFS; IFS=\":$IFS\"; foo=$(echo a:b:c); IFS=$OIFS; for i in $foo; do echo $i >> #{outf}; done")
    assert_equal "a:b:c\n", File.read(outf)
  end

  # backtick comsub captured with IFS=: but loop runs with default IFS -> one word
  def test_ifs_backtick_comsub_captured_with_colon_ifs_then_default_for
    execute("OIFS=$IFS; IFS=\":$IFS\"; foo=`echo a:b:c`; IFS=$OIFS; for i in $foo; do echo $i >> #{outf}; done")
    assert_equal "a:b:c\n", File.read(outf)
  end

  # typeset IFS=: inside function shadows global IFS; echo $1 splits on :
  def test_ifs_typeset_local_in_function_splits_echo
    omit 'typeset IFS local to function does not affect word splitting in echo $1'
    execute("function f { typeset IFS=:; echo $1; }; f a:b:c:d:e > #{outf}")
    assert_equal "a b c d e\n", File.read(outf)
  end

  # IFS=: as env prefix for non-special function call; $1 is the whole colon string
  # but echo $1 inside ff uses IFS=: so it splits
  def test_ifs_env_prefix_for_function_splits_inside
    omit 'IFS env prefix for function call does not propagate IFS into function body'
    execute("function ff { echo $1; }; x=a:b:c:d:e; IFS=: ff a:b:c:d:e > #{outf}")
    assert_equal "a b c d e\n", File.read(outf)
  end

  # global $x unchanged after IFS=: env-prefix function call
  def test_ifs_env_prefix_function_does_not_change_global_ifs
    execute("function ff { echo $1; }; x=a:b:c:d:e; IFS=: ff a:b:c:d:e > /dev/null; echo $x > #{outf}")
    assert_equal "a:b:c:d:e\n", File.read(outf)
  end

  # IFS=: as env prefix for simple builtin (echo): $x already expanded before cmd
  # runs so no colon-splitting occurs -> prints unsplit value
  def test_ifs_env_prefix_simple_cmd_no_split
    execute("x=a:b:c:d:e; IFS=: echo $x > #{outf}")
    assert_equal "a:b:c:d:e\n", File.read(outf)
  end

  # IFS=: as env prefix for eval: eval causes re-expansion under IFS=: -> splits
  def test_ifs_env_prefix_eval_splits
    omit 'IFS=: eval echo $x re-expansion not yet implemented'
    execute("x=a:b:c:d:e; IFS=: eval echo \\$x > #{outf}")
    assert_equal "a b c d e\n", File.read(outf)
  end

  # posix mode: IFS assignment before special builtin (export) is global
  def test_ifs_posix_assignment_before_export_is_global
    omit 'set -o posix not yet implemented'
    execute("x=a:b:c:d:e; set -o posix; IFS=: export x; echo $x > #{outf}")
    assert_equal "a b c d e\n", File.read(outf)
  end

  # ifs1.sub: IFS set to glob chars, unquoted * expands to filename, quoted * is literal
  # (skipped: requires sub-script with cd and temp dir setup)
  def test_ifs_glob_chars_recho_star
    omit 'requires sub-script (ifs1.sub) with temp dir and cd'
  end
end
