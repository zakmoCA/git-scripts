#!/bin/bash

# pull remotes for all local repos modified in the last 4 weeks

REPOS_DIR="$HOME/code"

cd "$REPOS_DIR" || exit

for dir in $(find . -type d -mtime -28 -maxdepth 1); do
    cd "$dir" || continue
    if [ -d .git ]; then
        echo "checking repository: $dir"
        
        if [ -z "$(git status --porcelain)" ]; then
            echo "✋ there are upstream changes in the remote repo"
            echo "no local unstaged changes 👍"
            echo "✅ pulling latest changes..."
            git pull
            echo "✨✨✨ successfully pulled latest changes ✨✨✨"
        else
            echo "unstaged changes present, skipping..."
        fi
    fi

    cd "$REPOS_DIR" || exit
done

echo "all appropriate repositories up to date with remote"