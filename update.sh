#!/usr/bin/env bash

# Script Working Directory
swd() {
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

dcwd="$(swd)"
source "${dcwd}/util.sh"
# _install_yq

# Global Variables
root="$(pwd)"
dir="$(cd -P "${dcwd}/.." >/dev/null 2>&1 && pwd)"
config=$(cat "${dcwd}/config.json")
update_all=false
update_occ=false
mapfile -t keys < <(echo "$config" | jq -r 'keys[]')


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
    echo "  -d, --dir               Config dir, defaults to ${dir}"
}

_list() {
    printf "Available Configs:\n  "
    for key in ${keys[@]}; do
        local target="$(get_target "$key")" 
        if [[ -d "${dir}/${target}" ]]; then
            printf "%s " "${key}"
        fi
    done
    echo
}

_update() {
    local rc
    local err
    local repo="$1"
    local target="$(get_target ${repo})"
    if ! _exists "${repo}"; then
        echo "[ERRO] ${repo} does not exist"
        return 1
    fi

    echo "[INFO] Fetching ${repo} from remote..."
    local cwd="$(pwd)"
    command cd "$target"
    local cb="$(git branch --show-current)"
    local db="$(_default_branch)"
    local before=$(git rev-parse "origin/${db}")
    git fetch origin --quiet
    local after=$(git rev-parse "origin/${db}")
    [[ "$before" != "$after" ]] && git diff "$before" "$after"
    for branch in $(git branch --format="%(refname:short)"); do
        if [[ \
                "$(git rev-parse "${branch}")" == \
                "$(git rev-parse "origin/${branch}")" \
            ]]; then
            continue
        fi
        echo "[INFO] Rebasing onto branch ${branch}"
        git checkout "$branch" > /dev/null 2> /dev/null
        err="$(git rebase --autostash "origin/${branch}" 2>&1 1>/dev/null)"
        rc=$?
        if [[ $rc -ne 0 ]]; then
            echo "[ERRO] git failed to rebase onto branch ${branch}:"
            IFS=$'\n'
            for line in ${err}; do
                echo "  $line"
            done
            git rebase --abort >/dev/null
            command cd "$cwd"
            return 1
        fi
    done
    git checkout "$cb" > /dev/null 2> /dev/null
    if [[ -f "update.sh" ]]; then
        echo "[INFO] Executing update.sh for ${repo}"
        ./update.sh
    fi
    command cd "$cwd"
}

_update_occ() {
    local rc
    local err

    echo "[INFO] Fetching occ from remote"
    local cwd="$(pwd)"
    command cd "${dcwd}"
    local cb="$(git branch --show-current)"
    local db="$(_default_branch)"
    local before=$(git rev-parse "origin/${db}")
    git fetch origin --quiet
    local after=$(git rev-parse "origin/${db}")
    [[ "$before" != "$after" ]] && git diff "$before" "$after"
    for branch in $(git branch --format="%(refname:short)"); do
        if [[ \
                "$(git rev-parse "${branch}")" == \
                "$(git rev-parse "origin/${branch}")" \
            ]]; then
            continue
        fi
        echo "[INFO] Rebasing onto branch ${branch}"
        git checkout "$branch" > /dev/null 2> /dev/null
        err="$(git rebase --autostash "origin/${branch}" 2>&1 1>/dev/null)"
        rc=$?
        if [[ $rc -ne 0 ]]; then
            echo "[ERRO] git failed to rebase onto branch ${branch}:"
            IFS=$'\n'
            for line in ${err}; do
                echo "  $line"
            done
            git rebase --abort >/dev/null
            command cd "$cwd"
            exit 1
        fi
    done
    git checkout "$cb" > /dev/null 2> /dev/null
    command cd "$cwd"
}

_update_all() {
    [[ -d "${dir}" ]] || mkdir -p "${dir}"
    command cd "${dir}"
    for key in ${keys[@]}; do
        local target="$(get_target ${key})"
        [[ -d "$target" ]] || continue
        _update "$key"
    done
}


# Main Function
_install_jq

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
        -a|--all|all)
            update_all=true
            update_occ=true
            shift
            ;;
        occ)
            update_occ=true
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

# update occ
"$update_occ" && _update_occ

# cd into target directory
[[ -d "${dir}" ]] || mkdir -p "${dir}"
command cd "${dir}"

# update all
if ${update_all}; then
    _update_all
    exit 0
fi

# update selected
for key in ${repos[@]}; do
    _update "$key"
done
