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

  # test (no args)  ->  1
  def test_no_args
    execute("test; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ ] (no args)  ->  1
  def test_bracket_no_args
    execute("[ ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -c /dev/tty ]  ->  0
  def test_bracket_c_char_device
    execute("[ -c /dev/tty ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -c /etc ]  ->  1 (directory is not a char device)
  def test_bracket_c_not_char_device
    execute("[ -c /etc ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -p fifo ]  ->  0 (named pipe)
  def test_bracket_p_named_pipe
    tf = "#{@tempdir}/mypipe"
    system("mkfifo #{tf}")
    execute("[ -p #{tf} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -p regular_file ]  ->  1 (regular file is not a pipe)
  def test_bracket_p_not_named_pipe
    tf = "#{@tempdir}/notpipe"
    File.write(tf, "data")
    execute("[ -p #{tf} ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -d "" ]  ->  1 (empty string is not a directory)
  def test_bracket_d_empty_string
    execute("[ -d '' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ "hello" == "hello" ]  ->  0 (double-equals string comparison)
  def test_bracket_str_double_eq_true
    execute("[ hello == hello ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ "hello" == "goodbye" ]  ->  1
  def test_bracket_str_double_eq_false
    execute("[ hello == goodbye ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ "hello" > "goodbye" ]  ->  0 (h comes after g lexicographically)
  def test_bracket_str_gt_true
    execute("[ hello \\> goodbye ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ "hello" < "goodbye" ]  ->  1 (h does not come before g)
  def test_bracket_str_lt_false
    execute("[ hello \\< goodbye ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -t 20 ]  ->  1 (fd 20 is not a terminal)
  def test_bracket_t_non_terminal_fd
    execute("[ -t 20 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -32 -eq 32 ]  ->  1 (negative number vs positive)
  def test_bracket_eq_negative_vs_positive
    execute("[ -32 -eq 32 ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -32 -eq -32 ]  ->  0 (negative numbers equal)
  def test_bracket_eq_negative_equal
    execute("[ -32 -eq -32 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # non-numeric arg to -eq  ->  exit 2
  def test_bracket_eq_non_numeric
    omit 'rubish returns 1 for bad integers, bash returns 2'
    execute("[ 4+3 -eq 7 ]; echo $? > #{outf}")
    assert_equal "2\n", File.read(outf)
  end

  # [ -n abcd -o aaa ]  ->  0 (either side true)
  def test_bracket_or_with_bare_string
    execute("[ -n abcd -o aaa ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n abcd -o -z aaa ]  ->  0 (-n abcd is true, -z aaa is false)
  def test_bracket_or_first_true
    execute("[ -n abcd -o -z aaa ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n abcd -a aaa ]  ->  0 (both sides true)
  def test_bracket_and_with_bare_string
    execute("[ -n abcd -a aaa ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -n abcd -a -z aaa ]  ->  1 (-z aaa is false)
  def test_bracket_and_second_false
    execute("[ -n abcd -a -z aaa ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ xx -a yy ]  ->  0 (both non-empty strings)
  def test_bracket_bare_and_both_nonempty
    execute("[ xx -a yy ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ xx -o "" ]  ->  0 (first is non-empty)
  def test_bracket_bare_or_first_nonempty
    execute("[ xx -o '' ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ xx -a "" ]  ->  1 (second is empty)
  def test_bracket_bare_and_second_empty
    execute("[ xx -a '' ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ file -ef hardlink ]  ->  0 (hard link is same inode)
  def test_bracket_ef_hardlink
    tf1 = "#{@tempdir}/original"
    tf2 = "#{@tempdir}/hardlink"
    File.write(tf1, "x")
    File.link(tf1, tf2)
    execute("[ #{tf1} -ef #{tf2} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ file1 -ef file2 ] where they are different files  ->  1
  def test_bracket_ef_different_files
    tf1 = "#{@tempdir}/file1"
    tf2 = "#{@tempdir}/file2"
    File.write(tf1, "x")
    File.write(tf2, "y")
    execute("[ #{tf1} -ef #{tf2} ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ noexist -ot file ]  ->  0 (nonexistent is considered older than existing)
  def test_bracket_ot_nonexistent_lhs
    omit 'rubish returns 1 for -ot when lhs does not exist; bash returns 0'
    tf = "#{@tempdir}/existing"
    File.write(tf, "x")
    execute("[ noexist_xyz -ot #{tf} ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ file -ot noexist ]  ->  1 (existing file is not older than nonexistent)
  def test_bracket_ot_nonexistent_rhs
    tf = "#{@tempdir}/existing2"
    File.write(tf, "x")
    execute("[ #{tf} -ot noexist_xyz ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ noexist -nt file ]  ->  1 (nonexistent is not newer)
  def test_bracket_nt_nonexistent_lhs
    tf = "#{@tempdir}/existing3"
    File.write(tf, "x")
    execute("[ noexist_xyz -nt #{tf} ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ noexist -ef file ]  ->  1 (nonexistent has no inode)
  def test_bracket_ef_nonexistent_lhs
    tf = "#{@tempdir}/existing4"
    File.write(tf, "x")
    execute("[ noexist_xyz -ef #{tf} ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ ! ( compound ) ]  ->  1 (negation of a true compound)
  def test_bracket_not_parens_compound
    omit 'escaped parens \\( \\) in [ ] not yet working'
    execute("[ ! \\( 700 -le 1000 -a -n 1 -a 20 = 20 \\) ]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [ -r /dev/fd/0 ]  ->  0 (stdin is readable)
  def test_bracket_r_fd0
    execute("[ -r /dev/fd/0 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [ -w /dev/fd/1 ]  ->  0 (stdout is writable)
  def test_bracket_w_fd1
    execute("[ -w /dev/fd/1 ]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end
end
