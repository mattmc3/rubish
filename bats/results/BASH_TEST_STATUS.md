# Bash Compat Suite — Status

The `bats/test_bash_suite_*.bats` files run real bash-vs-rubish comparisons:
each test runs the same command under `bash -c` and `rubish -c` and asserts the
output matches. No omits — every case runs and either passes or fails, so this
is the ground-truth measure of rubish's bash compatibility.

## Run

```bash
# serial
LC_ALL=C bats --tap bats/*.bats

# parallel (needs GNU parallel; ~4x faster)
LC_ALL=C bats --jobs 12 --tap bats/*.bats
```

Snapshot the result to `bats/results/<timestamp>.tap`, e.g.

```bash
LC_ALL=C bats --jobs 12 --tap bats/*.bats > "bats/results/$(date +%Y-%m-%dT%H-%M-%S).tap"
```

## Latest result — 2026-06-05 (rubish master @ c5ad4d5, bash 5.3)

**965 tests — 689 passing, 276 failing (71% pass)**

| Domain    | Tests | Pass | Fail | Pass% |
| --------- | ----- | ---- | ---- | ----- |
| arith     | 61    | 60   | 1    | 98%   |
| cond      | 52    | 50   | 2    | 96%   |
| test      | 64    | 59   | 5    | 92%   |
| builtins  | 40    | 36   | 4    | 90%   |
| posixpipe | 16    | 14   | 2    | 88%   |
| printf    | 132   | 114  | 18   | 86%   |
| varenv    | 24    | 20   | 4    | 83%   |
| subshell  | 6     | 5    | 1    | 83%   |
| arith_for | 20    | 15   | 5    | 75%   |
| exp       | 110   | 81   | 29   | 74%   |
| posixpat  | 49    | 36   | 13   | 73%   |
| braces    | 89    | 64   | 25   | 72%   |
| redir     | 6     | 4    | 2    | 67%   |
| tilde     | 22    | 14   | 8    | 64%   |
| ifs       | 14    | 8    | 6    | 57%   |
| comsub    | 25    | 13   | 12   | 52%   |
| func      | 22    | 11   | 11   | 50%   |
| nquote    | 18    | 9    | 9    | 50%   |
| array     | 47    | 22   | 25   | 47%   |
| case      | 30    | 14   | 16   | 47%   |
| appendop  | 19    | 9    | 10   | 47%   |
| quote     | 24    | 10   | 14   | 42%   |
| heredoc   | 34    | 8    | 26   | 24%   |
| read      | 18    | 0    | 18   | 0%    |
| strip     | 10    | 0    | 10   | 0%    |
| loops     | 7     | 7    | 0    | 100%  |
| invert    | 6     | 6    | 0    | 100%  |
| **TOTAL** | 965   | 689  | 276  | 71%   |

## Biggest wins (already strong)

- **arith / cond / test** (98 / 96 / 92%) — arithmetic, `[[ ]]`, and `test`/`[`
  are nearly complete.
- **builtins, printf, posixpipe** (90 / 86 / 88%) — core builtins and printf
  are in good shape (remaining printf gaps tracked separately).

## Biggest opportunities (ranked by failures)

| Rank | Domain   | Fails | What's missing                                                                  |
| ---- | -------- | ----- | ------------------------------------------------------------------------------- |
| 1    | exp      | 29    | parameter-expansion edge cases (`${x#$y}`, `${#N}`, nested `${}`, array slices) |
| 2    | heredoc  | 26    | backslash-newline joining, multiple heredocs, quoted delimiters/body (24% pass) |
| 3    | array    | 25    | indexed compound assignment, slices, scalar↔array coercion                      |
| 4    | braces   | 25    | invalid/edge brace forms, escaped commas, var-in-list, nested                   |
| 5    | printf   | 18    | format cycling, `%b` precision, numeric base prefixes, `%q` style               |
| 5    | read     | 18    | **entire `read` builtin failing (0%)** — IFS, `-r`, file redirect               |
| 7    | case     | 16    | `;&` / `;;&` fallthrough, reserved-word patterns                                |
| 8    | quote    | 14    | backslash-newline continuation, `$'...'` in double quotes                       |
| 9    | posixpat | 13    | collating `[.x.]` / equivalence `[=x=]` (PR #42 pending), CTLESC                |

### Highest-leverage targets

- **`read` (0%) and `strip` (0%)** are completely failing — likely one root
  cause each; fixing either unblocks a whole domain cheaply.
- **`heredoc` (24%)** — backslash-newline handling is the common thread across
  most of its 26 failures.
- **`exp` (29 fails)** is the single largest bucket; parameter-expansion edge
  cases.
