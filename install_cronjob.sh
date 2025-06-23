#!/bin/bash

# Full path to the auto script
SCRIPT_PATH="/home/pi/direkt-vom-hof-db/auto_commit.sh"
LOG_FILE="/home/piauto_commit.log"

# Cron job line (runs every hour)
CRON_JOB="0 * * * * bash $SCRIPT_PATH >> $LOG_FILE 2>&1"

# Install the cron job if not already present
( crontab -l 2>/dev/null | grep -v -F "$SCRIPT_PATH" ; echo "$CRON_JOB" ) | crontab -
echo "Cron job installed to run every hour."
