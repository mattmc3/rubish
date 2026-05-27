# Bash Test Suite Coverage

Each file in `test/test_bash_suite_*.rb` corresponds to one or more files in
`.bash/tests/`. Tests that rubish does not yet support are marked with `omit`.

## Covered files

| Test file                    | Bash source                              | Tests | Omitted |
| ---------------------------- | ---------------------------------------- | ----- | ------- |
| test_bash_suite_appendop.rb  | appendop.tests                           | 4     | 1       |
| test_bash_suite_arith.rb     | arith.tests                              | 63    | 1       |
| test_bash_suite_arith_for.rb | arith-for.tests                          | 10    | 0       |
| test_bash_suite_array.rb     | array.tests                              | 10    | 2       |
| test_bash_suite_braces.rb    | braces.tests                             | 24    | 6       |
| test_bash_suite_builtins.rb  | builtins.tests                           | 13    | 1       |
| test_bash_suite_case.rb      | case.tests                               | 16    | 4       |
| test_bash_suite_comsub.rb    | comsub.tests                             | 10    | 1       |
| test_bash_suite_cond.rb      | cond.tests                               | 23    | 1       |
| test_bash_suite_exp.rb       | exp.tests, new-exp.tests, more-exp.tests | 63    | 4       |
| test_bash_suite_func.rb      | func.tests                               | 12    | 0       |
| test_bash_suite_heredoc.rb   | heredoc.tests, herestr.tests             | 10    | 0       |
| test_bash_suite_ifs.rb       | ifs.tests                                | 5     | 0       |
| test_bash_suite_invert.rb    | invert.tests                             | 6     | 0       |
| test_bash_suite_loops.rb     | (while/until, no direct bash file)       | 8     | 0       |
| test_bash_suite_nquote.rb    | nquote.tests                             | 8     | 0       |
| test_bash_suite_posixpat.rb  | posixpat.tests                           | 15    | 0       |
| test_bash_suite_posixpipe.rb | posixpipe.tests                          | 7     | 1       |
| test_bash_suite_printf.rb    | printf.tests                             | 20    | 0       |
| test_bash_suite_quote.rb     | quote.tests                              | 10    | 1       |
| test_bash_suite_read.rb      | read.tests                               | 8     | 4       |
| test_bash_suite_redir.rb     | redir.tests                              | 8     | 3       |
| test_bash_suite_strip.rb     | strip.tests                              | 10    | 1       |
| test_bash_suite_subshell.rb  | (subshell, no direct bash file)          | 6     | 1       |
| test_bash_suite_test.rb      | test.tests                               | 48    | 1       |
| test_bash_suite_tilde.rb     | tilde.tests                              | 8     | 5       |
| test_bash_suite_varenv.rb    | varenv.tests                             | 13    | 0       |

**Total: 438 tests — 400 passing, 0 failing, 38 omitted (91% passing)**

## Not yet covered — practical to add

These bash test files have not been converted yet but contain tests that are
tractable to write (not blocked by job control, history, completion, etc.).

| Bash source                   | Notes                                                 |
| ----------------------------- | ----------------------------------------------------- |
| alias.tests                   | basic alias/unalias; most content spawns sub-scripts  |
| assoc.tests                   | associative arrays (declare -A)                       |
| attr.tests                    | declare/typeset attributes (-i, -r, -x, -l, -u)       |
| casemod.tests                 | case-mod with char classes (^[aeiou] etc.) on arrays  |
| comsub2.tests                 | more command substitution edge cases                  |
| comsub-eof.tests              | command substitution with EOF handling                |
| comsub-posix.tests            | POSIX command substitution behavior                   |
| errors.tests                  | error conditions and messages                         |
| extglob.tests                 | extended globbing ?(pat) \*(pat) +(pat) @(pat) !(pat) |
| extglob2.tests                | more extglob                                          |
| extglob3.tests                | more extglob                                          |
| getopts.tests                 | getopts builtin                                       |
| glob.tests                    | filename globbing                                     |
| glob-bracket.tests            | bracket expressions in globs                          |
| globstar.tests                | \*\* globbing (shopt -s globstar)                     |
| ifs-posix.tests               | IFS POSIX behavior                                    |
| nameref.tests                 | declare -n namerefs                                   |
| nquote1.tests - nquote5.tests | $'...' and $"..." quoting sub-scripts                 |
| parser.tests                  | parser edge cases                                     |
| posix2.tests                  | POSIX compliance tests                                |
| posixexp.tests                | POSIX parameter expansion (uses recho helper)         |
| posixexp2.tests               | more POSIX parameter expansion                        |
| precedence.tests              | && and \|\| operator precedence                       |
| quotearray.tests              | quoting in array contexts                             |
| rhs-exp.tests                 | RHS parameter expansion                               |
| set-e.tests                   | set -e (errexit) behavior                             |
| set-x.tests                   | set -x (xtrace) behavior                              |
| shopt.tests                   | shopt options                                         |
| tilde2.tests                  | more tilde expansion cases                            |
| trap.tests                    | trap builtin                                          |
| type.tests                    | type builtin                                          |
| vredir.tests                  | variable-based redirections ({var}>>file)             |

## Not worth targeting

These cover bash features rubish will not implement:

- complete.tests — readline completion
- coproc.tests — coprocesses
- cprint.tests — locale-specific printing
- dbg-support.tests / dbg-support2.tests — debugger support
- dstack.tests / dstack2.tests — pushd/popd directory stack
- dynvar.tests — dynamic scoping variables
- exportfunc.tests — exported functions
- histexp.tests — history expansion (!!)
- history.tests — history list management
- intl.tests — internationalization / locale
- invocation.tests — shell invocation flags
- iquote.tests — locale quoting ($"...")
- jobs.tests — job control
- lastpipe.tests — lastpipe shopt
- mapfile.tests — mapfile/readarray
- procsub.tests — process substitution <() >()
- rsh.tests — restricted shell mode

## Top 10 features to fix (by omissions unblocked)

| #   | Feature                                                                                             | Omissions |
| --- | --------------------------------------------------------------------------------------------------- | --------- |
| 1   | Brace expansion edge cases (empty braces, lone `}`, escaped braces, var in list)                   | 6         |
| 2   | Tilde expansion (`~`, `~/path`, `~` in assignment, `~` in export)                                  | 5         |
| 3   | Case statement edge cases (`;& ` fallthrough, `;;& ` continue, reserved word pattern)              | 4         |
| 4   | Read from file redirect (`read x < file`)                                                           | 3         |
| 5   | Stderr and fd redirect (`>&2`, `2>&1`)                                                              | 3         |
| 6   | Subshell exit code propagated to `$?`                                                               | 2         |

## Common omit reasons

| Reason                                             | Count |
| -------------------------------------------------- | ----- |
| tilde expansion not yet supported (all forms)      | 5     |
| read from file redirect not yet working            | 3     |
| stderr redirect >&2 / fd dup 2>&1 not yet working  | 3     |
| subshell exit code not propagated to $?            | 2     |
| case ;& / ;;& fallthrough not yet supported        | 2     |
| (()) null expression not yet supported             | 1     |
| ${a[@]} expansion in for loop not yet working      | 1     |
| ${a[@]:offset:len} array slice not yet supported   | 1     |
| negative offset in ${x: -N:L} not yet supported    | 1     |
| IFS= read not yet working                          | 1     |
