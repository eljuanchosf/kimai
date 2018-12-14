#! /usr/bin/env bash

source ../.env

if [ ! -z "$MYSQL_PEM" ]; then
    echo "Downloading MySQL PEM file"
    curl -s https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem -o $MYSQL_PEM
    chown :www-data $MYSQL_PEM
fi

echo "Connecting to DB with:"
cat <<EOF
Hostname: $MYSQL_HOSTNAME
User:     $MYSQL_USER
Database: $MYSQL_DATABASE
PEM:      $MYSQL_PEM
EOF

mysql -h $MYSQL_HOSTNAME -u $MYSQL_USER -p$MYSQL_PASSWORD -D $MYSQL_DATABASE --ssl-mode=VERIFY_CA \
	--ssl-ca=$MYSQL_PEM
