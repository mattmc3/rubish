# frozen_string_literal: true

# Tests sourced from .bash/tests/array.tests
require_relative 'test_helper'

class TestBash_Array < Test::Unit::TestCase
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

  # a=(1 2 3); echo ${a[0]}  ->  1
  def test_array_index_zero
    execute("a=(1 2 3); echo ${a[0]} > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # a=(1 2 3); echo ${a[2]}  ->  3
  def test_array_index_two
    execute("a=(1 2 3); echo ${a[2]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # a=(1 2 3); echo ${#a[@]}  ->  3
  def test_array_length
    execute("a=(1 2 3); echo ${#a[@]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # a=(1 2 3); echo ${a[@]}  ->  1 2 3
  def test_array_all_elements
    execute("a=(1 2 3); echo ${a[@]} > #{outf}")
    assert_equal "1 2 3\n", File.read(outf)
  end

  # a=(a b c); a[1]=B; echo ${a[@]}  ->  a B c
  def test_array_set_element
    execute("a=(a b c); a[1]=B; echo ${a[@]} > #{outf}")
    assert_equal "a B c\n", File.read(outf)
  end

  # a=(1 2 3); unset a[1]; echo ${a[@]}  ->  1 3
  def test_array_unset_element
    execute("a=(1 2 3); unset a[1]; echo ${a[@]} > #{outf}")
    assert_equal "1 3\n", File.read(outf)
  end

  # a=(1 2 3); for x in ${a[@]}; do echo $x; done  ->  1\n2\n3
  def test_array_for_loop
    omit '${a[@]} expansion in for loop not yet working'
    execute("a=(1 2 3); for x in ${a[@]}; do echo $x >> #{outf}; done")
    assert_equal "1\n2\n3\n", File.read(outf)
  end

  # a=(a b c); echo ${a[*]}  ->  a b c
  def test_array_star_expansion
    execute("a=(a b c); echo ${a[*]} > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # a=(1 2 3); a+=(4 5); echo ${a[@]}  ->  1 2 3 4 5
  def test_array_append
    execute("a=(1 2 3); a+=(4 5); echo ${a[@]} > #{outf}")
    assert_equal "1 2 3 4 5\n", File.read(outf)
  end

  # a=(a b c d e); echo ${a[@]:1:3}  ->  b c d
  def test_array_slice
    omit '${a[@]:offset:len} array slice not yet supported'
    execute("a=(a b c d e); echo ${a[@]:1:3} > #{outf}")
    assert_equal "b c d\n", File.read(outf)
  end
end
