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
CRON_CMD="$REPO_DIR/auto_commit.sh"

# Escape percent signs in cron
ESCAPED_CMD=$(echo "$CRON_CMD" | sed 's/%/\\%/g')
CRON_ENTRY="10 * * * * $ESCAPED_CMD >> $LOG_FILE 2>&1"

# === STEP 3: ADD CRON JOB TO RUN AUTOCOMMIT.SH ===
( crontab -l 2>/dev/null | grep -v "auto_commit.sh" ; echo "$CRON_ENTRY" ) | crontab -

echo "[*] Cron job added to run auto_commit.sh daily at 55 every hour."