#!/bin/bash

# Navigate to the repo directory
cd /home/pi/direkt-vom-hof-db || exit 1

# Git pull latest changes
git pull origin main

# Run the Python script
python3 fetch.py

# Stage any changes
git add .

# Commit changes if there are any
if ! git diff --cached --quiet; then
    git commit -m "Auto update: $(date)"
    git push origin main
else
    echo "No changes to commit."
fi
