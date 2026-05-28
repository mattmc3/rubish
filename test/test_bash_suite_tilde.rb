# frozen_string_literal: true

# Tests sourced from .bash/tests/tilde.tests
require_relative 'test_helper'

class TestBash_Tilde < Test::Unit::TestCase
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

  # HOME=/usr/xyz; echo ~/foo  ->  /usr/xyz/foo
  def test_tilde_expands_to_home
    omit 'tilde expansion not yet supported'
    execute("HOME=/usr/xyz; echo ~/foo > #{outf}")
    assert_equal "/usr/xyz/foo\n", File.read(outf)
  end

  # echo "~chet"/"foo"  ->  ~chet/foo  (quoted tilde not expanded)
  def test_tilde_quoted_no_expand
    execute("echo \"~chet\"/\"foo\" > #{outf}")
    assert_equal "~chet/foo\n", File.read(outf)
  end

  # echo abcd~chet  ->  abcd~chet  (tilde not at start of word)
  def test_tilde_not_at_start_no_expand
    execute("echo abcd~chet > #{outf}")
    assert_equal "abcd~chet\n", File.read(outf)
  end

  # HOME=/usr/xyz; SHELL=~/bash; echo $SHELL  ->  /usr/xyz/bash
  def test_tilde_in_assignment
    omit 'tilde expansion in assignment not yet supported'
    execute("HOME=/usr/xyz; SHELL=~/bash; echo $SHELL > #{outf}")
    assert_equal "/usr/xyz/bash\n", File.read(outf)
  end

  # HOME=/usr/xyz; path=...:~/bin:...; echo $path  ->  ...expanded...
  def test_tilde_in_colon_path
    omit 'tilde expansion in assignment not yet supported'
    execute("HOME=/usr/xyz; path=/usr/ucb:/bin:~/bin:~/tmp/bin:/usr/bin; echo $path > #{outf}")
    assert_equal "/usr/ucb:/bin:/usr/xyz/bin:/usr/xyz/tmp/bin:/usr/bin\n", File.read(outf)
  end

  # echo ":~chet/"  ->  :~chet/  (tilde not at start of word)
  def test_tilde_mid_word_no_expand
    execute("echo ':~chet/' > #{outf}")
    assert_equal ":~chet/\n", File.read(outf)
  end

  # case ~ in $HOME) echo ok;; esac  ->  ok
  def test_tilde_in_case
    omit 'tilde expansion not yet supported'
    execute("HOME=/usr/xyz; case ~ in \$HOME) echo ok > #{outf};; *) echo bad > #{outf};; esac")
    assert_equal "ok\n", File.read(outf)
  end

  # export PPATH=$XPATH:~/bin; echo $PPATH  ->  .../expanded/...
  def test_tilde_in_export
    omit 'tilde expansion in export not yet supported'
    execute("HOME=/usr/xyz; XPATH=/bin:/usr/bin:.; export PPATH=$XPATH:~/bin; echo $PPATH > #{outf}")
    assert_equal "/bin:/usr/bin:.:/usr/xyz/bin\n", File.read(outf)
  end

  # echo ~ch\et  ->  ~chet  (backslash mid-username prevents expansion)
  def test_tilde_backslash_mid_username
    execute("HOME=/usr/xyz; echo ~ch\\et > #{outf}")
    assert_equal "~chet\n", File.read(outf)
  end

  # echo \~chet/foo  ->  ~chet/foo  (escaped leading tilde = literal, no backslash in output)
  def test_escaped_tilde_no_expand
    omit 'escaped tilde outputs backslash instead of literal tilde'
    execute("echo \\~chet/foo > #{outf}")
    assert_equal "~chet/foo\n", File.read(outf)
  end

  # echo ~\chet/bar  ->  ~chet/bar  (backslash right after tilde prevents expansion)
  def test_tilde_backslash_after_tilde
    omit 'tilde followed by backslash incorrectly expands HOME then appends'
    execute("HOME=/usr/xyz; echo ~\\chet/bar > #{outf}")
    assert_equal "~chet/bar\n", File.read(outf)
  end

  # echo ~chet""/bar  ->  ~chet/bar  (empty quoted string after username prevents expansion)
  def test_tilde_empty_string_suffix
    execute("echo ~chet\"\"/bar > #{outf}")
    assert_equal "~chet/bar\n", File.read(outf)
  end

  # echo "SHELL=~/bash"  ->  SHELL=~/bash  (whole string quoted, tilde not expanded)
  def test_quoted_string_with_tilde
    execute("HOME=/usr/xyz; echo \"SHELL=~/bash\" > #{outf}")
    assert_equal "SHELL=~/bash\n", File.read(outf)
  end

  # echo abcd:~chet  ->  abcd:~chet  (tilde not at start of word = no expansion)
  def test_tilde_after_colon_in_arg
    execute("echo abcd:~chet > #{outf}")
    assert_equal "abcd:~chet\n", File.read(outf)
  end

  # cd /usr; cd /tmp; echo ~-  ->  /usr  (OLDPWD expansion)
  def test_tilde_minus_oldpwd
    omit 'cd does not update OLDPWD correctly'
    execute("cd /usr; cd /tmp; echo ~- > #{outf}")
    assert_equal "/usr\n", File.read(outf)
  end

  # cd /usr; cd /tmp; echo ~+  ->  /tmp  (PWD expansion)
  def test_tilde_plus_pwd
    omit 'cd does not update PWD correctly'
    execute("cd /usr; cd /tmp; echo ~+ > #{outf}")
    assert_equal "/tmp\n", File.read(outf)
  end

  # PPATH="$XPATH:~/bin"; echo "$PPATH"  ->  /bin:/usr/bin:.:~/bin  (quoted = no expand)
  def test_tilde_in_quoted_assignment
    execute('HOME=/usr/xyz; XPATH=/bin:/usr/bin:.; PPATH="$XPATH:~/bin"; echo "$PPATH" > ' + outf)
    assert_equal "/bin:/usr/bin:.:~/bin\n", File.read(outf)
  end

  # declare -x PPATH=$XPATH:~/bin; echo "$PPATH"  ->  /bin:/usr/bin:.:/usr/xyz/bin
  def test_tilde_in_declare_x_unquoted
    omit 'tilde expansion in declare -x uses real HOME, not shell-local HOME'
    execute('HOME=/usr/xyz; XPATH=/bin:/usr/bin:.; declare -x PPATH=$XPATH:~/bin; echo "$PPATH" > ' + outf)
    assert_equal "/bin:/usr/bin:.:/usr/xyz/bin\n", File.read(outf)
  end

  # declare -x PPATH="$XPATH:~/bin"; echo "$PPATH"  ->  /bin:/usr/bin:.:~/bin  (quoted = no expand)
  def test_tilde_in_declare_x_quoted
    execute('HOME=/usr/xyz; XPATH=/bin:/usr/bin:.; declare -x PPATH="$XPATH:~/bin"; echo "$PPATH" > ' + outf)
    assert_equal "/bin:/usr/bin:.:~/bin\n", File.read(outf)
  end

  # printf "%q\n" '~'  ->  \~
  def test_printf_q_formats_tilde
    omit 'printf does not support %q format'
    execute("printf '%q\\n' '~' > #{outf}")
    assert_equal "\\~\n", File.read(outf)
  end

  # case ~ in ~) echo ok 2;;  ->  ok 2  (tilde in case pattern matches expanded ~)
  def test_tilde_in_case_pattern
    execute("HOME=/usr/xyz; case ~ in ~) echo 'ok 2' > #{outf};; \\~) echo 'bad 2a' > #{outf};; *) echo 'bad 2b' > #{outf};; esac")
    assert_equal "ok 2\n", File.read(outf)
  end

  # case $unset in "") echo ok 3;;  ->  ok 3  (unset var = empty string)
  def test_case_unset_var_empty
    execute("case \"$tilde_test_unset_var\" in \"\") echo 'ok 3' > #{outf};; *) echo 'bad 3' > #{outf};; esac")
    assert_equal "ok 3\n", File.read(outf)
  end

  # USER=root; echo ~$USER  ->  ~root  (tilde followed by $ = not expanded as username)
  def test_tilde_dollar_var_no_expand
    omit 'tilde followed by variable incorrectly expands HOME then appends var value'
    execute("USER=root; echo ~\\$USER > #{outf}")
    assert_equal "~root\n", File.read(outf)
  end

  # echo foo=bar:~  ->  foo=bar:/usr/xyz  (tilde in argument with = form expands outside posix)
  def test_tilde_in_assignment_like_arg
    omit 'tilde in echo arg does not use shell-local HOME'
    execute("HOME=/usr/xyz; echo foo=bar:~ > #{outf}")
    assert_equal "foo=bar:/usr/xyz\n", File.read(outf)
  end

  # set -o posix; echo foo=bar:~  ->  foo=bar:~  (posix mode: no tilde expansion in args)
  def test_tilde_posix_mode_no_expand_in_arg
    omit 'posix mode tilde suppression not yet supported'
    execute("HOME=/usr/xyz; set -o posix; echo foo=bar:~ > #{outf}")
    assert_equal "foo=bar:~\n", File.read(outf)
  end
end
