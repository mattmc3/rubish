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

@test 'test_array_index_zero' {
  local cmd='a=(1 2 3); echo ${a[0]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_index_two' {
  local cmd='a=(1 2 3); echo ${a[2]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_length' {
  local cmd='a=(1 2 3); echo ${#a[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_all_elements' {
  local cmd='a=(1 2 3); echo ${a[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_set_element' {
  local cmd='a=(a b c); a[1]=B; echo ${a[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_unset_element' {
  local cmd='a=(1 2 3); unset a[1]; echo ${a[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_for_loop' {
  local cmd='a=(1 2 3); for x in ${a[@]}; do echo $x; done'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_star_expansion' {
  local cmd='a=(a b c); echo ${a[*]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_append' {
  local cmd='a=(1 2 3); a+=(4 5); echo ${a[@]}'
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

@test 'test_empty_array_expansion' {
  local cmd='x=(); echo ${x[@]}'
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

@test 'test_count_after_sparse_with_empty' {
  local cmd='unset a; a=abcde; a[2]=bdef; a[1]=; echo ${#a[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arithmetic_subscript' {
  local cmd='unset a; a[4+5/2]='\''test expression'\''; echo ${a[6]}'
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

@test 'test_compound_assignment_replaces_old_elements' {
  local cmd='barray=(old1 old2 old3 old4 old5); barray=(new1 new2 new3); echo ${#barray[@]}'
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

@test 'test_array_element_count' {
  local cmd='xpath=(/bin /usr/bin /usr/ucb); echo ${#xpath[@]}'
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

@test 'test_array_index_keys' {
  local cmd='unset x; x[0]=zero; x[1]=one; x[4]=four; x[10]=ten; echo ${!x[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_quoted_reserved_words' {
  local cmd='foo=(\\for \\case \\if \\then \\else); echo ${foo[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_number_elements' {
  local cmd='foo=(12 14 16 18 20); echo ${foo[@]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_array_large_number_element' {
  local cmd='foo=(4414758999202); echo ${foo[@]}'
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

@test 'test_sparse_array_count' {
  local cmd='z=([1]=one [4]=four [7]=seven [10]=ten); echo ${#z[@]}'
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

@test 'test_array_element_persists_after_scalar_assign' {
  local cmd='unset x; x[4]=bbb; x=abde; echo ${x[4]}'
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

@test 'test_array_element_with_spaces' {
  local cmd='a[5]='\''hello world'\''; echo ${a[5]}'
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

@test 'test_array_star_expansion_with_ifs' {
  local cmd='a=(a b c); echo ${a[*]}'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

