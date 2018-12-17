#! /usr/bin/env bash

set -e

sudo apt-get install -y -qq zip unzip

source ../.env

backup_dir="/mnt/KimaiBackups"
backup_file="$backup_dir/$(date -I).sql"

# Backup the database
mysqldump -h "$MYSQL_HOSTNAME" \
          -u "$MYSQL_USER" \
          -p"$MYSQL_PASSWORD" \
          -d "$MYSQL_DATABASE" \
          --ssl-mode=VERIFY_CA \
          --ssl-ca="$MYSQL_PEM" \
          --add-drop-table \
          --add-drop-database \
          > $backup_file

zip $backup_file.zip $backup_file
rm -f $backup_file

echo "Purging old backups (7 days or older)"
find $backup_dir -type f -mtime +6 -exec rm "{}" \;
