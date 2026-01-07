#!/bin/bash
# Run dotfiles tests in Docker containers
# Usage: ./tests/run-tests.sh [ubuntu|arch|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

run_test() {
    local distro="$1"
    local dockerfile="$SCRIPT_DIR/Dockerfile.$distro"
    local image_name="dotfiles-test-$distro"

    if [[ ! -f "$dockerfile" ]]; then
        echo -e "${RED}Dockerfile not found: $dockerfile${NC}"
        return 1
    fi

    log_header "Testing on $distro"

    echo -e "${YELLOW}Building Docker image...${NC}"
    docker build -t "$image_name" -f "$dockerfile" "$DOTFILES_DIR"

    echo ""
    echo -e "${YELLOW}Running tests...${NC}"
    echo ""

    if docker run --rm "$image_name"; then
        echo ""
        echo -e "${GREEN}✓ $distro tests passed!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ $distro tests failed!${NC}"
        return 1
    fi
}

# Parse arguments
TARGET="${1:-all}"
FAILED=0

case "$TARGET" in
    ubuntu)
        run_test ubuntu || FAILED=1
        ;;
    arch)
        run_test arch || FAILED=1
        ;;
    all)
        run_test ubuntu || FAILED=1
        run_test arch || FAILED=1
        ;;
    *)
        echo "Usage: $0 [ubuntu|arch|all]"
        echo ""
        echo "Options:"
        echo "  ubuntu  - Test on Ubuntu 24.04"
        echo "  arch    - Test on Arch Linux"
        echo "  all     - Test on all distributions (default)"
        exit 1
        ;;
esac

echo ""
log_header "Final Results"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
