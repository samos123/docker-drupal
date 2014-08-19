#!/bin/bash

drush @sites -r /app pm-enable zen --yes
drush @sites -r /app pm-enable googleanalytics --yes
drush @sites -r /app vset theme_default zen --yes

echo "Succesffuly executed extra setup script to enable modules and themes."
