#!/bin/bash

REPO_DIR="$HOME/direkt-vom-hof-db"
VENV_DIR="$REPO_DIR/venv"
PYTHON="$VENV_DIR/bin/python"

cd "$REPO_DIR" || exit 1

# Pull latest changes
git pull origin main

# Activate venv and run Python script
source "$VENV_DIR/bin/activate"
$PYTHON fetch.py
deactivate

# Git commit & push
git add .
if ! git diff --cached --quiet; then
    git commit -m "Auto update: $(date)"
    git push origin main
else
    echo "No changes to commit."
fi
