# frozen_string_literal: true

# Tests sourced from .bash/tests/posixpat.tests
require_relative 'test_helper'

class TestBash_Posixpat < Test::Unit::TestCase
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

  # case e in [[:xdigit:]]) echo ok;; esac  ->  ok
  def test_posixpat_xdigit_matches_e
    execute("case e in ([[:xdigit:]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case a in [[:alpha:]123]) echo ok;; esac  ->  ok
  def test_posixpat_alpha_with_literals_matches_a
    execute("case a in ([[:alpha:]123]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 1 in [[:alpha:]123]) echo ok;; esac  ->  ok
  def test_posixpat_alpha_with_literals_matches_1
    execute("case 1 in ([[:alpha:]123]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 9 in [![:alpha:]]) echo ok;; esac  ->  ok
  def test_posixpat_not_alpha_matches_9
    execute("case 9 in ([![:alpha:]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case a in [![:alpha:]]) echo bad;; *) echo ok;; esac  ->  ok
  def test_posixpat_not_alpha_no_match_a
    execute("case a in ([![:alpha:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case a in [[:al:]]) echo bad;; *) echo ok;; esac  ->  ok  (invalid class)
  def test_posixpat_invalid_class_no_match
    execute("case a in ([[:al:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case '!' in [abc[:punct:][0-9]]) echo ok;; esac  ->  ok
  def test_posixpat_punct_matches_bang
    execute("case '!' in ([abc[:punct:][0-9]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 'PATH' in [_[:alpha:]]*) echo ok;; esac  ->  ok
  def test_posixpat_alpha_star_matches_PATH
    execute("case 'PATH' in ([_[:alpha:]]*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case PATH in [_[:alpha:]][_[:alnum:]]*) echo ok;; esac  ->  ok
  def test_posixpat_alpha_alnum_star_matches_PATH
    execute("case PATH in ([_[:alpha:]][_[:alnum:]]*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case A in [[:cntrl:]]) echo bad;; *) echo ok;; esac  ->  ok
  def test_posixpat_not_cntrl_matches_A
    execute("case A in ([[:cntrl:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 9 in [[:digit:]]) echo ok;; esac  ->  ok
  def test_posixpat_digit_matches_9
    execute("case 9 in ([[:digit:]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case X in [[:digit:]]) echo bad;; *) echo ok;; esac  ->  ok
  def test_posixpat_digit_no_match_X
    execute("case X in ([[:digit:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case aB in [[:lower:]][[:upper:]]) echo ok;; esac  ->  ok
  def test_posixpat_lower_upper_pair
    execute("case aB in ([[:lower:]][[:upper:]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case a in [[:alpha:][:digit:]]) echo ok;; *) echo bad;; esac  ->  ok
  def test_posixpat_alpha_or_digit
    execute("case a in ([[:alpha:][:digit:]]) echo ok > #{outf};; (*) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case PS3 in [_[:alpha:]][_[:alnum:]][_[:alnum:]]*) echo ok;; esac  ->  ok
  def test_posixpat_identifier_prefix
    execute("case PS3 in ([_[:alpha:]][_[:alnum:]][_[:alnum:]]*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end
end
