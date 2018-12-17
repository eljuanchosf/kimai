#! /usr/bin/env bash

set -e

source ../.env

my_ip=$(dig @resolver1.opendns.com ANY myip.opendns.com +short)

if [ ! -z "$MYSQL_PEM" ]; then
    echo "Downloading MySQL PEM file"
    curl -s https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem -o $MYSQL_PEM
    chown :www-data $MYSQL_PEM
fi

MYSQL_USER=$(echo "$MYSQL_USER" | cut -f1 -d"@")

echo "Connecting to DB with:"
cat <<EOF
Connection information:
Hostname: $MYSQL_HOSTNAME
User:     $ROOT_USER
Database: $MYSQL_DATABASE
PEM:      $MYSQL_PEM

User to be created:
User:     $MYSQL_USER
My IP:    $my_ip
EOF

grant_privileges="GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'$my_ip' IDENTIFIED BY '$MYSQL_PASSWORD';"

#echo "Creating user..."
# mysql -u "$ROOT_USER" -p"$ROOT_PASSWORD" -h "$MYSQL_HOSTNAME" \
#      --ssl-mode=VERIFY_CA --ssl-ca="$MYSQL_PEM" --execute="$create_user"
echo "Granting privileges..."
mysql -u "$ROOT_USER" -p"$ROOT_PASSWORD" -h "$MYSQL_HOSTNAME" \
      --ssl-mode=VERIFY_CA --ssl-ca="$MYSQL_PEM" --execute="$grant_privileges"
