if command -q bw
  function bwunlock
    set -l bw_session (bw unlock --raw)
    if test -z "$bw_session"
      echo "Failed to open vault" >&2
    else
      set -Ux BW_SESSION "$bw_session"
      trap bwlock EXIT
    end
  end
end
