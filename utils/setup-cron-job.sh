#! /usr/bin/env bash

set -e

crontab -l | { cat; echo "0 4 * * * /home/juan/dev/kimai/utils/backup-db.sh >/dev/null 2>&1"; } | crontab -
