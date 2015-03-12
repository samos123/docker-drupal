FROM tutum/apache-php:latest
MAINTAINER Sam Stoelinga <sammiestoel@gmail.com>

CMD ["/entrypoint.sh"]

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get -yq install mysql-client && \
  rm -rf /var/lib/apt/lists/*

# Copy latest stable version of Drupal from git submodule into /app
RUN rm -fr /app
RUN mkdir -p /app/sites/default/files
VOLUME /app
ADD drupal/ /app
  # TODO pull latest code or by $VERSION
ADD settings.php /app/sites/default/settings.php
RUN chown www-data:www-data /app -R

# Install drush by using composer
RUN composer self-update && \
    COMPOSER_BIN_DIR=/usr/bin/ composer global require drush/drush:6.*

# Add entrypoint-script to
# - create 'drupal' DB and install default site, if necessary
# - invoke the web server
ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Update apache2 configuration for drupal
RUN a2enmod rewrite
ADD apache2-default.conf /etc/apache2/sites-enabled/000-default.conf
