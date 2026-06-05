# frozen_string_literal: true

# Tests sourced from .bash/tests/appendop.tests
require_relative 'test_helper'

class TestBash_Appendop < Test::Unit::TestCase
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

  # a=1; a+=4  ->  14  (string append)
  def test_appendop_string
    execute("a=1; a+=4; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end

  # a+=5 in command env
  def test_appendop_in_env
    execute("a=1; a+=4; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end

  # array append
  def test_appendop_array
    execute("x=(1 2 3); x+=(4 5 6); echo ${x[@]} > #{outf}")
    assert_equal "1 2 3 4 5 6\n", File.read(outf)
  end

  # export a+=4
  def test_appendop_export
    omit 'export with += not yet supported'
    execute("a=1; export a+=4; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end

  # x=(1 2 3 4 5 6); x[4]+=1  ->  x[4] was "5", string append "1" -> "51"
  def test_appendop_array_element_string
    execute("x=(1 2 3); x+=(4 5 6); x[4]+=1; echo ${x[@]} > #{outf}")
    assert_equal "1 2 3 4 51 6\n", File.read(outf)
  end

  # a+=5 in command-local env -- a is "14", printenv sees "145", a stays "14"
  def test_appendop_command_env_prefix
    omit 'command-local += env prefix not yet supported'
    execute("a=1; a+=4; a+=5 printenv a > #{outf}")
    assert_equal "145\n", File.read(outf)
  end

  # after command-local a+=5, shell var a is unchanged
  def test_appendop_command_env_prefix_unchanged
    execute("a=1; a+=4; a+=5 printenv a > /dev/null; echo $a > #{outf}")
    assert_equal "14\n", File.read(outf)
  end

  # typeset -i a; a+=7 from empty -> 7
  def test_appendop_integer_empty
    execute("a=; typeset -i a; a+=7; echo $a > #{outf}")
    assert_equal "7\n", File.read(outf)
  end

  # b=4+1; typeset -i b -> 5; b+=37 -> 5+37=42
  def test_appendop_integer_arith
    execute("b=4+1; typeset -i b; b+=37; echo $b > #{outf}")
    assert_equal "42\n", File.read(outf)
  end

  # typeset -i x; x=(1 2 3 4 5); x[4]+=7 -> 5+7=12
  def test_appendop_integer_array_element
    execute("unset x; x=(1 2 3 4 5); typeset -i x; x[4]+=7; echo ${x[@]} > #{outf}")
    assert_equal "1 2 3 4 12\n", File.read(outf)
  end

  # typeset -i x; x=([0]=7+11) -> 18
  def test_appendop_integer_array_arith_init
    omit 'integer array arithmetic initializer not yet supported'
    execute("unset x; typeset -i x; x=([0]=7+11); echo ${x[@]} > #{outf}")
    assert_equal "18\n", File.read(outf)
  end

  # typeset -i x; x=(1 2 3 4 [4]=7+11) -> 1 2 3 4 18
  def test_appendop_integer_array_index_arith
    omit 'integer array index arithmetic assignment not yet supported'
    execute("unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); echo ${x[@]} > #{outf}")
    assert_equal "1 2 3 4 18\n", File.read(outf)
  end

  # x=( 1 2 [2]+=7 4 5 ) with typeset -i x; x[2] was 0 in new assign context -> 7
  def test_appendop_array_literal_pluseq
    omit 'array literal += element not yet supported'
    execute("unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); x=( 1 2 [2]+=7 4 5 ); echo ${x[@]} > #{outf}")
    assert_equal "1 2 7 4 5\n", File.read(outf)
  end

  # x+=( [3]+=9 [5]=9 ) sparse append -> 1 2 7 13 5 9
  def test_appendop_array_sparse_append
    omit 'sparse array += append not yet supported'
    execute("unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); x=( 1 2 [2]+=7 4 5 ); x+=( [3]+=9 [5]=9 ); echo ${x[@]} > #{outf}")
    assert_equal "1 2 7 13 5 9\n", File.read(outf)
  end

  # typeset -i x=4+5; echo $x -> 9
  def test_appendop_typeset_integer_init
    execute("unset x; typeset -i x=4+5; echo $x > #{outf}")
    assert_equal "9\n", File.read(outf)
  end

  # typeset x+=4 on unset x -> x gets "4"
  def test_appendop_typeset_unset_pluseq
    omit 'typeset x+=value on unset var not yet supported'
    execute("unset x; typeset x+=4; echo $x > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # typeset -i x+=5 with x="4" -> integer coercion: 4+5=9
  def test_appendop_typeset_integer_pluseq
    omit 'typeset -i with += arithmetic not yet supported'
    execute("unset x; typeset x+=4; typeset -i x+=5; echo $x > #{outf}")
    assert_equal "9\n", File.read(outf)
  end

  # readonly x+=7 with x=9 -> 16; then echo $x -> 16
  def test_appendop_readonly_pluseq
    omit 'readonly with += not yet supported'
    execute("unset x; typeset x+=4; typeset -i x+=5; readonly x+=7; echo $x > #{outf}")
    assert_equal "16\n", File.read(outf)
  end

  # x+=5 on readonly x -> error message to stderr
  def test_appendop_readonly_error
    omit 'readonly += error message not yet verified'
    execute("unset x; typeset x+=4; typeset -i x+=5; readonly x+=7; x+=5 2> #{outf}; true")
    assert_match(/readonly variable/, File.read(outf))
  end
end
