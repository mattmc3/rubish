# frozen_string_literal: true

# Tests for while/until loops
require_relative 'test_helper'

class TestBash_Loops < Test::Unit::TestCase
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

  # while [ $x -gt 0 ]; do...; done
  def test_while_countdown
    execute("x=3; while [ $x -gt 0 ]; do echo $x >> #{outf}; x=$(( x - 1 )); done")
    assert_equal "3\n2\n1\n", File.read(outf)
  end

  # while false; do... done  ->  no output
  def test_while_false_no_output
    execute("while false; do echo nope >> #{outf}; done; echo done > #{outf}")
    assert_equal "done\n", File.read(outf)
  end

  # until [ $x -eq 3 ]; do...; done
  def test_until_count_to_3
    execute("x=0; until [ $x -eq 3 ]; do echo $x >> #{outf}; x=$(( x + 1 )); done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # while with break
  def test_while_break
    execute("i=0; while true; do if [ $i -eq 3 ]; then break; fi; echo $i >> #{outf}; i=$(( i + 1 )); done")
    assert_equal "0\n1\n2\n", File.read(outf)
  end

  # while with continue
  def test_while_continue
    execute("i=0; while [ $i -lt 5 ]; do i=$(( i + 1 )); if [ $i -eq 3 ]; then continue; fi; echo $i >> #{outf}; done")
    assert_equal "1\n2\n4\n5\n", File.read(outf)
  end

  # while read loop
  def test_while_read_loop
    tf = "#{@tempdir}/input"
    File.write(tf, "one\ntwo\nthree\n")
    execute("while read line; do echo $line >> #{outf}; done < #{tf}")
    assert_equal "one\ntwo\nthree\n", File.read(outf)
  end

  # nested while loops
  def test_while_nested
    execute("i=1; while [ $i -le 2 ]; do j=1; while [ $j -le 2 ]; do echo $i$j >> #{outf}; j=$(( j + 1 )); done; i=$(( i + 1 )); done")
    assert_equal "11\n12\n21\n22\n", File.read(outf)
  end

  # until false: runs once
  def test_until_false_runs_once
    execute("until false; do echo once > #{outf}; break; done")
    assert_equal "once\n", File.read(outf)
  end
end
