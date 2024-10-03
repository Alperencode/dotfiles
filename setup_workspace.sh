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
    # Run in a subshell to avoid terminating the script
    (bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)")

    log_info "Changing Oh My Bash theme to minimal..."
    sed -i 's/^OSH_THEME=".*"/OSH_THEME="minimal"/' ~/.bashrc
    log_success "Oh My Bash installed and theme changed to minimal!"
}

# Function to install Go
install_go() {
    log_info "Installing Go 1.23.1 for ARM64..."
    wget https://dl.google.com/go/go1.23.1.linux-arm64.tar.gz -O go.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz

    log_info "Configuring Go environment variables..."
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=/usr/local/go/bin:\$PATH:\$GOPATH/bin" >> ~/.bashrc

    # Remove the Go tar file after installation
    rm go.tar.gz
    log_success "Go installed and configured!"
}

# Function to install vim and apply vim configuration from external file
install_vim() {
    log_info "Installing Vim..."
    sudo apt update && sudo apt install -y vim

    log_info "Applying Vim configuration from vim/.vimrc..."
    if [ -f vim/.vimrc ]; then
        cp vim/.vimrc ~/.vimrc
        log_success "Vim configuration applied!"
    else
        log_warning "vim/.vimrc not found! Skipping vim configuration."
    fi
}

# Function to install tmux and apply tmux configuration from external file
install_tmux() {
    log_info "Installing tmux..."
    sudo apt install -y tmux

    log_info "Applying tmux configuration from tmux/.tmux.conf..."
    if [ -f tmux/.tmux.conf ]; then
        cp tmux/.tmux.conf ~/.tmux.conf
        log_success "tmux configuration applied!"
    else
        log_warning "tmux/.tmux.conf not found! Skipping tmux configuration."
    fi
}

# Function to setup GitHub account
setup_github() {
    log_info "Setting up GitHub account..."

    # Prompt user for GitHub username and email
    read -p "Enter your GitHub username: " github_username
    read -p "Enter your GitHub email: " github_email

    # Configure global git username and email
    git config --global user.name "$github_username"
    git config --global user.email "$github_email"
    
    log_success "GitHub user details configured: $github_username <$github_email>"

    # Generate an SSH key if one doesn't exist
    if [ ! -f ~/.ssh/id_rsa ]; then
        log_info "Generating a new SSH key..."
        ssh-keygen -t rsa -b 4096 -C "$github_email" -f ~/.ssh/id_rsa -N ""
        log_success "SSH key generated!"
    else
        log_warning "SSH key already exists. Skipping key generation."
    fi

    # Start the ssh-agent and add the SSH private key
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    # Display public key and instruction to add it to GitHub
    log_info "Here is your SSH public key. Copy it and add it to your GitHub account:"
    cat ~/.ssh/id_rsa.pub
    log_info "Follow the instructions here to add the key: https://github.com/settings/keys"
}

# Function to source .bashrc
source_bashrc() {
    log_info "Sourcing ~/.bashrc..."
    source ~/.bashrc
    log_success "~/.bashrc sourced!"
}

# Main function to call all others
main() {
    install_oh_my_bash
    install_vim
    install_go
    install_tmux
    setup_github
    source_bashrc
    
    # Exec a new bash to apply all changes
    log_info "All tasks completed. Starting a new bash shell to apply changes..."
    exec bash
}

main

