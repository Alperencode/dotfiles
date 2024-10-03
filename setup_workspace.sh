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
    source_bashrc
}

main

