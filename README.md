# Dotfiles

To download and run the setup workspace script, run the following command.

> Note: Script meant for UNIX based operating systems.

## Setup


### HTTP Authentication

```bash
sudo apt-get install git -y && \
git clone --recursive https://github.com/Alperencode/dotfiles.git && \
cd dotfiles && \
chmod +x setup_workspace.sh && \
./setup_workspace.sh -n
```

### HTTP Authentication (With NeoVim enabled)

```bash
sudo apt-get install git -y && \
git clone --recursive https://github.com/Alperencode/dotfiles.git && \
cd dotfiles && \
chmod +x setup_workspace.sh && \
./setup_workspace.sh -n
```

### HTTP Authentication (With NeoVim enabled)

```bash
sudo apt-get install git -y && \
git clone --recursive git@github.com:Alperencode/dotfiles.git && \
cd dotfiles && \
chmod +x setup_workspace.sh && \
./setup_workspace.sh -n
```

There is an optional `-r` flag.
Use it to show a path to text file that has github repositories you want to clone after the setup.

Usage example:

```bash
./setup_workspace.sh -r repositories.txt
```

This will parse the repositories line-by-line and clone them.
Use ssh format since the setup uses an ssh authentication. 

Example repositories.txt:

```
git@github.com:alperencode/dotfiles.git
git@github.com:alperencode/alperencode.git
```
