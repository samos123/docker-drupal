FROM samos123/drupal:latest

WORKDIR /app

# Use zen theme as default
RUN mkdir -p /app/sites/all/modules && mkdir -p /app/sites/all/themes

ADD modules/googleanalytics /app/sites/all/modules/googleanalytics
ADD themes/zen /app/sites/all/themes/zen
ADD extra-drupal-run-time-customization.sh /extra-drupal-run-time-customization.sh
RUN chmod 755 /extra-drupal-run-time-customization.sh

ENV EXTRA_SETUP_SCRIPT /extra-drupal-run-time-customization.sh
