# Oils Compat Suite Status

**2656 tests · 568 pass (21%) · 2088 fail · 0 skip**
rubish master `819bdd8` + `fix_array_at_expansion` (via `just rebuild-main`) vs bash 5.3, 2026-06-06.

The `bats/oils/*.bats` files are converted from oils-for-unix spec tests. Each
runs the same command under `bash -c` and `rubish -c` and compares both exit
status and combined output. Unlike the curated `bats/bash` suite, these are raw
conversions, so two caveats apply when reading the numbers:

- **Error-prefix noise (unfixable):** any test whose only divergence is an error
  message inflates the fail count. bash says `bash: line N: foo: ...`; rubish
  says `rubish: foo: ...` (plus a `Did you mean?` suggestion). The program name
  differs by design, so these never match and no reasonable fix flips them.
- **oils-only tests:** some reference `$SH` (never set under bats) or use YSH
  syntax (`var x = ...`). Both shells fail them; not real rubish bugs.

Net: the real fixable signal is smaller than 2088. The ranking below is built
from sampled root causes, not raw counts.

## Progress

| Date       | rubish                       | Pass | Total | Pass% |
| ---------- | ---------------------------- | ---- | ----- | ----- |
| 2026-06-06 | master `819bdd8`             | 552  | 2656  | 20%   |
| 2026-06-06 | + `fix_array_at_expansion`   | 568  | 2656  | 21%   |

## Run

```bash
just rebuild-main          # master + fix branches + bats suite
git checkout main
just test oils             # parallel; writes bats/<timestamp>-oils.tap
# or per-file tally:
ls bats/oils/*.bats | parallel -j12 'f={}; o=$(bats --tap "$f"); \
  echo "$(basename "$f" .bats) $(grep -c "^ok " <<<"$o") $(grep -c "^not ok " <<<"$o")"'
```

## Top 5 rubish fixes (by value = tests addressed × ease)

Ranked by sampled root cause, weighting how many tests one fix unlocks against
how contained the fix is. Two of these are hard crashes that emit a full Ruby
backtrace (wrong exit code + huge stderr), so they fail every test in their path.

### 1. Arithmetic array-subscript assignment `(( a[i]=v ))` — CRASH

Files: `array-sparse` (0/40), much of `arith` (22/74), `arith-dynamic` (0/4),
parts of `array`. **Est ~50–70 tests.** Ease: **medium.**

The arithmetic evaluator substitutes the element's *value* on the left-hand side,
then evals invalid Ruby:

```bash
bash   -c '(( a[1] = 9 )); echo "${a[1]}"'   # 9
rubish -c '(( a[1] = 9 )); echo "${a[1]}"'   # SyntaxError: "2 = 9" (arithmetic.rb:209)
```

Fix: recognize a `name[index]` lvalue in the arith evaluator and route it to an
array-element assignment instead of feeding it to `Kernel.eval`. Localized to
`lib/rubish/arithmetic.rb`.

### 2. `2>&1` fd-duplication inside a pipeline — CRASH

Files: `redirect` (3/41), `redirect-command`, `redirect-multi`, `pipeline`, plus
any `cmd 2>&1 | …` across the suite. **Est ~20–40 tests.** Ease: **easy.**

```bash
bash   -c 'ls /nope 2>&1 | head -1'   # ls: /nope: No such file or directory
rubish -c 'ls /nope 2>&1 | head -1'   # IO#reopen: no implicit conversion of Symbol into String (command.rb:770)
```

`cmd.stderr` holds a symbol (the dup target) but `IO#reopen` gets it raw. Resolve
the dup target to the actual fd before reopen. Localized to
`lib/rubish/runtime/command.rb`.

### 3. `read` builtin: `-a` arrays and pipeline scope

Files: `builtin-read` (4/64). **Est ~30–50 tests.** Ease: **medium.**

```bash
bash   -c 'read -a a <<< "x y z"; echo "${a[1]}"'        # y
rubish -c 'read -a a <<< "x y z"; echo "${a[1]}"'        # (empty: -a never splits into the array)

bash   -c 'echo hi | { read x; echo "[$x]"; }'           # [hi]
rubish -c 'echo hi | { read x; echo "[$x]"; }'           # hi   (brackets lost in piped brace group)
```

Two causes: `read -a` does not populate the named array, and `read` in a piped
brace group mangles the surrounding quoting/scope.

### 4. Associative arrays (`declare -A`) non-functional

Files: `array-assoc` (1/42), parts of `assign-extended` (1/39), `builtin-vars`.
**Est ~40–50 tests.** Ease: **hard** (full feature, not a point fix).

```bash
bash   -c 'declare -A m=([a]=1 [b]=2); echo "${m[a]} ${#m[@]}"'   # 1 2
rubish -c 'declare -A m=([a]=1 [b]=2); echo "${m[a]} ${#m[@]}"'   # (empty)
```

`declare -A` is accepted but nothing is stored or retrieved. High raw count, but
needs real associative storage plus `${m[k]}`, `${!m[@]}`, `${m[@]}`, `${#m[@]}`,
so it ranks below the cheaper crashes despite the test count.

### 5. `&>` / `&>>` redirect parsing

Files: `redirect`, `redirect-command`. **Est ~10–20 tests.** Ease: **easy.**

```bash
bash   -c 'echo hi &> /tmp/x; cat /tmp/x'   # hi
rubish -c 'echo hi &> /tmp/x; cat /tmp/x'   # [1] 29515 / hi   (parsed as `&` background + `>`)
```

`&>` is tokenized as background-`&` followed by `>`. Teach the lexer/parser the
`&>` and `&>>` redirect operators. Localized to the lexer/parser.

## Per-file results (sorted by failures)

| File | Tests | Pass | Fail | Pass% |
| ---- | ----- | ---- | ---- | ----- |
| array                |   78 |   16 |   62 |  20% |
| builtin-read         |   64 |    4 |   60 |   6% |
| arith                |   74 |   22 |   52 |  29% |
| builtin-printf       |   63 |   15 |   48 |  23% |
| alias                |   48 |    2 |   46 |   4% |
| array-assoc          |   42 |    1 |   41 |   2% |
| array-sparse         |   40 |    0 |   40 |   0% |
| word-split           |   55 |   16 |   39 |  29% |
| redirect             |   41 |    3 |   38 |   7% |
| assign-extended      |   39 |    1 |   38 |   2% |
| builtin-completion   |   51 |   14 |   37 |  27% |
| vars-special         |   42 |    6 |   36 |  14% |
| sh-options           |   38 |    5 |   33 |  13% |
| errexit              |   35 |    2 |   33 |   5% |
| var-sub-quote        |   41 |    9 |   32 |  21% |
| errexit-osh          |   35 |    3 |   32 |   8% |
| brace-expansion      |   55 |   23 |   32 |  41% |
| here-doc             |   36 |    5 |   31 |  13% |
| builtin-trap         |   33 |    2 |   31 |   6% |
| assign               |   48 |   17 |   31 |  35% |
| var-ref              |   31 |    1 |   30 |   3% |
| dbracket             |   49 |   19 |   30 |  38% |
| builtin-bracket      |   52 |   22 |   30 |  42% |
| nameref              |   32 |    3 |   29 |   9% |
| var-op-test          |   37 |   10 |   27 |  27% |
| builtin-vars         |   41 |   15 |   26 |  36% |
| bugs                 |   29 |    3 |   26 |  10% |
| extglob-match        |   29 |    4 |   25 |  13% |
| command-sub          |   30 |    5 |   25 |  16% |
| builtin-getopts      |   31 |    6 |   25 |  19% |
| builtin-cd           |   30 |    5 |   25 |  16% |
| background           |   27 |    2 |   25 |   7% |
| regex                |   37 |   13 |   24 |  35% |
| parse-errors         |   27 |    3 |   24 |  11% |
| sh-usage             |   24 |    1 |   23 |   4% |
| var-op-bash          |   27 |    5 |   22 |  18% |
| extglob-files        |   23 |    1 |   22 |   4% |
| builtin-process      |   26 |    4 |   22 |  15% |
| var-op-slice         |   22 |    1 |   21 |   4% |
| prompt               |   33 |   12 |   21 |  36% |
| glob                 |   39 |   18 |   21 |  46% |
| builtin-trap-err     |   23 |    2 |   21 |   8% |
| builtin-trap-bash    |   23 |    2 |   21 |   8% |
| xtrace               |   19 |    0 |   19 |   0% |
| var-op-strip         |   29 |   10 |   19 |  34% |
| var-op-patsub        |   28 |    9 |   19 |  32% |
| redirect-command     |   23 |    4 |   19 |  17% |
| builtin-eval-source  |   23 |    4 |   19 |  17% |
| array-literal        |   19 |    0 |   19 |   0% |
| pipeline             |   26 |    8 |   18 |  30% |
| loop                 |   29 |   11 |   18 |  37% |
| globignore           |   18 |    0 |   18 |   0% |
| builtin-umask        |   24 |    6 |   18 |  25% |
| builtin-kill         |   20 |    2 |   18 |  10% |
| builtin-type-bash    |   31 |   14 |   17 |  45% |
| builtin-history      |   17 |    0 |   17 |   0% |
| builtin-dirs         |   18 |    1 |   17 |   5% |
| strict-options       |   17 |    1 |   16 |   5% |
| builtin-set          |   24 |    8 |   16 |  33% |
| builtin-meta         |   18 |    2 |   16 |  11% |
| command_             |   16 |    1 |   15 |   6% |
| append               |   20 |    5 |   15 |  25% |
| nul-bytes            |   16 |    2 |   14 |  12% |
| builtin-echo         |   27 |   13 |   14 |  48% |
| builtin-bash         |   13 |    0 |   13 |   0% |
| arith-context        |   16 |    3 |   13 |  18% |
| shell-grammar        |   38 |   26 |   12 |  68% |
| quote                |   33 |   21 |   12 |  63% |
| introspect           |   13 |    1 |   12 |   7% |
| builtin-special      |   12 |    0 |   12 |   0% |
| builtin-fc           |   14 |    2 |   12 |  14% |
| array-compat         |   12 |    0 |   12 |   0% |
| redirect-multi       |   13 |    2 |   11 |  15% |
| exit-status          |   11 |    0 |   11 |   0% |
| array-assign         |   11 |    0 |   11 |   0% |
| serialize            |   10 |    0 |   10 |   0% |
| dparen               |   15 |    5 |   10 |  33% |
| tilde                |   14 |    5 |    9 |  35% |
| process-sub          |    9 |    0 |    9 |   0% |
| func-parsing         |   12 |    3 |    9 |  25% |
| case_                |   13 |    4 |    9 |  30% |
| builtin-meta-assign  |   11 |    2 |    9 |  18% |
| builtin-bind         |    9 |    0 |    9 |   0% |
| sh-options-bash      |    9 |    1 |    8 |  11% |
| posix                |   15 |    7 |    8 |  46% |
| assign-deferred      |    9 |    1 |    8 |  11% |
| var-num              |    7 |    0 |    7 |   0% |
| unicode              |    7 |    0 |    7 |   0% |
| paren-ambiguity      |    9 |    2 |    7 |  22% |
| glob-bash            |    8 |    1 |    7 |  12% |
| word-eval            |    8 |    2 |    6 |  25% |
| var-sub              |    6 |    0 |    6 |   0% |
| var-op-len           |    9 |    3 |    6 |  33% |
| type-compat          |    7 |    1 |    6 |  14% |
| builtin-misc         |    7 |    1 |    6 |  14% |
| whitespace           |    5 |    0 |    5 |   0% |
| sh-func              |   12 |    7 |    5 |  58% |
| if_                  |    5 |    0 |    5 |   0% |
| for-expr             |    9 |    4 |    5 |  44% |
| fatal-errors         |    5 |    0 |    5 |   0% |
| bool-parse           |    8 |    3 |    5 |  37% |
| temp-binding         |    4 |    0 |    4 |   0% |
| smoke                |   18 |   14 |    4 |  77% |
| print-source-code    |    4 |    0 |    4 |   0% |
| explore-parsing      |    5 |    1 |    4 |  20% |
| command-parsing      |    5 |    1 |    4 |  20% |
| builtin-type         |    6 |    2 |    4 |  33% |
| arith-dynamic        |    4 |    0 |    4 |   0% |
| empty-bodies         |    3 |    0 |    3 |   0% |
| divergence           |    4 |    1 |    3 |  25% |
| assign-dialects      |    4 |    1 |    3 |  25% |
| zsh-idioms           |    3 |    1 |    2 |  33% |
| nocasematch-match    |    6 |    4 |    2 |  66% |
| let                  |    2 |    0 |    2 |   0% |
| known-differences    |    2 |    0 |    2 |   0% |
| globstar             |    5 |    3 |    2 |  60% |
| arg-parse            |    3 |    1 |    2 |  33% |
| vars-bash            |    1 |    0 |    1 |   0% |
| subshell             |    2 |    1 |    1 |  50% |
| shell-bugs           |    1 |    0 |    1 |   0% |
| array-basic          |    5 |    4 |    1 |  80% |
| comments             |    2 |    2 |    0 | 100% |
| builtin-times        |    1 |    1 |    0 | 100% |
| **TOTAL** | **2656** | **568** | **2088** | **21%** |
