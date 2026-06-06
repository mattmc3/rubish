# Run a bats bash-compat suite in parallel and snapshot TAP to bats/results/.
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
    mkdir -p bats/results
    out="bats/results/$(date +%Y-%m-%dT%H-%M-%S)-{{suite}}.tap"
    LC_ALL=C bats --jobs {{jobs}} --tap "${files[@]}" | tee "$out"
    echo "wrote $out"
