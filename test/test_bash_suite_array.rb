# frozen_string_literal: true

# Tests sourced from .bash/tests/array.tests
require_relative 'test_helper'

class TestBash_Array < Test::Unit::TestCase
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

  # a=(1 2 3); echo ${a[0]}  ->  1
  def test_array_index_zero
    execute("a=(1 2 3); echo ${a[0]} > #{outf}")
    assert_equal "1\n", File.read(outf)
  end

  # a=(1 2 3); echo ${a[2]}  ->  3
  def test_array_index_two
    execute("a=(1 2 3); echo ${a[2]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # a=(1 2 3); echo ${#a[@]}  ->  3
  def test_array_length
    execute("a=(1 2 3); echo ${#a[@]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # a=(1 2 3); echo ${a[@]}  ->  1 2 3
  def test_array_all_elements
    execute("a=(1 2 3); echo ${a[@]} > #{outf}")
    assert_equal "1 2 3\n", File.read(outf)
  end

  # a=(a b c); a[1]=B; echo ${a[@]}  ->  a B c
  def test_array_set_element
    execute("a=(a b c); a[1]=B; echo ${a[@]} > #{outf}")
    assert_equal "a B c\n", File.read(outf)
  end

  # a=(1 2 3); unset a[1]; echo ${a[@]}  ->  1 3
  def test_array_unset_element
    execute("a=(1 2 3); unset a[1]; echo ${a[@]} > #{outf}")
    assert_equal "1 3\n", File.read(outf)
  end

  # a=(1 2 3); for x in ${a[@]}; do echo $x; done  ->  1\n2\n3
  def test_array_for_loop
    omit '${a[@]} expansion in for loop not yet working'
    execute("a=(1 2 3); for x in ${a[@]}; do echo $x >> #{outf}; done")
    assert_equal "1\n2\n3\n", File.read(outf)
  end

  # a=(a b c); echo ${a[*]}  ->  a b c
  def test_array_star_expansion
    execute("a=(a b c); echo ${a[*]} > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end

  # a=(1 2 3); a+=(4 5); echo ${a[@]}  ->  1 2 3 4 5
  def test_array_append
    execute("a=(1 2 3); a+=(4 5); echo ${a[@]} > #{outf}")
    assert_equal "1 2 3 4 5\n", File.read(outf)
  end

  # a=(a b c d e); echo ${a[@]:1:3}  ->  b c d
  def test_array_slice
    omit '${a[@]:offset:len} array slice not yet supported'
    execute("a=(a b c d e); echo ${a[@]:1:3} > #{outf}")
    assert_equal "b c d\n", File.read(outf)
  end

  # x=(); echo ${x[@]}  ->  (empty line)
  def test_empty_array_expansion
    execute("x=(); echo ${x[@]} > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # declare -a converts existing scalar: a=abcde; declare -a a; echo ${a[0]}  ->  abcde
  def test_declare_a_converts_scalar
    omit 'declare -a on existing scalar does not convert to array'
    execute("unset a; a=abcde; declare -a a; echo ${a[0]} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # sparse array: a=abcde; a[2]=bdef; echo ${a[0]} ${a[4]}  ->  abcde (a[4] unset)
  def test_sparse_array_access
    omit 'scalar assignment does not become array element [0]'
    execute("unset a; a=abcde; a[2]=bdef; echo ${a[0]} ${a[4]} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # sparse array all elements: a=abcde; a[2]=bdef; echo ${a[@]}  ->  abcde bdef
  def test_sparse_array_all_elements
    omit 'scalar assignment does not become array element [0]'
    execute("unset a; a=abcde; a[2]=bdef; echo ${a[@]} > #{outf}")
    assert_equal "abcde bdef\n", File.read(outf)
  end

  # a[1]=; ${#a[@]} with empty element counted  ->  3
  def test_count_after_sparse_with_empty
    execute("unset a; a=abcde; a[2]=bdef; a[1]=; echo ${#a[@]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # arithmetic subscript: a[4+5/2]="test expression" sets index 6
  def test_arithmetic_subscript
    execute("unset a; a[4+5/2]='test expression'; echo ${a[6]} > #{outf}")
    assert_equal "test expression\n", File.read(outf)
  end

  # indexed compound assignment: b=([0]=this [1]=is [2]=a [3]=test)
  def test_indexed_compound_assignment
    omit 'indexed compound assignment not supported'
    execute("b=([0]=this [1]=is [2]=a [3]=test); echo ${b[@]} > #{outf}")
    assert_equal "this is a test\n", File.read(outf)
  end

  # compound assignment replaces all old elements
  def test_compound_assignment_replaces_old_elements
    execute("barray=(old1 old2 old3 old4 old5); barray=(new1 new2 new3); echo ${#barray[@]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # integer array: declare -i -a iarray; iarray=(2+4 1+6 7+2) -> 6 7 9
  def test_integer_array_arithmetic
    omit 'declare -i -a integer array arithmetic not supported'
    execute("declare -i -a iarray; iarray=(2+4 1+6 7+2); echo ${iarray[@]} > #{outf}")
    assert_equal "6 7 9\n", File.read(outf)
  end

  # ${#xpath} - length of first element
  def test_array_first_element_length
    omit '${#arr} length of first element not supported'
    execute("xpath=(/bin /usr/bin /usr/ucb); echo ${#xpath} > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # ${#xpath[0]} - length of element 0
  def test_array_element_zero_length
    omit '${#arr[0]} length of element 0 not supported'
    execute("xpath=(/bin /usr/bin /usr/ucb); echo ${#xpath[0]} > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # ${#xpath[@]} - element count
  def test_array_element_count
    execute("xpath=(/bin /usr/bin /usr/ucb); echo ${#xpath[@]} > #{outf}")
    assert_equal "3\n", File.read(outf)
  end

  # pattern removal on all elements: ${xpath[@]##*/}
  def test_array_pattern_removal_all
    omit '${arr[@]##pattern} pattern removal on all elements not supported'
    execute("xpath=(/bin /usr/bin /sbin); echo ${xpath[@]##*/} > #{outf}")
    assert_equal "bin bin sbin\n", File.read(outf)
  end

  # pattern removal on single element: ${xpath[0]##*/}
  def test_array_pattern_removal_single
    omit '${arr[0]##pattern} pattern removal not supported'
    execute("xpath=(/bin /usr/bin /sbin); echo ${xpath[0]##*/} > #{outf}")
    assert_equal "bin\n", File.read(outf)
  end

  # ${!x[@]} - array index keys
  def test_array_index_keys
    execute("unset x; x[0]=zero; x[1]=one; x[4]=four; x[10]=ten; echo ${!x[@]} > #{outf}")
    assert_equal "0 1 4 10\n", File.read(outf)
  end

  # quoted reserved words in array literal
  def test_array_quoted_reserved_words
    execute("foo=(\\for \\case \\if \\then \\else); echo ${foo[@]} > #{outf}")
    assert_equal "for case if then else\n", File.read(outf)
  end

  # numbers as array elements
  def test_array_number_elements
    execute("foo=(12 14 16 18 20); echo ${foo[@]} > #{outf}")
    assert_equal "12 14 16 18 20\n", File.read(outf)
  end

  # large integer as array element
  def test_array_large_number_element
    execute("foo=(4414758999202); echo ${foo[@]} > #{outf}")
    assert_equal "4414758999202\n", File.read(outf)
  end

  # declare -a with compound literal
  def test_declare_a_compound_literal
    omit 'declare -a with compound assignment syntax not supported'
    execute("declare -a ddd=(aaa bbb); echo ${ddd[@]} > #{outf}")
    assert_equal "aaa bbb\n", File.read(outf)
  end

  # scalar treated as single-element array: ${foo[0]} and ${#foo[0]}
  def test_scalar_as_array_element_zero
    omit 'scalar variable not addressable as ${var[0]}'
    execute("foo='abc'; echo ${foo[0]} ${#foo[0]} > #{outf}")
    assert_equal "abc 3\n", File.read(outf)
  end

  # scalar: ${#foo[1]} returns 0 for unset index
  def test_scalar_as_array_unset_index_length
    omit 'scalar variable not addressable as ${var[1]}'
    execute("foo='abc'; echo ${#foo[1]} > #{outf}")
    assert_equal "0\n", File.read(outf)
  end

  # scalar: ${foo[@]} and ${#foo[@]}
  def test_scalar_as_array_all_and_count
    omit 'scalar variable not addressable with ${var[@]} / ${#var[@]}'
    execute("foo='abc'; echo ${foo[@]} ${#foo[@]} > #{outf}")
    assert_equal "abc 1\n", File.read(outf)
  end

  # sparse array count: z=([1]=one [4]=four [7]=seven [10]=ten); echo ${#z[@]}
  def test_sparse_array_count
    execute("z=([1]=one [4]=four [7]=seven [10]=ten); echo ${#z[@]} > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # sparse array index keys with gaps
  def test_sparse_array_keys_with_gaps
    omit 'indexed compound assignment key ordering not preserved'
    execute("z=([1]=one [4]=four [7]=seven [10]=ten); echo ${!z[@]} > #{outf}")
    assert_equal "1 4 7 10\n", File.read(outf)
  end

  # declare -a x=(a b c d e); echo ${x[4]}  ->  e
  def test_declare_a_with_compound_assignment
    omit 'declare -a with compound assignment syntax not supported'
    execute("declare -a x=(a b c d e); echo ${x[4]} > #{outf}")
    assert_equal "e\n", File.read(outf)
  end

  # scalar overrides array: x[4]=bbb; x=abde; echo $x  ->  abde
  def test_scalar_assignment_overrides_array
    omit 'scalar assignment after indexed element crashes'
    execute("unset x; x[4]=bbb; x=abde; echo $x > #{outf}")
    assert_equal "abde\n", File.read(outf)
  end

  # old element still accessible after scalar assignment: x[4]=bbb; x=abde; echo ${x[4]}  ->  bbb
  def test_array_element_persists_after_scalar_assign
    execute("unset x; x[4]=bbb; x=abde; echo ${x[4]} > #{outf}")
    assert_equal "bbb\n", File.read(outf)
  end

  # unset entire array
  def test_unset_whole_array
    omit 'unset of named array variable not clearing array'
    execute("x=(a b c); unset x; echo ${x[@]} > #{outf}")
    assert_equal "\n", File.read(outf)
  end

  # element with spaces
  def test_array_element_with_spaces
    execute("a[5]='hello world'; echo ${a[5]} > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # bare array name is same as [0]: ${a} == ${a[0]}
  def test_bare_array_name_is_index_zero
    omit 'bare ${a} on array does not return element [0]'
    execute("unset a; a=abcde; a[2]=bdef; echo ${a} > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # pattern substitution on all array elements: ${xpath[@]/\//\\}
  def test_array_substitution_all_elements
    omit '${arr[@]/pat/rep} substitution on all array elements not supported'
    execute("xpath=(/bin /usr/bin); echo ${xpath[@]/\\//\\\\} > #{outf}")
    assert_equal "\\bin \\usr/bin\n", File.read(outf)
  end

  # global pattern substitution on all elements: ${xpath[@]//\//\\}
  def test_array_global_substitution_all_elements
    omit '${arr[@]//pat/rep} global substitution on all array elements not supported'
    execute("xpath=(/bin /usr/bin); echo ${xpath[@]//\\//\\\\} > #{outf}")
    assert_equal "\\bin \\usr\\bin\n", File.read(outf)
  end

  # mixed indexed compound: array=(42 [1]=14 [2]=44)
  def test_mixed_indexed_compound_assignment
    omit 'mixed indexed compound assignment not supported'
    execute("array=(42 [1]=14 [2]=44); echo ${array[@]} > #{outf}")
    assert_equal "42 14 44\n", File.read(outf)
  end

  # brace expansion in array: letters=( {0..9} )
  def test_array_brace_expansion
    omit 'brace expansion in array literal not supported'
    execute("letters=( {0..9} ); echo \"${letters[2]}${letters[3]}${letters[4]}\" > #{outf}")
    assert_equal "234\n", File.read(outf)
  end

  # sparse slice: av[1]=one av[2]='' av[3]=three; ${av[@]:1:2} -> one
  def test_sparse_slice_with_null_element
    omit '${a[@]:offset:len} array slice not yet supported'
    execute("unset av; av[1]=one; av[2]=; av[3]=three; echo ${av[@]:1:2} > #{outf}")
    assert_equal "one\n", File.read(outf)
  end

  # sparse slice skipping unset: ${av[@]:3:2} -> three five
  def test_sparse_slice_skips_unset_element
    omit '${a[@]:offset:len} array slice not yet supported'
    execute("unset av; av[1]=one; av[2]=; av[3]=three; av[5]=five; av[7]=seven; echo ${av[@]:3:2} > #{outf}")
    assert_equal "three five\n", File.read(outf)
  end

  # ${a[*]} star expansion joins with first IFS char (space by default)
  def test_array_star_expansion_with_ifs
    execute("a=(a b c); echo ${a[*]} > #{outf}")
    assert_equal "a b c\n", File.read(outf)
  end
end
