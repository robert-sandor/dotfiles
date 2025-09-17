#!/usr/bin/env bash

tmux list-sessions -F "#S" |
  grep -v \"^"$(tmux display-message -p '#S')"\$\" |
  fzf --reverse --ghost="Session name" --height=10 --border --border=rounded --border-label=" Switch Tmux Session " --color=label:italic:black |
  xargs tmux switch-client -t
