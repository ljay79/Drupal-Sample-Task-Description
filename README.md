# Setup for development (local)

## Introduction
For a development environment on your own workstation / localhost this project has been setup using docker containers and taking advantage of docker-compose to run all microservices needed for a fully working local development environment.

## Pre-Requisite

The following environment is expected to be in place and working already. If not, please prepare following parts first.

* Linux based working machine or Windows 10 Pro with "WSL for Windows".
* Docker Host installed and running
    * exposed daemon to _tcp://localhost:2375_ without TLS
* Access to OK.de Bitbucket repositories (with SSH keys recommended)

> Note: When running docker as a non-root user on your local machine you might need to use custom userId and gorupId to be passed to 
> the container build process. Use the `.env` in projects root directory to define them.

## Project folder structure

```
sample/
  - services/backend/
    - Dockerfile
  - docker-compose.yml
  - README.md
  - ..
```

## Let's go and set it up

### 1. Setup Project localy

We do checkout the _develop_ branch of the applications services for development. Please create feature branches according to the development guidelines of your team.

```
$ mkdir sample
$ cd sample
```

```
$ git clone https://github.com/ljay79/Drupal-Sample-Task-Description.git .
```

Stay in your project's root folder:
```
$ pwd
/home/<user>/sample
```

#### Create your `.env`
Use the template file `.env.dev.dist` and copy it to `.env`, open and edit settings to your needs.
```
$ cp .env.dev.dist .env
$ vi .env
```

### 2. Build and run the services with docker-compose

These docker services are building each container of the app dynamically fresh from scratch.
If you want to use a specific built image you can update `docker-compose.yml` and specify an image:tag for each app service under the `build` section, see [docker-compose build](https://docs.docker.com/compose/compose-file/#build)

Docker will build and run following containers for you:

* _sample\_cms\_nginx_ - Drupal CMS
* _sample\_cms\_php_ - Drupal CMS
* _sample\_db_ - runs the MySQL database with a persistent data storage volume on the docker host machine

#### Instable internet connection or slow?
If you have a unstable or slow internet connection, it might improve and secure the build process when you download
the required docker images upfront. This way you get most of the data securely downloaded.
When one of the download fails, you can simply retry before rebuilding over and over the entire docker process.

```
docker pull ljay/amaz-drupal:php-fpm
docker pull ljay/amaz-nginx:1.18.0
docker pull ljay/mysql5:5.7.31
docker pull composer:2.0.8
```

### Prepare and build your local architecture
You might want to check the content of `.env` and `docker-compose.yml` and update some config values to your needs.
Container hostnames:

Database environment values:
```
MYSQL_ROOT_PASSWORD=root
MYSQL_ROOT_HOST=%
MYSQL_DATABASE=*****
MYSQL_USER==*****
..
```
Now run your services with docker-compose
```
$ docker-compose build --force-rm --no-cache --pull
$ docker-compose up -d --remove-orphans
```

You can also build most of the container one by one.
This will build the heavy container individually (best for inet connection issues),
then once done, run above `docker-compose up -d --remove-orphans` to spin up entire cluster which
will build the remaining (smaller) containers.
Using `--pull`will always attempt to pull a newer version of the image.
```
 # cms_php
$ docker-compose build --force-rm --no-cache --pull cms_php
 # cms db
$ docker-compose build --force-rm --no-cache --pull db
```

Optional:
On first local setup (when using local host mounted volume), you will need to log on to cms_php and install drupal
```
$ docker exec -it sample_cms_php bash
$ composer install
```

> This setup currently does not support subdirectory based proxy with nginx and uses subdomains theirfore.

Your 1 services are accessible via:

* CMS => http://localhost:8080/      (default admin; username Admin and password Admin)

Done ...
