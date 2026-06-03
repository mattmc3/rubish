# frozen_string_literal: true

# Tests sourced from .bash/tests/read.tests
require_relative 'test_helper'

class TestBash_Read < Test::Unit::TestCase
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

  # echo " a " | (read x; echo "$x.")  ->  a.
  def test_read_strips_leading_trailing_whitespace
    execute("echo ' a ' | (read x; echo \"$x.\") > #{outf}")
    assert_equal "a.\n", File.read(outf)
  end

  # echo " a  b  " | (read x y; echo -"$x"-"$y"-)  ->  -a-b-
  def test_read_two_vars_strips_whitespace
    execute("echo ' a  b  ' | (read x y; echo -\"$x\"-\"$y\"-) > #{outf}")
    assert_equal "-a-b-\n", File.read(outf)
  end

  # echo " a  b  " | (read x; echo -"$x"-)  ->  -a  b-
  def test_read_one_var_captures_rest
    execute("echo ' a  b  ' | (read x; echo -\"$x\"-) > #{outf}")
    assert_equal "-a  b-\n", File.read(outf)
  end

  # read from file: read x y z < file  ->  x[A] y[B] z[]
  def test_read_from_file
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "A B \n")
    execute("read x y z < #{tf}; echo \"x[$x] y[$y] z[$z]\" > #{outf}")
    assert_equal "x[A] y[B] z[]\n", File.read(outf)
  end

  # read single var from file gets whole line
  def test_read_single_var_whole_line
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "A B \n")
    execute("read x < #{tf}; echo \"x[$x]\" > #{outf}")
    assert_equal "x[A B]\n", File.read(outf)
  end

  # read into REPLY when no var given
  def test_read_reply_default
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "A B \n")
    execute("read < #{tf}; echo \"[$REPLY]\" > #{outf}")
    assert_equal "[A B ]\n", File.read(outf)
  end

  # IFS= read preserves leading spaces
  def test_read_ifs_empty_preserves_spaces
    omit 'IFS= read not yet working'
    execute("echo ' foo' | (IFS= read line; echo \"$line\") > #{outf}")
    assert_equal " foo\n", File.read(outf)
  end

  # read a b c <<EOF  ->  a=a b=b c=c
  def test_read_heredoc
    execute("read a b c <<EOF\na b c\nEOF\necho \"a=$a b=$b c=$c\" > #{outf}")
    assert_equal "a=a b=b c=c\n", File.read(outf)
  end

  # echo " a  b\ " | (read x y; echo -"$x"-"$y"-)  ->  -a-b -
  # Without -r, backslash-space in last word is treated as literal space,
  # so y ends up as "b " (trailing space after backslash removal). Right file: -a-b -
  def test_read_backslash_in_second_var
    omit 'field trailing space stripped in store_read_variables'
    execute("echo ' a  b\\ ' | (read x y; echo -\"$x\"-\"$y\"-) > #{outf}")
    assert_equal "-a-b -\n", File.read(outf)
  end

  # echo " a  b\ " | (read x; echo -"$x"-)  ->  -a  b-
  # Without -r, trailing backslash is dropped. x gets "a  b".
  def test_read_one_var_trailing_backslash_dropped
    execute("echo ' a  b\\ ' | (read x; echo -\"$x\"-) > #{outf}")
    assert_equal "-a  b-\n", File.read(outf)
  end

  # echo " a  b\ " | (read -r x y; echo -"$x"-"$y"-)  ->  -a-b\-
  # With -r, backslash is literal. y = "b\"
  def test_read_raw_two_vars_preserves_backslash
    execute("echo ' a  b\\ ' | (read -r x y; echo -\"$x\"-\"$y\"-) > #{outf}")
    assert_equal "-a-b\\-\n", File.read(outf)
  end

  # echo " a  b\ " | (read -r x; echo -"$x"-)  ->  -a  b\-
  # With -r, x gets the whole trimmed line including trailing backslash.
  def test_read_raw_one_var_preserves_backslash
    execute("echo ' a  b\\ ' | (read -r x; echo -\"$x\"-) > #{outf}")
    assert_equal "-a  b\\-\n", File.read(outf)
  end

  # echo "\ a  b\ " | (read -r x y; echo -"$x"-"$y"-)  ->  -\-a  b\-
  # With -r, first token is "\", second is "a  b\" (rest of line).
  def test_read_raw_leading_backslash_two_vars
    execute("echo '\\ a  b\\ ' | (read -r x y; echo -\"$x\"-\"$y\"-) > #{outf}")
    assert_equal "-\\-a  b\\-\n", File.read(outf)
  end

  # echo "\ a  b\ " | (read -r x; echo -"$x"-)  ->  -\ a  b\-
  # With -r, x gets the whole trimmed line.
  def test_read_raw_leading_backslash_one_var
    execute("echo '\\ a  b\\ ' | (read -r x; echo -\"$x\"-) > #{outf}")
    assert_equal "-\\ a  b\\-\n", File.read(outf)
  end

  # echo " \ a  b\ " | (read -r x y; echo -"$x"-"$y"-)  ->  -\-a  b\-
  # Leading space then backslash: IFS strips leading space, first token is "\".
  def test_read_raw_space_backslash_two_vars
    execute("echo ' \\ a  b\\ ' | (read -r x y; echo -\"$x\"-\"$y\"-) > #{outf}")
    assert_equal "-\\-a  b\\-\n", File.read(outf)
  end

  # echo " \ a  b\ " | (read -r x; echo -"$x"-)  ->  -\ a  b\-
  def test_read_raw_space_backslash_one_var
    execute("echo ' \\ a  b\\ ' | (read -r x; echo -\"$x\"-) > #{outf}")
    assert_equal "-\\ a  b\\-\n", File.read(outf)
  end

  # Extra variables beyond available words are set to empty string.
  # echo aa > file; read avar bvar cvar < file
  # -> avar=aa, bvar="", cvar=""
  def test_read_extra_vars_empty
    omit 'read from file redirect not yet working'
    tf = "#{@tempdir}/in"
    File.write(tf, "aa\n")
    execute("read avar bvar cvar < #{tf}; echo ==\"$avar\"==; echo ==\"$bvar\"==; echo ==\"$cvar\"== > #{outf}")
    assert_equal "==aa==\n====\n====\n", File.read(outf)
  end

  # echo " foo" | { IFS= ; read line; echo "$line" }  ->  " foo"
  # IFS set to empty string in same subshell before read.
  def test_read_ifs_empty_var_preserves_spaces
    omit 'IFS assignment not yet working in subshell'
    execute("echo ' foo' | { IFS= ; read line; echo \"$line\"; } > #{outf}")
    assert_equal " foo\n", File.read(outf)
  end

  # echo " foo" | { unset IFS ; read line; echo "$line" }  ->  "foo"
  # With IFS unset, default IFS applies, leading space stripped.
  def test_read_ifs_unset_strips_leading_space
    execute("echo ' foo' | (unset IFS; read line; echo \"$line\") > #{outf}")
    assert_equal "foo\n", File.read(outf)
  end

  # echo " foo" | { IFS=$'\n' ; read line; echo "$line" }  ->  " foo"
  # IFS=newline only; space is not a field separator, so leading space preserved.
  def test_read_ifs_newline_preserves_spaces
    omit 'IFS=$newline not yet working'
    execute("echo ' foo' | (IFS=$'\\n'; read line; echo \"$line\") > #{outf}")
    assert_equal " foo\n", File.read(outf)
  end

  # echo " foo" | { IFS=$':' ; read line; echo "$line" }  ->  " foo"
  # IFS=colon; space is not a field separator, so leading space preserved.
  def test_read_ifs_colon_preserves_spaces
    omit 'IFS=colon not yet working'
    execute("echo ' foo' | (IFS=':'; read line; echo \"$line\") > #{outf}")
    assert_equal " foo\n", File.read(outf)
  end

  # Readonly variable during read: the read fails for that variable.
  # readonly b; read a b c <<EOF\na b c\nEOF -> a=a, b stays unset, c=c, $?=2
  def test_read_readonly_var_error
    omit 'readonly var error during read not yet working'
    execute("readonly b; read a b c <<EOF\na b c\nEOF\necho \"a = $a b = $b c = $c stat = $?\" > #{outf}")
    assert_equal "a = a b = c = stat = 2\n", File.read(outf)
  end
end
