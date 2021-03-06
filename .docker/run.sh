#! /usr/bin/env bash

set -e

template=".docker/autoconf.php.template"
autoconf=".docker/autoconf.php"

if [ -z ${MYSQL_HOSTNAME+x} ]; then 
    echo "Reading from .env file"
    source .env
fi

if [ ! -z "$MYSQL_PEM" ]; then
    echo "Downloading MySQL PEM file"
    curl -s https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem -o $MYSQL_PEM
    chown :www-data $MYSQL_PEM
fi

echo "Parsing ENV values..."

sed -e "s/MYSQL_HOSTNAME/$MYSQL_HOSTNAME/g" \
    -e "s/MYSQL_DATABASE/$MYSQL_DATABASE/g" \
    -e "s/MYSQL_USER/$MYSQL_USER/g" \
    -e "s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g" \
    -e "s/MYSQL_SERVER_PREFIX/$MYSQL_SERVER_PREFIX/g" \
    -e "s/GA_SECRET_KEY/$GA_SECRET_KEY/g" \
    -e "s#MYSQL_PEM#$MYSQL_PEM#g" \
    -e "s/PASSWORD_SALT/$PASSWORD_SALT/g" $template > $autoconf


mv .docker/autoconf.php ./includes/
rm -rf ./installer

echo "Running server..."

apache2-foreground
