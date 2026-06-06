#!/usr/bin/env bats

RUBISH="bundle exec exe/rubish"

setup_file() {
  export BATS_TEST_TIMEOUT=2
}

setup() {
  # Isolate each test in bats's auto-cleaned temp dir so a test that
  # writes a file (even a failing one) never leaves a mess in the repo.
  cd "$BATS_TEST_TMPDIR" || return 1
}

@test 'test_case_simple_match' {
  local cmd='case foo in bar) echo skip;; foo) echo match;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_fallthrough_semi_amp' {
  local cmd='case foo in foo) echo fall ;& bar) echo thru;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_continue_match_double_semi_amp' {
  local cmd='case foobar in foo*) echo retest ;;& *bar) echo match;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_fallthrough_at_end' {
  local cmd='case a in a) echo a ;& esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_leading_paren_match' {
  local cmd='case foo in (foo) echo match;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_leading_paren_multi_branch' {
  local cmd='case world in (hello) echo hi;; (world) echo world;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_leading_paren_multi_pattern' {
  local cmd='case bar in (foo|bar) echo match;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_leading_paren_wildcard' {
  local cmd='case other in (hello) echo hi;; (*) echo catch;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_esac_as_pattern_word' {
  local cmd='case esac in (esac) echo esac;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_bracket_with_empty_var' {
  local cmd='case '\'']'\'' in ([$v]*[$v]) echo yes;; (*) echo no;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_pipe_pattern' {
  local cmd='case a in a|b) echo match;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_glob_pattern' {
  local cmd='case foobar in foo*) echo yes;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_no_match' {
  local cmd='case xyz in abc) echo nope;; def) echo nope;; esac; echo done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_question_wildcard' {
  local cmd='case ab in ?) echo one;; ??) echo two;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_var_match' {
  local cmd='x=foo; case $x in foo) echo yes;; *) echo no;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_catchall' {
  local cmd='case zzz in abc) echo abc;; *) echo catch;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_fallthrough_multi_chain' {
  local cmd='case foo in foo) echo ft ;& bax) echo to ;& qux) echo and ;; fop) echo skip ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_arith_side_effects_in_pattern' {
  local cmd='x=0; y=1; case 1 in \$((y=0)) ) ;; \$((x=1)) ) echo \$x.\$y ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_readonly_var_mutation_in_pattern' {
  local cmd='readonly xx=1; case 1 in \$((xx++)) ) echo hi1 ;; *) echo hi2; esac; echo \${xx}.\$?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_bracket_empty_var_matches_bracket_char' {
  local cmd='var=; case '\'']'\'' in ([\$var]*[\$var]) echo matches ;; (*) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_empty_bracket_no_match' {
  local cmd='case abc in ( [] ) echo yes ;; ( * ) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_quoted_empty_var_bracket_no_match' {
  local cmd='empty=; case abc in ( [\"\${empty}\"] ) echo yes ;; ( * ) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_empty_bracket_in_alternation_no_match' {
  local cmd='case abc in ( [] | [!a-z]* ) echo yes ;; ( * ) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_quoted_empty_var_in_alternation_no_match' {
  local cmd='empty=; case abc in ( [\"\${empty}\"] | [!a-z]* ) echo yes ;; ( * ) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_quoted_empty_var_alternation_nospace_no_match' {
  local cmd='empty=; case abc in ([\"\${empty}\"]|[!a-z]*) echo yes ;; (*) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_bracket_with_quoted_space_match' {
  local cmd='case \" \" in ( [\" \"] ) echo ok ;; ( * ) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_reserved_words_as_patterns' {
  local cmd='case k in else|done|time) echo matched ;; *) echo no ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_unset_var_matches_empty_pattern' {
  local cmd='case \"\${unset_var}\" in \"\") echo ok1 ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_unset_var_matches_pipe_with_other_var' {
  local cmd='case \"\${unset_var}\" in \"\$unset_var\"|\"\$var\") echo ok2 ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_unset_null_word_continue_test' {
  local cmd='case \"\${unset_var}\" in \"\") echo ok1 ;;& \"\$unset_var\"|\"\$var\") echo ok2 ;;& unset|\"\$unset_var\") echo ok3 ;; *) echo bad ;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

