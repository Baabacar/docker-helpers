#!/bin/bash

set -e

SCRIPT_NAME="docker-helper.sh"
ALIAS_NAME="docker-helper"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_URL="https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/$SCRIPT_NAME"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# User Shell Detection
detect_shell_rc() {
    local shell_name
    shell_name=$(basename "$SHELL")

    case "$shell_name" in
        bash)
            echo "$HOME/.bashrc"
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        sh)
            echo "$HOME/.profile"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

add_alias_if_not_exists() {
    local rc_file="$1"
    local alias_line="alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\""

    if grep -Fxq "$alias_line" "$rc_file"; then
        log_warning "Alias already exists in $rc_file"
    else
        echo "$alias_line" >> "$rc_file"
        log_success "Alias added to $rc_file"
    fi
}

download_script() {
    log "Downloading script from GitHub..."
    
    # Check which download tool is available
    if command -v curl >/dev/null 2>&1; then
        log_warning " Using curl for download"
        if ! curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"; then
            log_error "Download failed with curl" >&2
            return 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        log_warning "Using wget for download"
        if ! wget -q "$SCRIPT_URL" -O "$INSTALL_DIR/$SCRIPT_NAME"; then
            log_error "Download failed with wget" >&2
            return 1
        fi
    elif command -v wget2 >/dev/null 2>&1; then
        log_warning "Using wget2 for download"
        if ! wget2 -q "$SCRIPT_URL" -O "$INSTALL_DIR/$SCRIPT_NAME"; then
            log_error "Download failed with wget2" >&2
            return 1
        fi
    else
        log_error "No download tool found (curl, wget or wget2 required)" >&2
        return 1
    fi
    
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    return 0
}

main() {
    log "=== Installing $SCRIPT_NAME ==="

    # Create directory if needed
    mkdir -p "$INSTALL_DIR"

    # Download and install the script
    if ! download_script; then
        log_error "Failed to download the script" >&2
        exit 1
    fi
    log_success "Script installed in $INSTALL_DIR"

    # Add alias to the appropriate RC file
    RC_FILE=$(detect_shell_rc)
    add_alias_if_not_exists "$RC_FILE"

    echo ""
    log_success "Installation complete."
    log_warning "Restart your terminal or run: source $RC_FILE"
    log_warning "Use the script with: $ALIAS_NAME"
}

main
