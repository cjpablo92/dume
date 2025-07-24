#!/bin/bash
set -e

# Get script directory for proper path resolution
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")/../.." && pwd)"

source "$SCRIPT_DIR/libs/logger.sh"
source "$SCRIPT_DIR/libs/conf_manager.sh"


log_info "installing {{NAME}}..."

if is_callable_from_path "{{NAME}}"; then 
    log_info "\t{{NAME}} already installed"
else 
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # LINUX
        log_error "IMPLEMENT THIS FOR LINUX !!!"
        exit 1
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MAC OS
        if is_apple_silicon; then
            log_error "IMPLEMENT THIS FOR APPLE SILICON BASED MAC!!!"
            exit 1
        else 
            log_error "IMPLEMENT THIS FOR INTEL BASED MAC!!!"
            exit 1
        fi
    else
        log_error "unsupported os: ($OSTYPE) !!!"
        exit 1
    fi
fi

log_info "installing {{NAME}}...DONE!"
