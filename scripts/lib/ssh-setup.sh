#!/bin/bash
# SSH key generation and setup helpers

# ============================================================
# Generate SSH key
# ============================================================
generate_ssh_key() {
    echo ""
    echo "=== SSH Key Generation ==="
    echo ""

    # Check for existing keys
    local existing_keys=()
    for keyfile in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
        if [[ -f "$keyfile" ]]; then
            existing_keys+=("$keyfile")
        fi
    done

    if [[ ${#existing_keys[@]} -gt 0 ]]; then
        echo "Found existing SSH keys:"
        for key in "${existing_keys[@]}"; do
            echo "  - $key"
        done
        echo ""
        echo -n "Generate a new key anyway? [y/N] "
        read -r generate_choice
        if [[ ! "$generate_choice" =~ ^[Yy] ]]; then
            echo "Skipping key generation"
            return
        fi
    fi

    # Get email for key comment
    local email
    email=$(git config --global --get user.email 2>/dev/null || echo "")
    if [[ -z "$email" ]]; then
        echo -n "Enter email for SSH key: "
        read -r email
    else
        echo "Using email: $email"
        echo -n "Use this email? [Y/n] "
        read -r use_email
        if [[ "$use_email" =~ ^[Nn] ]]; then
            echo -n "Enter email for SSH key: "
            read -r email
        fi
    fi

    if [[ -z "$email" ]]; then
        echo "No email provided, skipping key generation"
        return
    fi

    # Generate Ed25519 key
    echo ""
    echo "Generating Ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519

    echo ""
    echo "SSH key generated: ~/.ssh/id_ed25519"
    echo ""
    echo "Public key:"
    cat ~/.ssh/id_ed25519.pub
    echo ""
}

# ============================================================
# Add SSH key to GitHub
# ============================================================
add_ssh_key_to_github() {
    echo ""
    echo "=== Add SSH Key to GitHub ==="
    echo ""

    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) not installed. Install with --cli flag."
        return 1
    fi

    # Check if authenticated
    if ! gh auth status &>/dev/null; then
        echo "Not authenticated with GitHub CLI."
        echo -n "Would you like to authenticate now? [y/N] "
        read -r auth_choice
        if [[ "$auth_choice" =~ ^[Yy] ]]; then
            gh auth login
        else
            echo "Skipping GitHub SSH key upload"
            return 1
        fi
    fi

    # Find the public key
    local pubkey=""
    if [[ -f ~/.ssh/id_ed25519.pub ]]; then
        pubkey=~/.ssh/id_ed25519.pub
    elif [[ -f ~/.ssh/id_rsa.pub ]]; then
        pubkey=~/.ssh/id_rsa.pub
    elif [[ -f ~/.ssh/id_ecdsa.pub ]]; then
        pubkey=~/.ssh/id_ecdsa.pub
    fi

    if [[ -z "$pubkey" ]]; then
        echo "No SSH public key found in ~/.ssh/"
        return 1
    fi

    echo "Found public key: $pubkey"
    echo ""
    cat "$pubkey"
    echo ""

    # Get key title
    local hostname
    hostname=$(hostname)
    local default_title="${USER}@${hostname}"
    echo -n "Key title [$default_title]: "
    read -r key_title
    key_title="${key_title:-$default_title}"

    # Upload to GitHub
    echo ""
    echo "Adding key to GitHub..."
    gh ssh-key add "$pubkey" --title "$key_title"

    echo ""
    echo "SSH key added to GitHub!"
    echo ""
    echo "You can also add this key as a signing key for commit verification:"
    echo "  gh ssh-key add $pubkey --title \"$key_title (signing)\" --type signing"
}

# ============================================================
# Full SSH setup
# ============================================================
setup_ssh() {
    generate_ssh_key

    if [[ -f ~/.ssh/id_ed25519.pub ]] || [[ -f ~/.ssh/id_rsa.pub ]]; then
        echo ""
        echo -n "Would you like to add this key to GitHub? [y/N] "
        read -r add_choice
        if [[ "$add_choice" =~ ^[Yy] ]]; then
            add_ssh_key_to_github
        fi
    fi
}
