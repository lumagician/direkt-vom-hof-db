#!/bin/bash

# === CONFIGURATION ===
REPO_URL="git@github.com:lumagician/direkt-vom-hof-db.git"
REPO_DIR="$HOME/direkt-vom-hof-db"
PYTHON_SCRIPT="fetch.py"
REQUIREMENTS_FILE="requirements.txt"
LOG_FILE="$HOME/fetch.log"

# === STEP 1: CLONE OR PULL THE REPO ===
if [ -d "$REPO_DIR/.git" ]; then
  echo "[*] Repository exists. Pulling latest changes..."
  cd "$REPO_DIR" && git pull
else
  echo "[*] Cloning repository..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

# === STEP 2: INSTALL PYTHON DEPENDENCIES ===
if [ -f "$REPO_DIR/$REQUIREMENTS_FILE" ]; then
  echo "[*] Installing requirements..."
  pip3 install -r "$REPO_DIR/$REQUIREMENTS_FILE"
else
  echo "[!] requirements.txt not found."
fi

# === STEP 3: CREATE WRAPPER SCRIPT ===
WRAPPER="$HOME/run_fetch.sh"
cat <<EOF > "$WRAPPER"
#!/bin/bash
cd "$REPO_DIR"
git pull
python3 "$PYTHON_SCRIPT"
git add .
git commit -m "Automated update from fetch.py on \$(date)"
git push
EOF

chmod +x "$WRAPPER"

# === STEP 4: ADD CRON JOB ===
CRON_ENTRY="59 59 * * * $WRAPPER >> $LOG_FILE 2>&1"
( crontab -l 2>/dev/null | grep -v "$WRAPPER" ; echo "$CRON_ENTRY" ) | crontab -

echo "[*] Cron job added to run daily at *:59:59."
