#!/bin/bash

drush @sites -r /var/www/html pm-enable zen --yes
drush @sites -r /var/www/html pm-enable googleanalytics --yes
drush @sites -r /var/www/html vset theme_default zen --yes

echo "Succesffuly executed extra setup script to enable modules and themes."
