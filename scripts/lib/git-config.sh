#!/bin/bash
# Git configuration helpers

# ============================================================
# Configure git defaults (safe, recommended settings)
# ============================================================
configure_git_defaults() {
    echo ""
    echo "=== Configuring Git Defaults ==="
    echo ""

    # Better merge conflict markers (shows base, ours, theirs)
    if ! git config --global --get merge.conflictStyle &>/dev/null; then
        git config --global merge.conflictStyle diff3
        echo "  Set merge.conflictStyle = diff3"
    else
        echo "  merge.conflictStyle already set"
    fi

    # Fast-forward only pulls (prevents accidental merge commits)
    if ! git config --global --get pull.ff &>/dev/null; then
        git config --global pull.ff only
        echo "  Set pull.ff = only"
    else
        echo "  pull.ff already set"
    fi

    # Auto-squash fixup commits during interactive rebase
    if ! git config --global --get rebase.autosquash &>/dev/null; then
        git config --global rebase.autosquash true
        echo "  Set rebase.autosquash = true"
    else
        echo "  rebase.autosquash already set"
    fi

    # Enable rerere (reuse recorded resolution)
    if ! git config --global --get rerere.enabled &>/dev/null; then
        git config --global rerere.enabled true
        echo "  Set rerere.enabled = true"
    else
        echo "  rerere.enabled already set"
    fi

    # Auto-update rerere cache
    if ! git config --global --get rerere.autoupdate &>/dev/null; then
        git config --global rerere.autoupdate true
        echo "  Set rerere.autoupdate = true"
    else
        echo "  rerere.autoupdate already set"
    fi

    # Default branch name
    if ! git config --global --get init.defaultBranch &>/dev/null; then
        git config --global init.defaultBranch main
        echo "  Set init.defaultBranch = main"
    else
        echo "  init.defaultBranch already set"
    fi

    # Push default to current branch
    if ! git config --global --get push.default &>/dev/null; then
        git config --global push.default current
        echo "  Set push.default = current"
    else
        echo "  push.default already set"
    fi

    # Auto-setup remote tracking
    if ! git config --global --get push.autoSetupRemote &>/dev/null; then
        git config --global push.autoSetupRemote true
        echo "  Set push.autoSetupRemote = true"
    else
        echo "  push.autoSetupRemote already set"
    fi

    # Configure delta as pager if installed
    configure_git_delta

    echo ""
    echo "Git defaults configured!"
}

# ============================================================
# Configure git-delta for better diffs
# ============================================================
configure_git_delta() {
    if ! command -v delta &> /dev/null; then
        return
    fi

    echo ""
    echo "Configuring git-delta..."

    # Use delta as the pager
    if ! git config --global --get core.pager &>/dev/null; then
        git config --global core.pager delta
        echo "  Set core.pager = delta"
    fi

    # Use delta for interactive diffs
    if ! git config --global --get interactive.diffFilter &>/dev/null; then
        git config --global interactive.diffFilter "delta --color-only"
        echo "  Set interactive.diffFilter = delta --color-only"
    fi

    # Delta options
    if ! git config --global --get delta.navigate &>/dev/null; then
        git config --global delta.navigate true
        echo "  Set delta.navigate = true (use n/N to jump between files)"
    fi

    if ! git config --global --get delta.side-by-side &>/dev/null; then
        git config --global delta.side-by-side true
        echo "  Set delta.side-by-side = true"
    fi

    if ! git config --global --get delta.line-numbers &>/dev/null; then
        git config --global delta.line-numbers true
        echo "  Set delta.line-numbers = true"
    fi

    echo "  git-delta configured!"
}

# ============================================================
# Initialize git user (interactive setup)
# ============================================================
init_git_user() {
    echo ""
    echo "=== Git User Setup ==="
    echo ""

    local needs_setup=false

    # Check user.name
    local current_name
    current_name=$(git config --global --get user.name 2>/dev/null || echo "")
    if [[ -z "$current_name" ]]; then
        needs_setup=true
        echo "Git user.name is not set."
        echo -n "Enter your name: "
        read -r git_name
        if [[ -n "$git_name" ]]; then
            git config --global user.name "$git_name"
            echo "  Set user.name = $git_name"
        else
            echo "  Skipped (no name provided)"
        fi
    else
        echo "  user.name = $current_name"
    fi

    # Check user.email
    local current_email
    current_email=$(git config --global --get user.email 2>/dev/null || echo "")
    if [[ -z "$current_email" ]]; then
        needs_setup=true
        echo "Git user.email is not set."
        echo -n "Enter your email: "
        read -r git_email
        if [[ -n "$git_email" ]]; then
            git config --global user.email "$git_email"
            echo "  Set user.email = $git_email"
        else
            echo "  Skipped (no email provided)"
        fi
    else
        echo "  user.email = $current_email"
    fi

    echo ""

    # Check GitHub CLI auth status
    if command -v gh &> /dev/null; then
        echo "Checking GitHub CLI auth status..."
        if gh auth status &>/dev/null; then
            echo "  GitHub CLI: authenticated"
            gh auth status 2>&1 | head -3 | sed 's/^/  /'
        else
            echo "  GitHub CLI: not authenticated"
            echo ""
            echo -n "Would you like to authenticate with GitHub? [y/N] "
            read -r auth_choice
            if [[ "$auth_choice" =~ ^[Yy] ]]; then
                echo ""
                gh auth login
            else
                echo "  Skipped GitHub authentication"
            fi
        fi
    else
        echo "GitHub CLI (gh) not installed. Install with --cli flag."
    fi

    echo ""
    echo "Git user setup complete!"
}

# ============================================================
# Full git initialization (defaults + user setup)
# ============================================================
init_git() {
    configure_git_defaults
    init_git_user
}
