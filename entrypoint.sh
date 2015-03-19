#!/bin/bash
set -e

function run_scripts () {
	SCRIPTS_DIR="/scripts/$1.d"
	SCRIPT_FILES_PATTERN="^${SCRIPTS_DIR}/[0-9][0-9][a-zA-Z0-9_-]+$"
	SCRIPTS=$(find "$SCRIPTS_DIR" -type f -uid 0 -executable -regex "$SCRIPT_FILES_PATTERN" | sort)
	if [ -n "$SCRIPTS" ] ; then
		echo "=>> $1-scripts:"
	    for script in $SCRIPTS ; do
	        echo "=> $script"
			. "$script"
	    done
	fi
}

###

if [ -n "$MYSQL_PORT_3306_TCP" ]; then
	if [ -z "$DB_HOST" ]; then
		DB_HOST=$MYSQL_PORT_3306_TCP_ADDR
		DB_PORT=$MYSQL_PORT_3306_TCP_PORT
	else
		echo >&2 'WARNING: Both DB_HOST and MYSQL_PORT_3306_TCP found.'
		echo >&2 "  Connecting to DB_HOST ($DB_HOST)"
		echo >&2 '  instead of the linked mysql container.'
	fi
fi

: ${DB_PORT:='3306'}

if [ -z "$DB_HOST" ]; then
	echo >&2 'ERROR: missing DB_HOST and MYSQL_PORT_3306_TCP environment variables.'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
	echo >&2 '  with -e DB_HOST=hostname?'
	exit 1
fi

: ${DB_USER:='root'}
if [ "$DB_USER" = 'root' ]; then
	: ${DB_PASS:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${DB_NAME:='drupal'}

if [ -z "$DB_PASS" ]; then
	echo >&2 'ERROR: missing required DB_PASS environment variable'
	echo >&2 '  Did you forget to -e DB_PASS=... ?'
	echo >&2
	echo >&2 '  (Also of interest might be DB_USER and DB_NAME.)'
	exit 1
fi

export DB_HOST DB_PORT DB_NAME DB_USER DB_PASS
echo -e "# Drupals's database configuration, parsed in /var/www/sites/default/settings.php\n
export DB_HOST=${DB_HOST} DB_PORT=${DB_PORT} DB_NAME=${DB_NAME} DB_USER=${DB_USER} DB_PASS=${DB_PASS}" >> /root/.bashrc

###

echo "=> Trying to connect to MySQL/MariaDB using:"
echo "========================================================================"
echo "      Database Host Address:  $DB_HOST"
echo "      Database Port number:   $DB_PORT"
echo "      Database Name:          $DB_NAME"
echo "      Database Username:      $DB_USER"
echo "      Database Password:      $DB_PASS"
echo "========================================================================"

for ((i=0;i<20;i++))
do
    DB_CONNECTABLE=$(mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ $DB_CONNECTABLE -eq 0 ]]; then
        break
    fi
    sleep 3
done

if ! [[ $DB_CONNECTABLE -eq 0 ]]; then
	echo "Cannot connect to MySQL"
    exit $DB_CONNECTABLE
fi

###

if ! drush sql-query "SHOW DATABASES LIKE '${DB_NAME}';" > /dev/null ; then
	run_scripts setup
    echo "=> Done installing site!"
	if [ $EXTRA_SETUP_SCRIPT ]; then
		echo "=> WARNING: The usage of EXTRA_SETUP_SCRIPT is deprectated. Put your script into /scripts/post-setup.d/"
		. $EXTRA_SETUP_SCRIPT
		echo "=> Successfully ran extra setup script ${EXTRA_SETUP_SCRIPT}."
	fi
else
    echo "=> Skipped setup - database ${DB_NAME} already exists."
fi

###

run_scripts pre-launch

exec apache2-foreground

exit 1
