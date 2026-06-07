#!/usr/bin/env bash
# Runs SUITE (one or more .bats globs) in parallel, one process per file, each
# bounded by FILE_TIMEOUT so a runaway test can't stall the whole run. Writes a
# timestamped TAP plus a one-line summary to OUT_DIR. Used by Dockerfile.oils.
set -u
ulimit -u "$(ulimit -Hu)" 2>/dev/null || true

ts=$(date +%Y-%m-%dT%H-%M-%S)
tap="$OUT_DIR/${ts}-oils.tap"

# Per-file TAPs are scratch: keep them on the container's own disk, not the
# mounted OUT_DIR, and always clean them up (even on crash) so nothing leaks
# onto the host. Only the merged $tap is written to OUT_DIR.
parts=$(mktemp -d)
trap 'rm -rf "$parts"' EXIT

run_file() {
  local f="$1" b
  b=$(basename "$f" .bats)
  LC_ALL=C timeout "$FILE_TIMEOUT" bats --tap "$f" > "$parts/$b.tap" 2>&1 \
    || echo "not ok TIMEOUT_OR_ERR $b (exit $?)" >> "$parts/$b.tap"
}
export -f run_file
export parts FILE_TIMEOUT

ls $SUITE | xargs -P "$PJOBS" -I{} bash -c 'run_file "$@"' _ {}

cat "$parts"/*.tap > "$tap"

ok=$(grep -c '^ok ' "$tap")
sk=$(grep -c '# skip' "$tap")
nf=$(grep -c '^not ok ' "$tap")
echo "SUMMARY pass=$((ok - sk)) skipped=$sk fail=$nf  ->  $tap"
