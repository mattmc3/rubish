#!/usr/bin/env bats

RUBISH="bundle exec exe/rubish"

setup_file() {
  BATS_TEST_TIMEOUT=2
}

@test 'test_appendop_export' {
  local cmd='a=1; export a+=4; echo $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_command_env_prefix' {
  local cmd='a=1; a+=4; a+=5 printenv a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_arith' {
  local cmd='b=4+1; typeset -i b; b+=37; echo $b'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_array_element' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x[4]+=7; echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_array_arith_init' {
  local cmd='unset x; typeset -i x; x=([0]=7+11); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_integer_array_index_arith' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_array_literal_pluseq' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); x=( 1 2 [2]+=7 4 5 ); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_array_sparse_append' {
  local cmd='unset x; x=(1 2 3 4 5); typeset -i x; x=(1 2 3 4 [4]=7+11); x=( 1 2 [2]+=7 4 5 ); x+=( [3]+=9 [5]=9 ); echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_typeset_unset_pluseq' {
  local cmd='unset x; typeset x+=4; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_typeset_integer_pluseq' {
  local cmd='unset x; typeset x+=4; typeset -i x+=5; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_appendop_readonly_pluseq' {
  local cmd='unset x; typeset x+=4; typeset -i x+=5; readonly x+=7; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_null_expr' {
  local cmd='(()) ; echo $?'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_brace_body' {
  local cmd='for ((i=0; i < 20; i++)) { :; }; echo $i'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_for_bad_init_continues' {
  local cmd='for ((j=;;)); do :; done; echo X'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_break_outside_loop_continues' {
  local cmd='break; echo after'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_slice' {
  local cmd='a=(a b c d e); echo ${a[@]:1:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_declare_a_converts_scalar' {
  local cmd='unset a; a=abcde; declare -a a; echo ${a[0]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_sparse_array_access' {
  local cmd='unset a; a=abcde; a[2]=bdef; echo ${a[0]} ${a[4]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_sparse_array_all_elements' {
  local cmd='unset a; a=abcde; a[2]=bdef; echo ${a[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_indexed_compound_assignment' {
  local cmd='b=([0]=this [1]=is [2]=a [3]=test); echo ${b[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_integer_array_arithmetic' {
  local cmd='declare -i -a iarray; iarray=(2+4 1+6 7+2); echo ${iarray[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_first_element_length' {
  local cmd='xpath=(/bin /usr/bin /usr/ucb); echo ${#xpath}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_element_zero_length' {
  local cmd='xpath=(/bin /usr/bin /usr/ucb); echo ${#xpath[0]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_pattern_removal_all' {
  local cmd='xpath=(/bin /usr/bin /sbin); echo ${xpath[@]##*/}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_pattern_removal_single' {
  local cmd='xpath=(/bin /usr/bin /sbin); echo ${xpath[0]##*/}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_declare_a_compound_literal' {
  local cmd='declare -a ddd=(aaa bbb); echo ${ddd[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_scalar_as_array_element_zero' {
  local cmd='foo='\''abc'\''; echo ${foo[0]} ${#foo[0]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_scalar_as_array_unset_index_length' {
  local cmd='foo='\''abc'\''; echo ${#foo[1]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_scalar_as_array_all_and_count' {
  local cmd='foo='\''abc'\''; echo ${foo[@]} ${#foo[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_sparse_array_keys_with_gaps' {
  local cmd='z=([1]=one [4]=four [7]=seven [10]=ten); echo ${!z[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_declare_a_with_compound_assignment' {
  local cmd='declare -a x=(a b c d e); echo ${x[4]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_scalar_assignment_overrides_array' {
  local cmd='unset x; x[4]=bbb; x=abde; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_unset_whole_array' {
  local cmd='x=(a b c); unset x; echo ${x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bare_array_name_is_index_zero' {
  local cmd='unset a; a=abcde; a[2]=bdef; echo ${a}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_substitution_all_elements' {
  local cmd='xpath=(/bin /usr/bin); echo ${xpath[@]/\\//\\\\}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_global_substitution_all_elements' {
  local cmd='xpath=(/bin /usr/bin); echo ${xpath[@]//\\//\\\\}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_mixed_indexed_compound_assignment' {
  local cmd='array=(42 [1]=14 [2]=44); echo ${array[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_brace_expansion' {
  local cmd='letters=( {0..9} ); echo \"${letters[2]}${letters[3]}${letters[4]}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_sparse_slice_with_null_element' {
  local cmd='unset av; av[1]=one; av[2]=; av[3]=three; echo ${av[@]:1:2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_sparse_slice_skips_unset_element' {
  local cmd='unset av; av[1]=one; av[2]=; av[3]=three; av[5]=five; av[7]=seven; echo ${av[@]:3:2}'
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

@test 'test_brace_with_var_expansion' {
  local cmd='var=baz; echo foo{bar,${var}}'
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

@test 'test_brace_invalid_single_with_dot' {
  local cmd='echo {abcde.f}'
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

@test 'test_exit_code_in_subshell' {
  local cmd='(exit 42); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_readonly_marks_var' {
  local cmd='readonly RO=42; RO=99; echo $RO'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_exit_non_numeric_arg' {
  local cmd='(exit status); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_unalias_removes_alias' {
  local cmd='alias foo='\''bar'\''; unalias foo; alias foo'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_fallthrough_semi_amp' {
  local cmd='case foo in foo) echo fall ;& bar) echo thru;; esac'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_continue_match_double_semi_amp' {
  local cmd='case foobar in foo*) echo retest ;;& *bar) echo match;; esac'
  skip "hangs: rubish does not return on this command"
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

@test 'test_case_no_match' {
  local cmd='case xyz in abc) echo nope;; def) echo nope;; esac; echo done'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_fallthrough_multi_chain' {
  local cmd='case foo in foo) echo ft ;& bax) echo to ;& qux) echo and ;; fop) echo skip ;; esac'
  skip "hangs: rubish does not return on this command"
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
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_case_unset_null_word_continue_test' {
  local cmd='case \"\${unset_var}\" in \"\") echo ok1 ;;& \"\$unset_var\"|\"\$var\") echo ok2 ;;& unset|\"\$unset_var\") echo ok3 ;; *) echo bad ;; esac'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_in_arith' {
  local cmd='echo $(($(echo 3) + 4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_return_aborts_comsub' {
  local cmd='func() { local v; v=$(echo comsub; return; echo after); echo \"$FUNCNAME: v = $v\"; }; func'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_backtick_escaped_dollar' {
  local cmd='echo `echo '\''\\$'\'' bab`'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_backtick_escaped_backslash' {
  local cmd='echo `echo '\''\\\\'\'' ab`'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_comsub_exit_status' {
  local cmd='$(exit 42); echo $?'
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

@test 'test_cond_t_bad_arg' {
  local cmd='[[ -t X ]]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_using_length' {
  local cmd='z=abcdefghijklmnop; echo ${z:0:${#z}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_strip_from_match' {
  local cmd='s1=abcdefghijkl; s2=efgh; first=\${s1/\$s2*/}; echo \$first'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_negative_offset' {
  local cmd='x=abcdefghijklmnop; echo ${x: -3:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_error_if_unset' {
  local cmd='unset MISS_VAR; (echo ${MISS_VAR:?missing}; echo nope) 2>&1; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_expansion_bracket' {
  local cmd='echo $[ 13 * 2 ]'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_count_positional_braces' {
  local cmd='set -- one two three four five; echo ${#}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_length_of_positional' {
  local cmd='set -- one two three four five; echo ${#1}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_count_via_hash_at' {
  local cmd='set -- one two three four five; echo ${#@}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_positional_params_select' {
  local cmd='set -- one two three four five; echo $1 $3 ${5}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_negative_offset_nop' {
  local cmd='z=abcdefghijklmnop; echo ${z: -3:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_var_pattern' {
  local cmd='xxx=endocrine; yyy=n; echo ${xxx/$yyy/*}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_all_var_pattern' {
  local cmd='xxx=endocrine; yyy=n; echo ${xxx//$yyy/*}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_prefix_insert_empty' {
  local cmd='var='\'''\''; echo \"${var/#/x}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_star_empty_var' {
  local cmd='var='\'''\''; echo \"${var/*/x}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nested_param_expansion' {
  local cmd='XXX=xxx; unset BAR; FOO=${BAR:-${XXX} yyy}; echo $FOO'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_subshell_return_code' {
  local cmd='f1() { return 5; }; (f1); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_temp_env_prefix' {
  local cmd='f1() { echo $AVAR; }; AVAR=AVAR; AVAR=foo f1; echo $AVAR'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_subshell_return_inside_body' {
  local cmd='f1() { (return 5); status=$?; echo $status; return $status; }; f1; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_declare_capital_f' {
  local cmd='f1() { return 5; }; declare -F f1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_declare_lowercase_f' {
  local cmd='f1() { return 5; }; declare -f f1'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_return_in_pipeline' {
  local cmd='segv() { echo foo | return 5; }; segv; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_func_readonly_f' {
  local cmd='rfunc() { echo hi; }; readonly -f rfunc; readonly -f'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_multiple_second_wins' {
  local cmd='cat << EOF1 << EOF2\nhi\nEOF1\nthere\nEOF2'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_unquoted_backslash_newline_join' {
  local cmd='cat <<EOF\nline 1\\\nline 2\nEOF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_backslash_newline_in_delimiter' {
  local cmd='cat << EO\\\nF\nhi\nEOF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_backslash_newline_terminator' {
  local cmd='cat <<EOF\nhi\nEO\\\nF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_continuation_then_delimiter' {
  local cmd='cat <<EOF\nnext\\\nEOF\nEOF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_double_quote_in_body' {
  local cmd='cat <<EOF\necho \"\nEOF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_heredoc_escaped_double_quote_in_body' {
  local cmd='cat <<EOF\necho \\\"\nEOF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_typeset_local_in_function_splits_echo' {
  local cmd='function f { typeset IFS=:; echo $1; }; f a:b:c:d:e'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_env_prefix_for_function_splits_inside' {
  local cmd='function ff { echo $1; }; x=a:b:c:d:e; IFS=: ff a:b:c:d:e'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_env_prefix_eval_splits' {
  local cmd='x=a:b:c:d:e; IFS=: eval echo \\$x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_ifs_posix_assignment_before_export_is_global' {
  local cmd='x=a:b:c:d:e; set -o posix; IFS=: export x; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_no_expand_in_dquotes' {
  local cmd='echo \"$'\''a\\tb\\tc'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_nquote_tab_no_word_split' {
  local cmd='args() { for a in \"$@\"; do echo \"'\''$a'\''\"; done; }; args $'\''A\\tB'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_dangling_backslash_in_bracket' {
  local cmd='case a in ([[:alpha:]\\]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_a_matches_a' {
  local cmd='case a in ([[.a.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_hyphen_range' {
  local cmd='case '\''-'\'' in ([[.hyphen.]-9]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_a_to_z_range' {
  local cmd='case p in ([[.a.]-[.z.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_dash' {
  local cmd='case '\''-'\'' in ([[.-.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_space' {
  local cmd='case '\'' '\'' in ([[.space.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_dash_to_9' {
  local cmd='case '\''4'\'' in ([[.-.]-9]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_sym_with_valid_range' {
  local cmd='case c in ([[.yyz.][.a.]-z]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_sym_with_az_range' {
  local cmd='case c in ([[.yyz.][.a.]-[.z.]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_bad_range_a_Z' {
  local cmd='case p in ([[.a.]-[.Z.]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_end_sym_literal_p' {
  local cmd='case p in ([[.a.]-[.zz.]p]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_start_sym_literal_p' {
  local cmd='case p in ([[.aa.]-[.z.]p]) echo ok;; (*) echo bad;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_invalid_sym_with_literal_c' {
  local cmd='case c in ([[.yyz.]cde]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_collating_multichar_sym_with_range' {
  local cmd='case abc in ([[.cb.]a-Za]*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_equiv_class_b_matches_b' {
  local cmd='case abc in ([[:alpha:]][[=b=]][[:ascii:]]) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_posixpat_equiv_class_B_no_match_b' {
  local cmd='case abc in ([[:alpha:]][[=B=]][[:ascii:]]) echo bad;; (*) echo ok;; esac'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bang_triple_negation' {
  local cmd='! ! ! true; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_b_single_quote_escape' {
  local cmd='printf -- '\''--%b--\\n'\'' \"\\'\''abcd\\'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_printf_missing_char_arg' {
  local cmd='printf '\''%c\\n'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_cmd_sub_multiple_trailing_newlines_stripped' {
  local cmd='v=$(printf '\''hi\\n\\n\\n'\''); echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_double_backslash_newline_continuation' {
  local cmd='echo \"foo\\\nbar\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_dollar_paren_double_backslash_newline_continuation' {
  local cmd='echo $(echo \"foo\\\nbar\")'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_param_default_single_quoted_backslash' {
  local cmd='unset foo; echo ${foo:-'\''string \\'\''}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_quote_param_default_unquoted_backslash_brace' {
  local cmd='unset foo; echo ${foo:-string \\\\\\}}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_empty_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | (IFS= read line; echo \"$line\")'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_backslash_in_second_var' {
  local cmd='echo '\'' a  b\\ '\'' | (read x y; echo -\"$x\"-\"$y\"-)'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_empty_var_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | { IFS= ; read line; echo \"$line\"; }'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_newline_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | (IFS=$'\''\\n'\''; read line; echo \"$line\")'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_ifs_colon_preserves_spaces' {
  local cmd='echo '\'' foo'\'' | (IFS='\'':'\''; read line; echo \"$line\")'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_read_readonly_var_error' {
  local cmd='readonly b; read a b c <<EOF\na b c\nEOF\necho \"a = $a b = $b c = $c stat = $?\"'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_redir_while_read_heredoc' {
  local cmd='while read line; do echo $line; done <<EOF\nab\ncd\nEOF'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_redir_while_read_heredoc_var_persists' {
  local cmd='while read line; do l2=$line; done <<EOF\nab\ncd\nEOF\necho $l2'
  skip "hangs: rubish does not return on this command"
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_strip_all_blank_lines' {
  local cmd='v=`echo '\'''\'' ; echo '\'''\'' ; echo '\'''\''`; echo \"'\''$v'\''\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_subshell_exit_code' {
  local cmd='(exit 5); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_bracket_eq_non_numeric' {
  local cmd='[ 4+3 -eq 7 ]; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_backslash_after_tilde' {
  local cmd='HOME=/usr/xyz; echo ~\\chet/bar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_minus_oldpwd' {
  local cmd='cd /usr; cd /tmp; echo ~-'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_plus_pwd' {
  local cmd='cd /usr; cd /tmp; echo ~+'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_dollar_var_no_expand' {
  local cmd='USER=root; echo ~\\$USER'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_posix_mode_no_expand_in_arg' {
  local cmd='HOME=/usr/xyz; set -o posix; echo foo=bar:~'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_same_line_assign_propagates' {
  local cmd='HOME=/a/b/c a=$HOME; echo $HOME $a'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_temp_env_for_function' {
  local cmd='func() { echo $A; }; A=AVAR; A=BVAR func; echo $A'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_local_array_in_function' {
  local cmd='func2() { local -a avar=(a b c); echo ${avar[@]}; }; avar=42; echo $avar; func2; echo $avar'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_varenv_set_a_typeset_export' {
  local cmd='unset FOOFOO; FOOFOO=bar; set -a; typeset FOOFOO=abcde; printenv FOOFOO'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

