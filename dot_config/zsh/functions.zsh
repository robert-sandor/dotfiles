dotfiles() {
  if ! command -v chezmoi >/dev/null 2>&1; then
    echo "missing chezmoi" >&2
  fi

  if [[ -f "$1" ]]; then
    chezmoi edit -a --watch "$1"
  else
    local file
    file=$(chezmoi managed -i files | fzf -q "$1")
    [[ -n "$file" ]] && chezmoi edit -a --watch "$HOME/$file"
  fi
}

sshrm() {
  local selected
  selected=$(cut -d ' ' -f1 ~/.ssh/known_hosts | uniq | fzf-tmux -p -- -q "$1")
  [[ -n "$selected" ]] && ssh-keygen -R "$selected"
}
