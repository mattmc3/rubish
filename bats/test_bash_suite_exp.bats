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

@test 'test_param_length' {
  local cmd='x=hello; echo ${#x}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_length_empty' {
  local cmd='x='\'''\''; echo ${#x}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_substring_offset_len' {
  local cmd='x=abcdefgh; echo ${x:2:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_substring_offset_only' {
  local cmd='x=abcdefgh; echo ${x:2}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_when_set' {
  local cmd='x=hello; echo ${x:-world}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_when_unset' {
  local cmd='unset x; echo ${x:-world}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_when_empty' {
  local cmd='x='\'''\''; echo ${x:-default}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_alternate_when_set' {
  local cmd='x=hello; echo ${x:+yes}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_alternate_when_unset' {
  local cmd='unset x; echo ${x:+yes}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_assign_if_unset' {
  local cmd='unset x; echo ${x:=assigned}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_shortest' {
  local cmd='x=abcdef; echo ${x#abc}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_longest' {
  local cmd='x=abcabcdef; echo ${x##*abc}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_shortest' {
  local cmd='x=abcdef; echo ${x%def}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_longest' {
  local cmd='x=abcdefdef; echo ${x%%def*}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_path_prefix' {
  local cmd='x=/path/to/file.txt; echo ${x##*/}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_extension' {
  local cmd='x=/path/to/file.txt; echo ${x%.*}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_first' {
  local cmd='x=hello; echo ${x/l/L}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_all' {
  local cmd='x=hello; echo ${x//l/L}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_upcase_first' {
  local cmd='x=hello; echo ${x^}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_upcase_all' {
  local cmd='x=hello; echo ${x^^}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_downcase_first' {
  local cmd='x=HELLO; echo ${x,}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_downcase_all' {
  local cmd='x=HELLO; echo ${x,,}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_trailing_spaces_trim_greedy' {
  local cmd='foo='\''abcd   '\''; echo -${foo%% *}-'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_set_no_colon' {
  local cmd='var=abcde; echo ${var:-xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_assign_already_set' {
  local cmd='var=abcde; echo ${var:=xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_alternate_use_alternate' {
  local cmd='var=abcde; echo ${var:+xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_substring_long' {
  local cmd='x=abcdefghijklmnop; echo ${x:8}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_substring_from_zero' {
  local cmd='x=abcdefghijklmnop; echo ${x:0:4}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_length_of_env_var' {
  local cmd='echo ${#PATH}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_whole_word' {
  local cmd='x=hello; echo ${x/hello/world}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_glob_pattern' {
  local cmd='x=aabbcc; echo ${x/b*/X}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_anchor_start' {
  local cmd='x=hello; echo ${x/#hel/HEL}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_anchor_end' {
  local cmd='x=hello; echo ${x/%llo/LLO}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_no_colon_unset' {
  local cmd='unset x; echo ${x-unset}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_no_colon_empty_is_set' {
  local cmd='x='\'''\''; echo ${x-unset}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_zero_four' {
  local cmd='z=abcdefghijklmnop; echo ${z:0:4}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_four_three' {
  local cmd='z=abcdefghijklmnop; echo ${z:4:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_past_end' {
  local cmd='z=abcdefghijklmnop; echo ${z:7:30}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_substr_len_exceeds' {
  local cmd='z=abcdefghijklmnop; echo ${z:0:100}'
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

@test 'test_newexp_replace_char_class' {
  local cmd='v=abcde; echo ${v/a[a-z]/xx}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_glob_3chars' {
  local cmd='v=abcde; echo ${v/a??/axx}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_glob_mid' {
  local cmd='v=abcde; echo ${v/c??/xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_anchor_start' {
  local cmd='v=abcde; echo ${v/#a/ab}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_anchor_start_no_match' {
  local cmd='v=abcde; echo ${v/#d/ab}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_single' {
  local cmd='v=abcde; echo ${v/d/ab}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_anchor_end' {
  local cmd='v=abcde; echo ${v/%?/last}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_anchor_end_no_match' {
  local cmd='v=abcde; echo ${v/%x/last}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_strip_trailing_spaces_greedy' {
  local cmd='foo='\''abcd   '\''; echo -${foo%% *}-'
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

@test 'test_newexp_replace_single_char' {
  local cmd='x=abc; echo ${x/b/B}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_all_char' {
  local cmd='x=aabbcc; echo ${x//b/X}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_glob_first_only' {
  local cmd='x=hello; echo ${x/l*/X}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_newexp_replace_empty_replacement' {
  local cmd='x=hello; echo ${x/l/}'
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

@test 'test_param_length_spaces' {
  local cmd='x='\''hello world'\''; echo ${#x}'
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

@test 'test_param_substr_offset3' {
  local cmd='x=hello; echo ${x:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_substr_offset1_len3' {
  local cmd='x=hello; echo ${x:1:3}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_downcase_first_mixed' {
  local cmd='x=Hello; echo ${x,}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_assign_if_unset_stores' {
  local cmd='unset x; x=${x:=mydefault}; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_alternate_nonempty' {
  local cmd='x=foo; echo ${x:+alt}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_alternate_empty' {
  local cmd='x='\'''\''; echo ${x:+alt}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_expansion_basic' {
  local cmd='echo $((28 + 14))'
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

@test 'test_param_strip_suffix_then_append' {
  local cmd='x=file.c; echo ${x%.c}.o'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_longest_slash' {
  local cmd='x=posix/src/std; echo ${x%%/*}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_var_pattern' {
  local cmd='HOME=/usr/homes/chet; x=/usr/homes/chet/src/cmd; echo ${x#$HOME}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_no_match' {
  local cmd='z=abcdef; echo ${z#xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_longest_no_match' {
  local cmd='z=abcdef; echo ${z##xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_no_match' {
  local cmd='z=abcdef; echo ${z%xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_longest_no_match' {
  local cmd='z=abcdef; echo ${z%%xyz}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_count_positional' {
  local cmd='set -- one two three four five; echo $#'
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

@test 'test_declare_no_wordsplit_in_assignment' {
  local cmd='a='\''a b c d e'\''; declare b=$a; echo $b'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_null_string_concat_quoted' {
  local cmd='echo abcd\"\"efgh'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_null_string_concat_single_quoted' {
  local cmd='echo abcd'\'''\''efgh'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_comsub' {
  local cmd='unset x; echo \"${x:-$(echo '\''foo bar'\'')}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_backslash_escape' {
  local cmd='echo \"\\\\\\\\\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_tilde_single_quotes_literal' {
  local cmd='echo '\''~'\'''
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_dollar_star_unquoted' {
  local cmd='set -- \"abc\" \"def ghi\" \"jkl\"; echo $*'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_dollar_star_quoted' {
  local cmd='set -- \"abc\" \"def ghi\" \"jkl\"; echo \"$*\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_dollar_at_quoted' {
  local cmd='set -- \"abc\" \"def ghi\" \"jkl\"; echo \"$@\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_dollar_star_quoted_custom_ifs' {
  local cmd='OIFS=\"$IFS\"; IFS=\":$IFS\"; set -- \"abc\" \"def ghi\" \"jkl\"; echo \"$*\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_length_known_value' {
  local cmd='POSIX=/usr/posix; echo ${#POSIX}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_longest_path' {
  local cmd='x=/one/two/three; echo ${x##*/}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_default_quoted_spaces' {
  local cmd='unset foo; echo \"${foo:-foo bar}\"'
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

@test 'test_param_substr_out_of_range_empty' {
  local cmd='var=abc; c=${var:3}; echo $c'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_substr_negative_length' {
  local cmd='var=abc; echo ${var:0:-2}'
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

@test 'test_param_replace_unset_var_pattern' {
  local cmd='xxx=endocrine; unset zzz; echo ${xxx/$zzz/*}'
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

@test 'test_param_replace_prefix_insert_nonempty' {
  local cmd='var=abc; echo \"${var/#/x}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_star_pattern_nonempty' {
  local cmd='var=abc; echo \"${var/*/x}\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_quoted_literal_star' {
  local cmd='P='\''*@*'\''; echo ${P%\"*\"}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_suffix_empty_pattern' {
  local cmd='P='\''*@*'\''; echo ${P%\"\"}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_strip_prefix_empty_pattern' {
  local cmd='P='\''*@*'\''; echo ${P#\"\"}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_declare_preserves_spaces_in_value' {
  local cmd='zz='\''a b c d e'\''; declare a=$zz; echo \"$a\"'
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

@test 'test_param_replace_escaped_question' {
  local cmd='a='\''a?b?c'\''; echo ${a//\\?/ }'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_replace_double_backslash_question' {
  local cmd='a='\''a?b?c'\''; echo ${a//\\\\?/ }'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_bang_default_when_unset' {
  local cmd='echo ${!:-posparams}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_bang_empty_no_bg_job' {
  local cmd='echo ${!}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_param_unset_quoted_empty_line' {
  local cmd='unset xxx; echo \"$xxx\"'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

