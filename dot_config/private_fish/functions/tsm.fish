# tmux session manager using zoxide + fzf
# Usage: tsm
# - Lists directories from zoxide
# - Pick one with fzf
# - Creates or switches to a tmux session rooted at that directory

function tsm
    # Ensure dependencies exist
    for cmd in zoxide fzf tmux
        if not command -qs $cmd
            echo (set_color red)"tsm: missing dependency: $cmd"(set_color normal)
            return 127
        end
    end

    # Build the candidate list from zoxide
    # Use `zoxide query -l` to list all known directories (by frecency)
    set -l selection (zoxide query -l | fzf --height 60% --reverse --prompt "zoxide> " --tiebreak=begin,index)
    if test -z "$selection"
        return 0
    end

    set -l dir $selection
    if not test -d "$dir"
        echo (set_color red)"tsm: chosen path does not exist: $dir"(set_color normal)
        return 1
    end

    # Derive a stable, mostly human-friendly tmux session name from the path
    set -l base (basename "$dir")
    # Sanitize base to be tmux-friendly: replace non-alphanum with dashes, lowercase
    set -l base (string lower -- $base | string replace -ra "[^a-z0-9._-]" "-")

    # Compute a short, stable suffix from the full path for uniqueness
    set -l hash ""
    if command -qs md5
        set hash (md5 -qs "$dir" | string sub -l 6)
    else if command -qs shasum
        set hash (echo -n "$dir" | shasum -a 1 | awk '{print $1}' | string sub -l 6)
    else
        # Fallback: sanitize path itself (less collision-resistant)
        set hash (string replace -a "/" "-" -- "$dir" | string sub -l 6)
    end
    set -l session "$base-$hash"

    # Helper: does session exist?
    tmux has-session -t "$session" >/dev/null 2>&1
    set -l exists $status

    # If inside tmux, switch client; else attach/new
    if set -q TMUX
        if test $exists -eq 0
            tmux switch-client -t "$session"
        else
            # Create detached session with working directory, then switch
            tmux new-session -d -s "$session" -c "$dir"
            if test $status -ne 0
                echo (set_color red)"tsm: failed to create tmux session '$session'"(set_color normal)
                return 1
            end
            tmux switch-client -t "$session"
        end
    else
        if test $exists -eq 0
            exec tmux attach-session -t "$session"
        else
            exec tmux new-session -s "$session" -c "$dir"
        end
    end
end
