from util import Module, HOME, CONFIG
from pathlib import Path

# mkdir config directory
config_path: Path = HOME / "wrnlb" / "config"
if not config_path.exists():
    config_path.mkdir()
pwd = config_path.resolve().as_posix()


# nvim
nvim = Module(
    "nvim",
    "git@github.com:wrnlb666/nvim.conf.git",
    pwd,
    "nvim.conf",
).link(
    ".",
    CONFIG / "nvim",
)


# tmux
tmux = Module(
    "tmux",
    "git@github.com:gpakosz/.tmux.git",
    pwd,
    "tmux",
).link(
    ".tmux.conf",
    HOME / ".tmux.conf",
)


# tmux.conf
tmuxconf = Module(
    "tmux.conf",
    "git@github.com:wrnlb666/tmux.conf.git",
    pwd,
    "tmux.conf",
).link(
    ".tmux.conf.local",
    HOME / ".tmux.conf.local",
)


# zsh
def zsh_func() -> None:
    with open(".zshrc", "a") as zshrc:
        zshrc.write("""
        # my zsh config
        if [[ -r ~/.zshrc.local ]]; then
            source ~/.zshrc.local
        fi
        """)


zsh = Module(
    "zsh",
    "git@github.com:wrnlb666/zsh.conf.git",
    pwd,
    "zsh.conf",
).link(
    ".zshrc.local",
    HOME / ".zshrc.local",
)


# .gitconfig
git = Module(
    "git",
    "git@github.com:wrnlb666/gitconfig.git",
    pwd,
    "gitconfig",
).link(
    ".gitconfig",
    HOME / ".gitconfig",
)


# gdb
gdb = Module(
    "gdb",
    "git@github.com:wrnlb666/gdbinit.git",
    pwd,
    "gdbinit",
).link(
    ".gdbinit",
    HOME / ".gdbinit",
)


# starship
starship = Module(
    "starship",
    "git@github.com:wrnlb666/starship.toml.git",
    pwd,
    "starship",
).link(
     "starship.toml",
    CONFIG / "starship.toml",
)
