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

  # missing init clause: variable preset before loop
  def test_arith_for_missing_init
    execute("i=0; for (( ; i < 3; i++ )); do echo $i >> #{outf}; done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # quoted string as condition: for (( i=0; "i < 3"; i++ ))
  def test_arith_for_quoted_string_condition
    omit 'quoted string in arith condition not yet supported'
    execute("for (( i=0; \"i < 3\"; i++ )); do echo $i >> #{outf}; done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # continue with double increment: outputs 0, 2, 4
  def test_arith_for_continue_double_increment
    execute("for ((i = 0; ;i++ )); do echo $i >> #{outf}; if (( i < 3 )); then (( i++ )); continue; fi; break; done")
    assert_equal "0\n2\n4\n", File.read(outf)
  end

  # one-liner: do on same line without semicolon before it
  def test_arith_for_oneliner_do
    execute("for ((i=0; i < 20; i++)) do :; done; echo $i > #{outf}")
    assert_equal "20\n", File.read(outf)
  end

  # brace body: for (( )) { body }
  def test_arith_for_brace_body
    omit 'brace body form of arith for not yet supported'
    execute("for ((i=0; i < 20; i++)) { :; }; echo $i > #{outf}")
    assert_equal "20\n", File.read(outf)
  end

  # descending loop with semicolon before do
  def test_arith_for_descend_semicolon_before_do
    execute("for (( i = 4; ;i--)) ; do echo $i >> #{outf}; if (( $i == 0 )); then break; fi; done")
    assert_equal "4\n3\n2\n1\n0\n", File.read(outf)
  end

  # no init, no cond, decrement: inline echo -n
  def test_arith_for_no_init_no_cond_decrement
    execute("i=4; for (( ;;i--)) ; do echo -n $i >> #{outf}; if (( i == 0 )); then break; fi; done")
    assert_equal "43210", File.read(outf)
  end

  # arithmetic error in step (7++): first iteration runs, then error on step
  def test_arith_for_error_in_step
    omit 'arith error in step raises instead of printing error and stopping loop'
    execute("for (( i=1; i < 4; 7++ )); do echo ok$i >> #{outf}; done")
    assert_equal "ok1\n", File.read(outf)
  end

  # bad init syntax (j=;): loop body never runs, script continues
  def test_arith_for_bad_init_continues
    omit 'arith syntax error in init raises instead of printing error and continuing'
    execute("for ((j=;;)); do :; done; echo X > #{outf}")
    assert_equal "X\n", File.read(outf)
  end

  # break outside loop: warning to stderr, execution continues
  def test_break_outside_loop_continues
    omit 'break outside loop throws uncaught instead of warning and continuing'
    execute("break; echo after > #{outf}")
    assert_equal "after\n", File.read(outf)
  end
end
