function sshrm -d "Remove host from ssh known hosts"
    set selected (cat ~/.ssh/known_hosts | cut -d ' ' -f1 | uniq | fzf-tmux -p -- -q "$argv[1]")
    test -n "$selected"; and ssh-keygen -R "$selected"
end
