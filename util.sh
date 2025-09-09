
# Try installing mikefarah/yq if not exists
_instal_yq() {
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

