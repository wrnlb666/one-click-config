#!/usr/bin/env bash

# Try installing mikefarah/yq if not exists
if [[ ! -x "$(command -v yq)" ]]; then
    echo "[WARN] yq not installed"
    distro="$(lsb_release -d | cut -f2)"
    if [[ -x "$(command -v pacman)" ]]; then
        sudo pacman -S --no-confirm go-yq
    else
        echo "[ERRO] please install yq manually"
        exit 1
    fi
fi


# Global Variables
root="$(pwd)"
dir="${HOME}/wrnlb/config"
config=$(cat "${root}/config.yaml")
ins_all=false
mapfile -t keys < <(echo "$config" | yq 'keys[]')


# Helper function
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
    echo "  -h, --help      Print this help menu"
    echo "  -l, --list      List current available configs"
    echo "  -a, --all       Install all available configs"
    echo "  -d, --dir       Config dir, defaults to ~/wrnlb/config"
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
    local url="$(get_url ${repo})"
    local target="$(get_target ${repo})"

    echo "[INFO] Cloning ${repo}..."
    err="$(git clone "$url" "$target" 2>&1)"
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
    (cd "$target" && ./install.sh)
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
        -h|--help)
            _help
            exit 0
            shift
            ;;
        -l|--list)
            _list
            exit 0
            shift
            ;;
        -d|--dir)
            dir="$2"
            shift
            shift
            ;;
        -a|--all)
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

if ${ins_all}; then
    _install_all
    exit 0
fi

[[ -d "${dir}" ]] || mkdir -p "${dir}"
command cd "${dir}"
for key in ${repos[@]}; do
    _install "$key"
done
