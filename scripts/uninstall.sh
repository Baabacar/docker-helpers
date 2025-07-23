#!/bin/bash

set -e

SCRIPT_NAME="docker-helper.sh"
ALIAS_NAME="docker-helper"
INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/$SCRIPT_NAME"

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

# Remove alias
remove_alias() {
    local rc_file="$1"
    # Secure version of the sed pattern
    local alias_pattern="alias $ALIAS_NAME=\"$INSTALL_PATH\""
    
    if [ ! -f "$rc_file" ]; then
        log_warning "File $rc_file not found"
        return
    fi

    if grep -Fxq "$alias_pattern" "$rc_file"; then
        # More portable solution than sed -i
        temp_file=$(mktemp)
        grep -Fvx "$alias_pattern" "$rc_file" > "$temp_file"
        mv "$temp_file" "$rc_file"
        log_success "Alias removed from $rc_file${NC}"
    else
        log_warning "Alias not found in $rc_file"
    fi
}

# Remove script
remove_script() {
    if [ -f "$INSTALL_PATH" ]; then
        rm -f "$INSTALL_PATH"
        log_success "Script removed from $INSTALL_PATH"
        
        # Remove directory if empty
        if [ -z "$(ls -A "$INSTALL_DIR")" ]; then
            rmdir "$INSTALL_DIR"
            log_warning "Directory $INSTALL_DIR removed (empty)"
        fi
    else
        log_warning "No script to remove at $INSTALL_PATH"
    fi
}

log "=== Uninstalling docker-registry-manage ==="
remove_script
remove_alias "$(detect_shell_rc)"
log_success "Uninstallation complete."
log_warning "Restart your terminal to finalize."
