## Introduction

[Nims-Hyrax](https://github.com/nims-dpfc/nims-hyrax) is an implementation of the Hyrax stack by [Cottage Labs](https://cottagelabs.com/) and [AntLeaf](https://antleaf.com/). It is built with Docker containers, which simplify development and deployment onto live services.

## Code Status

[![CircleCI Status for nims-dpfc/nims-hyrax](https://circleci.com/gh/nims-dpfc/nims-hyrax/tree/develop.svg?style=svg)](https://circleci.com/gh/nims-dpfc/nims-hyrax)

[![Coverage Status](https://coveralls.io/repos/github/nims-dpfc/nims-hyrax/badge.svg?branch=develop)](https://coveralls.io/github/nims-dpfc/nims-hyrax?branch=develop)

## Getting Started

Clone the repository with `git clone https://github.com/nims-dpfc/nims-hyrax.git`.

Ensure you have docker and docker-compose. See [notes on installing docker](https://github.com/nims-dpfc/nims-hyrax/blob/develop/README.md#installing-docker).

Open a console and try running `docker -h` and `docker-compose -h` to verify they are both accessible.

Create the environment file `.env`. You can start by copying the template file [.env.template.development](https://github.com/nims-dpfc/nims-hyrax/blob/develop/.env.template.development) to `.env` and customizing the values to your setup. (For production environment, use .env.template as your template, not .env.template.development)

## quick start
If you would like to do a test run of the system, start the docker containers
```bash
$ cd nims-hyrax
$ docker-compose up -d
```
You should see the containers being built and the services start.

### For Development
We use the [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) branching model, so ensure you set up 
your project directory by running `git flow init` and accept the defaults.
[Installation for git-flow](https://github.com/nvie/gitflow/wiki/Installation).

```shell
Branch name for production releases: [master] 
Branch name for "next release" development: [develop] 
Feature branches? [feature/] 
Bugfix branches? [bugfix/] 
Release branches? [release/] 
Hotfix branches? [hotfix/] 
Support branches? [support/] 
Version tag prefix? [] 
Hooks and filters directory? [<your-path-to-checked-out-repo>/nims-hyrax/.git/hooks] 
```

The default branch in this repository is `develop`, and `master` should be used for stable releases only. After
finishing bugfixes or releases with `git-flow` remember to also push tags with `git push --tags`.

New code is created in `feature/` or `hotfix/` branches, and from there we make a pull request against the develop branch. A member of the team other than the new code's author reviews the pull request and performs the merge. Codeship tests run when the `develop` branch is updated.

## Guide to docker-compose and the services needed to run the materials data repository

![services diagram](https://github.com/nims-dpfc/nims-hyrax/blob/develop/hyrax/docs/container_diag.png)


There are 4 `docker-compose` files provided in the repository, which build the containers running the services as shown above
  * [docker-compose.yml](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml) is the main docker-compose file. It builds all the core servcies required to run the application
    * [fcrepo](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L16-L27) is the container running the [Fedora 4 commons repository](https://wiki.duraspace.org/display/FEDORA47/Fedora+4.7+Documentation), an rdf document store. By default, this runs the fedora service on port 8080 internally in docker (http://fcrepo:8080/fcrepo/rest).<br/><br/>
    * [Solr container](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L29-L46) runs [SOLR](lucene.apache.org/solr/), an enterprise search server. By default, this runs the SOLR service on port 8983 internally in docker (http://solr:8983).<br/><br/>
    * [db container](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L48-L60) running a postgres database, used by the Hyrax application. By default, this runs the database service on port 5432 internally in docker.<br/><br/>
    * [redis container](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L109-L125) running [redis](https://redis.io/), used by Hyrax to manage background tasks. By default, this runs the redis service on port 6379 internally in docker.<br/><br/>
    * [app container](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L62-L81) sets up the [Hyrax] application, which is then used by 2 services - web and workers.<br/><br/>
    * [Web container](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L83-L94) runs the materials data repository application. By default, this runs the materials data repository service on port 3000 internally in docker (http://web:3000). <br/><br/>This container runs [docker-entrypoint.sh](https://github.com/nims-dpfc/nims-hyrax/blob/develop/hyrax/docker-entrypoint.sh). It needs the database, solr and fedora containers to be up and running. It waits for 15s to ensure Solr and fedora are running and exits if they are not. It [runs a rake task](https://github.com/nims-dpfc/nims-hyrax/blob/develop/hyrax/docker-entrypoint.sh#L38-L39), ([setup_hyrax.rake](https://github.com/nims-dpfc/nims-hyrax/blob/develop/hyrax/lib/tasks/setup_hyrax.rake)) to setup the application. <br/><br/>The default workflows are loaded, the default admin set and collection types are created and the users in [setup.json](https://github.com/nims-dpfc/nims-hyrax/blob/develop/hyrax/seed/setup.json) are created as a part of the setup.<br/><br/>
    * [Wokers container](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.yml#L96-L107) runs the background tasks for materials data repository, using [sidekiq](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=2ahUKEwio06ew2qPhAhUMZt4KHT0jDwQQFjAAegQIBBAB&url=https%3A%2F%2Fgithub.com%2Fmperham%2Fsidekiq&usg=AOvVaw3mZXHmVT7i5YYB8_u56eH2) and redis. By default, this runs the worker service. <br/><br/> Hyrax processes long-running or particularly slow work in background jobs to speed up the web request/response cycle. When a user submits a file through a work (using the web or an import task), there a humber of background jobs that are run, initilated by the hyrax actor stack, as explained [here](https://samvera.github.io/what-happens-deposit-2.0.html)<br/><br/>You can monitor the background workers using the materials data repository service at http://web:3000/sidekiq when logged in as an admin user. <br/><br/>
  * [docker-compose.override.yml](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose.override.yml) This file exposes the ports for fcrepo, solr and the hyrax web container, so they an be accessed outside the container. If running this service in development or test, we could use this file. <br/><br/>
  * [docker-compose-production.yml](https://github.com/nims-dpfc/nims-hyrax/blob/develop/docker-compose-production.yml) is the production configuration, customised for the infrastructure at NIMS. <br/><br/>


The data for the application is stored in docker named volumes as specified by the compose files. These are:

```bash
$ docker volume list
nims-hyrax_cache
nims-hyrax_db
nims-hyrax_derivatives
nims-hyrax_fcrepo
nims-hyrax_file_uploads
nims-hyrax_letsencrypt
nims-hyrax_redis
nims-hyrax_solr_home
```

These will persist when the system is brought down and rebuilt. Deleting them will require importers etc. to run again.


## Running in development or test

When running in development and test environment, prepare your .env file using .env.template.development as the template. You need to use `docker-compose -f docker-compose.yml -f docker-compose.override.yml`. This will use the docker-compose.yml file and the docker-compose.override.yml file and not use the docker-compose-production.yml.
  * fcrepo container will run the fedora service, which will be available in port 8080 at  http://localhost:8080/fcrepo/rest
  * Solr container will run the Solr service, which will be available in port 8983 at  http://localhost:8983
  * The web container runs the materials data repository service, which will be available in port 3000 at http://localhost:3000

You could setup an alias for docker-compose on your local machine, to ease typing

```bash
alias ngdrdocker='docker-compose -f docker-compose.yml -f docker-compose.override.yml'
```

### Yarn and static assets

Static asset build is only run in `production` environment to speed up container creation in develop. To see features such as the IIIF viewer, `yarn install` must be run on the web container once it's up.

```
ngdrdocker run web yarn install
```

## Running in production

When running in production, prepare your .env file using .env.template as the template (not .env.template.development). You need to use `docker-compose -f docker-compose.yml -f docker-compose-production.yml`, replacing docker-compose.override.yml with docker-compose-production.yml. To assist this, an alias similar to that below can be useful:

```bash
alias ngdrdocker='docker-compose -f docker-compose.yml -f docker-compose-production.yml'
```

* The service will run without the ports of intermediary services such as Solr being exposed to the host.
* Materials data repository is accessible at port 443, http requests to port 80 will be redirected to https.

## Builidng, starting and managing the service with docker

### Build the docker container

To start with, you would need to build the system, before running the services. To do this you need to issue the `build` command
```bash
$ ngdrdocker build
```
Note: This is using the alias defined above, as a short form for <br/>
In development:
```bash
$ docker-compose -f docker-compose.yml -f docker-compose.override.yml build
```
In production:
```bash
$ docker-compose -f docker-compose.yml -f docker-compose-production.yml build
```

### Start and run the services in the containers

To run the containers after build, issue the `up` command (-d means run as daemon, in the background):

```bash
ngdrdocker up -d
```
Note: This is using the alias defined above, as a short form for <br/>
In development:
```bash
$ docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```
In production:
```bash
$ docker-compose -f docker-compose.yml -f docker-compose-production.yml up -d
```

The containers should all start and the services should be available in their end points as described above
* web server at http://localhost:3000 in development and https://domain-name in production

### docker container status and logs

You can see the state of the containers with `docker-compose ps`, and view logs e.g. for the web container using `docker-compose logs web`

The services that you would need to monitor the logs for are docker mainly web and workers.


### Some example docker commands and usage:

[Docker cheat sheet](https://github.com/wsargent/docker-cheat-sheet)

```bash
# Bring the whole application up to run in the background, building the containers
ngdrdocker up -d --build

# Halt the system
ngdrdocker down

# Re-create the nginx container without affecting the rest of the system (and run in the background with -d)
ngdrdocker up -d --build --no-deps --force-recreate nginx

# View the logs for the web application container
ngdrdocker logs web

# Create a log dump file
ngdrdocker logs web | tee web_logs_`date --iso-8601`
# (writes to e.g. web_logs_2019-03-27)

# View all running containers
docker ps
# (example output:)
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS                PORTS                                      NAMES
f42cf90d4494        nims-hyrax_nginx                 "sh -c 'nginx && cer…"   5 days ago          Up 5 days             0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nims-hyrax_nginx_1
6da65933de09        nims-hyrax_web                   "bash -c /bin/docker…"   5 days ago          Up 14 hours           3000/tcp                                   nims-hyrax_web_1
ab9600b12f2d        nims-hyrax_workers               "bundle exec sidekiq"    5 days ago          Up 5 days                                                        nims-hyrax_workers_1
a9e18ff5eef7        ualbertalib/docker-fcrepo4:4.7   "catalina.sh run"        5 days ago          Up 5 days             8080/tcp                                   nims-hyrax_fcrepo_1
8a31c9b41e54        nims-hyrax_solr                  "/docker-entrypoint.…"   5 days ago          Up 5 days (healthy)   8983/tcp                                   nims-hyrax_solr_1
4382df4d4033        nims-hyrax_db                    "docker-entrypoint.s…"   5 days ago          Up 5 days (healthy)   5432/tcp                                   nims-hyrax_db_1
7580bf933d43        redis:5                          "docker-entrypoint.s…"   5 days ago          Up 5 days (healthy)   6379/tcp                                   nims-hyrax_redis_1

# Using its container name, you can run a shell in a container to view or make changes directly
docker exec -it nims-hyrax_nginx_1 sh
```

#### Installing Docker

On `saku05` and the demo server on Digital Ocean we use docker version 18.09.3, and docker-compose version 1.23.2

1. Install Docker [by following step 1 of the Docker Compose installation tutorial](https://docs.docker.com/compose/install/) on your machine.

2. Make sure you don't need to `sudo` to run docker. [Instructions on set-up and how to test that it works.](https://docs.docker.com/engine/installation/linux/ubuntulinux/#/manage-docker-as-a-non-root-user)

3. Install [Docker Compose by following steps 2 and onwards from the Docker Compose installation Tutorial](https://docs.docker.com/compose/install/).

> Ubuntu Linux users, the command that Docker-Compose provides you with will not work since /usr/local/bin is not writeable by anybody but root in default Ubuntu setups. Use `sudo tee` instead, e.g.:

```bash
$ curl -L https://github.com/docker/compose/releases/download/[INSERT_DESIRED_DOCKER_COMPOSE_VERSION_HERE]/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null && sudo chmod a+x /usr/local/bin/docker-compose
```

4. Open a console and try running `docker -h` and `docker-compose -h` to verify they are both accessible.


### Using a local Docker-based CAS server for Single Sign-On and Single Sign-Off

If you would like to use a local Docker-based CAS server for single sign-on and sign off, a little more configuration is 
required. Note that these steps are optional: you could use database authentication or LDAP authentication, or a remote 
CAS server instead.

1. In your system's `/etc/hosts` file, add the following two entries which will redirect the specified hostnames to localhost:

    ```
    127.0.0.1       mdr.nims.test
    127.0.0.1       cas.mdr.nims.test
    ``` 

2. In your `.env` file, set the following variables:

    ```
    MDR_DEVISE_AUTH_MODULE=cas_authenticatable
    CAS_BASE_URL=https://cas.mdr.nims.test:8443/cas/
    ```

3. Now build and run the `web` and `cas` containers:

    ```bash
    docker-compose build web cas
    docker-compose up web cas
    ```

4. Open a browser and goto the MDR website: http://mdr.nims.test:3000/
    Click on Login and you should be directed to https://cas.mdr.nims.test:8443/cas/

    At this point your web browser will likely complain that the SSL certificate is invalid / untrusted. Grant the 
    certificate `cas.mdr.nims.test` full trust:
 
    * In Chrome, view the certificate and export it (or drag it) to your desktop
    * Next, double-click on the certificate file (`cas.mdr.nims.test.cer`) and mark it as Always Trust (see: https://support.apple.com/en-gb/guide/keychain-access/kyca11871/mac)
    * Check that reloading https://cas.mdr.nims.test:8443/cas/ should now present the valid CAS website without any certificate warnings or other errors

5. To test single sign-on, open a browser window and go to to the MDR website: http://mdr.nims.test:3000/
    
    * Click on "login" and you will be redirected to the CAS website. 
    * Log in as `user1` / `password`.
    * After completing the login on the CAS website you will be redirected back to the MDR website and now logged in as `user1`
    
6. To test single sign-off, after logging in as `user1` on MDR (see previous step), open an extra browser window and navigate directly to the CAS website: https://cas.mdr.nims.test:8443/cas
    
    * Logout of the CAS system (by clicking on "log out" in "please log out and exit your web browser")
    * Then reload the *other* browser window which had the user logged in to MDR and verify that they are now logged out.

## Backups

There is [docker documentation](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes) advising how to back up volumes and their data.

### System initialisation and configuration

* As mentioned above, there is a `.env` file containing application secrets. This **must not** be checked into version control!
* The system is configured on start-up using the `docker-entrypoint.sh` script, which configures users in the `seed/setup.json` file.
* Importers are run manually in the container using the rails console. See [The project wiki](https://github.com/nims-dpfc/nims-hyrax/wiki) for more information.
