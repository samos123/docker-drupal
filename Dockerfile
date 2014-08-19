FROM tutum/apache-php:latest
MAINTAINER Sam Stoelinga <sammiestoel@gmail.com>
# Install packages and change apache config
RUN apt-get update && \
  apt-get -yq install mysql-client && \
  rm -rf /var/lib/apt/lists/*

# Copy latest stable version of Drupal from git submodule into /app
RUN rm -fr /app
ADD drupal/ /app
ADD settings.php /app/sites/default/settings.php
RUN mkdir -p /app/sites/default/files
RUN chown www-data:www-data /app -R

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
