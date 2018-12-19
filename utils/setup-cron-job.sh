#! /usr/bin/env bash

set -e

crontab -l | { cat; echo "0 4 * * * /home/juan/dev/kimai/utils/backup-db.sh 2>&1 | /usr/bin/logger -t kimai-backup"; } | crontab -
