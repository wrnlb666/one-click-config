#!/usr/bin/env sh

# make config folder
mkdir -p ~/wrnlb/config
cd ~/wrnlb/config

# git
git clone git@github.com:wrnlb666/gitconfig.git
ln -sf $(pwd)/gitconfig/.gitconfig ~/

# zsh
git clone git@github.com:wrnlb666/zsh.conf.git
ln -sf $(pwd)/zsh.conf/.zshrc.local ~/
echo "# my zsh config" >> ~/.zshrc
echo "if [ -r ~/.zshrc.local ]; then" >> ~/.zshrc
echo "    source ~/.zshrc.local" >> ~/.zshrc
echo "fi" >> ~/.zshrc

# nvim
git clone git@github.com:wrnlb666/nvim.conf.git
ln -sf $(pwd)/nvim.conf ~/.config/nvim

# tmux
git clone git@github.com:gpakosz/.tmux.git tmux
ln -sf $(pwd)/tmux/.tmux.conf ~/
git clone git@github.com:wrnlb666/tmux.conf.git
ln -sf $(pwd)/tmux.conf/.tmux.conf.local ~/

# starship
git clone git@github.com:wrnlb666/starship.toml.git starship
ln -sf $(pwd)/starship/starship.toml ~/

# gdb
git clone git@github.com:wrnlb666/gdbinit.git
ln -s -f $(pwd)/gdbinit/.gdbinit ~/
