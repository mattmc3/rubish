# frozen_string_literal: true

# Tests sourced from .bash/tests/heredoc.tests and herestr.tests
require_relative 'test_helper'

class TestBash_Heredoc < Test::Unit::TestCase
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

  # cat <<EOF\na\nb\nc\nEOF  ->  a\nb\nc
  def test_heredoc_basic
    execute("cat <<EOF > #{outf}\na\nb\nc\nEOF")
    assert_equal "a\nb\nc\n", File.read(outf)
  end

  # quoted heredoc: no variable expansion
  def test_heredoc_quoted_no_expansion
    execute("a=foo; cat <<'EOF' > #{outf}\nthere$a\nstuff\nEOF")
    assert_equal "there$a\nstuff\n", File.read(outf)
  end

  # unquoted heredoc: variable expansion
  def test_heredoc_unquoted_expansion
    execute("a=foo; cat <<EOF > #{outf}\nthere$a\nEOF")
    assert_equal "therefoo\n", File.read(outf)
  end

  # tab-stripped heredoc with <<-
  def test_heredoc_tab_strip
    execute("cat <<- EOF > #{outf}\n\ttab1\n\ttab2\n\tEOF")
    assert_equal "tab1\ntab2\n", File.read(outf)
  end

  # empty heredoc
  def test_heredoc_empty
    execute("cat <<EOF > #{outf}\nEOF")
    assert_equal "", File.read(outf)
  end

  # heredoc with variable in body
  def test_heredoc_var_in_body
    execute("x=hello; cat <<EOF > #{outf}\n$x world\nEOF")
    assert_equal "hello world\n", File.read(outf)
  end

  # here-string: read x <<< "alpha"; echo $x  ->  alpha
  def test_herestr_basic_read
    execute("read x <<<alpha; echo $x > #{outf}")
    assert_equal "alpha\n", File.read(outf)
  end

  # here-string: cat <<< "hello"  ->  hello
  def test_herestr_cat
    execute("cat <<<hello > #{outf}")
    assert_equal "hello\n", File.read(outf)
  end

  # here-string with variable
  def test_herestr_var
    execute("X=world; cat <<<\"hello $X\" > #{outf}")
    assert_equal "hello world\n", File.read(outf)
  end

  # here-string: read x <<< "alpha beta"; echo $x  ->  alpha beta
  def test_herestr_read_spaces
    execute("read x <<<'alpha beta'; echo $x > #{outf}")
    assert_equal "alpha beta\n", File.read(outf)
  end

  # read takes only the first line from a heredoc
  def test_heredoc_read_first_line_only
    execute("read x <<EOF > #{outf}\na\nb\nc\nEOF\necho $x >> #{outf}")
    assert_equal "a\n", File.read(outf)
  end

  # quoted delimiter: no variable expansion inside body
  def test_heredoc_quoted_delimiter_no_var_expansion
    execute("cat <<'EOF' > #{outf}\n$PS4\nEOF")
    assert_equal "$PS4\n", File.read(outf)
  end

  # empty heredoc body gives empty string on read
  def test_heredoc_empty_read
    execute("read x <<EOF > #{outf}\nEOF\necho \"[$x]\" >> #{outf}")
    assert_equal "[]\n", File.read(outf)
  end

  # heredoc: $empty (unset var) expands to empty -> read gets empty
  def test_heredoc_empty_var_expansion
    execute("unset empty; read x <<EOF > #{outf}\n$empty\nEOF\necho \"[$x]\" >> #{outf}")
    assert_equal "[]\n", File.read(outf)
  end

  # multiple heredocs on one command: second heredoc body wins
  def test_heredoc_multiple_second_wins
    omit 'multiple heredocs on one command not yet supported'
    execute("cat << EOF1 << EOF2 > #{outf}\nhi\nEOF1\nthere\nEOF2")
    assert_equal "there\n", File.read(outf)
  end

  # quoted heredoc: backslash at end of line is literal, not a continuation
  def test_heredoc_quoted_backslash_literal
    execute("cat <<'EOF' > #{outf}\nhi\\\nthere$a\nstuff\nEOF")
    assert_equal "hi\\\nthere$a\nstuff\n", File.read(outf)
  end

  # unquoted heredoc: backslash-newline is removed (line continuation)
  def test_heredoc_unquoted_backslash_newline_join
    omit 'backslash-newline joining in heredoc body not yet supported'
    execute("cat <<EOF > #{outf}\nline 1\\\nline 2\nEOF")
    assert_equal "line 1line 2\n", File.read(outf)
  end

  # heredoc delimiter itself can use backslash-newline to span lines
  def test_heredoc_backslash_newline_in_delimiter
    omit 'backslash-newline in heredoc delimiter not yet supported'
    execute("cat << EO\\\nF > #{outf}\nhi\nEOF")
    assert_equal "hi\n", File.read(outf)
  end

  # heredoc body terminator with backslash-newline collapses to delimiter
  def test_heredoc_backslash_newline_terminator
    omit 'backslash-newline in heredoc terminator not yet supported'
    execute("cat <<EOF > #{outf}\nhi\nEO\\\nF")
    assert_equal "hi\n", File.read(outf)
  end

  # backslash-newline before delimiter: body line "next\EOF" -> "nextEOF"
  def test_heredoc_continuation_then_delimiter
    omit 'backslash-newline joining before delimiter in heredoc not yet supported'
    execute("cat <<EOF > #{outf}\nnext\\\nEOF\nEOF")
    assert_equal "nextEOF\n", File.read(outf)
  end

  # heredoc with output redirect then append
  def test_heredoc_append_to_file
    f2 = File.join(@tempdir, 'app')
    execute("cat > #{f2} <<EOF\nabc\nEOF")
    execute("cat >> #{f2} <<EOF\ndef ghi\njkl mno\nEOF")
    assert_equal "abc\ndef ghi\njkl mno\n", File.read(f2)
  end

  # double quote inside heredoc body is literal
  def test_heredoc_double_quote_in_body
    omit 'double quote in heredoc body stripped by rubish'
    execute("cat <<EOF > #{outf}\necho \"\nEOF")
    assert_equal "echo \"\n", File.read(outf)
  end

  # backslash-escaped double quote in unquoted heredoc
  def test_heredoc_escaped_double_quote_in_body
    omit 'backslash escape of double quote in heredoc body not yet supported'
    execute("cat <<EOF > #{outf}\necho \\\"\nEOF")
    assert_equal "echo \"\n", File.read(outf)
  end

  # comsub containing a herestring
  def test_heredoc_comsub_herestring
    execute("echo $(cat <<<\"comsub here-string\") > #{outf}")
    assert_equal "comsub here-string\n", File.read(outf)
  end

  # herestring: bare unquoted word
  def test_herestr_bare_word
    execute("read x <<<beta; echo $x > #{outf}")
    assert_equal "beta\n", File.read(outf)
  end

  # herestring: variable reference without quotes
  def test_herestr_var_unquoted
    execute("X=4; read x <<<$X; echo $x > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # herestring: variable reference with double quotes
  def test_herestr_var_double_quoted
    execute("X=4; read x <<<\"$X\"; echo $x > #{outf}")
    assert_equal "4\n", File.read(outf)
  end

  # herestring: empty double-quoted string
  def test_herestr_empty_double_quoted
    execute("read x <<< \"\"; echo \"[$x]\" > #{outf}")
    assert_equal "[]\n", File.read(outf)
  end

  # herestring: unset variable expands to empty
  def test_herestr_empty_unset_var
    execute("unset empty; read x <<<\"$empty\"; echo \"[$x]\" > #{outf}")
    assert_equal "[]\n", File.read(outf)
  end

  # herestring: two variables concatenated
  def test_herestr_two_vars
    execute("a=hot; b=damn; cat <<<\"$a $b\" > #{outf}")
    assert_equal "hot damn\n", File.read(outf)
  end

  # herestring: single-quoted preserves literal content
  def test_herestr_single_quoted
    execute("cat <<<'what a fabulous window treatment' > #{outf}")
    assert_equal "what a fabulous window treatment\n", File.read(outf)
  end

  # herestring: single-quoted preserves embedded double quote
  def test_herestr_single_quoted_double_quote
    execute("cat <<<'double\"quote' > #{outf}")
    assert_equal "double\"quote\n", File.read(outf)
  end

  # herestring: single-quoted suppresses command substitution
  def test_herestr_single_quoted_no_comsub
    execute("cat <<<'echo $(echo hi)' > #{outf}")
    assert_equal "echo $(echo hi)\n", File.read(outf)
  end

  # herestring: double-quoted string is literal (no comsub when content is plain)
  def test_herestr_double_quoted_literal
    execute("cat <<<\"echo ho\" > #{outf}")
    assert_equal "echo ho\n", File.read(outf)
  end

  # herestring: double-quoted comsub is expanded before passing to cat
  def test_herestr_double_quoted_comsub
    execute("cat <<<\"echo $(echo 'off to work we go')\" > #{outf}")
    assert_equal "echo off to work we go\n", File.read(outf)
  end
end
