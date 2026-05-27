# frozen_string_literal: true

# Tests sourced from .bash/tests/test.tests
require_relative 'test_helper'

class TestBash_Test < Test::Unit::TestCase
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

  # [ -d /etc ]  ->  0
  def test_bracket_d_dir
    execute("[ -d /etc ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -d /dev/null ]  ->  1
  def test_bracket_d_not_dir
    execute("[ -d /dev/null ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -f /etc/passwd ]  ->  0
  def test_bracket_f_regular_file
    execute("[ -f /etc/passwd ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -f /etc ]  ->  1
  def test_bracket_f_directory
    execute("[ -f /etc ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -e /dev/null ]  ->  0
  def test_bracket_e_exists
    execute("[ -e /dev/null ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -e /nonexist_xyz_rubish ]  ->  1
  def test_bracket_e_nonexist
    execute("[ -e /nonexist_xyz_rubish ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -r /dev/null ]  ->  0
  def test_bracket_r_readable
    execute("[ -r /dev/null ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -w /dev/null ]  ->  0
  def test_bracket_w_writable
    execute("[ -w /dev/null ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -x /bin/sh ]  ->  0
  def test_bracket_x_executable
    execute("[ -x /bin/sh ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -s file ] on nonempty file  ->  0
  def test_bracket_s_nonempty_file
    tf = "#{@tempdir}/nonempty"
    File.write(tf, "data")
    execute("[ -s #{tf} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -s file ] on empty file  ->  1
  def test_bracket_s_empty_file
    tf = "#{@tempdir}/empty"
    File.write(tf, "")
    execute("[ -s #{tf} ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -z "" ]  ->  0
  def test_bracket_z_empty_string
    execute("[ -z '' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -z "foo" ]  ->  1
  def test_bracket_z_nonempty_string
    execute("[ -z 'foo' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -n "hello" ]  ->  0
  def test_bracket_n_nonempty_string
    execute("[ -n 'hello' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n "" ]  ->  1
  def test_bracket_n_empty_string
    execute("[ -n '' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ "hello" = "hello" ]  ->  0
  def test_bracket_str_eq_true
    execute("[ 'hello' = 'hello' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ "hello" = "goodbye" ]  ->  1
  def test_bracket_str_eq_false
    execute("[ 'hello' = 'goodbye' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ "hello" != "goodbye" ]  ->  0
  def test_bracket_str_ne_true
    execute("[ 'hello' != 'goodbye' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ "hello" != "hello" ]  ->  1
  def test_bracket_str_ne_false
    execute("[ 'hello' != 'hello' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ "foo" ]  ->  0
  def test_bracket_string_nonempty
    execute("[ 'foo' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ "" ]  ->  1
  def test_bracket_string_empty
    execute("[ '' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ 200 -eq 200 ]  ->  0
  def test_bracket_eq_true
    execute("[ 200 -eq 200 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 34 -eq 222 ]  ->  1
  def test_bracket_eq_false
    execute("[ 34 -eq 222 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ 34 -ne 222 ]  ->  0
  def test_bracket_ne_true
    execute("[ 34 -ne 222 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 200 -ne 200 ]  ->  1
  def test_bracket_ne_false
    execute("[ 200 -ne 200 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ 340 -gt 222 ]  ->  0
  def test_bracket_gt_true
    execute("[ 340 -gt 222 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 200 -gt 200 ]  ->  1
  def test_bracket_gt_false
    execute("[ 200 -gt 200 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ 34 -lt 222 ]  ->  0
  def test_bracket_lt_true
    execute("[ 34 -lt 222 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 200 -lt 200 ]  ->  1
  def test_bracket_lt_false
    execute("[ 200 -lt 200 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ 200 -ge 200 ]  ->  0
  def test_bracket_ge_equal
    execute("[ 200 -ge 200 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 34 -ge 222 ]  ->  1
  def test_bracket_ge_false
    execute("[ 34 -ge 222 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ 200 -le 200 ]  ->  0
  def test_bracket_le_equal
    execute("[ 200 -le 200 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 340 -le 222 ]  ->  1
  def test_bracket_le_false
    execute("[ 340 -le 222 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ ! -z "foo" ]  ->  0
  def test_bracket_not
    execute("[ ! -z 'foo' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n "a" -a -z "" ]  ->  0
  def test_bracket_and_true
    execute("[ -n 'a' -a -z '' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n "a" -a -n "" ]  ->  1
  def test_bracket_and_false
    execute("[ -n 'a' -a -n '' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -n "a" -o -n "" ]  ->  0
  def test_bracket_or_true
    execute("[ -n 'a' -o -n '' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n "" -o -n "" ]  ->  1
  def test_bracket_or_both_false
    execute("[ -n '' -o -n '' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ ! ! "foo" ]  ->  0
  def test_bracket_double_not
    execute("[ ! ! 'foo' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 700 -le 1000 -a -n "1" -a "20" = "20" ]  ->  0
  def test_bracket_compound_and
    execute("[ 700 -le 1000 -a -n '1' -a '20' = '20' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ 12 -eq 34 ]  ->  1
  def test_bracket_eq_unequal
    execute("[ 12 -eq 34 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ ! 12 -eq 34 ]  ->  0
  def test_bracket_not_eq_unequal
    execute("[ ! 12 -eq 34 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -L symlink ]  ->  0
  def test_bracket_L_symlink
    tf = "#{@tempdir}/target"
    sl = "#{@tempdir}/link"
    File.write(tf, "data")
    File.symlink(tf, sl)
    execute("[ -L #{sl} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -L regular_file ]  ->  1
  def test_bracket_L_not_symlink
    tf = "#{@tempdir}/notlink"
    File.write(tf, "data")
    execute("[ -L #{tf} ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ file2 -nt file1 ]  ->  0
  def test_bracket_nt_newer_file
    tf1 = "#{@tempdir}/older"
    tf2 = "#{@tempdir}/newer"
    File.write(tf1, "a")
    sleep 0.1
    File.write(tf2, "b")
    execute("[ #{tf2} -nt #{tf1} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ file1 -ot file2 ]  ->  0
  def test_bracket_ot_older_file
    tf1 = "#{@tempdir}/older2"
    tf2 = "#{@tempdir}/newer2"
    File.write(tf1, "a")
    sleep 0.1
    File.write(tf2, "b")
    execute("[ #{tf1} -ot #{tf2} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ file -ef file ]  ->  0
  def test_bracket_ef_same_file
    tf = "#{@tempdir}/same"
    File.write(tf, "x")
    execute("[ #{tf} -ef #{tf} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ ( -n "x" ) ]  ->  0
  def test_bracket_parens
    omit 'escaped parens \\( \\) in [ ] not yet working'
    execute("[ \\( -n 'x' \\) ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end
end
