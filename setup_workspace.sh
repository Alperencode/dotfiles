#!/bin/bash

# Define color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper function for logging
log_info() {
    echo -e "\n${BLUE}INFO:${NC} $1"
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
    if [ -d ~/.oh-my-bash ]; then
        log_warning "Oh My Bash is already installed. Skipping installation."
        return
    fi

    log_info "Installing Oh My Bash..."
    chmod +x ohmybash/setup_bash.sh
    ./ohmybash/setup_bash.sh
}

# Function to install Go
install_go() {
    local target_version="1.24.1"

    if command -v go &> /dev/null; then
        local installed_version=$(go version | awk '{print $3}' | sed 's/go//')
        if [ "$installed_version" = "$target_version" ]; then
            log_warning "Go $target_version is already installed. Skipping installation."
            return
        else
            log_info "Go $installed_version is installed, but target version is $target_version. Updating..."
        fi
    fi

    log_info "Installing Go $target_version for ARM64..."
    wget https://dl.google.com/go/go${target_version}.linux-arm64.tar.gz -O go.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz

    # Check if Go paths are already in .bashrc
    if ! grep -q "export GOPATH=" ~/.bashrc; then
        log_info "Configuring Go environment variables..."
        echo "export GOPATH=\$HOME/go" >> ~/.bashrc
        echo "export PATH=/usr/local/go/bin:\$PATH:\$GOPATH/bin" >> ~/.bashrc
    else
        log_warning "Go environment variables already configured in .bashrc"
    fi

    rm go.tar.gz
    log_success "Go installed and configured"

    # Check if swag is already installed
    if [ -f "$HOME/go/bin/swag" ]; then
        log_warning "swag is already installed. Skipping installation."
    else
        log_info "Installing swag (Swagger generator)..."
        /usr/local/go/bin/go install github.com/swaggo/swag/cmd/swag@latest
        log_success "swag installed successfully"
    fi
}

# Function to install Neovim from source
install_neovim() {
    local min_version="0.8.0"

    # Check if neovim is already installed and meets minimum version
    if command -v nvim &> /dev/null; then
        local installed_version=$(nvim --version | head -n1 | awk '{print $2}' | sed 's/v//')
        if [ "$(printf '%s\n' "$min_version" "$installed_version" | sort -V | head -n1)" = "$min_version" ]; then
            log_warning "Neovim $installed_version is already installed (>= $min_version). Skipping Neovim build."
        else
            log_info "Neovim $installed_version is installed, but version >= $min_version is required. Updating..."
            sudo apt-get remove -y neovim

            log_info "Installing Neovim build dependencies..."
            sudo apt-get update
            sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential git ripgrep

            log_info "Cloning and building Neovim from source..."
            cd ~
            if [ -d ~/neovim ]; then
                rm -rf ~/neovim
            fi

            git clone https://github.com/neovim/neovim
            cd neovim
            git checkout stable
            make CMAKE_BUILD_TYPE=RelWithDebInfo
            sudo make install

            # Clean up build directory
            cd ~
            rm -rf neovim

            log_success "Neovim installed successfully"
        fi
    else
        log_info "Installing Neovim build dependencies..."
        sudo apt-get update
        sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential git ripgrep

        log_info "Cloning and building Neovim from source..."
        cd ~
        if [ -d ~/neovim ]; then
            rm -rf ~/neovim
        fi

        git clone https://github.com/neovim/neovim
        cd neovim
        git checkout stable
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install

        # Clean up build directory
        cd ~
        rm -rf neovim

        log_success "Neovim installed successfully"
    fi

    # Apply Neovim configuration from submodule
    apply_neovim_config

}

# Function to apply Neovim customizations
apply_neovim_config() {
    local nvim_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    local current_dir=$(pwd)

    log_info "Applying Neovim configuration from nvim-config submodule..."

    if [ ! -d "nvim-config" ]; then
        log_error "nvim-config submodule not found. Did you clone with --recurse-submodules?"
        log_info "Run: git submodule update --init --recursive"
        return 1
    fi

    # Remove existing config if present
    if [ -d "$nvim_config_dir" ]; then
        log_warning "Removing existing Neovim config..."
        rm -rf "$nvim_config_dir"
    fi

    # Create symlink to submodule
    ln -s "$current_dir/nvim-config" "$nvim_config_dir"
    log_success "Neovim configuration linked from submodule"

    log_info "Run 'nvim' to install plugins on first launch"
}

install_vim() {
    if command -v vim &> /dev/null; then
        log_warning "Vim is already installed. Skipping installation."
    else
        log_info "Installing Vim..."
        sudo apt update && sudo apt install -y vim
        log_success "Vim installed"
    fi

    log_info "Applying Vim configuration from vim/.vimrc..."
    if [ -f vim/.vimrc ]; then
        cp vim/.vimrc ~/.vimrc
        log_success "Vim configuration applied"
    else
        log_warning "vim/.vimrc not found. Skipping vim configuration."
    fi

    if [ -f ~/.vim/autoload/plug.vim ]; then
        log_warning "vim-plug is already installed. Skipping installation."
    else
        log_info "Installing vim-plug..."
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        log_success "vim-plug installed"
    fi
}

# Function to install tmux and apply configuration
install_tmux() {
    if command -v tmux &> /dev/null; then
        log_warning "tmux is already installed. Skipping installation."
    else
        log_info "Installing tmux..."
        sudo apt install -y tmux
        log_success "tmux installed"
    fi

    log_info "Applying tmux configuration from tmux/.tmux.conf..."
    if [ -f tmux/.tmux.conf ]; then
        cp tmux/.tmux.conf ~/.tmux.conf
        log_success "tmux configuration applied"
    else
        log_warning "tmux/.tmux.conf not found. Skipping tmux configuration."
    fi
}

install_tmux_plugins() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [ -d "$tpm_dir" ]; then
        log_warning "TPM already installed. Skipping TPM installation."
    else
        log_info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        log_success "TPM installed"
    fi

    # Install tmux plugins if tmux server is running
    if tmux info &>/dev/null; then
        log_info "Installing tmux plugins via TPM..."
        tmux source-file ~/.tmux.conf
        tmux run-shell "$tpm_dir/bin/install_plugins"
        log_success "tmux plugins installed"
    else
        log_warning "tmux server not running. Plugins will install on first tmux start (Ctrl+b I)."
    fi
}

# Function to setup GitHub credentials and SSH key
setup_github() {
    # Check if git config already has user name and email
    local existing_name=$(git config --global user.name)
    local existing_email=$(git config --global user.email)

    if [ -n "$existing_name" ] && [ -n "$existing_email" ]; then
        log_warning "GitHub credentials already configured: $existing_name <$existing_email>"
        read -p "Do you want to reconfigure? (y/N): " reconfigure
        if [[ ! "$reconfigure" =~ ^[Yy]$ ]]; then
            log_info "Keeping existing GitHub configuration"
        else
            log_info "Setting up GitHub account..."
            read -p "Enter your GitHub username: " github_username
            read -p "Enter your GitHub email: " github_email

            git config --global user.name "$github_username"
            git config --global user.email "$github_email"
            log_success "GitHub user configured: $github_username <$github_email>"
        fi
    else
        log_info "Setting up GitHub account..."
        read -p "Enter your GitHub username: " github_username
        read -p "Enter your GitHub email: " github_email

        git config --global user.name "$github_username"
        git config --global user.email "$github_email"
        log_success "GitHub user configured: $github_username <$github_email>"
    fi

    # Always set vim as the editor if not already set
    git config --global core.editor "vim"

    if [ ! -f ~/.ssh/id_rsa ]; then
        log_info "Generating SSH key..."
        local email="${github_email:-$(git config --global user.email)}"
        ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""
        log_success "SSH key generated"

        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa

        log_info "Your SSH public key (add to GitHub):"
        cat ~/.ssh/id_rsa.pub
        log_info "GitHub SSH key setup guide: https://github.com/settings/keys"
    else
        log_warning "SSH key already exists. Skipping generation."
        log_info "Your existing SSH public key:"
        cat ~/.ssh/id_rsa.pub
        log_info "GitHub SSH key setup guide: https://github.com/settings/keys"
    fi
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

            # Check if repository already exists
            if [ -d "../$repo_name" ]; then
                log_warning "Repository '../$repo_name' already exists. Skipping clone."
                continue
            fi

            git clone "$repo" "../$repo_name"
            if [ $? -eq 0 ]; then
                log_success "Cloned: $repo -> ../$repo_name"
            else
                log_warning "Failed to clone: $repo"
            fi
        fi
    done < "$repo_file"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -r <file>       Clone repositories from the specified file
    -n, --neovim    Install Neovim with kickstart.nvim configuration
    -h, --help      Show this help message

Examples:
    $0                      # Install everything except Neovim
    $0 --neovim             # Install everything including Neovim
    $0 -n -r repos.txt      # Install with Neovim and clone repos from file
EOF
}

main() {
    local repo_file=""
    local install_nvim=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r)
                repo_file="$2"
                shift 2
                ;;
            -n|--neovim)
                install_nvim=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    install_vim
    
    if [ "$install_nvim" = true ]; then
        install_neovim
    else
        log_info "Skipping Neovim installation (use --neovim or -n to install)"
    fi
    
    install_tmux
    install_tmux_plugins
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
