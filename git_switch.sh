#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "error: .env file not found in current directory"
    exit 1
fi

REPOS_DIR="$HOME/code"
ENV_BUILD_PATH="$REPOS_DIR/git-switch/build_env.sh"

declare -A GIT_ACCOUNTS=(
    ["$ORIGINAL_USERNAME"]="$ORIGINAL_ACCOUNT_EMAIL"
    ["$SECOND_USERNAME"]="$SECOND_ACCOUNT_EMAIL"
)

usage() {
    echo "usage: $0 <scope> <github-username>"
    echo "scope options:"
    echo "  - local (or l): set git config for new repository only"
    echo "  - global (or g): set global git config"
    echo "available accounts:"
    for account in "${!GIT_ACCOUNTS[@]}"; do
        echo "  - $account"
    done
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

SCOPE=$1
USERNAME=$2

case $SCOPE in
    "local" | "l")
        SCOPE="local"
        ;;
    "global" | "g")
        SCOPE="global"
        ;;
    *)
        echo "error: invalid scope. use 'local/l' or 'global/g'"
        usage
        ;;
esac

if [ -z "${GIT_ACCOUNTS[$USERNAME]}" ]; then
    echo "error: unknown github username '$USERNAME'"
    usage
fi

is_git_repo() {
    git rev-parse --is-inside-work-tree &> /dev/null
}

has_commits() {
    [ -n "$(git rev-parse --verify HEAD 2>/dev/null)" ] 
}

handle_local_config() {
    if is_git_repo; then
        if has_commits; then
            echo "error: cannot set local git config - repository already has commits"
            echo "this script is for fresh repos/new global config for subsequent repos"
            exit 1
        fi
    else
        git init
    fi
    
    git config user.name "$USERNAME"
    git config user.email "${GIT_ACCOUNTS[$USERNAME]}"
    
    echo "local git configuration updated for this repository:"
    echo "user: $(git config user.name)"
    echo "email: $(git config user.email)"
}

handle_global_config() {
    git config --global user.name "$USERNAME"
    git config --global user.email "${GIT_ACCOUNTS[$USERNAME]}"
    
    echo "global git configuration updated:"
    echo "user: $(git config --global user.name)"
}

if [ "$SCOPE" = "local" ]; then
    handle_local_config
else
    handle_global_config
fi

echo -e "\nreminder:"
if [ "$USERNAME" = "$SECOND_USERNAME" ]; then
    echo "for new repositories, use ssh with github-second:"
    echo "git remote add origin git@github-second:$USERNAME/repo-name.git"
else
    echo "for new repositories, use https:"
    echo "git remote add origin https://github.com/$USERNAME/repo-name.git"
fi

# build .env if none on local machine
if [ ! -f .env.example ]; then
    bash "$ENV_BUILD_PATH"
fi