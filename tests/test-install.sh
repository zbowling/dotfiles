#!/bin/bash
# Test script for dotfiles installation
# Runs inside Docker container

# Don't exit on error - we want to run all tests
set +e

DOTFILES_DIR="$HOME/dotfiles"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

log_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Test that a command exists
test_command() {
    local cmd="$1"
    local desc="${2:-$cmd is installed}"
    if command -v "$cmd" &> /dev/null; then
        log_pass "$desc"
        return 0
    else
        log_fail "$desc"
        return 1
    fi
}

# Test that a file exists
test_file() {
    local file="$1"
    local desc="${2:-$file exists}"
    if [[ -f "$file" ]]; then
        log_pass "$desc"
        return 0
    else
        log_fail "$desc"
        return 1
    fi
}

# Test that a symlink exists and points to correct target
test_symlink() {
    local link="$1"
    local target="$2"
    local desc="${3:-$link -> $target}"
    # Expand ~ in paths
    link="${link/#\~/$HOME}"
    target="${target/#\~/$HOME}"
    if [[ -L "$link" ]]; then
        local actual_target
        actual_target="$(readlink "$link")"
        if [[ "$actual_target" == "$target" ]] || [[ "$(readlink -f "$link")" == "$(readlink -f "$target")" ]]; then
            log_pass "$desc"
            return 0
        else
            log_fail "$desc (points to: $actual_target)"
            return 1
        fi
    else
        log_fail "$desc (not a symlink)"
        return 1
    fi
}

# Test that a directory symlink exists and points to correct target
test_dir_symlink() {
    local link="$1"
    local target="$2"
    local desc="${3:-$link -> $target}"
    # Expand ~ in paths
    link="${link/#\~/$HOME}"
    target="${target/#\~/$HOME}"
    if [[ -L "$link" && -d "$link" ]]; then
        local actual_target
        actual_target="$(readlink "$link")"
        if [[ "$actual_target" == "$target" ]] || [[ "$(readlink -f "$link")" == "$(readlink -f "$target")" ]]; then
            log_pass "$desc"
            return 0
        else
            log_fail "$desc (points to: $actual_target)"
            return 1
        fi
    elif [[ -d "$link" && ! -L "$link" ]]; then
        log_fail "$desc (is directory, not symlink)"
        return 1
    else
        log_fail "$desc (not found or not a directory symlink)"
        return 1
    fi
}

# Test that a file contains a string
test_contains() {
    local file="$1"
    local pattern="$2"
    local desc="${3:-$file contains $pattern}"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        log_pass "$desc"
        return 0
    else
        log_fail "$desc"
        return 1
    fi
}

echo "=========================================="
echo "Dotfiles Installation Tests"
echo "=========================================="
echo ""

# Detect OS
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    log_info "Testing on: $NAME"
else
    log_info "Testing on: Unknown OS"
fi
echo ""

# ==========================================
# Test 1: Run install.sh
# ==========================================
echo "--- Test: install.sh ---"
log_info "Running install.sh..."

cd "$DOTFILES_DIR"

# Install Antidote first (required for zsh)
if [[ ! -d ~/.antidote ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
fi

# Run install script
./install.sh

echo ""
log_info "Running install.sh again (idempotency test)..."
./install.sh

echo ""

# ==========================================
# Test 2: Verify symlinks
# ==========================================
echo "--- Test: Symlinks ---"
test_symlink ~/.zshrc "$DOTFILES_DIR/zsh/.zshrc" "~/.zshrc symlink"
test_symlink ~/.zsh_plugins.txt "$DOTFILES_DIR/zsh/.zsh_plugins.txt" "~/.zsh_plugins.txt symlink"
test_symlink ~/.config/starship.toml "$DOTFILES_DIR/starship/starship.toml" "starship.toml symlink"
test_symlink ~/.config/fish/config.fish "$DOTFILES_DIR/fish/config.fish" "fish config symlink"
test_symlink ~/.config/ghostty/config "$DOTFILES_DIR/ghostty/config" "ghostty config symlink"
test_dir_symlink ~/.config/alacritty "$DOTFILES_DIR/alacritty" "alacritty config symlink"
test_dir_symlink ~/.config/zellij "$DOTFILES_DIR/zellij" "zellij config symlink"
echo ""

# ==========================================
# Test 3: Verify bash patches
# ==========================================
echo "--- Test: Bash configuration ---"
test_contains ~/.bashrc "starship init bash" "bashrc has starship"
test_contains ~/.bashrc "1password/agent.sock" "bashrc has 1Password SSH agent"
echo ""

# ==========================================
# Test 4: Run package installer (CLI only, skip sudo-heavy stuff)
# ==========================================
echo "--- Test: Package installer ---"
log_info "Running install-packages.sh --runtimes..."

# Only test runtimes (no sudo needed)
./scripts/install-packages.sh --runtimes

# Verify runtimes installed (check binary locations since PATH isn't updated yet)
test_file ~/.local/bin/mise "mise installed"
test_file ~/.local/bin/uv "uv installed"
test_file ~/.nvm/nvm.sh "nvm installed"
test_file ~/.cargo/bin/rustup "rustup installed"
echo ""

# ==========================================
# Test 5: Verify zsh can load config
# ==========================================
echo "--- Test: Zsh configuration loads ---"
log_info "Testing zsh config syntax..."
if zsh -n ~/.zshrc 2>/dev/null; then
    log_pass "zsh config syntax valid"
else
    log_fail "zsh config syntax valid"
fi
echo ""

# ==========================================
# Test 6: Verify fish can load config
# ==========================================
echo "--- Test: Fish configuration loads ---"
log_info "Testing fish config syntax..."
if fish -n ~/.config/fish/config.fish 2>/dev/null; then
    log_pass "fish config syntax valid"
else
    log_fail "fish config syntax valid"
fi
echo ""

# ==========================================
# Test 7: Validate editor installation functions
# ==========================================
echo "--- Test: Editor functions validation ---"
log_info "Validating editor installation functions..."

# Source required files
source "$DOTFILES_DIR/scripts/lib/detect-os.sh"
source "$DOTFILES_DIR/scripts/lib/packages-editors.sh"

# Check each function exists
check_editor_function() {
    local func_name="$1"
    if declare -f "$func_name" > /dev/null 2>&1; then
        log_pass "$func_name defined"
        return 0
    else
        log_fail "$func_name defined"
        return 1
    fi
}

check_editor_function install_vscode
check_editor_function install_cursor
check_editor_function install_zed
check_editor_function install_antigravity
check_editor_function install_gemini_cli
check_editor_function install_codex
check_editor_function install_claude_code
check_editor_function install_neovim_lazyvim

echo ""

# ==========================================
# Summary
# ==========================================
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
