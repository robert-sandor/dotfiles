#!/usr/bin/env bash

set -euo pipefail

err() { printf '%s\n' "$*" >&2; }

# Ensure dependencies exist
missing=0
for cmd in zoxide fzf tmux; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "sessionizer: missing dependency: $cmd"
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  exit 127
fi

# Build the candidate list from zoxide and select via fzf
if ! selection=$(zoxide query -i); then
  exit 0
fi

if [ -z "${selection}" ]; then
  exit 0
fi

dir=${selection}
if [ ! -d "$dir" ]; then
  err "sessionizer: chosen path does not exist: $dir"
  exit 1
fi

parent="${dir%/*}"                 # Get parent directory path
session="${parent##*/}/${dir##*/}" # Get basename of parent + basename of dir
session="${session//./_}"          # Replace all dots with underscores

# Check if session exists
if tmux has-session -t "$session" >/dev/null 2>&1; then
  if [ -n "${TMUX-}" ]; then
    tmux switch-client -t "$session"
  else
    exec tmux attach-session -t "$session"
  fi
else
  if [ -n "${TMUX-}" ]; then
    # Create detached session with working directory, then switch
    if ! tmux new-session -d -s "$session" -c "$dir"; then
      err "sessionizer: failed to create tmux session '$session'"
      exit 1
    fi
    tmux switch-client -t "$session"
  else
    exec tmux new-session -s "$session" -c "$dir"
  fi
fi
