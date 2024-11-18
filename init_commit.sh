#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "error: .env file not found in current directory"
    exit 1
fi

usage() {
    echo "usage: $0 <repo-name>"
    echo "initializes, commits, and pushes to a new github repo"
    echo "note: ensure i have already created the repo on github"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

REPO_NAME=$1

is_git_repo() {
    git rev-parse --is-inside-work-tree &> /dev/null
}

has_commits() {
    [ -n "$(git rev-parse --verify HEAD 2>/dev/null)" ]
}

has_remote() {
    git remote -v | grep -q "origin"
}

has_files_to_commit() {
    [ -n "$(git status --porcelain)" ]
}

main() {
    if ! is_git_repo; then
        echo "error: not a git repo"
        echo "please init a git repo first"
        exit 1
    fi

    if has_commits; then
        echo "error: repo already has commits"
        echo "this script is for new repos only"
        exit 1
    fi

    if has_remote; then
        echo "error: remote 'origin' already exists"
        echo "this script is for new repos only"
        exit 1
    fi

    if ! has_files_to_commit; then
        echo "error: no files to commit"
        echo "add some files to repo first"
        exit 1
    fi

    if ! git add .; then
        echo "error: failed to add files to git"
        exit 1
    fi

    if ! git commit -m "initial commit"; then
        echo "error: failed to create initial commit"
        exit 1
    fi

    # add remote
    if ! git remote add origin "git@github-second:$SECOND_USERNAME/$REPO_NAME.git"; then
        echo "error: failed to add remote"
        echo "check if repo exists on github and you have the correct permissions"
        exit 1
    fi

    if ! git push -u origin main; then
        echo "error: failed to push to remote repo"
        echo "possible issues:"
        echo "  - repository doesn't exist on github"
        echo "  - ssh key not properly configured"
        echo "  - no internet connection"
        git remote remove origin
        exit 1
    fi

    echo "success: git repo initialised and first commit pushed to github"
    echo "repository url: https://github.com/$SECOND_USERNAME/$REPO_NAME"
}

# run main function
main
