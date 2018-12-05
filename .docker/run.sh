#! /usr/bin/env bash

set -e

template=".docker/autoconf.php.template"
autoconf=".docker/autoconf.php"

echo "Parsing ENV values..."

if [ ! -z "$MYSQL_PEM" ]; then
    curl https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem -o $MYSQL_PEM
fi

sed -e "s/MYSQL_HOSTNAME/$MYSQL_HOSTNAME/g" \
    -e "s/MYSQL_DATABASE/$MYSQL_DATABASE/g" \
    -e "s/MYSQL_USER/$MYSQL_USER/g" \
    -e "s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g" \
    -e "s/MYSQL_SERVER_PREFIX/$MYSQL_SERVER_PREFIX/g" \
    -e "s/GA_SECRET_KEY/$GA_SECRET_KEY/g" \
    -e "s/MYSQL_PEM/$MYSQL_PEM/g" \
    -e "s/PASSWORD_SALT/$PASSWORD_SALT/g" $template > $autoconf


mv .docker/autoconf.php ./includes/
rm -rf ./installer

apache2-foreground