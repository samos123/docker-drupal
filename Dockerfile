FROM php:apache
MAINTAINER Sam Stoelinga <sammiestoel@gmail.com>

EXPOSE 80
CMD ["/entrypoint.sh"]
WORKDIR /app

# Update apache2 configuration for drupal
RUN a2enmod rewrite
ADD apache2-default.conf /etc/apache2/sites-enabled/000-default.conf

# Add PHP-settings
ADD php-conf.d/ /usr/local/etc/php/conf.d/

# Install mysql-client
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install \
    libfreetype6 \
    libjpeg62 \
    libpng12-0 \
    libx11-6 \
    libxpm4 \
    mysql-client

# Install PHP-extensions
RUN BUILD_DEPS="libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev libxpm-dev zlib1g-dev"; \
    DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install $BUILD_DEPS \
 && docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib/x86_64-linux-gnu --with-png-dir=/usr/lib/x86_64-linux-gnu \
        --with-xpm-dir=/usr/lib/x86_64-linux-gnu --with-freetype-dir=/usr/lib/x86_64-linux-gnu \
 && docker-php-ext-install gd pdo_mysql zip \
 && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $BUILD_DEPS \
 && rm -rf /var/lib/apt/lists/*

# Install composer and drush by using composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer self-update \
 && COMPOSER_BIN_DIR=/usr/bin/ composer global require drush/drush:6.* \
 && echo "allow_url_fopen = off" >> /usr/local/etc/php/conf.d/drupal-recommends.ini

# Copy latest stable version of Drupal from git submodule into /app
RUN rm -fr /app && mkdir -p /app/sites/default/files \
 && rm -fr /var/www/html && ln -sf /app /var/www/html
ADD drupal/ /app
  # FIXME pull latest code or by $VERSION
ADD settings.php /app/sites/default/settings.php
RUN chown www-data:www-data /app -R

VOLUME /app/sites/default/files

# Add entrypoint-script to
# - create 'drupal' DB and install default site, if necessary
# - invoke the web server
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
