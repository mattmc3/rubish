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

@test 'test_arith_precedence_mul_before_add' {
  local cmd='echo $((3 + 5 * 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitwise_and' {
  local cmd='echo $((33 & 55))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitwise_or' {
  local cmd='echo $((33 | 17))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitwise_xor' {
  local cmd='echo $((8 ^ 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitwise_not' {
  local cmd='echo $((~1))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_logical_not' {
  local cmd='echo $((! 0))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_true' {
  local cmd='echo $((4<5 ? 1 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_false' {
  local cmd='echo $((4>5 ? 1 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_grouped_false' {
  local cmd='echo $((4>(2+3) ? 1 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_grouped_true' {
  local cmd='echo $((4<(2+3) ? 1 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_both_grouped_true' {
  local cmd='echo $(((2+2)<(2+3) ? 1 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_both_grouped_false' {
  local cmd='echo $(((2+2)>(2+3) ? 1 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_unevaluated_branch' {
  local cmd='echo $(((2+2)>(2+3) ? 2**0 : 32))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_exponent' {
  local cmd='echo $((2**15 - 1))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_exponent_in_expr' {
  local cmd='echo $((2**(16-1)))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_exponent_multiply' {
  local cmd='echo $((2**16*2))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_max_signed_32' {
  local cmd='echo $((2**31-1))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_exponent_zero' {
  local cmd='echo $((2**0))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_hex_literal' {
  local cmd='echo $((0xff))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_hex_or_octal' {
  local cmd='echo $((0x100 | 007))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_large_int' {
  local cmd='echo $((2147483645 + 4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_left_shift' {
  local cmd='echo $((1 << 4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_right_shift' {
  local cmd='echo $((256 >> 4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_var_in_expr' {
  local cmd='x=4; echo $((x+1))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_two_vars' {
  local cmd='x=10; y=3; echo $((x*y))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_modulo' {
  local cmd='echo $((10 % 3))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_compound_plus_eq' {
  local cmd='x=5; echo $((x+=3))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_compound_minus_eq' {
  local cmd='x=10; echo $((x-=3))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_compound_mul_eq' {
  local cmd='x=3; echo $((x*=4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_compound_div_eq' {
  local cmd='x=12; echo $((x/=4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_compound_mod_eq' {
  local cmd='x=7; echo $((x%=3))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_equality_true' {
  local cmd='echo $((4 == 4))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_equality_false' {
  local cmd='echo $((4 == 5))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_not_equal' {
  local cmd='echo $((4 != 5))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_post_increment' {
  local cmd='x=4; (( x++ )); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_post_decrement' {
  local cmd='x=4; (( x-- )); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_pre_increment' {
  local cmd='x=4; echo $((++x))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_pre_decrement' {
  local cmd='x=4; echo $((--x))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_unary_plus' {
  local cmd='echo $(( +4 - 8 ))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_unary_minus' {
  local cmd='echo $(( -4 + 8 ))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_nested_ternary' {
  local cmd='S=105; W=$((S>99?4:S>9?3:S>0?2:0)); echo $W'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_until_loop' {
  local cmd='x=7; until (( x == 4 )); do x=4; done; echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_if_cond' {
  local cmd='if (( 4 + 4 )); then echo ok; fi'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_null_expr' {
  local cmd='(()) ; echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_power_10' {
  local cmd='echo $((2**10))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_pythagorean' {
  local cmd='x=3; y=4; echo $((x*x + y*y))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_integer_division' {
  local cmd='echo $((10/3))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_post_increment_return' {
  local cmd='i=5; echo $((i++)); echo $i'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_post_decrement_return' {
  local cmd='i=5; echo $((i--)); echo $i'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_double_post_inc' {
  local cmd='x=0; (( x++ )); (( x++ )); echo $x'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_cond_gt_true' {
  local cmd='(( 4 > 3 )); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_cond_gt_false' {
  local cmd='(( 3 > 4 )); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_cond_ge' {
  local cmd='(( 4 >= 4 )); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_cond_le' {
  local cmd='(( 3 <= 4 )); echo $?'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_ternary_var' {
  local cmd='x=1; y=$((x > 0 ? 100 : 200)); echo $y'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitand' {
  local cmd='echo $((4 & 6))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitor' {
  local cmd='echo $((4 | 2))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitxor' {
  local cmd='echo $((4 ^ 6))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_bitnot_zero' {
  local cmd='echo $((~0))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_lshift_8' {
  local cmd='echo $((1 << 8))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

@test 'test_arith_rshift' {
  local cmd='echo $((1024 >> 2))'
  expected=$(bash -c "$cmd")
  actual=$($RUBISH -c "$cmd")
  [ "$actual" = "$expected" ]
}

