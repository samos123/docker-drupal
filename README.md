# Drupal image without database

This image contains latest stable Drupal release of 7.x and is build from
tutum-php it will automatically setup the database and install a default site
for you.

The image doesn't contain a database so you have to create a seperate database
container and link this container or pass the correct environment variables
containing the database information.


## Why create another Drupal image?

Many of the other Drupal images got a database baked in or didn't install Drupal
automatically and didn't offer much flexibity. This image can be easily be used
as base image for your own Drupal images see below Customization by using
Dockerfiles.

This image uses drush to install a default site and create the database on the
linked db container so that you only have to specify custom modules and custom
themes and you are ready to go.


## Usage

If you want to launch a bare drupal image you can do so:

    docker run -d -e MYSQL_ROOT_PASSWORD="test123" --name db mysql
    docker run -d --link db:mysql -p 80:80 samos123/drupal

Alternatively you can use [Docker-Compose](https://docs.docker.com/compose/)
in a directory that contains the provided [`docker-compose.yml`](https://github.com/samos123/docker-tutum-drupal/blob/master/docker-compose.yml):

    docker-compose up

This will launch a new drupal site with a default theme and no additional
modules. If you want custom modules I recommend using the approach listed below.


## Database options

You can use a linked database-container as shown above or use an external
database-host. Therefore pass the following environment variables to your
container:
  - `DB_HOST`
  - `DB_PORT` (default: `3306`)
  - `DB_NAME` (default: `drupal`)
  - `DB_USER` (default: `root`)
  - `DB_PASS`


## Customiziation

To run a script that customizes the initial setup, add it to your derived
image or mount it in your container and pass the variable `EXTRA_SETUP_SCRIPT`
naming its absolute path when the container runs the first time.

See the [folder examples](https://github.com/samos123/docker-tutum-drupal/tree/master/examples)
of how to use the Zen template and google-analytics and build an image
containing them.


## Credits

Authors of image: Sam Stoelinga, Frank Sachsenheim

Source code: [https://github.com/samos123/docker-tutum-drupal](https://github.com/samos123/docker-tutum-drupal)

Registry url: [https://registry.hub.docker.com/u/samos123/drupal/](https://registry.hub.docker.com/u/samos123/drupal/)

This image is based on tutum-php and tutum-wordpress-nosql made by Tutum.
