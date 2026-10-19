function sshrm -d "Remove host from ssh known hosts"
    set -l selected (string split -f1 ' ' < ~/.ssh/known_hosts | string split ',' | sort -u | fzf-tmux -p -- -q "$argv[1]")
    test -n "$selected"; and ssh-keygen -R "$selected"
end
