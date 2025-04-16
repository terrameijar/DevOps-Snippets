#!/usr/bin/env bash

LOG_FILE="/var/log/wp_backup.log"

# Direct script output to both stdout and the log file
exec > >(tee -a "$LOG_FILE") 2>&1

WP_DB_NAME=""
WP_HOSTNAME="localhost"
MYSQL_OPTS_FILE=""
DATE=$(date +"%d-%m-%Y")
YEAR=$(date +"%Y")
WP_BACKUP_LOCATION=""
WP_BACKUP_FILE="$WP_BACKUP_LOCATION/${WP_DB_NAME}_backup_$DATE.sql.gz"
WP_ROOT_DIR_BACKUP_FILE="$WP_BACKUP_LOCATION/public_html_backup_$DATE.tar.gz"
WP_DATA_DIR=""

S3_BUCKET=""


# Initial setup, check that required files and directories exist
echo "$(date +"%d-%m-%Y %H:%M") - Checking prerequisites..."
if [[ ! -f "$MYSQL_OPTS_FILE" ]]; then
        echo "$(date +"%d-%m-%Y %H:%M") - Error: MySQL options file not found at $MYSQL_OPTS_FILE" >&2
        exit 1
fi

if [[ ! -d "$WP_BACKUP_LOCATION" ]]; then
        mkdir -p "$WP_BACKUP_LOCATION" || { echo "Failed to create backup directory: $WP_BACKUP_LOCATION" >&2; exit 1; }
fi


echo "$(date +"%d-%m-%Y %H:%M") - Starting database backup..."
if mysqldump --defaults-file="$MYSQL_OPTS_FILE" --add-drop-table -h "$WP_HOSTNAME"  "$WP_DB_NAME" | gzip > "$WP_BACKUP_FILE"; then
        echo "$(date +"%d-%m-%Y %H:%M") - Backup Successful: $WP_BACKUP_FILE ($(date))"
        echo "$(date +"%d-%m-%Y %H:%M") - Deleting DB backups older than 30 days"
        find "$WP_BACKUP_LOCATION" -type f -name "*.sql.gz" -mtime +30 -delete
else
        echo "$(date +"%d-%m-%Y %H:%M") - Database backup failed for $WP_DB_NAME on $WP_HOSTNAME" >&2
        exit 1
fi

echo "$(date +"%d-%m-%Y %H:%M") - Starting Wordpress Files Backup..."
if tar -zcf "$WP_ROOT_DIR_BACKUP_FILE" "$WP_DATA_DIR"; then
        echo "$(date +"%d-%m-%Y %H:%M") - Wordpress root directory backup successfull: $WP_ROOT_DIR_BACKUP_FILE"
        echo "$(date +"%d-%m-%Y %H:%M") - Deleting WP root directory backups older than 30 days"
        find "$WP_BACKUP_LOCATION" -type f -name "*.tar.gz" -mtime +30 -delete
else
        echo "$(date +"%d-%m-%Y %H:%M") - Wordpress root directory backup failed. Check permissions or disk space." >&2
        exit 1
fi

# Upload database backup to S3
echo "$(date +"%d-%m-%Y %H:%M") - Uploading Database backup to S3..."
if aws s3 cp "$WP_BACKUP_FILE" "s3://$S3_BUCKET/$YEAR/"; then
        echo echo "$(date +"%d-%m-%Y %H:%M") - Database backup uploaded to S3" >&2
else
        echo echo "$(date +"%d-%m-%Y %H:%M") - Failed to upload database backup to S3"
        exit 1
fi


# Upload WordPress Root directory to S3
echo "$(date +"%d-%m-%Y %H:%M") - Starting Wordpress Root Directory Backup..."
if aws s3 cp "$WP_ROOT_DIR_BACKUP_FILE" "s3://$S3_BUCKET/$YEAR/"; then
        echo "$(date +"%d-%m-%Y %H:%M") - WordPress root directory backup uploaded to S3: s3://$S3_BUCKET/$YEAR/$(basename "$WP_ROOT_DIR_BACKUP_FILE")"
else
        echo "$(date +"%d-%m-%Y %H:%M") - Failed to upload WordPress Root directory"
        exit 1
fi
