function set_bitwarden_ssh_agent
    set -l os_type (uname)
    set -l socket_path ""

    switch $os_type
        case Darwin
            # macOS: Check for App Store version first, then .dmg version
            set -l appstore_socket "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
            set -l dmg_socket "$HOME/.bitwarden-ssh-agent.sock"

            if test -S $appstore_socket
                set socket_path $appstore_socket
            else if test -S $dmg_socket
                set socket_path $dmg_socket
            end

        case Linux
            # Linux: Check for Flatpak version first, then standard version
            set -l flatpak_socket "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
            set -l standard_socket "$HOME/.bitwarden-ssh-agent.sock"

            if test -S $flatpak_socket
                set socket_path $flatpak_socket
            else if test -S $standard_socket
                set socket_path $standard_socket
            end
    end

    # Set the SSH_AUTH_SOCK environment variable
    if test -n "$socket_path"
        set -gx SSH_AUTH_SOCK $socket_path
    end
end
