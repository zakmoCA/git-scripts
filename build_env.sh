#!/bin/bash

if [ ! -f "$HOME/.ssh/config" ]; then
    echo "error: git config not found at $HOME/.git-config/config"
    exit 1
fi

source "$HOME/.ssh/config"

# build machines local .env 
cat > .env << EOF
# github account credentials
# generated from sys configs on $(date)
ORIGINAL_USERNAME="$GIT_ORIGINAL_USERNAME"
ORIGINAL_ACCOUNT_EMAIL="$GIT_ORIGINAL_ACCOUNT_EMAIL"
SECOND_USERNAME="$GIT_SECOND_USERNAME"
SECOND_ACCOUNT_EMAIL="$GIT_SECOND_ACCOUNT_EMAIL"
EOF

echo "created .env file from zshell configs"