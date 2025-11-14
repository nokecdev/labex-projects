#!/bin/bash

echo "Log Manager Initialized."
LOG_DIR="/home/labex/project/app_logs"
DEST_DIR="~/project/backups"

if [ -d "$LOG_DIR" ]; then
    echo "Enter the backup filename: "
    read BACKUP_FILENAME
    echo "Backing up logs to: $BACKUP_FILENAME"
    if [ ! -d "$DEST_DIR" ]; then
        mkdir -p $DEST_DIR
    fi
    for file in $LOG_DIR/*; do
        filename=$(basename "$file")
        cp $file $DEST_DIR/$filename
        echo "Copied $file"
    done
    echo "Backup complete."
else
    echo "Error: Log directory not found"
    echo "exit 1"
fi