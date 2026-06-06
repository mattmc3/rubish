# Bash Compat Suite Status

**965 tests · 782 pass (81%) · 183 fail · 0 skip**
rubish master `819bdd8` vs bash 5.3, 2026-06-06.

The `bats/bash/*.bats` files run real bash-vs-rubish comparisons: each test runs
the same command under `bash -c` and `rubish -c` and asserts the output matches.
No omits, every case runs and either passes or fails, so this is the
ground-truth measure of rubish's bash compatibility.

## Progress

| Date       | Pass | Total | Pass% |
| ---------- | ---- | ----- | ----- |
| 2026-06-05 | 689  | 965   | 71%   |
| 2026-06-06 | 782  | 965   | 81%   |

## Run

```bash
just test bash          # parallel; writes bats/<timestamp>-bash.tap
# or directly:
LC_ALL=C bats --jobs 12 --tap bats/bash/*.bats
```

## Per-file results

| Domain    | Tests | Pass | Fail | Pass% |
| --------- | ----- | ---- | ---- | ----- |
| strip     | 10    | 10   | 0    | 100%  |
| invert    | 6     | 6    | 0    | 100%  |
| loops     | 7     | 7    | 0    | 100%  |
| arith     | 61    | 60   | 1    | 98%   |
| posixpat  | 49    | 48   | 1    | 98%   |
| cond      | 52    | 50   | 2    | 96%   |
| nquote    | 18    | 17   | 1    | 94%   |
| posixpipe | 16    | 15   | 1    | 94%   |
| printf    | 132   | 122  | 10   | 92%   |
| test      | 64    | 59   | 5    | 92%   |
| builtins  | 40    | 36   | 4    | 90%   |
| exp       | 110   | 92   | 18   | 84%   |
| varenv    | 24    | 20   | 4    | 83%   |
| subshell  | 6     | 5    | 1    | 83%   |
| quote     | 24    | 19   | 5    | 79%   |
| tilde     | 22    | 17   | 5    | 77%   |
| arith_for | 20    | 15   | 5    | 75%   |
| braces    | 89    | 65   | 24   | 73%   |
| ifs       | 14    | 10   | 4    | 71%   |
| comsub    | 25    | 17   | 8    | 68%   |
| redir     | 6     | 4    | 2    | 67%   |
| heredoc   | 34    | 22   | 12   | 65%   |
| func      | 22    | 13   | 9    | 59%   |
| array     | 47    | 22   | 25   | 47%   |
| case      | 30    | 14   | 16   | 47%   |
| appendop  | 19    | 9    | 10   | 47%   |
| read      | 18    | 8    | 10   | 44%   |
| **TOTAL** | 965   | 782  | 183  | 81%   |

## Biggest opportunities (by failures)

| Domain   | Fails | Area                                                       |
| -------- | ----- | ---------------------------------------------------------- |
| array    | 25    | indexed compound assignment, slices, scalar/array coercion |
| braces   | 24    | invalid/edge brace forms, nested or var-in-list            |
| exp      | 18    | parameter-expansion edge cases                             |
| case     | 16    | `;&` / `;;&` fallthrough, reserved-word patterns           |
| heredoc  | 12    | multiple heredocs, quoted-delimiter edges                  |
| appendop | 10    | `+=` with export/readonly/integer/array                    |
| read     | 10    | IFS variants, `-r`, file redirect                          |
| printf   | 10    | format cycling, `%b` precision, numeric base               |
