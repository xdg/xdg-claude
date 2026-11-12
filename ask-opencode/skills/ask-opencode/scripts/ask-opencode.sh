#!/usr/bin/env bash
# Run headless opencode for a one-shot second opinion and print only its answer.
#
# Usage: ask-opencode.sh [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE
#        ask-opencode.sh -r MODEL     # resolve MODEL and print the full ID
#
# MODEL is a full `provider/model[#variant]` ID or a short name ("astra",
# "opus", "gpt-6-luna") matched against `opencode models`. A short name
# that matches zero or several IDs fails with exit 3 and lists candidates.
# EFFORT becomes the `#variant` suffix (e.g. high, max).
#
# Why a wrapper: `opencode run` uses the default "build" agent, which can
# edit files and run shell commands, and it saves every session. The
# wrapper injects a read-only agent, bounds the run with a timeout, prints
# only the final answer, and deletes the session afterward.
set -euo pipefail

usage="usage: $0 [-m MODEL] [-e EFFORT] [-t SECONDS] [-C DIR] PROMPT_FILE | $0 -r MODEL"

# Deny everything except reading inside the working directory. "question"
# is denied too: headless, nobody can answer it. grep stays allowed for
# utility, but opencode checks its permission against the search pattern,
# not the file, so it can still return .env contents; secrets_notice asks
# the reviewer not to. That is a request, not enforcement.
read_only_config='{"agent":{"ask-reviewer":{"mode":"primary",
  "description":"Read-only reviewer for one-shot second opinions",
  "permission":{"*":"deny","grep":"allow","glob":"allow","list":"allow",
    "read":{"*":"allow","*.env":"deny","*.env.*":"deny","*.env.example":"allow"}}}}}'

secrets_notice="Do not read or search .env files (.env, .env.*, *.env) or other files
that hold credentials. When you grep, set an include filter or a path that
leaves them out. .env.example is fine.

"

# Print the one model ID matching $1, or list candidates and exit 3.
resolve_model() {
  local name="$1" base variant=""
  case "$name" in */*) echo "$name"; return ;; esac
  base="${name%%#*}"
  [ "$base" != "$name" ] && variant="#${name#*#}"
  opencode models 2>/dev/null | perl -e '
    my ($want, $variant) = (lc shift, shift);
    $want =~ s/\s+/-/g;
    chomp(my @ids = <STDIN>);
    my @exact = grep { (split m{/}, lc)[-1] eq $want } @ids;
    my @sub   = grep { index(lc, $want) >= 0 } @ids;
    my @hits  = @exact == 1 ? @exact : @sub;
    if (@hits == 1) { print "$hits[0]$variant\n"; exit 0 }
    if (@hits) { print STDERR "model \"$want\" is ambiguous; candidates:\n", map("  $_\n", @hits) }
    else       { print STDERR "no model matches \"$want\"; run `opencode models` to list them\n" }
    exit 3;
  ' "$base" "$variant"
}

model=""
effort=""
timeout_secs=600
workdir="$PWD"
resolve_only=""
while getopts "m:e:t:C:r:" opt; do
  case "$opt" in
    m) model="$OPTARG" ;;
    e) effort="$OPTARG" ;;
    t) timeout_secs="$OPTARG" ;;
    C) workdir="$OPTARG" ;;
    r) resolve_only="$OPTARG" ;;
    *) echo "$usage" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))

command -v opencode >/dev/null || { echo "opencode CLI not found on PATH" >&2; exit 127; }

if [ -n "$resolve_only" ]; then
  resolve_model "$resolve_only"
  exit
fi

[ $# -eq 1 ] || { echo "$usage" >&2; exit 2; }
prompt_file="$1"
[ -r "$prompt_file" ] || { echo "cannot read prompt file: $prompt_file" >&2; exit 2; }

args=(run --standalone --agent ask-reviewer --format json)
if [ -n "$model" ]; then
  model="$(resolve_model "$model")"
  if [ -n "$effort" ]; then
    case "$model" in *'#'*) ;; *) model="$model#$effort" ;; esac
  fi
  args+=(-m "$model")
elif [ -n "$effort" ]; then
  echo "-e requires -m: the variant attaches to a model ID" >&2; exit 2
fi
args+=("$secrets_notice$(cat "$prompt_file")")

events="$(mktemp "${TMPDIR:-/tmp}/opencode-events.XXXXXX")"
stderr_log="$(mktemp "${TMPDIR:-/tmp}/opencode-stderr.XXXXXX")"
trap 'rm -f "$events" "$stderr_log"' EXIT

# --standalone: the background service would not see OPENCODE_CONFIG_CONTENT.
# macOS has no coreutils `timeout`; perl's alarm is everywhere.
set +e
(cd "$workdir" && OPENCODE_CONFIG_CONTENT="$read_only_config" \
  perl -e 'alarm shift; exec @ARGV' "$timeout_secs" opencode "${args[@]}") \
  </dev/null >"$events" 2>"$stderr_log"
status=$?
set -e

# Event stream: one JSON object per line. The answer is the text emitted
# after the last step_start; earlier steps narrate tool calls.
parsed="$(perl -MJSON::PP -e '
  my ($session, $error, @text);
  while (my $line = <STDIN>) {
    my $ev = eval { decode_json($line) } or next;
    $session //= $ev->{sessionID};
    if    ($ev->{type} eq "step_start") { @text = () }
    elsif ($ev->{type} eq "text")       { push @text, $ev->{part}{text} }
    elsif ($ev->{type} eq "error")      { $error = $ev->{error}{message} // encode_json($ev->{error}) }
  }
  print "SESSION\t", ($session // ""), "\n";
  print "ERROR\t$error\n" if defined $error;
  print "ANSWER\n", join("\n", @text) if @text;
' <"$events")"

session="$(printf '%s\n' "$parsed" | sed -n 's/^SESSION	//p')"
if [ -n "$session" ] &&
  ! (perl -e 'alarm shift; exec @ARGV' 30 opencode session delete "$session") >/dev/null 2>&1; then
  echo "warning: could not delete opencode session $session" >&2
fi

answer="$(printf '%s\n' "$parsed" | sed -n '/^ANSWER$/,$p' | sed '1d')"
error="$(printf '%s\n' "$parsed" | sed -n 's/^ERROR	//p')"
if [ $status -ne 0 ] || [ -n "$error" ] || [ -z "$answer" ]; then
  if [ $status -eq 142 ]; then # 128 + SIGALRM
    echo "opencode timed out after ${timeout_secs}s" >&2
  else
    echo "opencode exited $status without a complete answer" >&2
  fi
  [ -n "$error" ] && echo "error: $error" >&2
  [ -n "$answer" ] && printf 'partial output:\n%s\n' "$answer" >&2
  cat "$stderr_log" >&2
  exit $(( status ? status : 1 ))
fi
printf '%s\n' "$answer"
