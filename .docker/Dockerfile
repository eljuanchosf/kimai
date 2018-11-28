FROM php:7.2-apache
LABEL maintainer="juanpgenovese@gmail.com"

RUN apt-get update && apt-get upgrade && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    zip \
    zlib1g-dev

RUN docker-php-ext-install -j$(nproc) mysqli zip

COPY . /srv/app
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /srv/app
RUN curl -s --show-error https://getcomposer.org/installer | php && \
    php composer.phar install --no-dev --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader
RUN chown -R www-data:www-data /srv/app && \
    a2enmod rewrite

EXPOSE 80

CMD [".docker/run.sh"]
