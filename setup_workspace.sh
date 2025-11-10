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
    chmod +x ohmybash/setup_bash.sh
    ./ohmybash/setup_bash.sh
}

# Function to install Go
install_go() {
    log_info "Installing Go for ARM64..."
    wget https://dl.google.com/go/go1.24.1.linux-arm64.tar.gz -O go.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz

    log_info "Configuring Go environment variables..."
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=/usr/local/go/bin:\$PATH:\$GOPATH/bin" >> ~/.bashrc

    rm go.tar.gz
    log_success "Go installed and configured"

    log_info "Installing swag (Swagger generator)..."
    /usr/local/go/bin/go install github.com/swaggo/swag/cmd/swag@latest
    log_success "swag installed successfully"
}

# Function to install vim and apply vim configuration
install_vim() {
    log_info "Installing Vim..."
    sudo apt update && sudo apt install -y vim

    log_info "Applying Vim configuration from vim/.vimrc..."
    if [ -f vim/.vimrc ]; then
        cp vim/.vimrc ~/.vimrc
        log_success "Vim configuration applied"
    else
        log_warning "vim/.vimrc not found Skipping vim configuration."
    fi

    log_info "Installing vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log_success "vim-plug installed"
}

# Function to install tmux and apply configuration
install_tmux() {
    log_info "Installing tmux..."
    sudo apt install -y tmux

    log_info "Applying tmux configuration from tmux/.tmux.conf..."
    if [ -f tmux/.tmux.conf ]; then
        cp tmux/.tmux.conf ~/.tmux.conf
        log_success "tmux configuration applied"
    else
        log_warning "tmux/.tmux.conf not found Skipping tmux configuration."
    fi
}

# Function to setup GitHub credentials and SSH key
setup_github() {
    log_info "Setting up GitHub account..."
    read -p "Enter your GitHub username: " github_username
    read -p "Enter your GitHub email: " github_email

    git config --global user.name "$github_username"
    git config --global user.email "$github_email"
    git config --global core.editor "vim"

    log_success "GitHub user configured: $github_username <$github_email>"

    if [ ! -f ~/.ssh/id_rsa ]; then
        log_info "Generating SSH key..."
        ssh-keygen -t rsa -b 4096 -C "$github_email" -f ~/.ssh/id_rsa -N ""
        log_success "SSH key generated"
    else
        log_warning "SSH key already exists. Skipping generation."
    fi

    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    log_info "Your SSH public key (add to GitHub):"
    cat ~/.ssh/id_rsa.pub
    log_info "GitHub SSH key setup guide: https://github.com/settings/keys"
}

# Clone repositories from file
clone_repos() {
    local repo_file="$1"
    if [ ! -f "$repo_file" ]; then
        log_error "Repository file '$repo_file' does not exist."
        return
    fi

    log_info "Cloning repositories listed in '$repo_file' into upper directory"
    while IFS= read -r repo; do
        if [ -n "$repo" ]; then
            repo_name=$(basename "$repo" .git)
            git clone "$repo" "../$repo_name"
            if [ $? -eq 0 ]; then
                log_success "Cloned: $repo -> ../$repo_name"
            else
                log_warning "Failed to clone: $repo"
            fi
        fi
    done < "$repo_file"
}

main() {
    local repo_file=""
    while getopts ":r:" opt; do
        case $opt in
            r)
                repo_file="$OPTARG"
                ;;
            \?)
                log_error "Invalid option: -$OPTARG"
                exit 1
                ;;
            :)
                log_error "Option -$OPTARG requires a file path."
                exit 1
                ;;
        esac
    done

    install_vim
    install_tmux
    install_oh_my_bash
    install_go
    setup_github

    if [ -n "$repo_file" ]; then
        clone_repos "$repo_file"
    fi

    log_info "All tasks completed. Starting a new bash shell to apply changes..."
    exec bash
}

main "$@"
