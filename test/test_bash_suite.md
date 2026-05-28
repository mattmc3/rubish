# Bash Test Suite Coverage

Each file in `test/test_bash_suite_*.rb` corresponds to one or more files in
`.bash/tests/`. Tests that rubish does not yet support are marked with `omit`.

## Covered files

| Test file                    | Bash source                              | Tests | Omitted |
| ---------------------------- | ---------------------------------------- | ----- | ------- |
| Test file                    | Bash source                              | Tests | Omitted |
| ---------------------------- | ---------------------------------------- | ----- | ------- |
| test_bash_suite_appendop.rb  | appendop.tests                           | 19    | 13      |
| test_bash_suite_arith.rb     | arith.tests                              | 63    | 1       |
| test_bash_suite_arith_for.rb | arith-for.tests                          | 20    | 5       |
| test_bash_suite_array.rb     | array.tests                              | 47    | 26      |
| test_bash_suite_braces.rb    | braces.tests                             | 89    | 29      |
| test_bash_suite_builtins.rb  | builtins.tests                           | 46    | 12      |
| test_bash_suite_case.rb      | case.tests                               | 30    | 10      |
| test_bash_suite_comsub.rb    | comsub.tests                             | 25    | 6       |
| test_bash_suite_cond.rb      | cond.tests                               | 52    | 6       |
| test_bash_suite_exp.rb       | exp.tests, new-exp.tests, more-exp.tests | 110   | 20      |
| test_bash_suite_func.rb      | func.tests                               | 23    | 8       |
| test_bash_suite_heredoc.rb   | heredoc.tests, herestr.tests             | 35    | 7       |
| test_bash_suite_ifs.rb       | ifs.tests                                | 15    | 5       |
| test_bash_suite_invert.rb    | invert.tests                             | 6     | 0       |
| test_bash_suite_loops.rb     | (while/until, no direct bash file)       | 8     | 0       |
| test_bash_suite_nquote.rb    | nquote.tests                             | 18    | 3       |
| test_bash_suite_posixpat.rb  | posixpat.tests                           | 49    | 20      |
| test_bash_suite_posixpipe.rb | posixpipe.tests                          | 16    | 3       |
| test_bash_suite_printf.rb    | printf.tests                             | 132   | 31      |
| test_bash_suite_quote.rb     | quote.tests                              | 26    | 7       |
| test_bash_suite_read.rb      | read.tests                               | 22    | 10      |
| test_bash_suite_redir.rb     | redir.tests                              | 18    | 12      |
| test_bash_suite_strip.rb     | strip.tests                              | 10    | 1       |
| test_bash_suite_subshell.rb  | (subshell, no direct bash file)          | 6     | 1       |
| test_bash_suite_test.rb      | test.tests                               | 79    | 4       |
| test_bash_suite_tilde.rb     | tilde.tests                              | 25    | 14      |
| test_bash_suite_varenv.rb    | varenv.tests                             | 24    | 6       |

**Total: 1013 tests — 753 passing, 0 failing, 260 omitted (74% passing)**

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
| 1   | Posixpat bracket expressions (extglob, CTLESC, dangling backslash)                                  | 20        |
| 2   | Parameter expansion: var-as-pattern (`${x#$y}`), positional `${#}`, `${#N}`, `${N}` with braces   | 10        |
| 3   | Tilde expansion (all forms: `~`, `~/path`, `~+`, `~-`, `~user`, in assignment/export)              | 14        |
| 4   | Appendop: `typeset -i` arithmetic, array literal `+=`, command-local `+=` prefix                   | 13        |
| 5   | Builtins: eval double-expansion, `builtin`/`command` keyword, `declare -p`, alias format           | 12        |
| 6   | printf `'x` char-value notation for numeric formats (`%d`, `%o`, `%x`, `%f`)                       | 5         |
| 7   | printf `%b` precision/width truncation (like `%s` but after escape expansion)                       | 5         |
| 8   | Read builtin: IFS variants, file redirect, readonly-var error, trailing-space stripping             | 10        |
| 9   | printf format repetition when args exceed format slots                                              | 2         |
| 10  | Brace expansion edge cases (empty braces, lone `}`, escaped braces, var in list)                   | 6         |

## Common omit reasons

| Reason                                                        | Count |
| ------------------------------------------------------------- | ----- |
| tilde expansion not yet supported (all forms)                 | 14    |
| posixpat bracket/extglob/CTLESC patterns not handled          | 20    |
| appendop typeset -i arithmetic / array / command-prefix       | 13    |
| builtin/command keyword, eval double-expansion, declare -p    | 12    |
| read: IFS variants, file redirect, trailing-space, readonly   | 10    |
| param expansion: var-as-pattern, ${#}, ${#N}, ${N} with {}   | 10    |
| printf 'x char-value, %b precision, format repeat, octal fmt | 14    |
| quote/nquote: backslash-newline continuation, $'...' in dquot | 9     |
| heredoc: backslash-newline join, multiple heredocs, dquote    | 7     |
| brace expansion edge cases                                    | 6     |
| comsub edge cases (inline concat, backtick escapes, exit)     | 6     |
| IFS: typeset/env-prefix local IFS, eval split, posix mode    | 5     |
| case ;& / ;;& fallthrough not yet supported                   | 4     |
| subshell exit code not propagated to $?                       | 3     |
