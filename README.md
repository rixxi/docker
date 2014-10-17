# Docker Stack for deployment of Nette Applications

This approach works with slight modifications works for most PHP web applications.


## Containers

All containers should be treated as read-only unless is stated otherwise.
Used patterns:
* one service per container
* [Data Volume Container](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container)

Such separation allows for building and orchestrating using composer meta information ie.: determining PHP version, necessary extensions etc.


### Application (rixxi/sandbox)

Servers as storage of all necessary source codes and pre-built assets using directory structure from Nette Sandbox.

**It is just an example**, you should build your own image, just don't forget to put everything in `/nette`.


#### Configuration

For passing arguments to application via environment variables you can use [rixxi/env](https://github.com/rixxi/env) but be sure to know its [limitations](https://github.com/rixxi/env#limitations).

Your `app/config/config.local.neon` should be either empty file or setup using environment variables.

```neon
env:
    whitelist: no # allow all environment variables without listing them

doctrine:
    host: %env.MYSQL_PORT_3006_TCP_ADDR%:%env.MYSQL_PORT_3006_TCP_PORT%
```

TIP: Your doctrine proxies should be already generated in temp.

### Web Server (rixxi/nginx)

Web server with basic php-fpm configuration.

#### Environment

* Server name
* SSL settings (optional)

#### Dependencies

* Application for static assets.
* Server for execution.


### Server (rixxi/php-fpm)

For execution of /nette/www/index.php.

#### Environment

* Server name
* Application specific configuration

#### Dependencies

* Application for code.
* Persistent Storage (optional) for cache, data and optionally sessions.


### Persistent Data Storage (rixxi/data)

Simplifies configuration, backups, recoveries and lot of other stuff.


### Persistent Cache Storage (rixxi/cache)

Simplifies erasing of cache and separates it from rest of the data.


## File System Structure

Application should be in app container in `/nette` directory with document root in `www`.
Cache is exporting `/nette/temp/cache` directory and journal file `/nette/temp/dfjr.bin`.
Data is exporting `/nette/data`.


## Examples

### Production

Runs server with app and persistent storage at localhost:8080.

#### Create Persistent Storage for Data and Cache (Data Volume Container)

```sh
docker run --name project.cache rixxi/cache
docker run --name project.data rixxi/data
```

Either build containers locally or pull them from registry.

```sh
docker pull project/app
docker pull rixxi/php-fpm
docker pull rixxi/nginx
```

#### Run Service Containers

```sh
# remove garbage left from crashes
docker rm -f project.app
docker rm -f project.php-fpm
docker rm -f project.nginx

# application - data volume container
docker run -d project/app \
    project.app

# php-fpm server
docker run -d rixxi/php-fpm \
    --env 'SERVER_NAME=foo.bar' \
    --volumes-from project.app:app:ro \
    --volumes-from project.data \
    --volumes-from project.cache \
    project.php-fpm

# server
docker run -d rixxi/nginx \
    --publish 80:80 \
    --env 'SERVER_NAME=foo.bar' \
    --link project.php-fpm:php-fpm \
    --volumes-from project.app:ro \
    project.nginx
```

### Development

Mount app /nette to directory with app code and build assets manually. If you
need to debug data, mount persistent storage to local directory too.

```sh
docker run -d -v  vendor/app --volume ~/dev/vendor/package:/nette vendor.app
```
