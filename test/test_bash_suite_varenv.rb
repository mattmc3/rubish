# frozen_string_literal: true

# Tests sourced from .bash/tests/varenv.tests
require_relative 'test_helper'

class TestBash_Varenv < Test::Unit::TestCase
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

  # d=$c c=$d with c=1 d=2 -> both become 1
  def test_varenv_swap_not_atomic
    execute("c=1; d=2; d=$c; c=$d; echo $c $d > #{outf}")
    assert_equal "1 1\n", File.read(outf)
  end

  # unset d; echo ${d-unset}  ->  unset
  def test_varenv_unset_default
    execute("unset d; echo ${d-unset} > #{outf}")
    assert_equal "unset\n", File.read(outf)
  end

  # a=bcde; echo ${#a}  ->  4
  def test_varenv_length
    execute("a=bcde; echo ${#a} > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # HOME=/usr/chet; echo $HOME  ->  /usr/chet
  def test_varenv_export_visible
    execute("export HOME=/usr/chet; echo $HOME > #{outf}")
    assert_equal "/usr/chet\n", File.read(outf)
  end

  # local env assignment: HOME=/a/b/c printenv HOME  ->  /a/b/c
  def test_varenv_local_env_assign
    execute("HOME=/a/b/c printenv HOME > #{outf}")
    assert_equal "/a/b/c\n", File.read(outf)
  end

  # c=1; d=2; echo $c $d  ->  1 2
  def test_varenv_basic_assign
    execute("c=1; d=2; echo $c $d > #{outf}")
    assert_equal "1 2\n", File.read(outf)
  end

  # readonly x=5
  def test_varenv_readonly
    execute("readonly RO_VAR=5; echo $RO_VAR > #{outf}")
    assert_equal "5\n", File.read(outf)
  end

  # export makes var visible to child process
  def test_varenv_export_child
    execute("export MYVAR=hello; echo $(printenv MYVAR) > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # unset removes var
  def test_varenv_unset
    execute("x=foo; unset x; echo ${x:-gone} > #{outf}")
    assert_equal "gone\n", File.read(outf)
  end

  # local var assignment in subshell doesn't affect parent
  def test_varenv_subshell_not_affect_parent
    execute("x=parent; (x=child); echo $x > #{outf}")
    assert_equal "parent\n", File.read(outf)
  end

  # a=5; a+=3; echo $a  ->  53  (string append, not arithmetic)
  def test_varenv_string_append
    execute("a=5; a+=3; echo $a > #{outf}")
    assert_equal "53\n", File.read(outf)
  end

  # a=1; b=2; c=3; echo $a $b $c  ->  1 2 3
  def test_varenv_multiple_assign
    execute("a=1; b=2; c=3; echo $a $b $c > #{outf}")
    assert_equal "1 2 3\n", File.read(outf)
  end

  # command-local env: VAR=val cmd
  def test_varenv_command_local
    execute("X=old; X=new printenv X > #{outf}")
    assert_equal "new\n", File.read(outf)
  end

  # same-line assignment: HOME=/a/b/c a=$HOME uses the new HOME value
  # HOME=/a/b/c a=$HOME; echo $HOME $a  ->  /a/b/c /a/b/c
  def test_varenv_same_line_assign_propagates
    omit 'same-line assignment propagation not yet implemented'
    execute("HOME=/a/b/c a=$HOME; echo $HOME $a > #{outf}")
    assert_equal "/a/b/c /a/b/c\n", File.read(outf)
  end

  # temp env assignment does not change shell's own variable during expansion
  # export HOME=/usr/chet; HOME=/a/b/c /bin/echo $HOME  ->  /usr/chet
  def test_varenv_temp_env_no_affect_expansion
    execute("export HOME=/usr/chet; HOME=/a/b/c /bin/echo $HOME > #{outf}")
    assert_equal "/usr/chet\n", File.read(outf)
  end

  # function local variable: local YYZ shadows outer YYZ inside the function;
  # outer YYZ and A are unchanged after the call
  def test_varenv_function_local_var
    execute("func() { local YYZ; YYZ='song by rush'; echo $YYZ; }; YYZ='toronto airport'; echo $YYZ > #{outf}; func >> #{outf}; echo $YYZ >> #{outf}")
    assert_equal "toronto airport\nsong by rush\ntoronto airport\n", File.read(outf)
  end

  # temp env for a function call: A=BVAR func; A is BVAR inside, AVAR outside
  def test_varenv_temp_env_for_function
    omit 'temp env propagation into functions not yet implemented'
    execute("func() { echo $A; }; A=AVAR; A=BVAR func > #{outf}; echo $A >> #{outf}")
    assert_equal "BVAR\nAVAR\n", File.read(outf)
  end

  # expansion does not use assignment statements preceding a builtin
  # export A=AVAR; A=ZVAR echo $A  ->  AVAR  (not ZVAR)
  def test_varenv_no_expansion_from_builtin_prefix_assign
    execute("export A=AVAR; A=ZVAR echo $A > #{outf}")
    assert_equal "AVAR\n", File.read(outf)
  end

  # local -a array in function; outer scalar is unaffected after call
  def test_varenv_local_array_in_function
    omit 'local -a not yet implemented'
    execute("func2() { local -a avar=(a b c); echo ${avar[@]}; }; avar=42; echo $avar > #{outf}; func2 >> #{outf}; echo $avar >> #{outf}")
    assert_equal "42\na b c\n42\n", File.read(outf)
  end

  # declare -i creates an integer variable; assignment stores integer value
  # declare -i ivar; ivar=10; declare -p ivar  ->  declare -i ivar="10"
  def test_varenv_declare_integer
    omit 'declare -p output redirect not yet working'
    execute("declare -i ivar; ivar=10; declare -p ivar > #{outf}")
    assert_equal "declare -i ivar=\"10\"\n", File.read(outf)
  end

  # export an unset variable: echo ${ivar-unset}  ->  unset
  def test_varenv_export_unset_then_assign
    execute("export ivar; echo ${ivar-unset} > #{outf}")
    assert_equal "unset\n", File.read(outf)
  end

  # export attribute persists after assignment: declare -p shows -x
  def test_varenv_export_attr_persists
    omit 'declare -p output redirect not yet working'
    execute("export ivar; ivar=42; declare -p ivar > #{outf}")
    assert_equal "declare -x ivar=\"42\"\n", File.read(outf)
  end

  # set -a causes typeset assignment to create an exported variable
  # unset FOOFOO; FOOFOO=bar; set -a; typeset FOOFOO=abcde; printenv FOOFOO  ->  abcde
  def test_varenv_set_a_typeset_export
    omit 'set -a auto-export not yet implemented'
    execute("unset FOOFOO; FOOFOO=bar; set -a; typeset FOOFOO=abcde; printenv FOOFOO > #{outf}")
    assert_equal "abcde\n", File.read(outf)
  end

  # typeset in a function scopes the variable locally; outer var unchanged
  # tt() { typeset a=b; echo a=$a; }; a=z; echo a=$a; tt; echo a=$a
  def test_varenv_typeset_function_scope
    execute("tt() { typeset a=b; echo a=$a; }; a=z; echo a=$a > #{outf}; tt >> #{outf}; echo a=$a >> #{outf}")
    assert_equal "a=z\na=b\na=z\n", File.read(outf)
  end
end
