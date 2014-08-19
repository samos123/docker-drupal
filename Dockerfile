FROM tutum/apache-php:latest
MAINTAINER Borja Burgos <borja@tutum.co>, Feng Honglin <hfeng@tutum.co>

# Install packages
RUN apt-get update && \
  apt-get -yq install mysql-client && \
  rm -rf /var/lib/apt/lists/*

# Download latest version of Wordpress into /app
RUN rm -fr /app
ADD drupal/ /app
RUN chown www-data:www-data /app -R

# Install drush by using composer
RUN composer self-update && COMPOSER_BIN_DIR=/usr/bin/ composer global require drush/drush:6.*


# Add script to create 'wordpress' DB
ADD run-drupal.sh /run-drupal.sh
RUN chmod 755 /*.sh


# Expose environment variables
ENV DB_HOST **LinkMe**
ENV DB_PORT **LinkMe**
ENV DB_NAME drupal
ENV DB_USER admin
ENV DB_PASS **ChangeMe**

EXPOSE 80

CMD ["/run-drupal.sh"]
