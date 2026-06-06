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

@test 'test_brace_basic_suffix' {
  local cmd='echo ff{c,b,a}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_basic_infix' {
  local cmd='echo f{d,e,f}g'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_basic_prefix' {
  local cmd='echo {l,n,m}xyz'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_single_element_no_expand' {
  local cmd='echo {abc}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_escaped_open' {
  local cmd='echo \\{a,b,c,d,e}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_empty' {
  local cmd='echo {}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_close_only' {
  local cmd='echo }'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_unclosed' {
  local cmd='echo abcd{efgh'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_in_word_list' {
  local cmd='echo foo {1,2} bar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_with_var_expansion' {
  local cmd='var=baz; echo foo{bar,${var}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_nested' {
  local cmd='echo /usr/{ucb/{ex,edit},lib/{ex,how_ex}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_ascending' {
  local cmd='echo {1..10}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_descending' {
  local cmd='echo {10..1}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_with_prefix_suffix' {
  local cmd='echo x{10..1}y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_alpha_ascending' {
  local cmd='echo {a..f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_alpha_descending' {
  local cmd='echo {f..a}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_single' {
  local cmd='echo {3..3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_negative' {
  local cmd='echo {-1..-10}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_step' {
  local cmd='echo {1..10..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_descending_step' {
  local cmd='echo {10..1..-2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_alpha_step' {
  local cmd='echo {a..z..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_with_word' {
  local cmd='echo {{0..10},braces}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_zero_padded' {
  local cmd='echo {00..10}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_invalid_mixed' {
  local cmd='echo {1..f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_escaped_comma' {
  local cmd='echo {abc\\,def}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_space_inside' {
  local cmd='echo { }'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_lone_open' {
  local cmd='echo {'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_escaped_open_in_list' {
  local cmd='echo {x,y,\\{a,b,c}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_escaped_comma_and_brace' {
  local cmd='echo {x\\,y,\\{abc\\},trie}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_dotdot_in_list_not_seq' {
  local cmd='echo {0..10,braces}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_and_word_with_prefix_suffix' {
  local cmd='echo x{{0..10},braces}y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_single_with_prefix_suffix' {
  local cmd='echo x{3..3}y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_descending_with_suffix' {
  local cmd='echo {10..1}y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_lower_to_upper_cross' {
  local cmd='echo {a..A}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_upper_to_lower_cross' {
  local cmd='echo {A..a}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_alpha_single_same' {
  local cmd='echo {f..f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_invalid_alpha_to_num' {
  local cmd='echo {f..1}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_prefix_and_adjacent' {
  local cmd='echo 0{1..9} {10..20}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_negative_to_zero' {
  local cmd='echo {-20..0}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_nested_unmatched_outer' {
  local cmd='echo a-{b{d,e}}-c'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_unclosed_with_inner_expansion' {
  local cmd='echo a-{bdef-{g,i}-c'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_quoted_single_element_with_list' {
  local cmd='echo {\"klklkl\"}{1,2,3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_quoted_comma_literal' {
  local cmd='echo {\"x,x\"}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_neg_descend_pos_step' {
  local cmd='echo {-1..-10..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_neg_descend_neg_step' {
  local cmd='echo {-1..-10..-2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_descend_pos_step' {
  local cmd='echo {10..1..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_ascend_step2' {
  local cmd='echo {1..20..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_step_exceeds_range' {
  local cmd='echo {1..20..20}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_descend_step5' {
  local cmd='echo {100..0..5}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_descend_neg_step5' {
  local cmd='echo {100..0..-5}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_full_alpha' {
  local cmd='echo {a..z}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_alpha_neg_step' {
  local cmd='echo {z..a..-2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_large_ints' {
  local cmd='echo {2147483645..2147483649}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_zero_padded_step' {
  local cmd='echo {00..10..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_no_pad_descend_step2' {
  local cmd='echo {10..0..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_no_pad_descend_neg_step2' {
  local cmd='echo {10..0..-2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_seq_neg_to_neg_zero' {
  local cmd='echo {-50..-0..5}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_outer_invalid_inner_num_seqs' {
  local cmd='echo {{1,2,3}..{7,8,9}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_outer_invalid_alpha_seq_num_seq' {
  local cmd='echo {{a..c}..{1..3}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_outer_invalid_alpha_seq_num_list' {
  local cmd='echo {{a..c}..{1,10}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_outer_invalid_list_num_seq' {
  local cmd='echo {{a,c}..{1..4}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_outer_invalid_list_single_num' {
  local cmd='echo {{1,2,3}..4}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_outer_invalid_single_num_list' {
  local cmd='echo {6..{7,8,9}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_dotdot_as_path' {
  local cmd='echo {a,../a.cfg}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_dotdot_trailing_in_item' {
  local cmd='echo {a..,/a.cfg}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_seq_valid_brace_with_path' {
  local cmd='echo {a..b,/a.cfg}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_dotdot_in_second_item' {
  local cmd='echo {a,b../a.cfg}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_two_dotdot_items' {
  local cmd='echo {1..4,5..8}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_dotdot_item_and_num' {
  local cmd='echo {1..4,8}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_num_and_dotdot_item' {
  local cmd='echo {1,5..8}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_single_with_dot' {
  local cmd='echo {abcde.f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_empty_start_seq' {
  local cmd='echo X{..a}Z'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_empty_end_seq' {
  local cmd='echo 0{1..}2'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_alpha_to_num_step' {
  local cmd='echo {a..1..5}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_seq_within_valid_expansion' {
  local cmd='echo {x,y}{1..a}{0,1,2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_dotf' {
  local cmd='echo {1..10.f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_ff' {
  local cmd='echo {1..ff}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_step_ff' {
  local cmd='echo {1..10..ff}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_1dot20' {
  local cmd='echo {1.20..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_step_f2' {
  local cmd='echo {1..20..f2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_step_2f' {
  local cmd='echo {1..20..2f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_2f_range' {
  local cmd='echo {1..2f..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_ff_range' {
  local cmd='echo {1..ff..2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_0f' {
  local cmd='echo {1..0f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_invalid_bad_10f' {
  local cmd='echo {1..10f}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_var_expand_with_trailing_dot' {
  local cmd='var=baz; echo foo{bar,${var}.}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_quoted_var_as_prefix' {
  local cmd='var=baz; echo \"${var}\"{x,y}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_var_name_suffix_expansion' {
  local cmd='varx=vx; vary=vy; var=baz; echo $var{x,y}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_brace_param_expand_as_prefix' {
  local cmd='var=baz; echo ${var}{x,y}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

