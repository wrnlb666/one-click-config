# one-click-config
My config installation script with one click

## Caution
All the config files are intended for my personal use. Backup your old config files so that there is a return.


## Installation
```sh
wget https://raw.githubusercontent.com/wrnlb666/one-click-config/refs/heads/main/install.sh
chmod +x install.sh
./install.sh
rm install.sh
```

## Parameter
Default behavior is to install all configs. But the script does not have to install all configs. 
E.g. If you only wants to install config files for `zsh`, `neovim`, `tmux`, and `starship`, do the following. 
```sh
wget https://raw.githubusercontent.com/wrnlb666/one-click-config/refs/heads/main/install.sh
chmod +x install.sh
./install.sh zsh neovim tmux starship
rm install.sh
```
