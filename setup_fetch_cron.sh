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

# === STEP 3: CREATE WRAPPER SCRIPT ===
WRAPPER="$HOME/run_fetch.sh"
cat <<EOF > "$WRAPPER"
#!/bin/bash
cd "$REPO_DIR"
source "$VENV_DIR/bin/activate"
git pull
python3 "$PYTHON_SCRIPT"
git add .
git commit -m "Automated update from fetch.py on \$(date)"
git push
deactivate
EOF

chmod +x "$WRAPPER"

# === STEP 4: ADD CRON JOB ===
CRON_ENTRY="59 59 * * * $WRAPPER >> $LOG_FILE 2>&1"
( crontab -l 2>/dev/null | grep -v "$WRAPPER" ; echo "$CRON_ENTRY" ) | crontab -

echo "[*] Cron job added to run daily at 23:59:59."
