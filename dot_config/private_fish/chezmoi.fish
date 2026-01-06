function dotfiles -d 'manage dotfiles'
    if test -f "$argv[1]"
        chezmoi edit -a --watch "$argv[1]"
    else
        set file (chezmoi managed -i files | fzf -q "$argv[1]")
        test -n "$file"; and chezmoi edit -a --watch "~/$file"
    end
end

function chezmoi_status -d 'gets status for chezmoi'
    if test -n "$(chezmoi status)"
        echo "chezmoi has changes"
    else
        echo "chezmoi is synced"
    end
end
