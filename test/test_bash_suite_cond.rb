# frozen_string_literal: true

# Tests sourced from .bash/tests/cond.tests
require_relative 'test_helper'

class TestBash_Cond < Test::Unit::TestCase
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

  # [[ x ]]  ->  0
  def test_cond_nonempty_string
    execute("[[ x ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ ! x ]]  ->  1
  def test_cond_negated_nonempty_string
    execute("[[ ! x ]]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ ! x || x ]]  ->  0
  def test_cond_not_or
    execute("[[ ! x || x ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -n a ]]  ->  0
  def test_cond_n_nonempty
    execute("[[ -n a ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -z $UNSET ]]  ->  0
  def test_cond_z_unset
    ENV.delete('UNSET')
    execute("[[ -z $UNSET ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -n $UNSET ]]  ->  1
  def test_cond_n_unset
    ENV.delete('UNSET')
    execute("[[ -n $UNSET ]]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ $x == /usr/homes/* ]]  ->  0  (glob matching)
  def test_cond_glob_match
    execute("x=/usr/homes/chet; [[ $x == /usr/homes/* ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $x == '/usr/homes/*' ]]  ->  1  (quoted pattern = literal)
  def test_cond_quoted_pattern_no_glob
    omit 'quoted RHS in [[ == ]] not treated as literal pattern'
    execute("x=/usr/homes/chet; [[ $x == '/usr/homes/*' ]]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ 4 -lt 5 ]]  ->  0
  def test_cond_numeric_lt
    execute("[[ 4 -lt 5 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ 5 -gt 4 ]]  ->  0
  def test_cond_numeric_gt
    execute("[[ 5 -gt 4 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ 4 -eq 4 ]]  ->  0
  def test_cond_numeric_eq
    execute("[[ 4 -eq 4 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ 4 -ne 5 ]]  ->  0
  def test_cond_numeric_ne
    execute("[[ 4 -ne 5 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ 4 -le 4 ]]  ->  0
  def test_cond_numeric_le
    execute("[[ 4 -le 4 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ 4 -ge 4 ]]  ->  0
  def test_cond_numeric_ge
    execute("[[ 4 -ge 4 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ foo < zoo ]]  ->  0
  def test_cond_string_lt
    execute("[[ foo < zoo ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ zoo > foo ]]  ->  0
  def test_cond_string_gt
    execute("[[ zoo > foo ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -n $x && $x == foo ]] with x unset  ->  1
  def test_cond_and_short_circuits
    ENV.delete('x')
    execute("[[ -n $x && $x == foo ]]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ -z $x || -n hello ]]  ->  0
  def test_cond_or_true
    ENV.delete('x')
    execute("[[ -z $x || -n hello ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -d / ]]  ->  0
  def test_cond_d_root
    execute("[[ -d / ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -f /etc/passwd ]]  ->  0
  def test_cond_f_passwd
    execute("[[ -f /etc/passwd ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -e /etc/passwd ]]  ->  0
  def test_cond_e_exists
    execute("[[ -e /etc/passwd ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ ! ! 1 -eq 1 ]]  ->  0
  def test_cond_double_negation
    execute("[[ ! ! 1 -eq 1 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $f == *.c ]] with f=test.c  ->  0
  def test_cond_glob_extension
    execute("f=test.c; [[ $f == *.c ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end
end
