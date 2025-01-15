#!/bin/zsh

# Check if we are in an SSH session
if [[ -z "$SSH_CLIENT" && -z "$SSH_CONNECTION" ]]; then
    return 0  # If not an SSH session, exit the script
fi

# Check if the codessh command already exists
if type codessh &>/dev/null; then
    return 0  # If the command already exists, exit the script
fi

# Define the codessh command
codessh() {
    # If no directory is provided, default to the current directory
    local target_dir="${1:-.}"

    # Convert the directory path to an absolute path
    if ! target_dir=$(realpath "$target_dir" 2>/dev/null); then
        echo "Error: Invalid directory '$target_dir'." >&2
        return 1
    fi

    # Check if the CODE_SSH_CONFIG_NAME environment variable is set
    if [[ -n "$CODE_SSH_CONFIG_NAME" ]]; then
        # If set, use SSH config alias to generate the command
        echo "code --folder-uri vscode-remote://ssh-remote+$CODE_SSH_CONFIG_NAME$target_dir"
    else
        # Otherwise, use username and remote IP address to generate the command
        local username=${USER}
        local remote_ip=$(echo $SSH_CONNECTION | awk '{print $3}')
        if [[ -z "$remote_ip" ]]; then
            echo "Error: Could not determine remote IP address." >&2
            return 1
        fi
        echo "code --folder-uri vscode-remote://ssh-remote+$username@$remote_ip$target_dir"
    fi
}

