# frozen_string_literal: true

# Tests sourced from .bash/tests/case.tests
require_relative 'test_helper'

class TestBash_Case < Test::Unit::TestCase
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

  # case foo in bar) echo skip;; foo) echo match;; esac  ->  match
  def test_case_simple_match
    execute("case foo in bar) echo skip;; foo) echo match > #{outf};; esac")
    assert_equal "match\n", File.read(outf)
  end

  # case foo in foo) echo fall;& bar) echo thru;; esac  ->  fall\nthru
  def test_case_fallthrough_semi_amp
    omit 'case ;& fallthrough not yet supported'
    execute("case foo in foo) echo fall > #{outf} ;& bar) echo thru >> #{outf};; esac")
    assert_equal "fall\nthru\n", File.read(outf)
  end

  # case foobar in foo*) echo retest;;& *bar) echo match;; esac  ->  retest\nmatch
  def test_case_continue_match_double_semi_amp
    omit 'case ;;& continue-testing not yet supported'
    execute("case foobar in foo*) echo retest > #{outf} ;;& *bar) echo match >> #{outf};; esac")
    assert_equal "retest\nmatch\n", File.read(outf)
  end

  # case a in a) echo a;& esac  ->  a  (fallthrough with no next branch)
  def test_case_fallthrough_at_end
    execute("case a in a) echo a > #{outf} ;& esac")
    assert_equal "a\n", File.read(outf)
  end

  # case foo in (foo) echo match;; esac  ->  match
  def test_case_leading_paren_match
    execute("case foo in (foo) echo match > #{outf};; esac")
    assert_equal "match\n", File.read(outf)
  end

  # case world in (hello) echo hi;; (world) echo world;; esac  ->  world
  def test_case_leading_paren_multi_branch
    execute("case world in (hello) echo hi > #{outf};; (world) echo world > #{outf};; esac")
    assert_equal "world\n", File.read(outf)
  end

  # case bar in (foo|bar) echo match;; esac  ->  match
  def test_case_leading_paren_multi_pattern
    execute("case bar in (foo|bar) echo match > #{outf};; esac")
    assert_equal "match\n", File.read(outf)
  end

  # case other in (hello) echo hi;; (*) echo catch;; esac  ->  catch
  def test_case_leading_paren_wildcard
    execute("case other in (hello) echo hi > #{outf};; (*) echo catch > #{outf};; esac")
    assert_equal "catch\n", File.read(outf)
  end

  # case esac in (esac) echo esac;; esac  ->  esac
  def test_case_esac_as_pattern_word
    omit 'reserved word as case pattern not yet supported'
    execute("case esac in (esac) echo esac > #{outf};; esac")
    assert_equal "esac\n", File.read(outf)
  end

  # var unset: case ']' in [$var]*[$var]) echo yes;; *) echo no;; esac  ->  no
  def test_case_bracket_with_empty_var
    ENV.delete('v')
    execute("case ']' in ([$v]*[$v]) echo yes > #{outf};; (*) echo no > #{outf};; esac")
    assert_equal "no\n", File.read(outf)
  end

  # case a in a|b) echo match;; esac  ->  match
  def test_case_pipe_pattern
    execute("case a in a|b) echo match > #{outf};; esac")
    assert_equal "match\n", File.read(outf)
  end

  # case foobar in foo*) echo yes;; esac  ->  yes
  def test_case_glob_pattern
    execute("case foobar in foo*) echo yes > #{outf};; esac")
    assert_equal "yes\n", File.read(outf)
  end

  # case xyz in abc) echo nope;; def) echo nope;; esac; echo done  ->  done
  def test_case_no_match
    omit 'case with no match followed by semicolon causes parse error'
    execute("case xyz in abc) echo nope;; def) echo nope;; esac; echo done > #{outf}")
    assert_equal "done\n", File.read(outf)
  end

  # case ab in ?) echo one;; ??) echo two;; esac  ->  two
  def test_case_question_wildcard
    execute("case ab in ?) echo one;; ??) echo two;; esac > #{outf}")
    assert_equal "two\n", File.read(outf)
  end

  # x=foo; case $x in foo) echo yes;; *) echo no;; esac  ->  yes
  def test_case_var_match
    execute("x=foo; case $x in foo) echo yes > #{outf};; *) echo no > #{outf};; esac")
    assert_equal "yes\n", File.read(outf)
  end

  # case zzz in abc) echo abc;; *) echo catch;; esac  ->  catch
  def test_case_catchall
    execute("case zzz in abc) echo abc > #{outf};; *) echo catch > #{outf};; esac")
    assert_equal "catch\n", File.read(outf)
  end
end
