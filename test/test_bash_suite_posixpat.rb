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

  # case a in [:al:]) echo ok;; esac  ->  ok 5
  # [:al:] is NOT a character class (no outer brackets), it's a literal bracket expression
  # matching any of ':', 'a', 'l'
  def test_posixpat_literal_bracket_matches_a
    execute("case a in ([:al:]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\003' in [[:cntrl:]]) echo ok;; esac  ->  ok 10
  def test_posixpat_cntrl_matches_ctrl_c
    execute("case $'\\003' in ([[:cntrl:]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\033' in [[:graph:]]) echo oops;; *) echo ok;; esac  ->  ok 14
  def test_posixpat_graph_no_match_esc
    execute("case $'\\033' in ([[:graph:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\040' in [[:graph:]]) echo oops;; *) echo ok;; esac  ->  ok 15
  def test_posixpat_graph_no_match_space_oct
    execute("case $'\\040' in ([[:graph:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case ' ' in [[:graph:]]) echo oops;; *) echo ok;; esac  ->  ok 16
  def test_posixpat_graph_no_match_space
    execute("case ' ' in ([[:graph:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\040' in [[:print:]]) echo ok;; *) echo oops;; esac  ->  ok 18
  def test_posixpat_print_matches_space_oct
    execute("case $'\\040' in ([[:print:]]) echo ok > #{outf};; (*) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case a in [[:alpha:]\]) echo oops;; *) echo ok;; esac  ->  ok 21
  # dangling backslash inside bracket expression should not match
  def test_posixpat_dangling_backslash_in_bracket
    execute("case a in ([[:alpha:]\\]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\n' in [[:blank:]]) -> no; [[:space:]]) -> ok -- space
  # newline is [:space:] but not [:blank:]
  def test_posixpat_newline_is_space_not_blank
    execute("case $'\\n' in ([[:blank:]]) echo bad > #{outf};; ([[:space:]]) echo ok > #{outf};; (*) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\t' in [[:blank:]]) -> ok -- blank
  # tab is [:blank:]
  def test_posixpat_tab_is_blank
    execute("case $'\\t' in ([[:blank:]]) echo ok > #{outf};; (*) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\377' in [[:ascii:]]) echo oops;; esac  ->  no output (0xFF not ASCII)
  def test_posixpat_high_byte_not_ascii
    execute("case $'\\377' in ([[:ascii:]]) echo bad > #{outf};; esac")
    assert_false File.exist?(outf)
  end

  # case 9 in [1[:alpha:]123]) echo oops;; esac  ->  no output (9 not in set)
  def test_posixpat_9_not_in_alpha_1_2_3
    execute("case 9 in ([1[:alpha:]123]) echo bad > #{outf};; esac")
    assert_false File.exist?(outf)
  end

  # case a in [[:alpha:]) echo oops;; esac  ->  no output (unterminated bracket)
  # an unterminated bracket expr containing a valid char class that matches must fail
  def test_posixpat_unterminated_bracket_no_match
    execute("case a in ([[:alpha:]) echo bad > #{outf};; esac")
    assert_false File.exist?(outf)
  end

  # case $'\b' in [[:graph:]]) echo oops;; esac  ->  no output (backspace not graph)
  def test_posixpat_backspace_not_graph
    execute("case $'\\b' in ([[:graph:]]) echo bad > #{outf};; esac")
    assert_false File.exist?(outf)
  end

  # case $'\b' in [[:print:]]) echo oops;; esac  ->  no output (backspace not print)
  def test_posixpat_backspace_not_print
    execute("case $'\\b' in ([[:print:]]) echo bad > #{outf};; esac")
    assert_false File.exist?(outf)
  end

  # case $' ' in [[:punct:]]) echo oops;; esac  ->  no output (space not punct)
  def test_posixpat_space_not_punct
    execute("case $' ' in ([[:punct:]]) echo bad > #{outf};; esac")
    assert_false File.exist?(outf)
  end

  # Collating symbol tests (POSIX [.symbol.] syntax)

  # case 'a' in [[.a.]]) echo ok;; esac  ->  ok 1 (collating: ok 1)
  def test_posixpat_collating_a_matches_a
    omit 'collating symbols [.x.] not implemented'
    execute("case a in ([[.a.]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case '-' in [[.hyphen.]-9]) echo ok;; esac  ->  ok 2 (collating: ok 2)
  def test_posixpat_collating_hyphen_range
    omit 'collating symbols [.x.] not implemented'
    execute("case '-' in ([[.hyphen.]-9]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 'p' in [[.a.]-[.z.]]) echo ok;; esac  ->  ok 3 (collating: ok 3)
  def test_posixpat_collating_a_to_z_range
    omit 'collating symbols [.x.] not implemented'
    execute("case p in ([[.a.]-[.z.]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case '-' in [[.-.]] -> ok 4 (collating: ok 4)
  def test_posixpat_collating_dash
    omit 'collating symbols [.x.] not implemented'
    execute("case '-' in ([[.-.]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case ' ' in [[.space.]] -> ok 5 (collating: ok 5)
  def test_posixpat_collating_space
    omit 'collating symbols [.x.] not implemented'
    execute("case ' ' in ([[.space.]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case ' ' in [[.grave-accent.]]) -> ok 6 (no match, grave-accent is not space)
  def test_posixpat_collating_grave_no_match_space
    execute("case ' ' in ([[.grave-accent.]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case '4' in [[.-.]-9]) echo ok -> ok 7 (collating: ok 7)
  def test_posixpat_collating_dash_to_9
    omit 'collating symbols [.x.] not implemented'
    execute("case '4' in ([[.-.]-9]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 'c' in [[.yyz.]-[.z.]]) -> ok 8 (invalid symbol, no match)
  def test_posixpat_collating_invalid_range_no_match
    execute("case c in ([[.yyz.]-[.z.]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 'c' in [[.yyz.][.a.]-z]) -> ok 9 (c in a-z range)
  def test_posixpat_collating_invalid_sym_with_valid_range
    omit 'collating symbols [.x.] not implemented'
    execute("case c in ([[.yyz.][.a.]-z]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 'c' in [[.yyz.][.a.]-[.z.]]) -> ok 10 (c in a-z range)
  def test_posixpat_collating_invalid_sym_with_az_range
    omit 'collating symbols [.x.] not implemented'
    execute("case c in ([[.yyz.][.a.]-[.z.]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case 'p' in [[.a.]-[.Z.]]) -> ok 11 (no match, bad range a-Z)
  def test_posixpat_collating_bad_range_a_Z
    execute("case p in ([[.a.]-[.Z.]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case p in [[.a.]-[.zz.]p]) -> ok 12 (invalid end sym, p literal matches)
  def test_posixpat_collating_invalid_end_sym_literal_p
    omit 'collating symbols [.x.] not implemented'
    execute("case p in ([[.a.]-[.zz.]p]) echo ok > #{outf};; (*) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case p in [[.aa.]-[.z.]p]) -> ok 13 (invalid start sym, p literal matches)
  def test_posixpat_collating_invalid_start_sym_literal_p
    omit 'collating symbols [.x.] not implemented'
    execute("case p in ([[.aa.]-[.z.]p]) echo ok > #{outf};; (*) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case c in [[.yyz.]cde]) -> ok 14 (c matches literal c in set)
  def test_posixpat_collating_invalid_sym_with_literal_c
    omit 'collating symbols [.x.] not implemented'
    execute("case c in ([[.yyz.]cde]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case abc in [[.cb.]a-Za]*) -> ok 15 (a matches set, bc matches *)
  def test_posixpat_collating_multichar_sym_with_range
    omit 'collating symbols [.x.] not implemented'
    execute("case abc in ([[.cb.]a-Za]*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case $'\t' in [[.space.][.tab.][.newline.]]) -> ok 16 (tab matches)
  def test_posixpat_collating_tab_in_whitespace_set
    omit 'collating symbols [.x.] not implemented'
    execute("case $'\\t' in ([[.space.][.tab.][.newline.]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # Equivalence class tests (POSIX [[=x=]] syntax)

  # case "abc" in [[:alpha:]][[=b=]][[:ascii:]]) -> ok 1 (equiv: ok 1)
  def test_posixpat_equiv_class_b_matches_b
    omit 'equivalence classes [=x=] not implemented'
    execute("case abc in ([[:alpha:]][[=b=]][[:ascii:]]) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case "abc" in [[:alpha:]][[=B=]][[:ascii:]]) -> ok 2 (B != b, no match)
  def test_posixpat_equiv_class_B_no_match_b
    execute("case abc in ([[:alpha:]][[=B=]][[:ascii:]]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # case a in [[=b=]) -> ok 3 (incomplete equiv class, no match)
  def test_posixpat_incomplete_equiv_class_no_match
    execute("case a in ([[=b=]) echo bad > #{outf};; (*) echo ok > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end
end
