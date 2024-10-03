#!/bin/bash

# Define color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Helper function for logging
log_info() {
    echo -e "\n${BLUE}INFO:${NC} $1\n"
}

log_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Function to install oh-my-bash and change theme
install_oh_my_bash() {
    log_info "Installing Oh My Bash..."
    
    # Install Oh My Bash
    bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

    log_info "Changing Oh My Bash theme to minimal..."
    sed -i 's/^OSH_THEME=".*"/OSH_THEME="minimal"/' ~/.bashrc
    log_success "Oh My Bash installed and theme changed to minimal!"
}

# Function to customize minimal.theme.sh
customize_theme() {
    log_info "Customizing minimal theme..."

    local theme_file="$HOME/.oh-my-bash/themes/minimal/minimal.theme.sh"

    if [ -f "$theme_file" ]; then
        sed -i 's|PS1="$(scm_prompt_info)${_omb_prompt_reset_color} \W ${_omb_prompt_reset_color}"|PS1="$(scm_prompt_info)${_omb_prompt_reset_color} ${_omb_prompt_teal}(\h) \W ${_omb_prompt_reset_color}"|' "$theme_file"
        log_success "Minimal theme customized successfully!"
    else
        log_warning "Theme file not found: $theme_file"
    fi
}

# Main function to call all others
main() {
    install_oh_my_bash
    customize_theme
}

main
