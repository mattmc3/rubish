#!/usr/bin/env bats

_repo="$(git -C "$BATS_TEST_DIRNAME" rev-parse --show-toplevel)"
export BUNDLE_GEMFILE="$_repo/Gemfile"
RUBISH="bundle exec $_repo/exe/rubish"

setup_file() {
  export BATS_TEST_TIMEOUT=2
}

setup() {
  # Isolate each test in bats's auto-cleaned temp dir so a test that
  # writes a file (even a failing one) never leaves a mess in the repo.
  cd "$BATS_TEST_TMPDIR" || return 1
}

@test 'test_cond_nonempty_string' {
  local cmd='[[ x ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_negated_nonempty_string' {
  local cmd='[[ ! x ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_not_or' {
  local cmd='[[ ! x || x ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_n_nonempty' {
  local cmd='[[ -n a ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_z_unset' {
  local cmd='[[ -z $UNSET ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_n_unset' {
  local cmd='[[ -n $UNSET ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_glob_match' {
  local cmd='x=/usr/homes/chet; [[ $x == /usr/homes/* ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_quoted_pattern_no_glob' {
  local cmd='x=/usr/homes/chet; [[ $x == '\''/usr/homes/*'\'' ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_numeric_lt' {
  local cmd='[[ 4 -lt 5 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_numeric_gt' {
  local cmd='[[ 5 -gt 4 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_numeric_eq' {
  local cmd='[[ 4 -eq 4 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_numeric_ne' {
  local cmd='[[ 4 -ne 5 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_numeric_le' {
  local cmd='[[ 4 -le 4 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_numeric_ge' {
  local cmd='[[ 4 -ge 4 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_string_lt' {
  local cmd='[[ foo < zoo ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_string_gt' {
  local cmd='[[ zoo > foo ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_and_short_circuits' {
  local cmd='[[ -n $x && $x == foo ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_or_true' {
  local cmd='[[ -z $x || -n hello ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_d_root' {
  local cmd='[[ -d / ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_f_passwd' {
  local cmd='[[ -f /etc/passwd ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_e_exists' {
  local cmd='[[ -e /etc/passwd ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_double_negation' {
  local cmd='[[ ! ! 1 -eq 1 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_glob_extension' {
  local cmd='f=test.c; [[ $f == *.c ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_string_gt_and_ef' {
  local cmd='[[ foo > bar && $PWD -ef . ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_single_negation_arith' {
  local cmd='[[ ! 1 -eq 1 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_triple_negation' {
  local cmd='[[ ! ! ! 1 -eq 1 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_quadruple_negation' {
  local cmd='[[ ! ! ! ! 1 -eq 1 ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_paren_term' {
  local cmd='[[ (a) ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_paren_unary' {
  local cmd='[[ (-n a) ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_t_bad_arg' {
  local cmd='[[ -t X ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_backslash_quoted_glob' {
  local cmd='TDIR=/usr/homes/chet; [[ \$TDIR == /usr/homes/\\* ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_and_empty_ne_foo' {
  local cmd='[[ -z \$UNSET && \$UNSET == foo ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_or_short_circuits_true' {
  local cmd='TDIR=/usr/homes/chet; [[ -n \$TDIR || \$HOME -ef \${H*} ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_and_or_precedence_short_circuit' {
  local cmd='TDIR=/usr/homes/chet; [[ -n \$TDIR && -z \$UNSET || \$HOME -ef \${H*} ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_and_higher_precedence_than_or' {
  local cmd='TDIR=/usr/homes/chet; [[ -n \$TDIR && -n \$UNSET || \$TDIR -ef . ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_or_short_circuits_and' {
  local cmd='TDIR=/usr/homes/chet; [[ -n \$TDIR || -n \$UNSET && \$PWD -ef xyz ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_parens_override_precedence' {
  local cmd='TDIR=/usr/homes/chet; [[ ( -n \$TDIR || -n \$UNSET ) && \$PWD -ef xyz ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_arith_unset_var_as_zero_rhs' {
  local cmd='unset IVAR; [[ 7 -gt \$IVAR ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_arith_unset_var_as_zero_lhs' {
  local cmd='unset IVAR; [[ \$IVAR -gt 7 ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_arith_expr_rhs' {
  local cmd='[[ 7 -eq 4+3 ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_arith_expr_in_var' {
  local cmd='IVAR=4+3; [[ \$IVAR -eq 7 ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_arith_varname_operand' {
  local cmd='IVAR=4+3; A=7; [[ \$IVAR -eq A ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_arith_quoted_operands' {
  local cmd='IVAR=4+3; [[ \"\$IVAR\" -eq \"7\" ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_glob_unset_var' {
  local cmd='unset filename; [[ \$filename == *.c ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_null_pattern_no_match' {
  local cmd='STR=file.c; PAT=; if [[ \$STR = \$PAT ]]; then echo oops; else echo ok; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_null_pattern_matches_null' {
  local cmd='STR=; PAT=; if [[ \$STR = \$PAT ]]; then echo ok; else echo bad; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_extglob_plus_digits_match' {
  local cmd='shopt -s extglob; arg=-7; [[ \$arg == -+([0-9]) ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_extglob_plus_digits_no_match' {
  local cmd='shopt -s extglob; arg=-H; [[ \$arg == -+([0-9]) ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_extglob_leading_plus' {
  local cmd='shopt -s extglob; arg=+4; [[ \$arg == ++([0-9]) ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_reserved_word_after_cond' {
  local cmd='if [[ str ]] then [[ str ]] fi; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_ctlesc_self_match' {
  local cmd='var=$'\''ab\\001'\''; [[ \$var == \$var ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_cond_ctlesc_glob_match' {
  local cmd='var=$'\''ab\\001'\''; [[ \$var == a* ]]; echo \$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

