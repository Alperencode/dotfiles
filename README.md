# Dotfiles

To download and run the setup workspace script, run the following command.

> Note: Script meant for UNIX based operating systems.

```bash
git clone --recursive https://github.com/Alperencode/dotfiles.git && \
cd dotfiles && \
chmod +x setup_workspace.sh && \
./setup_workspace.sh
```

There is an optional -r flag.
Use it to show a path to text file that has github repositories you want to clone after the setup.

Usage example:

```bash
./setup_workspace.sh -r repositories.txt
```

This will parse the repositories line-by-line and clone them.