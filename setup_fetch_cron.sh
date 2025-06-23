#!/bin/bash

# === CONFIGURATION ===
REPO_URL="git@github.com:lumagician/direkt-vom-hof-db.git"
REPO_DIR="$HOME/direkt-vom-hof-db"
PYTHON_SCRIPT="fetch.py"
REQUIREMENTS_FILE="requirements.txt"
VENV_DIR="$REPO_DIR/venv"
LOG_FILE="$HOME/fetch.log"

# === STEP 1: CLONE OR PULL THE REPO ===
if [ -d "$REPO_DIR/.git" ]; then
  echo "[*] Repository exists. Pulling latest changes..."
  cd "$REPO_DIR" && git pull
else
  echo "[*] Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

# === STEP 2: CREATE VENV AND INSTALL DEPENDENCIES ===
cd "$REPO_DIR"

if [ ! -d "$VENV_DIR" ]; then
  echo "[*] Creating Python virtual environment..."
  python3 -m venv venv
fi

echo "[*] Activating venv and installing requirements..."
source "$VENV_DIR/bin/activate"
if [ -f "$REQUIREMENTS_FILE" ]; then
  pip install --upgrade pip
  pip install -r "$REQUIREMENTS_FILE"
else
  echo "[!] requirements.txt not found."
fi
deactivate

# === STEP 3: ADD CRON JOB TO RUN FETCH.PY IN VENV ===
# Use full path to python in the venv
VENV_PYTHON="$VENV_DIR/bin/python"
CRON_CMD="cd $REPO_DIR && git pull && $VENV_PYTHON $PYTHON_SCRIPT && git add . && git commit -m 'Auto update on \$(date)' && git push"

# Escape percent signs in cron
ESCAPED_CMD=$(echo "$CRON_CMD" | sed 's/%/\\%/g')
CRON_ENTRY="59 59 * * * $ESCAPED_CMD >> $LOG_FILE 2>&1"

# Add to crontab (avoid duplicates)
( crontab -l 2>/dev/null | grep -v "$PYTHON_SCRIPT" ; echo "$CRON_ENTRY" ) | crontab -

echo "[*] Cron job added to run fetch.py daily at 23:59:59 using virtualenv."
