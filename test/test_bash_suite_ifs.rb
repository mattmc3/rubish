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
    omit 'IFS colon split in for loop not yet working'
    execute('IFS=:')
    execute("x=a:b:c; for i in $x; do echo $i >> #{outf}; done")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # IFS=:; for i in $(echo a:b:c); do echo $i; done  ->  a\nb\nc
  def test_ifs_colon_cmd_sub_split_in_for
    omit 'IFS colon split of cmd sub in for loop not yet working'
    execute('IFS=:')
    execute("for i in $(echo a:b:c); do echo $i >> #{outf}; done")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # x='one two three'; for i in $x; do echo $i; done  ->  one\ntwo\nthree
  def test_ifs_default_splits_spaces_in_for
    omit 'IFS word splitting of variable in for loop not yet working'
    execute("x='one two three'; for i in $x; do echo $i >> #{outf}; done")
    assert_equal "one\ntwo\nthree\n", File.read(outf)
  end

  # IFS=; x='one two'; for i in $x; do echo $i; done  ->  one two  (no split)
  def test_ifs_empty_suppresses_split
    omit 'empty IFS suppression in for loop not yet working'
    execute('IFS=')
    execute("x='one two'; for i in $x; do echo $i >> #{outf}; done")
    assert_equal "one two\n", File.read(outf)
  end

  # x='one two three'; echo "$x"  ->  one two three  (quoted no split)
  def test_ifs_quoted_var_no_split
    execute("x='one two three'; echo \"$x\" > #{outf}")
    assert_equal "one two three\n", File.read(outf)
  end
end
