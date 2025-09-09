#!/usr/bin/env bash

# Try installing mikefarah/yq if not exists
if [[ ! -x "$(command -v yq)" ]]; then
    echo "[WARN] yq not installed"
    # distro="$(lsb_release -d | cut -f2)"
    if [[ -x "$(command -v pacman)" ]]; then
        sudo pacman -S --noconfirm go-yq
    elif [[ -x "$(command -v stew)" ]]; then
        stew i mikefarah/yq
    elif [[ -x "$(command -v brew)" ]]; then
        brew install yq
    elif [[ -x "$(command -v go)" ]]; then
        go install github.com/mikefarah/yq/v4@latest
        PATH="$(go env GOPATH):$PATH"
    elif [[ -x "$(command -v snap)" ]]; then
        snap install yq
    else
        echo "[ERRO] please install yq manually"
        exit 1
    fi
fi

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


# Global Variables
root="$(pwd)"
dir="${HOME}/wrnlb/config"
config=$(cat "$(swd)/config.yaml")
ins_all=false
use_http=false
mapfile -t keys < <(echo "$config" | yq 'keys[]')


# Helper function
_exists() {
    local repo="$1"
    local res="$(echo "$config" | yq ".${repo}")"
    if [[ "$res" == "null" ]]; then
        return 1
    fi
    return 0
}

get_url() {
    local repo="$1"
    echo "$config" | yq ".${repo}.url"
}

get_target() {
    local repo="$1"
    echo "$config" | yq ".${repo}.target"
}

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

_list() {
    printf "Available Configs:\n  "
    for key in ${keys[@]}; do
        printf "%s " "${key}"
        # url="$(get_url ${key})"
        # target="$(get_target ${key})"
        # echo "${key}: "
        # echo "  url:    ${url}"
        # echo "  target: ${target}"
    done
    echo
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
        --http|--https)
            use_http=true
            shift
            ;;
        -a|--all|all)
            ins_all=true
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

# cd into target directory
[[ -d "${dir}" ]] || mkdir -p "${dir}"
command cd "${dir}"

if ${ins_all}; then
    _install_all
    exit 0
fi

for key in ${repos[@]}; do
    _install "$key"
done
