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

  # [[ foo > bar && $PWD -ef . ]]  ->  0  (string gt + -ef same dir)
  def test_cond_string_gt_and_ef
    omit '[[ -ef ]] same-file operator not implemented'
    execute("[[ foo > bar && $PWD -ef . ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ ! 1 -eq 1 ]]  ->  1
  def test_cond_single_negation_arith
    execute("[[ ! 1 -eq 1 ]]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ ! ! ! 1 -eq 1 ]]  ->  1
  def test_cond_triple_negation
    execute("[[ ! ! ! 1 -eq 1 ]]; echo $? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ ! ! ! ! 1 -eq 1 ]]  ->  0
  def test_cond_quadruple_negation
    execute("[[ ! ! ! ! 1 -eq 1 ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ (a) ]]  ->  0  (parenthesized term)
  def test_cond_paren_term
    execute("[[ (a) ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ (-n a) ]]  ->  0  (parenthesized unary)
  def test_cond_paren_unary
    execute("[[ (-n a) ]]; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -t X ]]  ->  2  (bad fd arg)
  def test_cond_t_bad_arg
    omit '-t with non-integer arg returns 1 not 2'
    execute("[[ -t X ]]; echo $? > #{outf}")
    assert_equal "2\n", File.read(outf)
  end

  # [[ $TDIR == /usr/homes/\* ]]  ->  1  (backslash-quoted glob = literal)
  def test_cond_backslash_quoted_glob
    omit 'backslash-escaped glob char not treated as literal in [[ == ]]'
    execute("TDIR=/usr/homes/chet; [[ \$TDIR == /usr/homes/\\* ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ -z $UNSET && $UNSET == foo ]]  ->  1  (empty != foo)
  def test_cond_and_empty_ne_foo
    ENV.delete('UNSET')
    execute("[[ -z \$UNSET && \$UNSET == foo ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ -n $TDIR || $HOME -ef ${H*} ]]  ->  0  (|| short-circuits on true LHS)
  def test_cond_or_short_circuits_true
    execute("TDIR=/usr/homes/chet; [[ -n \$TDIR || \$HOME -ef \${H*} ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -n $TDIR && -z $UNSET || $HOME -ef ${H*} ]]  ->  0
  # true && true || (short-circuits) -> 0
  def test_cond_and_or_precedence_short_circuit
    ENV.delete('UNSET')
    execute("TDIR=/usr/homes/chet; [[ -n \$TDIR && -z \$UNSET || \$HOME -ef \${H*} ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ -n $TDIR && -n $UNSET || $TDIR -ef . ]]  ->  1
  # (true && false) || (TDIR -ef .) -> false || false -> 1
  def test_cond_and_higher_precedence_than_or
    ENV.delete('UNSET')
    execute("TDIR=/usr/homes/chet; [[ -n \$TDIR && -n \$UNSET || \$TDIR -ef . ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ -n $TDIR || -n $UNSET && $PWD -ef xyz ]]  ->  0
  # true || (false && ...) -> short-circuits -> 0
  def test_cond_or_short_circuits_and
    ENV.delete('UNSET')
    execute("TDIR=/usr/homes/chet; [[ -n \$TDIR || -n \$UNSET && \$PWD -ef xyz ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ ( -n $TDIR || -n $UNSET ) && $PWD -ef xyz ]]  ->  1
  # parens group OR first -> (true || false) && (PWD -ef xyz) -> true && false -> 1
  def test_cond_parens_override_precedence
    ENV.delete('UNSET')
    execute("TDIR=/usr/homes/chet; [[ ( -n \$TDIR || -n \$UNSET ) && \$PWD -ef xyz ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ 7 -gt $IVAR ]] with IVAR unset (treated as 0)  ->  0
  def test_cond_arith_unset_var_as_zero_rhs
    execute("unset IVAR; [[ 7 -gt \$IVAR ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $IVAR -gt 7 ]] with IVAR unset (treated as 0)  ->  1
  def test_cond_arith_unset_var_as_zero_lhs
    execute("unset IVAR; [[ \$IVAR -gt 7 ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # [[ 7 -eq 4+3 ]]  ->  0  (arithmetic expression as operand)
  def test_cond_arith_expr_rhs
    omit '[[ ]] does not evaluate arithmetic expressions as operands'
    execute("[[ 7 -eq 4+3 ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $IVAR -eq 7 ]] with IVAR=4+3  ->  0  (var holds arithmetic expression)
  def test_cond_arith_expr_in_var
    omit '[[ ]] does not evaluate arithmetic expressions stored in variables'
    execute("IVAR=4+3; [[ \$IVAR -eq 7 ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $IVAR -eq A ]] with IVAR=4+3, A=7  ->  0  (var name as arith operand)
  def test_cond_arith_varname_operand
    execute("IVAR=4+3; A=7; [[ \$IVAR -eq A ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ "$IVAR" -eq "7" ]] with IVAR=4+3  ->  0  (quoted arithmetic)
  def test_cond_arith_quoted_operands
    omit '[[ ]] does not evaluate arithmetic expressions in quoted operands'
    execute("IVAR=4+3; [[ \"\$IVAR\" -eq \"7\" ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $filename == *.c ]] with filename unset  ->  1
  def test_cond_glob_unset_var
    execute("unset filename; [[ \$filename == *.c ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # null pattern does not match non-null string
  def test_cond_null_pattern_no_match
    execute("STR=file.c; PAT=; if [[ \$STR = \$PAT ]]; then echo oops > #{outf}; else echo ok > #{outf}; fi")
    assert_equal "ok\n", File.read(outf)
  end

  # null pattern matches null string
  def test_cond_null_pattern_matches_null
    execute("STR=; PAT=; if [[ \$STR = \$PAT ]]; then echo ok > #{outf}; else echo bad > #{outf}; fi")
    assert_equal "ok\n", File.read(outf)
  end

  # extglob: [[ $arg == -+([0-9]) ]] with arg=-7  ->  0
  def test_cond_extglob_plus_digits_match
    execute("shopt -s extglob; arg=-7; [[ \$arg == -+([0-9]) ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # extglob: [[ $arg == -+([0-9]) ]] with arg=-H  ->  1
  def test_cond_extglob_plus_digits_no_match
    execute("shopt -s extglob; arg=-H; [[ \$arg == -+([0-9]) ]]; echo \$? > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # extglob: [[ $arg == ++([0-9]) ]] with arg=+4  ->  0
  def test_cond_extglob_leading_plus
    execute("shopt -s extglob; arg=+4; [[ \$arg == ++([0-9]) ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # reserved words allowed after conditional: if [[ str ]] then [[ str ]] fi
  def test_cond_reserved_word_after_cond
    execute("if [[ str ]] then [[ str ]] fi; echo $? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $var == $var ]] with CTLESC char  ->  0
  def test_cond_ctlesc_self_match
    execute("var=$'ab\\001'; [[ \$var == \$var ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # [[ $var == a* ]] with var containing ctrl char  ->  0
  def test_cond_ctlesc_glob_match
    execute("var=$'ab\\001'; [[ \$var == a* ]]; echo \$? > #{outf}")
    assert_equal "0\n", File.read(outf)
  end
end
