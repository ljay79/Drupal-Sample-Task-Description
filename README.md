# Table of Content
..tbc

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
ok.de/
  - images/
  - infrastructure/
  - services/frontend/
    - Dockerfile
  - services/frontend-cms/
    - Dockerfile
  - services/frontend-worker/
    - Dockerfile
  - docker-compose.yml
  - README.md
  - stack-*.yml
  - ..
```

## Let's go and set it up

### 1. Setup Project localy

We do checkout the _develop_ branch of the applications services for development. Please create feature branches according to the development guidelines of your team.

```
$ mkdir ok.de
$ cd ok.de
```

```
$ git clone -b develop git@bitbucket.org:onj/ok.de-architecture.git .
$ git clone -b develop git@bitbucket.org:onj/ok.de-frontend.git ./services/frontend/
$ git clone -b develop git@bitbucket.org:onj/ok.de-frontend-cms.git ./services/frontend-cms/
$ git clone -b develop git@bitbucket.org:onj/ok.de-frontend-worker.git ./services/frontend-worker/
```

Stay in your project's root folder:
```
$ pwd
/home/<user>/ok.de
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

* _ok21\_cms\_nginx_ - Drupal CMS
* _ok21\_cms\_php_ - Drupal CMS
* _ok21\_db_ - runs the MySQL database with a persistent data storage volume on the docker host machine
* _ok21\_elk_ - Elastic Logstash Kibana, visualize webserver logs
* _ok21\_maildev_ - MailDev is a simple way to test your project's generated emails during development with an easy to use web interface
* _ok21\_nginx_proxy_ - nginx reverse-proxy to run multiple apps exposing same port (ie: app1:80, app2:80, ..) see: [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)
* _ok21\_phpmyadm_ - for convenience a PhpMyAdmin instance to connect to the database
* _ok21\_redis\_cache_ - Redis server for caching
* _ok21\_redis\_sess_ - Redis server for session storage

#### Instable internet connection or slow?
If you have a unstable or slow internet connection, it might improve and secure the build process when you download
the required docker images upfront. This way you get most of the data securely downloaded.
When one of the download fails, you can simply retry before rebuilding over and over the entire docker process.

```
docker pull ljay/amaz-drupal:php-fpm
docker pull ljay/amaz-nginx:1.18.0
docker pull ljay/amaz-drupal:php-fpm
docker pull ljay/mysql5:5.7.31
docker pull jay/vuejs-boilerplate:latest
docker pull jwilder/nginx-proxy:latest
docker pull phpmyadmin/phpmyadmin:latest
docker pull redis:6.0.10-alpine
docker pull djfarrelly/maildev:latest
docker pull willdurand/elk:latest
docker pull composer:2.0.8
```

### Prepare and build your local architecture
You might want to check the content of `.env` and `docker-compose.yml` and update some config values to your needs.
Container hostnames:

```
<cms|api|..>:
  environment:
    - VIRTUAL_HOST=team-cms.ok.local
```

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
 # www_vue
$ docker-compose build --force-rm --no-cache --pull www_vue
 # cms_php
$ docker-compose build --force-rm --no-cache --pull cms_php
 # cmsdb
$ docker-compose build --force-rm --no-cache --pull db
```

On first local setup (when using local host mounted volume), you will need to log on to cms_php and install drupal
```
$ docker exec -it ok21_cms_php bash
$ cd team-cms
$ composer install
```

> This setup currently does not support subdirectory based proxy with nginx and uses subdomains theirfore.

Your 3 services are accessible via:

* Frontend => http://www.ok.local/
* CMS => http://team-cms.ok.local/      (default admin; username Admin and password Admin)
* API => http://pub-api.ok.local/       (endpoint: "http://pub-api.ok.local/json/rnou1b/api")
* 

.. plus
* PhpMyAdmin => http://ok.local:8580/
* ELK => http://ok.local:81/
* MailDev => http://ok.local:8001/


Done ...

## Workflow for Developers

### Rebuild docker image and update container

Sample: service "www_vue" got an updated Docker image we want to use.
```
$ docker-compose stop
$ docker-compose rm www_vue
$ docker-compose build --force-rm --no-cache --pull www_vue
 # start project
$ docker-compose up -d
```

### Full update of local environment
Stop all containers using `docker-compose stop`

#### For full reset of database
Make sure to create a backup of your database before any further actions!
```
### removing DB container and volume
docker container rm ok21_db_dev
docker volume rm ok21_db-data
```

Optional change the database backup you want to use in your local `.env` file:
> INITIAL_DUMP_IMPORT=ok21_web_cms.dev.20210217.sql

Pull git updates for the services ie: _frontend-cms_
### rebuild a service container
```
docker-compose build --force-rm --pull cms_php
```

### Start docker services which will rebuild the database if previously removed
```
docker-compose up -d
```

Verify, everything runs as expected and optional perform Drupal updates, such as:
`composer install`, `drush cr`, `http://team-cms.ok.local/update.php`, ..



tbc...

> - commit changes
> - create tag
> - git push --tags
> - push all changes `git push`
>     - will trigger bitbucket pipeline
> pipeline will pick up latest tag always to deploy to AWS stack


tbc...

If you are going to soley develop on your local machine with this project, you can stop here and skip all other parts for cloud infrastructure setup.


## Workflow for DevOps

Drupal Admin Access
user: admin
pass: admin
