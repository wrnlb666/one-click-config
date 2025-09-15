#!/usr/bin/env bash

# Script Working Directory
swd()
{
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        # Get symlink directory
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        # Resolve symlink target (relative or absolute)
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            # Candidate path is relative, resolve to full path
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    # Get final script directory path from fully resolved source path
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}

source "$(swd)/util.sh"

# Global Variables
root="$(pwd)"
dir="${HOME}/wrnlb/config"
config=$(cat "$(swd)/config.yaml")
install_all=false
install_occ=false
use_http=false
mapfile -t keys < <(echo "$config" | yq 'keys[]')


# Helper function
_help() {
    echo "Usage: "
    echo "  ${0} [OPTION] [CONFIG]..."
    echo "  With no OPTION or CONFIG specified defaults to -h."
    echo ""
    echo "Options:"
    echo "  -h, --help, help        Print this help menu"
    echo "  -l, --list, ls, list    List current available configs"
    echo "  -a, --all, all          Install all available configs"
    echo "  --http                  Clone with https instead of ssh"
    echo "  -d, --dir               Config dir, defaults to ~/wrnlb/config"
}

_install() {
    local rc
    local err
    local repo="$1"
    if ! _exists "${repo}"; then
        echo "[ERRO] ${repo} does not exist"
        return 1
    fi
    local url="$(get_url "${repo}")"
    local target="$(get_target "${repo}")"
    
    if "${use_http}"; then
        url="https://github.com/${url}"
    else
        url="git@github.com:${url}"
    fi

    echo "[INFO] Cloning ${repo}..."
    err="$(git clone "$url" "$target" 2>&1 1>/dev/null)"
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "[ERRO] git faled to clone ${repo}:"
        IFS=$'\n'
        for line in ${err}; do
            echo "  $line"
        done
        exit 1
    fi
    echo "[INFO] Installing ${repo}..."
    (command cd "$target" && ./install.sh)
}

_install_occ() {
    [[ -d ~/.local/bin ]] || mkdir ~/.local/bin
    ln -sf "$(swd)/occ" ~/.local/bin/occ
}

_install_all() {
    [[ -d "${dir}" ]] || mkdir -p "${dir}"
    command cd "${dir}"
    for key in ${keys[@]}; do
        _install "$key"
    done
}


# Main Function
if [[ "$#" -eq 0 ]]; then
    _help
    exit 0
fi

_install_yq
declare -a repos
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help|help)
            _help
            exit 0
            shift
            ;;
        -l|--list|ls|list)
            _list
            exit 0
            shift
            ;;
        -d|--dir)
            dir="$2"
            shift
            shift
            ;;
        occ)
            install_occ=true
            shift
            ;;
        --http|--https)
            use_http=true
            shift
            ;;
        -a|--all|all)
            install_all=true
            install_occ=true
            shift
            ;;
        -*|--*)
            echo "[ERRO] Unknown option $1"
            _help
            exit 1
            ;;
        *)
            repos+=("$1")
            shift
            ;;
    esac
done

# install occ
[[ "$install_occ" ]] && _install_occ

# cd into target directory
[[ -d "${dir}" ]] || mkdir -p "${dir}"
command cd "${dir}"

if ${install_all}; then
    _install_all
    exit 0
fi

for key in ${repos[@]}; do
    _install "$key"
done
