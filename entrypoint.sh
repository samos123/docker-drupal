#!/bin/bash
set -e

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

echo "=> Trying to connect to MySQL/MariaDB using:"
echo "========================================================================"
echo "      Database Host Address:  $DB_HOST"
echo "      Database Port number:   $DB_PORT"
echo "      Database Name:          $DB_NAME"
echo "      Database Username:      $DB_USER"
echo "      Database Password:      $DB_PASS"
echo "========================================================================"

for ((i=0;i<10;i++))
do
    DB_CONNECTABLE=$(mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P$DB_PORT -e 'status' >/dev/null 2>&1; echo "$?")
    if [[ DB_CONNECTABLE -eq 0 ]]; then
        break
    fi
    sleep 5
done

if [[ $DB_CONNECTABLE -eq 0 ]]; then
    DB_EXISTS=$(mysql -u$DB_USER -p$DB_PASS -h$DB_HOST -P$DB_PORT -e "SHOW DATABASES LIKE '"$DB_NAME"';" 2>&1 |grep "$DB_NAME" > /dev/null ; echo "$?")
    if [[ DB_EXISTS -eq 1  ]]; then
		cd /app && drush site-install --db-url=mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME \
	   		--site-name=default --account-pass=changeme << EOF
y
EOF
        echo "=> Done installing site using drush!"
		if [ $EXTRA_SETUP_SCRIPT ]; then
			. $EXTRA_SETUP_SCRIPT
			echo "=> Successfully ran extra setup script ${EXTRA_SETUP_SCRIPT}."
		fi
    else
        echo "=> Skipped creation of database $DB_NAME – it already exists."
    fi
else
    echo "Cannot connect to Mysql"
    exit $DB_CONNECTABLE
fi

exec /run.sh
exit 1
