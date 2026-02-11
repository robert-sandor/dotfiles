function set_bitwarden_ssh_agent
  # Possible locations are for: macos appstore, linux flatpak, macos dmg and linux package
    set -l possible_socket_locations \
      "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock" \
      "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock" \
      "$HOME/.bitwarden-ssh-agent.sock"

    for socket in $possible_socket_locations
      if test -S $socket
        set -gx SSH_AUTH_SOCK "$socket"
        break
      end
    end
end
