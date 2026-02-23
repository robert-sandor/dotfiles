if command -q bw
  function bwlock
    if test -z "$BW_SESSION"
      return
    end

    set -Ue BW_SESSION
    bw lock
  end
end
