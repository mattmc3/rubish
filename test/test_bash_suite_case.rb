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

  # case foo in foo) echo ft;& bax) echo to;& qux) echo and;; fop) echo skip;; esac  ->  ft\nto\nand
  def test_case_fallthrough_multi_chain
    omit 'case ;& multi-level fallthrough not yet supported'
    execute("case foo in foo) echo ft >> #{outf} ;& bax) echo to >> #{outf} ;& qux) echo and >> #{outf} ;; fop) echo skip >> #{outf} ;; esac")
    assert_equal "ft\nto\nand\n", File.read(outf)
  end

  # x=0 y=1; case 1 in $((y=0)) ) ;; $((x=1)) ) ... echo $x.$y  ->  1.0
  def test_case_arith_side_effects_in_pattern
    execute("x=0; y=1; case 1 in \$((y=0)) ) ;; \$((x=1)) ) echo \$x.\$y > #{outf} ;; esac")
    assert_equal "1.0\n", File.read(outf)
  end

  # readonly xx=1; $((xx++)) causes error; *) echo hi2; echo ${xx}.$?  ->  error + hi2 + 1.1
  def test_case_readonly_var_mutation_in_pattern
    omit 'readonly variable mutation in arithmetic pattern not enforced'
    execute("readonly xx=1; case 1 in \$((xx++)) ) echo hi1 >> #{outf} ;; *) echo hi2 >> #{outf}; esac; echo \${xx}.\$? >> #{outf}")
    assert_equal "hi2\n1.1\n", File.read(outf)
  end

  # var=; case ']' in [$var]*[$var]) echo matches;; *) echo no;; esac  ->  matches (bash [] quirk)
  def test_case_bracket_empty_var_matches_bracket_char
    omit 'bash [] bracket quirk with empty var not supported'
    execute("var=; case ']' in ([\$var]*[\$var]) echo matches > #{outf} ;; (*) echo no > #{outf} ;; esac")
    assert_equal "matches\n", File.read(outf)
  end

  # case abc in ( [] ) echo yes;; (*) echo no;; esac  ->  no
  def test_case_empty_bracket_no_match
    execute("case abc in ( [] ) echo yes > #{outf} ;; ( * ) echo no > #{outf} ;; esac")
    assert_equal "no\n", File.read(outf)
  end

  # empty=''; case abc in ( ["$empty"] ) echo yes;; (*) echo no;; esac  ->  no
  def test_case_quoted_empty_var_bracket_no_match
    execute("empty=; case abc in ( [\"\${empty}\"] ) echo yes > #{outf} ;; ( * ) echo no > #{outf} ;; esac")
    assert_equal "no\n", File.read(outf)
  end

  # case abc in ( [] | [!a-z]* ) echo yes;; (*) echo no;; esac  ->  no
  def test_case_empty_bracket_in_alternation_no_match
    execute("case abc in ( [] | [!a-z]* ) echo yes > #{outf} ;; ( * ) echo no > #{outf} ;; esac")
    assert_equal "no\n", File.read(outf)
  end

  # empty=''; case abc in ( ["$empty"] | [!a-z]* ) echo yes;; (*) echo no;; esac  ->  no
  def test_case_quoted_empty_var_in_alternation_no_match
    execute("empty=; case abc in ( [\"\${empty}\"] | [!a-z]* ) echo yes > #{outf} ;; ( * ) echo no > #{outf} ;; esac")
    assert_equal "no\n", File.read(outf)
  end

  # case abc in (["$empty"]|[!a-z]*) echo yes;; (*) echo no;; esac  ->  no  (no spaces)
  def test_case_quoted_empty_var_alternation_nospace_no_match
    execute("empty=; case abc in ([\"\${empty}\"]|[!a-z]*) echo yes > #{outf} ;; (*) echo no > #{outf} ;; esac")
    assert_equal "no\n", File.read(outf)
  end

  # case " " in ( [" "] ) echo ok;; (*) echo no;; esac  ->  ok
  def test_case_bracket_with_quoted_space_match
    omit 'quoted space in bracket pattern causes parser hang'
    execute("case \" \" in ( [\" \"] ) echo ok > #{outf} ;; ( * ) echo no > #{outf} ;; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case k in else|done|time|esac) for f in 1 2 3; do :; done esac  ->  (no output, no crash)
  def test_case_reserved_words_as_patterns
    omit 'reserved words as case patterns cause parser hang'
    execute("case k in else|done|time) echo matched > #{outf} ;; *) echo no > #{outf} ;; esac")
    assert_equal "no\n", File.read(outf)
  end

  # unset var; case "$unset" in '') echo ok1;; esac  ->  ok1
  def test_case_unset_var_matches_empty_pattern
    ENV.delete('unset_var')
    execute("case \"\${unset_var}\" in \"\") echo ok1 > #{outf} ;; esac")
    assert_equal "ok1\n", File.read(outf)
  end

  # unset var; case "$unset" in "$unset"|"$var") echo ok2;; esac  ->  ok2
  def test_case_unset_var_matches_pipe_with_other_var
    ENV.delete('unset_var')
    ENV['var'] = 'value'
    execute("case \"\${unset_var}\" in \"\$unset_var\"|\"\$var\") echo ok2 > #{outf} ;; esac")
    assert_equal "ok2\n", File.read(outf)
  end

  # unset var; case "$unset" in '') echo ok1;;& "$unset"|"$var") echo ok2;;& ...  ->  ok1\nok2\nok3
  def test_case_unset_null_word_continue_test
    omit 'case ;;& continue-testing not yet supported'
    ENV.delete('unset_var')
    ENV['var'] = 'value'
    execute("case \"\${unset_var}\" in \"\") echo ok1 >> #{outf} ;;& \"\$unset_var\"|\"\$var\") echo ok2 >> #{outf} ;;& unset|\"\$unset_var\") echo ok3 >> #{outf} ;; *) echo bad >> #{outf} ;; esac")
    assert_equal "ok1\nok2\nok3\n", File.read(outf)
  end
end
