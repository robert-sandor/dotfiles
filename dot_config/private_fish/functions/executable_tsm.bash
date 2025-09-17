#!/usr/bin/env bash
set -euo pipefail

# tmux session manager using zoxide + fzf (Bash)
# Usage: tsm.bash
# - Lists directories from zoxide
# - Pick one with fzf
# - Creates or switches to a tmux session rooted at that directory

err() { printf '%s\n' "$*" >&2; }

need() {
  command -v "$1" >/dev/null 2>&1
}

# Ensure dependencies exist
missing=0
for cmd in zoxide fzf tmux; do
  if ! need "$cmd"; then
    err "tsm: missing dependency: $cmd"
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  exit 127
fi

# Build the candidate list from zoxide and select via fzf
if ! selection=$(zoxide query -l 2>/dev/null | fzf --height 60% --reverse --prompt "zoxide> " --tiebreak=begin,index); then
  # User canceled or no selection
  exit 0
fi

if [ -z "${selection}" ]; then
  exit 0
fi

dir=${selection}
if [ ! -d "$dir" ]; then
  err "tsm: chosen path does not exist: $dir"
  exit 1
fi

# Derive a stable, mostly human-friendly tmux session name from the path
base=$(basename -- "$dir")
# sanitize base: lowercase and replace non-alphanum (except . _ -) with dashes
base=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]/-/g')

# Compute a short, stable suffix from the full path for uniqueness (6 chars)
hash=""
if command -v md5 >/dev/null 2>&1; then
  hash=$(md5 -qs "$dir" | cut -c1-6)
elif command -v shasum >/dev/null 2>&1; then
  hash=$(printf '%s' "$dir" | shasum -a 1 | awk '{print $1}' | cut -c1-6)
else
  # Fallback: sanitize path itself (less collision-resistant)
  hash=$(printf '%s' "$dir" | sed 's|/|-|g' | cut -c1-6)
fi
session="${base}-${hash}"

# Check if session exists
if tmux has-session -t "$session" >/dev/null 2>&1; then
  exists=0
else
  exists=1
fi

# If inside tmux, switch client; else attach/new
if [ -n "${TMUX-}" ]; then
  if [ $exists -eq 0 ]; then
    tmux switch-client -t "$session"
  else
    # Create detached session with working directory, then switch
    if ! tmux new-session -d -s "$session" -c "$dir"; then
      err "tsm: failed to create tmux session '$session'"
      exit 1
    fi
    tmux switch-client -t "$session"
  fi
else
  if [ $exists -eq 0 ]; then
    exec tmux attach-session -t "$session"
  else
    exec tmux new-session -s "$session" -c "$dir"
  fi
fi
