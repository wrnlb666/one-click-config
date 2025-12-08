
# Try installing mikefarah/yq if not exists
_install_yq_binary() {
    local err="[ERRO] please install yq manually"
    local required=("uname" "curl")
    for r in ${required[@]}; do
        if [[ ! -x "$(command -v "$r")" ]]; then
            echo "$err"
            return 1
        fi
    done
    # check OS
    local OS="$(uname -s)"
    local os
    case "$OS" in
        Linux)
            os="linux"
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
        *)
            echo "$err"
            return 1
            ;;
    esac
    # install yq from github
    [[ -d ~/.local/bin ]] || mkdir -p ~/.local/bin
    curl "https://github.com/mikefarah/yq/releases/latest/download/yq_${os}_${arch}" \
        -Lo ~/.local/bin/yq
    if [[ $? -ne 0 ]]; then
        echo "$err"
        return 1
    fi
    chmod +x ~/.local/bin/yq
    export PATH="${HOME}/.local/bin:$PATH"
}

_install_yq() {
    if [[ ! -x "$(command -v yq)" ]]; then
        echo "[WARN] yq not installed"
        # distro="$(lsb_release -d | cut -f2)"
        if [[ -x "$(command -v pacman)" ]]; then
            sudo pacman -S --noconfirm go-yq || exit 1
        elif [[ -x "$(command -v dnf5)" ]]; then
            sudo dnf5 install -y yq || exit 1
        elif [[ -x "$(command -v brew)" ]]; then
            brew install yq || exit 1
        elif [[ -x "$(command -v go)" ]]; then
            go install github.com/mikefarah/yq/v4@latest || exit 1
            export PATH="$(go env GOPATH):$PATH"
        else
            _install_yq_binary || exit 1
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

_list() {
    printf "Available Configs:\n  "
    for key in ${keys[@]}; do
        printf "%s " "${key}"
    done
    echo
}

