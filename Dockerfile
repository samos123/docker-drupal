FROM tutum/apache-php:latest
MAINTAINER Sam Stoelinga <sammiestoel@gmail.com>

CMD ["/entrypoint.sh"]

# Update apache2 configuration for drupal
RUN a2enmod rewrite
ADD apache2-default.conf /etc/apache2/sites-enabled/000-default.conf

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get -yq install mysql-client \
 && rm -rf /var/lib/apt/lists/*

# Copy latest stable version of Drupal from git submodule into /app
ENV DRUPAL_VERSION=7.34
ENV DRUPAL_TARBALL_MD5=bb4d212e1eb1d7375e41613fbefa04f2
RUN cd / && rm -fr /app \
 && curl -O http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz \
 && echo "${DRUPAL_TARBALL_MD5}  drupal-${DRUPAL_VERSION}.tar.gz" | md5sum -c \
 && tar -xf drupal-${DRUPAL_VERSION}.tar.gz && rm drupal-${DRUPAL_VERSION}.tar.gz \
 && mv drupal-${DRUPAL_VERSION} app \
 && cd - \
 && rm [A-Z]*.txt install.php web.config

ADD settings.php /app/sites/default/settings.php
RUN mkdir -p /app/sites/default/files && chown www-data:www-data /app -R

# Install drush by using composer
RUN composer self-update && \
    COMPOSER_BIN_DIR=/usr/bin/ composer global require drush/drush:6.*

# Add entrypoint-script to
# - create 'drupal' DB and install default site, if necessary
# - invoke the web server
ADD entrypoint.sh /entrypoint.sh


