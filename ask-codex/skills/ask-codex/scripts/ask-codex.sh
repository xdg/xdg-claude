#!/usr/bin/env bash
# Run headless codex for a one-shot second opinion and print only its answer.
#
# Usage: ask-codex.sh [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE
#
# Why a wrapper: `codex exec` reads stdin whenever it is not a TTY and
# blocks until EOF, so an agent that forgets `</dev/null` hangs forever.
# The wrapper closes stdin, runs read-only and ephemeral, bounds the run
# with a timeout, and keeps codex's banner (stderr) out of the answer.
set -euo pipefail

model=""
effort=""
timeout_secs=600
workdir="$PWD"
while getopts "m:e:t:C:" opt; do
  case "$opt" in
    m) model="$OPTARG" ;;
    e) effort="$OPTARG" ;;
    t) timeout_secs="$OPTARG" ;;
    C) workdir="$OPTARG" ;;
    *) echo "usage: $0 [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] || { echo "usage: $0 [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE" >&2; exit 2; }
prompt_file="$1"
[ -r "$prompt_file" ] || { echo "cannot read prompt file: $prompt_file" >&2; exit 2; }

command -v codex >/dev/null || { echo "codex CLI not found on PATH" >&2; exit 127; }

answer="$(mktemp -t codex-answer)"
stderr_log="$(mktemp -t codex-stderr)"
trap 'rm -f "$answer" "$stderr_log"' EXIT

args=(exec --skip-git-repo-check --ephemeral -s read-only --color never -C "$workdir" -o "$answer")
[ -n "$model" ] && args+=(-m "$model")
[ -n "$effort" ] && args+=(-c "model_reasoning_effort=$effort")
args+=("$(cat "$prompt_file")")

# macOS has no coreutils `timeout`; perl's alarm is everywhere.
set +e
perl -e 'alarm shift; exec @ARGV' "$timeout_secs" codex "${args[@]}" </dev/null >/dev/null 2>"$stderr_log"
status=$?
set -e

if [ $status -ne 0 ] || [ ! -s "$answer" ]; then
  echo "codex exited $status with no answer; stderr follows:" >&2
  cat "$stderr_log" >&2
  exit "$status"
fi
cat "$answer"
