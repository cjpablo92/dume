#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DUME_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
SETUP_SCRIPT="$DUME_DIR/setup.sh"

# Source the configuration manager to get path variables
source "$DUME_DIR/libs/conf_manager.sh"
source "$DUME_DIR/libs/logger.sh"

# Enable verbose logging
export VERBOSE=true

# Validate that setup.sh exists
if [[ ! -f "$SETUP_SCRIPT" ]]; then
    log_error "setup.sh not found in $DUME_DIR"
    exit 1
fi

# Make setup.sh executable
chmod +x "$SETUP_SCRIPT"

# Determine target directory and create symlink based on OS
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # LINUX
    TARGET_DIR="$LINUX_PATH_FOLDER"
    TARGET_LINK="$LINUX_PATH_FOLDER/dume"
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # MAC OS
    TARGET_DIR="$MAC_PATH_FOLDER"
    TARGET_LINK="$MAC_PATH_FOLDER/dume"
else
    log_error "Unsupported OS: ($OSTYPE)"
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Remove existing symlink if it exists
if [[ -L "$TARGET_LINK" ]] || [[ -f "$TARGET_LINK" ]]; then
    log_info "Removing existing dume installation..."
    rm -f "$TARGET_LINK"
fi

# Create the symlink
log_info "Installing dume to $TARGET_LINK"

if ln -s "$SETUP_SCRIPT" "$TARGET_LINK" 2>/dev/null; then
    log_info "✓ dume installed successfully!"
    log_info "You can now run 'dume' from anywhere in your system"
    log_info "Try: dume -h"
else
    # If symlink creation fails, try with sudo
    log_info "Permission denied. Trying with sudo..."
    if sudo ln -s "$SETUP_SCRIPT" "$TARGET_LINK"; then
        log_info "✓ dume installed successfully with sudo!"
        log_info "You can now run 'dume' from anywhere in your system"
        log_info "Try: dume -h"
    else
        log_error "Failed to install dume. Please check permissions for $TARGET_DIR"
        exit 1
    fi
fi

# Verify installation
if command -v dume >/dev/null 2>&1; then
    log_info "✓ Installation verified: dume is available in PATH"
else
    log_warn "⚠ dume installed but not found in PATH. You may need to:"
    log_info "  - Restart your terminal session"
    log_info "  - Add $TARGET_DIR to your PATH in ~/.bashrc or ~/.zshrc"
fi 