#!/usr/bin/env sh

# info func
info() {
    msg="$@"
    echo "[INFO]: installing $msg"
}

# git
igit() {
    info git
    git clone git@github.com:wrnlb666/gitconfig.git
    ln -sf $(pwd)/gitconfig/.gitconfig ~/
}

# zsh
izsh() {
    info zsh
    git clone git@github.com:wrnlb666/zsh.conf.git
    ln -sf $(pwd)/zsh.conf/.zshrc.local ~/
    echo "# my zsh config" >> ~/.zshrc
    echo "if [ -r ~/.zshrc.local ]; then" >> ~/.zshrc
    echo "    source ~/.zshrc.local" >> ~/.zshrc
    echo "fi" >> ~/.zshrc
}

# nvim
invim() {
    info nvim
    git clone git@github.com:wrnlb666/nvim.conf.git
    ln -sf $(pwd)/nvim.conf ~/.config/nvim
}

# tmux
itmux() {
    info tmux
    git clone git@github.com:gpakosz/.tmux.git tmux
    ln -sf $(pwd)/tmux/.tmux.conf ~/
    git clone git@github.com:wrnlb666/tmux.conf.git
    ln -sf $(pwd)/tmux.conf/.tmux.conf.local ~/
}

# starship
istarship() {
    info starship
    git clone git@github.com:wrnlb666/starship.toml.git starship
    ln -sf $(pwd)/starship/starship.toml ~/
}

# gdb
igdb() {
    info gdb
    git clone git@github.com:wrnlb666/gdbinit.git
    ln -s -f $(pwd)/gdbinit/.gdbinit ~/
}

# all
iall() {
    igit
    izsh
    invim
    itmux
    istarship
    igdb
}

# main
install="$@"

# make config folder
mkdir -p ~/wrnlb/config
cd ~/wrnlb/config

if [ $# -eq 0 ]; then
    iall
    exit 0
fi

if [ "${install[0]}" = "all" ]; then
    iall
    exit 0
fi

# main loop
for c in $install; do
    case "$c" in
        git)
            igit
            ;;
        zsh)
            izsh
            ;;
        nvim)
            invim
            ;;
        neovim)
            invim
            ;;
        tmux)
            itmux
            ;;
        starship)
            istarship
            ;;
        gdb)
            igdb
            ;;
        *)
            echo "[ERRO]: unrecognize config $c" >&2
            exit 1
            ;;
    esac
done


