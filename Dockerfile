FROM tutum/apache-php:latest
MAINTAINER Sam Stoelinga <sammiestoel@gmail.com>
ENV DRUPAL_VERSION=7.34
ENV DRUPAL_TARBALL_MD5=bb4d212e1eb1d7375e41613fbefa04f2

# Install packages and change apache config
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get -yq install mysql-client && \
  rm -rf /var/lib/apt/lists/*

# Copy latest stable version of Drupal from git submodule into /app
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

# Add script to create 'drupal' DB and install default site
ADD run-drupal.sh /run-drupal.sh
RUN chmod 755 /run-drupal.sh

# Update apache2 configuration for drupal
RUN a2enmod rewrite
ADD apache2-default.conf /etc/apache2/sites-enabled/000-default.conf

# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME drupal
ENV DB_USER admin
ENV DB_PASS **ChangeMe**

EXPOSE 80

CMD ["/run-drupal.sh"]
