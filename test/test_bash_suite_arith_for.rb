# frozen_string_literal: true

# Tests sourced from .bash/tests/arith-for.tests
require_relative 'test_helper'

class TestBash_ArithFor < Test::Unit::TestCase
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

  # for ((i=0; i<3; i++)); do echo $i; done  ->  0\n1\n2
  def test_arith_for_basic
    execute("for ((i=0; i<3; i++)); do echo $i >> #{outf}; done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # for ((i=1; i<=3; i++))  ->  1\n2\n3
  def test_arith_for_count_3
    execute("for ((i=1; i<=3; i++)); do echo $i >> #{outf}; done")
    assert_equal "1\n2\n3\n", File.read(outf)
  end

  # for with post-increment in body
  def test_arith_for_increment_in_body
    execute("for ((i=0; i<3; )); do echo $i >> #{outf}; (( i++ )); done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # for with break
  def test_arith_for_break
    execute("for ((i=0; ; i++)); do if (( i >= 3 )); then break; fi; echo $i >> #{outf}; done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # for with continue
  def test_arith_for_continue
    execute("for ((i=0; i<5; i++)); do if (( i == 2 )); then continue; fi; echo $i >> #{outf}; done")
    assert_equal "0\n1\n3\n4\n", File.read(outf)
  end

  # for with descending count
  def test_arith_for_descend
    execute("for ((i=3; i>0; i--)); do echo $i >> #{outf}; done")
    assert_equal "3\n2\n1\n", File.read(outf)
  end

  # for with i<20, check final value
  def test_arith_for_final_value
    execute("for ((i=0; i<20; i++)); do :; done; echo $i > #{outf}")
    assert_equal "20\n", File.read(outf)
  end

  # nested arithmetic for loops
  def test_arith_for_nested
    execute("for ((i=0; i<2; i++)); do for ((j=0; j<2; j++)); do echo $i$j >> #{outf}; done; done")
    assert_equal "00\n01\n10\n11\n", File.read(outf)
  end

  # for loop sum
  def test_arith_for_sum
    execute("s=0; for ((i=1; i<=5; i++)); do (( s += i )); done; echo $s > #{outf}")
    assert_equal "15\n", File.read(outf)
  end

  # for ((; ; )) infinite loop with break
  def test_arith_for_infinite_break
    execute("i=0; for ((;;)); do if (( i > 2 )); then break; fi; echo $i >> #{outf}; (( i++ )); done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end
end
