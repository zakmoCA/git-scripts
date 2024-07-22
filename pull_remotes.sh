#!/bin/bash

# pull remotes for all local repos modified in the last 4 weeks

REPOS_DIR="$HOME/code"

cd "$REPOS_DIR" || exit

for dir in $(find . -type d -mtime -28 -maxdepth 1); do
    cd "$dir" || continue
    if [ -d .git ]; then
        echo "checking repository: $dir"
        
        if [ -z "$(git status --porcelain)" ]; then
            echo "no unstaged changes, pulling latest changes..."
            git pull
        else
            echo "unstaged changes present, skipping..."
        fi
    fi

    cd "$REPOS_DIR" || exit
done

echo "all appropriate repositories up to date with remote"