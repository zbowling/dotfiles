#!/bin/bash
# Local linting script
# Usage: ./scripts/lint.sh [--fix]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FIX_MODE=false
FAILED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse args
for arg in "$@"; do
    case $arg in
        --fix)
            FIX_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --fix    Auto-fix issues where possible"
            echo "  --help   Show this help"
            exit 0
            ;;
    esac
done

cd "$DOTFILES_DIR"

echo ""
echo -e "${BLUE}========================================"
echo "  Dotfiles Linter"
echo -e "========================================${NC}"
echo ""

# ============================================================
# ShellCheck
# ============================================================
run_shellcheck() {
    echo -e "${YELLOW}=== ShellCheck ===${NC}"
    echo ""

    if ! command -v shellcheck &> /dev/null; then
        echo "shellcheck not installed. Install with:"
        echo "  brew install shellcheck  # macOS"
        echo "  sudo apt install shellcheck  # Ubuntu"
        echo ""
        return 1
    fi

    # Find shell scripts
    local scripts
    scripts=$(find . -type f \( -name "*.sh" -o -name "*.bash" \) \
        ! -path "./.git/*" \
        ! -path "./node_modules/*" \
        2>/dev/null)

    local count=0
    local failed=0

    for script in $scripts; do
        ((count++))
        if shellcheck -x "$script" 2>&1; then
            echo -e "${GREEN}✓${NC} $script"
        else
            echo -e "${RED}✗${NC} $script"
            ((failed++))
        fi
    done

    echo ""
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}ShellCheck: $count scripts passed${NC}"
        return 0
    else
        echo -e "${RED}ShellCheck: $failed/$count scripts failed${NC}"
        return 1
    fi
}

# ============================================================
# shfmt (shell formatting)
# ============================================================
run_shfmt() {
    echo ""
    echo -e "${YELLOW}=== Shell Formatting (shfmt) ===${NC}"
    echo ""

    if ! command -v shfmt &> /dev/null; then
        echo "shfmt not installed. Install with:"
        echo "  brew install shfmt  # macOS"
        echo "  go install mvdan.cc/sh/v3/cmd/shfmt@latest  # Go"
        echo ""
        return 0  # Non-blocking
    fi

    local scripts
    scripts=$(find . -type f -name "*.sh" \
        ! -path "./.git/*" \
        ! -path "./node_modules/*" \
        2>/dev/null)

    if [[ "$FIX_MODE" == true ]]; then
        echo "Fixing formatting..."
        for script in $scripts; do
            shfmt -w -i 4 -bn -sr -ln bash "$script"
            echo -e "${GREEN}Fixed:${NC} $script"
        done
    else
        local failed=0
        for script in $scripts; do
            if ! shfmt -d -i 4 -bn -sr -ln bash "$script" > /dev/null 2>&1; then
                echo -e "${YELLOW}Needs formatting:${NC} $script"
                ((failed++))
            fi
        done

        if [[ $failed -gt 0 ]]; then
            echo ""
            echo "Run with --fix to auto-format, or:"
            echo "  shfmt -w -i 4 -bn -sr -ln bash <file>"
        else
            echo -e "${GREEN}All scripts properly formatted${NC}"
        fi
    fi
}

# ============================================================
# Markdown lint
# ============================================================
run_markdownlint() {
    echo ""
    echo -e "${YELLOW}=== Markdown Lint ===${NC}"
    echo ""

    if ! command -v markdownlint &> /dev/null; then
        echo "markdownlint not installed. Install with:"
        echo "  npm install -g markdownlint-cli"
        echo ""
        return 0  # Non-blocking
    fi

    if [[ "$FIX_MODE" == true ]]; then
        markdownlint --fix '**/*.md' --ignore node_modules --ignore .git 2>&1 || true
        echo -e "${GREEN}Markdown files fixed${NC}"
    else
        if markdownlint '**/*.md' --ignore node_modules --ignore .git 2>&1; then
            echo -e "${GREEN}Markdown files OK${NC}"
        else
            echo ""
            echo "Run with --fix to auto-fix some issues"
        fi
    fi
}

# ============================================================
# YAML lint
# ============================================================
run_yamllint() {
    echo ""
    echo -e "${YELLOW}=== YAML Lint ===${NC}"
    echo ""

    if ! command -v yamllint &> /dev/null; then
        echo "yamllint not installed. Install with:"
        echo "  pip install yamllint"
        echo ""
        return 0  # Non-blocking
    fi

    local yaml_files
    yaml_files=$(find . -type f \( -name "*.yml" -o -name "*.yaml" \) \
        ! -path "./.git/*" \
        ! -path "./node_modules/*" \
        2>/dev/null)

    if [[ -z "$yaml_files" ]]; then
        echo "No YAML files found"
        return 0
    fi

    if yamllint -d relaxed $yaml_files 2>&1; then
        echo -e "${GREEN}YAML files OK${NC}"
    fi
}

# ============================================================
# Run all linters
# ============================================================
run_shellcheck || FAILED=1
run_shfmt
run_markdownlint
run_yamllint

echo ""
echo -e "${BLUE}========================================${NC}"
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}  All checks passed!${NC}"
else
    echo -e "${RED}  Some checks failed${NC}"
fi
echo -e "${BLUE}========================================${NC}"
echo ""

exit $FAILED
