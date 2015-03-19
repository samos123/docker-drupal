FROM php:apache
MAINTAINER Sam Stoelinga <sammiestoel@gmail.com>

ENTRYPOINT ["/entrypoint.sh"]

# Provide compatibility for images depending on previous versions
RUN ln -s /var/www/html /app

# Update apache2 configuration for drupal
RUN a2enmod rewrite

# Install packages
RUN apt-get -q update \
 && DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install \
	file \
    libfreetype6 \
    libjpeg62 \
    libpng12-0 \
    libx11-6 \
    libxpm4 \
    mysql-client

# Install PHP-extensions
RUN BUILD_DEPS="libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng12-dev libxpm-dev re2c zlib1g-dev"; \
    DEBIAN_FRONTEND=noninteractive apt-get -yq --no-install-recommends install $BUILD_DEPS \
 && docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib/x86_64-linux-gnu --with-png-dir=/usr/lib/x86_64-linux-gnu \
        --with-xpm-dir=/usr/lib/x86_64-linux-gnu --with-freetype-dir=/usr/lib/x86_64-linux-gnu \
 && docker-php-ext-install gd mbstring pdo_mysql zip \
 && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $BUILD_DEPS \
 && rm -rf /var/lib/apt/lists/* \
 && pecl install uploadprogress

# Download Drupal from ftp.drupal.org
ENV DRUPAL_VERSION=7.35
ENV DRUPAL_TARBALL_MD5=fecc55bd0bd476bc35d9ebf68452942d
WORKDIR /var/www
RUN rm -R html \
 && curl -OsS http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz \
 && echo "${DRUPAL_TARBALL_MD5}  drupal-${DRUPAL_VERSION}.tar.gz" | md5sum -c \
 && tar -xf drupal-${DRUPAL_VERSION}.tar.gz && rm drupal-${DRUPAL_VERSION}.tar.gz \
 && mv drupal-${DRUPAL_VERSION} html \
 && cd html \
 && rm [A-Z]*.txt install.php web.config

# Install composer and drush by using composer
ENV COMPOSER_BIN_DIR=/usr/local/bin
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer global require drush/drush:6.* \
 && drush cc drush

# Add PHP-settings
ADD php-conf.d/ $PHP_INI_DIR/conf.d/

# Create private-files volume, copy sites/default's defaults and make it a volume
RUN mkdir private && chown -R www-data:www-data /var/www
WORKDIR html
ADD sites/ sites/
VOLUME /var/www/html/sites
VOLUME /var/www/private

# Add entrypoint-script to
# - create 'drupal' DB and install default site, if necessary
# - invoke the web server
ADD entrypoint.sh /
