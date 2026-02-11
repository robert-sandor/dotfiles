function dotfiles -d 'manage dotfiles'
  if not command -q chezmoi
    echo "missing chezmoi" >&2
  end

  if test -f "$argv[1]"
    chezmoi edit -a --watch "$argv[1]"
  else
    set file (chezmoi managed -i files | fzf -q "$argv[1]")
    test -n "$file"; and chezmoi edit -a --watch "~/$file"
  end
end
