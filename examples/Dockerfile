FROM samos123/drupal:latest

RUN mkdir -p /var/www/html/sites/all/modules && mkdir -p /var/www/html/sites/all/themes

ADD modules/googleanalytics /var/www/html/sites/all/modules/googleanalytics
ADD themes/zen /var/www/html/sites/all/themes/zen
ADD extra-drupal-run-time-customization.sh /

ENV EXTRA_SETUP_SCRIPT /extra-drupal-run-time-customization.sh
