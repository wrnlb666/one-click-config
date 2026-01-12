# Try installing jq if not exists
_install_jq_binary() {
    local err="[ERRO] please install jq manually"
    local required=("uname" "curl")
    for r in ${required[@]}; do
        if [[ ! -x "$(command -v "$r")" ]]; then
            echo "$err"
            return 1
        fi
    done
    # check OS
    local OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
    local os
    case "$OS" in
        linux)
            os="linux"
            ;;
        darwin)
            os="macos"
            ;;
        *)
            echo "$err"
            return 1
            ;;
    esac
    # check ARCH
    local ARCH="$(uname -m)"
    local arch
    case "$ARCH" in
        x86_64)
            arch="amd64"
            ;;
        aarch64)
            arch="arm64"
            ;;
        *)
            echo "$err"
            return 1
            ;;
    esac
    # install jq from github
    [[ -d ~/.local/bin ]] || mkdir -p ~/.local/bin
    curl "https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-${os}-${arch}" \
        -Lo ~/.local/bin/jq
    if [[ $? -ne 0 ]]; then
        echo "$err"
        return 1
    fi
    chmod +x ~/.local/bin/jq
    export PATH="${HOME}/.local/bin:$PATH"
}

_install_jq() {
    if [[ ! -x "$(command -v jq)" ]]; then
        echo "[WARN] jq not installed"
        # distro="$(lsb_release -d | cut -f2)"
        if [[ -x "$(command -v pacman)" ]]; then
            sudo pacman -S --noconfirm jq || exit 1
        elif [[ -x "$(command -v dnf)" ]]; then
            sudo dnf5 install -y jq || exit 1
        elif [[ -x "$(command -v apt)" ]]; then
            sudo apt install -y jq || exit 1
        elif [[ -x "$(command -v brew)" ]]; then
            brew install jq || exit 1
        else
            _install_jq_binary || exit 1
        fi
    fi
}

# Get default branch to show diff
_default_branch() {
    # Try the locally cached remote HEAD
    local ref
    ref=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null) || true
    if [ -n "$ref" ]; then
        echo "${ref#origin/}"
        return 0
    fi

    # Fallbacks
    if git show-ref --verify --quiet refs/heads/main; then
        echo "main"; return 0
    fi
    if git show-ref --verify --quiet refs/heads/master; then
        echo "master"; return 0
    fi

    echo "[ERRO] Could not determine default branch locally." >&2
    exit 1
}

# Helper functions
_exists() {
    local repo="$1"
    local res="$(echo "$config" | jq -r ".${repo}")"
    if [[ "$res" == "null" ]]; then
        return 1
    fi
    return 0
}

get_git() {
    local repo="$1"
    echo "$config" | jq -r ".${repo}.git"
}

get_url() {
    local repo="$1"
    echo "$config" | jq -r ".${repo}.url"
}

get_target() {
    local repo="$1"
    echo "$config" | jq -r ".${repo}.target"
}
