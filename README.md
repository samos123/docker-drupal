# Drupal image without database

This image contains the latest stable Drupal 7-release. It will automatically
setup the database and install a default site for you.

The image doesn't contain a database so you have to create a seperate database
container and link this container or pass the database information of a
MySQL-host.


## Why create another Drupal image?

Many of the other Drupal images got a database baked in or didn't install Drupal
automatically and didn't offer much flexibity. This image can be easily be used
as base image for your own Drupal images see below Customization by using
Dockerfiles.

This image uses `drush` to install a default site and creates the database on
the database-server if none exists yet.


## Usage

If you want to launch a bare drupal image you can do so:

    docker run -d -e MYSQL_ROOT_PASSWORD="test123" --name db mysql
    docker run -d --link db:mysql -p 80:80 samos123/drupal

Alternatively you can use [Docker-Compose](https://docs.docker.com/compose/)
in a directory that contains the provided [`docker-compose.yml`](https://github.com/samos123/docker-drupal/blob/master/docker-compose.yml):

    docker-compose up

This will launch a new drupal site with a default theme and no additional
modules. If you want custom modules, see *Customization*.

As customizations and uploads are stored you must take care of these directories
if you want to keep these:
  - `/var/www/html/sites` (modules, themes, uploaded files)
  - `/var/www/private` (non-public files, e.g. to store backups)

As these folders are defined as *volumes* in the sample `docker-compose.yml`,
you can easily update your container to use the latest image while preserving
any modifications with:

    docker-compose pull && docker-compose up -d


## Database options

You can use a linked database-container as shown above or use an external
database-host. Therefore pass the following environment variables to your
container:

  - `DB_HOST`
  - `DB_PORT` (default: `3306`)
  - `DB_NAME` (default: `drupal`)
  - `DB_USER` (default: `root`)
  - `DB_PASS`


## Other options

  - `UPLOAD_LIMIT` (default: `10M`) - sets variables for the *PHP*-interpreter
    to control maximum upload sizes
  - `MEMORY_LIMIT` (default: `64M`) - sets the [`memory_limit`](http://php.net/manual/en/ini.core.php#ini.memory-limit)
     for the *PHP*-interpreter


## Customiziation

To customize a Drupal-instance, you can add/modify scripts in a derived image
or mount them in your container into one of these directories:
`/scripts/setup.d` or `/scripts/pre-launch.d`. Furthermore,

  - the scripts' name must start with two digits, the rest may consist of
    alphanumerics, `_` and `-`
    - the scripts will be executed in alphanumerical order of their names
  - the scripts must be set executable (`chmod a+x <scriptpath>`)

See the [folder examples](https://github.com/samos123/docker-drupal/tree/master/examples)
of how to use the *Zen*-template and the *modules_filer*-module and build an
image containing them.

*Drush*'s system-wide configuration (`/etc/drushrc.php`) sets its default-
behaviour to be verbose (`-v`) and affirmative (`--yes`) in order to grant easy
and elaborated usage of scripts. If you want to change that behaviour in an
interactive environment or for certain sites (e.g. `docker exec -ti
<drupal_container> /bin/bash`), change it in an
[overriding `drushrc.php`-location](https://raw.githubusercontent.com/drush-ops/drush/master/examples/example.drushrc.php).

See the [documentation of php:apache](https://github.com/docker-library/php/) on
the usage of `docker-php-ext-configure` and `docker-php-ext-install` to install
PHP extensions.


## Credits

Authors of image: Sam Stoelinga, Frank Sachsenheim

Source code: [https://github.com/samos123/docker-drupal](https://github.com/samos123/docker-drupal)

Registry url: [https://registry.hub.docker.com/u/samos123/drupal/](https://registry.hub.docker.com/u/samos123/drupal/)
