# Drupal image without database included

This image contains latest stable Drupal release 7.31
and is build from tutum-php it will automatically setup
the database on a linked container 
and install a default site for you.

The image doesn't contain a database so you have to create
a seperate database container and link this container
or pass the correct environment variables containing
the database information.

Source code: [https://github.com/samos123/docker-tutum-drupal](https://github.com/samos123/docker-tutum-drupal)
Registry url: [https://registry.hub.docker.com/u/samos123/drupal/](https://registry.hub.docker.com/u/samos123/drupal/)

## Why create another Drupal image?
Many of the other Drupal images got a database baked in or 
didn't install Drupal automatically.

This image uses drush to install a default site and create the database
on the linked db container so that
you only have to specify custom modules and custom themes
and you would be ready to go.

## Usage
If you want to launch a bare drupal image you can do so:

    docker run -d -e MYSQL_PASS="test123" --name db tutum/mysql:5.5
    docker run -d --link db:db -p 80:80 samos123/drupal

## Customiziation by using Dockerfiles (Recommended)
See the folder examples of how to use the Zen template and google-analytics and
build an image containing them.

See [Example Drupal customized with Zen theme and Google Analytics module](https://github.com/samos123/docker-tutum-drupal/tree/master/examples)


