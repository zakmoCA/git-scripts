#!/bin/bash

# script for a daily & upon-startup cron job for my laptop (secondary machine)
# automates pulling latest remote changes via pull_remotes.sh if no local unstaged changes, and re-clones locally if merge conflicts

REPOS_DIR="$HOME/code"
SCRIPT_PATH="$REPOS_DIR/git-scripts/pull_remotes.sh"

check_conflicts() {
    local repo_path="$1"
    
    git fetch origin

    if git diff --quiet HEAD..origin/main; then
        return 1
    else
        if git merge-tree $(git merge-base HEAD origin/main) HEAD origin/main | grep -q "^<<<<<<< "; then
            return 0
        else
            return 1
        fi
    fi
}

refresh_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    local remote_url=$(git -C "$repo_path" config --get remote.origin.url)

    echo "deleting $repo_name..."
    rm -rf "$repo_path"

    echo "re-cloning $repo_name..."
    git clone "$remote_url" "$repo_path"
    echo "✨✨✨ $repo_name refreshed ✨✨✨"
}

cd "$REPOS_DIR" || exit 1

for dir in */; do
    cd "$REPOS_DIR/$dir" || continue

    if [ -d .git ]; then
        echo "checking repo: $dir"

        if check_conflicts "$PWD"; then
            echo "❗️conflicts detected, refreshing repo 🔄..."
            refresh_repo "$PWD"
        else
            echo "no conflicts detected"
        fi
    fi

    cd "$REPOS_DIR" || exit 1
done

echo "✅✅✅ remove_conflicts script completed"
echo "now running pull_remotes script..."

if [ -f "$SCRIPT_PATH" ]; then
    bash "$SCRIPT_PATH"
    echo "✅✅✅ pull_remotes completed, all repos up to date"
else 
    echo "❗️ERROR: pull_remotes script not found at $SCRIPT_PATH"
    exit 1
fi 
