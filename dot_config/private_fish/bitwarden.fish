function bw-unlock -d 'Unlock Bitwarden CLI'
    if not test -n "$BW_SESSION"
        set -l session (bw unlock --raw)
        if test -n "$session"
            set -gx BW_SESSION $session
            echo "Bitwarden CLI unlocked."
        else
            echo "Failed to unlock Bitwarden CLI."
        end
    else
        echo "Bitwarden CLI is already unlocked."
    end
end

function bw-lock -d 'Lock Bitwarden CLI'
    if test -n "$BW_SESSION"
        bw lock
        set -e BW_SESSION
        echo "Bitwarden CLI locked."
    else
        echo "Bitwarden CLI is already locked."
    end
end

trap bw-lock EXIT
