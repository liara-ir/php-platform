FROM thecodingmachine/php:7.2-v2-apache

USER root

RUN curl -fsSL 'https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz' -o sourceguardian.tar.gz \
  && mkdir -p /tmp/sourceguardian \
  && tar -xvvzf sourceguardian.tar.gz -C /tmp/sourceguardian \
  && mv /tmp/sourceguardian/ixed.7.2.lin `php-config --extension-dir` \
  && rm -Rf sourceguardian.tar.gz /tmp/sourceguardian \
  && docker-php-ext-enable ixed.7.2.lin \
  && curl -fsSL 'https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz' -o ioncube.tar.gz \
  && tar -xvvzf ioncube.tar.gz -C /tmp \
  && mv /tmp/ioncube/ioncube_loader_lin_7.2.so `php-config --extension-dir` \
  && rm -Rf ioncube.tar.gz /tmp/ioncube \
  && docker-php-ext-enable ioncube_loader_lin_7.2

ENV PHP_EXTENSIONS="bcmath bz2 calendar exif \
amqp gnupg imap mcrypt memcached \
mongodb sockets yaml \
gd gettext gmp igbinary imagick intl \
pcntl pdo_pgsql pgsql redis \
shmop soap sysvmsg \
apcu mysqli pdo_mysql \
sysvsem sysvshm wddx xsl opcache zip"

ENV ROOT=/var/www/html \
    COMPOSER_ALLOW_SUPERUSER=1 \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data

ONBUILD COPY . $ROOT

ONBUILD RUN if [ -f $ROOT/composer.json ]; then \
  composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --ansi \
    --no-scripts; \
fi && chown -R www-data:www-data $ROOT

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN php /usr/local/bin/generate_conf.php | tee /usr/local/etc/php/conf.d/generated_conf.ini > /dev/null

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
