# Branch holding the bats test suite (tests only, no lib changes).
bats_branch := "test_bash_compat_using_bats"

# Refuses on a dirty tree. On conflict it names the branch and aborts so
# you can exclude that fix or resolve the interaction on its own branch.
# Rebuild main: master + all fix_* branches + bats suite. Disposable.
rebuild-main:
    #!/usr/bin/env bash
    set -eo pipefail
    if [ -n "$(git status --porcelain)" ]; then
      echo "working tree dirty; commit or stash first" >&2; exit 1
    fi
    git checkout -B main master
    branches="$(git for-each-ref --format='%(refname:short)' 'refs/heads/fix_*') {{bats_branch}}"
    for b in $branches; do
      echo ">> merging $b"
      if ! git merge --no-edit "$b"; then
        git merge --abort
        echo "CONFLICT on $b -- exclude it or fix the interaction on its branch, then rerun" >&2
        exit 1
      fi
    done
    n="$(git for-each-ref 'refs/heads/fix_*' | wc -l | tr -d ' ')"
    echo "main rebuilt: master + $n fix branch(es) + {{bats_branch}}"

# Run a bats bash-compat suite in parallel and snapshot the TAP to bats/.
# suite: bash | oils | all (default). Needs bats-core and GNU parallel.
test suite="all" jobs="12":
    #!/usr/bin/env bash
    set -uo pipefail
    case "{{suite}}" in
      bash) files=(bats/bash/*.bats) ;;
      oils) files=(bats/oils/*.bats) ;;
      all)  files=(bats/bash/*.bats bats/oils/*.bats) ;;
      *) echo "unknown suite '{{suite}}' (use: bash | oils | all)" >&2; exit 2 ;;
    esac
    out="bats/$(date +%Y-%m-%dT%H-%M-%S)-{{suite}}.tap"
    LC_ALL=C bats --jobs {{jobs}} --tap "${files[@]}" | tee "$out"
    echo "wrote $out"
