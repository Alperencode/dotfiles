#!/bin/bash

# Function to install oh-my-bash and change theme
install_oh_my_bash() {
    echo "Installing Oh My Bash..."
    bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
    
    echo "Changing Oh My Bash theme to minimal..."
    sed -i 's/^OSH_THEME=".*"/OSH_THEME="minimal"/' ~/.bashrc
}

# Function to install Go
install_go() {
    echo "Installing Go 1.23.1 for ARM64..."
    wget https://dl.google.com/go/go1.23.1.linux-arm64.tar.gz -O go.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go.tar.gz
    echo "Configuring Go environment variables..."
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=/usr/local/go/bin:\$PATH:\$GOPATH/bin" >> ~/.bashrc
}

# Function to install vim and apply vim configuration from external file
install_vim() {
    echo "Installing Vim..."
    sudo apt update && sudo apt install -y vim

    echo "Applying Vim configuration from vim/.vimrc..."
    if [ -f vim/.vimrc ]; then
        cp vim/.vimrc ~/.vimrc
    else
        echo "vim/.vimrc not found!"
    fi
}

# Function to install tmux and apply tmux configuration from external file
install_tmux() {
    echo "Installing tmux..."
    sudo apt install -y tmux

    echo "Applying tmux configuration from tmux/.tmux.conf..."
    if [ -f tmux/.tmux.conf ]; then
        cp tmux/.tmux.conf ~/.tmux.conf
    else
        echo "tmux/.tmux.conf not found!"
    fi
}

# Function to setup GitHub account
setup_github() {
    echo "Setting up GitHub account..."

    # Prompt user for GitHub username and email
    read -p "Enter your GitHub username: " github_username
    read -p "Enter your GitHub email: " github_email

    # Configure global git username and email
    git config --global user.name "$github_username"
    git config --global user.email "$github_email"
    
    echo "GitHub user details configured: $github_username <$github_email>"

    # Generate an SSH key if one doesn't exist
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "Generating a new SSH key..."
        ssh-keygen -t rsa -b 4096 -C "$github_email" -f ~/.ssh/id_rsa -N ""
    else
        echo "SSH key already exists."
    fi

    # Start the ssh-agent and add the SSH private key
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa

    # Display public key and instruction to add it to GitHub
    echo "Here is your SSH public key. Copy it and add it to your GitHub account:"
    cat ~/.ssh/id_rsa.pub
    echo "Follow the instructions here to add the key: https://github.com/settings/keys"
}

# Function to source .bashrc
source_bashrc() {
    echo "Sourcing ~/.bashrc..."
    source ~/.bashrc
}

# Main function to call all others
main() {
    install_oh_my_bash
    install_vim
    install_go
    install_tmux
    setup_github
    source_bashrc
}

main
