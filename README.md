[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

# sameersbn/gitlab:7.13.5

- [Introduction](#introduction)
    - [Version](#version)
    - [Changelog](Changelog.md)
- [Contributing](#contributing)
- [Issues](#issues)
- [Announcements](https://github.com/sameersbn/docker-gitlab/issues/39)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Persistence](#persistence)
    - [Database](#database)
        - [PostgreSQL (Recommended)](#postgresql)
            - [External PostgreSQL Server](#external-postgresql-server)
            - [Linking to PostgreSQL Container](#linking-to-postgresql-container)
        - [MySQL](#mysql)
            - [Internal MySQL Server](#internal-mysql-server)
            - [External MySQL Server](#external-mysql-server)
            - [Linking to MySQL Container](#linking-to-mysql-container)
    - [Redis](#redis)
        - [Internal Redis Server](#internal-redis-server)
        - [External Redis Server](#external-redis-server)
        - [Linking to Redis Container](#linking-to-redis-container)
    - [Mail](#mail)
    - [SSL](#ssl)
        - [Generation of Self Signed Certificates](#generation-of-self-signed-certificates)
        - [Strengthening the server security](#strengthening-the-server-security)
        - [Installation of the SSL Certificates](#installation-of-the-ssl-certificates)
        - [Enabling HTTPS support](#enabling-https-support)
        - [Configuring HSTS](#configuring-hsts)
        - [Using HTTPS with a load balancer](#using-https-with-a-load-balancer)
        - [Establishing trust with your server](#establishing-trust-with-your-server)
        - [Installing Trusted SSL Server Certificates](#installing-trusted-ssl-server-certificates)
    - [Deploy to a subdirectory (relative url root)](#deploy-to-a-subdirectory-relative-url-root)
    - [OmniAuth Integration](#omniauth-integration)
        - [Google](#google)
        - [Twitter](#twitter)
        - [GitHub](#github)
        - [GitLab](#gitlab)
        - [BitBucket](#bitbucket)
        - [SAML](#saml)
    - [External Issue Trackers](#external-issue-trackers)
    - [Mapping host user and group](#mapping-host-user-and-group)
    - [Piwik](#piwik)
    - [Available Configuration Parameters](#available-configuration-parameters)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
    - [Automated Backups](#automated-backups)
    - [Amazon Web Services (AWS) Remote Backups](#amazon-web-services-aws-remote-backups)
    - [Rake Tasks](#rake-tasks)
    - [Upgrading](#upgrading)
    - [Shell Access](#shell-access)
- [References](#references)

# Introduction

Dockerfile to build a [GitLab](https://about.gitlab.com/) container image.

## Version

Current Version: `7.13.5`

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/sameersbn/docker-gitlab/issues) they may encounter
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

# Issues

Docker is a relatively new project and is active being developed and tested by a thriving community of developers and testers and every release of docker features many enhancements and bugfixes.

Given the nature of the development and release cycle it is very important that you have the latest version of docker installed because any issue that you encounter might have already been fixed with a newer docker release.

For ubuntu users I suggest [installing docker](https://docs.docker.com/installation/ubuntulinux/) using docker's own package repository since the version of docker packaged in the ubuntu repositories are a little dated.

Here is the shortform of the installation of an updated version of docker on ubuntu.

```bash
sudo apt-get purge docker.io
curl -s https://get.docker.io/ubuntu/ | sudo sh
sudo apt-get update
sudo apt-get install lxc-docker
```

Fedora and RHEL/CentOS users should try disabling selinux with `setenforce 0` and check if resolves the issue. If it does than there is not much that I can help you with. You can either stick with selinux disabled (not recommended by redhat) or switch to using ubuntu.

You may also set `DEBUG_ENTRYPOINT=true` to enable debugging of the entrypoint script, which could help you pin point any configuration issues.

If using the latest docker version and/or disabling selinux does not fix the issue then please file a issue request on the [issues](https://github.com/sameersbn/docker-gitlab/issues) page.

In your issue report please make sure you provide the following information:

- The host distribution and release version.
- Output of the `docker version` command
- Output of the `docker info` command
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Prerequisites

Your docker host needs to have 1GB or more of available RAM to run GitLab. Please refer to the GitLab [hardware requirements](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/requirements.md#hardware-requirements) documentation for additional information.

# Installation

Pull the image from the docker index. This is the recommended method of installation as it is easier to update image. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull sameersbn/gitlab:7.13.5
```

You can also pull the `latest` tag which is built from the repository *HEAD*

```bash
docker pull sameersbn/gitlab:latest
```

Alternately you can build the image locally.

```bash
git clone https://github.com/sameersbn/docker-gitlab.git
cd docker-gitlab
docker build --tag=$USER/gitlab .
```

# Quick Start

The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/).

```bash
wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.yml
docker-compose up
```

Alternately, you can manually launch the `gitlab` container and the supporting `postgresql` and `redis` containers by following this three step guide.

Step 1. Launch a postgresql container

```bash
docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:9.4-3
```

Step 2. Launch a redis container

```bash
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:latest
```

Step 3. Launch the gitlab container

```bash
docker run --name gitlab -d \
    --link gitlab-postgresql:postgresql --link gitlab-redis:redisio \
    --publish 10022:22 --publish 10080:80 \
    --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
sameersbn/gitlab:7.13.5
```

*Please refer to [Available Configuration Parameters](#available-configuration-parameters) to understand `GITLAB_PORT` and other configuration options*

__NOTE__: Please allow a couple of minutes for the GitLab application to start.

Point your browser to `http://localhost:10080` and login using the default username and password:

* username: **root**
* password: **5iveL!fe**

You should now have the GitLab application up and ready for testing. If you want to use this image in production the please read on.

*The rest of the document will use the docker command line. You can quite simply adapt your configuration into a `docker-compose.yml` file if you wish to do so.*

# Configuration

## Persistence

GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount a volume at,

* `/home/git/data`

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/gitlab/gitlab
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/gitlab
```

Volumes can be mounted in docker by specifying the `-v` option in the docker run command.

```bash
docker run --name gitlab -d \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

## Database

GitLab uses a database backend to store its data. You can configure this image to use either MySQL or PostgreSQL.

*Note: GitLab HQ recommends using PostgreSQL over MySQL*

### PostgreSQL

#### External PostgreSQL Server

The image also supports using an external PostgreSQL Server. This is also controlled via environment variables.

```sql
CREATE ROLE gitlab with LOGIN CREATEDB PASSWORD 'password';
CREATE DATABASE gitlabhq_production;
GRANT ALL PRIVILEGES ON DATABASE gitlabhq_production to gitlab;
```

We are now ready to start the GitLab application.

*Assuming that the PostgreSQL server host is 192.168.1.100*

```bash
docker run --name gitlab -d \
    --env 'DB_TYPE=postgres' --env 'DB_HOST=192.168.1.100' \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

#### Linking to PostgreSQL Container

You can link this image with a postgresql container for the database requirements. The alias of the postgresql server container should be set to **postgresql** while linking with the gitlab image.

If a postgresql container is linked, only the `DB_TYPE`, `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a postgresql container, we will use the [sameersbn/postgresql](https://github.com/sameersbn/docker-postgresql) image. When using postgresql image in production you should mount a volume for the postgresql data store. Please refer the [README](https://github.com/sameersbn/docker-postgresql/blob/master/README.md) of docker-postgresql for details.

First, lets pull the postgresql image from the docker index.

```bash
docker pull sameersbn/postgresql:9.4-3
```

For data persistence lets create a store for the postgresql and start the container.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/gitlab/postgresql
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/postgresql
```

The run command looks like this.

```bash
docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:9.4-3
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-postgresql:postgresql \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

Here the image will also automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the postgresql container as they are specified in the `docker run` command for the postgresql container. This is made possible using the magic of docker links and works with the following images:

 - [postgresql](https://hub.docker.com/_/postgresql/)
 - [sameersbn/postgresql](https://hub.docker.com/r/sameersbn/postgresql/)
 - [orchardup/postgresql](https://hub.docker.com/r/orchardup/postgresql/)
 - [paintedfox/postgresql](https://hub.docker.com/r/paintedfox/postgresql/)

### MySQL

#### Internal MySQL Server

The internal mysql server has been removed from the image. Please use a [linked mysql](#linking-to-mysql-container) container or specify a connection to a [external mysql](#external-mysql-server) server.

If you have been using the internal mysql server follow these instructions to migrate to a linked mysql container:

Assuming that your mysql data is available at `/srv/docker/gitlab/mysql`

```bash
docker run --name gitlab-mysql -d \
    --volume /srv/docker/gitlab/mysql:/var/lib/mysql \
    sameersbn/mysql:latest
```

This will start a mysql container with your existing mysql data. Now login to the mysql container and create a user for the existing `gitlabhq_production` database.

All you need to do now is link this mysql container to the gitlab ci container using the `--link gitlab-mysql:mysql` option and provide the `DB_NAME`, `DB_USER` and `DB_PASS` parameters.

Refer to [Linking to MySQL Container](#linking-to-mysql-container) for more information.

#### External MySQL Server

The image can be configured to use an external MySQL database. The database configuration should be specified using environment variables while starting the GitLab image.

Before you start the GitLab image create user and database for gitlab.

```sql
CREATE USER 'gitlab'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT ALL PRIVILEGES ON `gitlabhq_production`.* TO 'gitlab'@'%.%.%.%';
```

We are now ready to start the GitLab application.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run --name gitlab -d \
    --env 'DB_HOST=192.168.1.100' --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

#### Linking to MySQL Container

You can link this image with a mysql container for the database requirements. The alias of the mysql server container should be set to **mysql** while linking with the gitlab image.

If a mysql container is linked, only the `DB_TYPE`, `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a mysql container, we will use the [sameersbn/mysql](https://github.com/sameersbn/docker-mysql) image. When using docker-mysql in production you should mount a volume for the mysql data store. Please refer the [README](https://github.com/sameersbn/docker-mysql/blob/master/README.md) of docker-mysql for details.

First, lets pull the mysql image from the docker index.

```bash
docker pull sameersbn/mysql:latest
```

For data persistence lets create a store for the mysql and start the container.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/gitlab/mysql
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/mysql
```

The run command looks like this.

```bash
docker run --name gitlab-mysql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/mysql:/var/lib/mysql \
    sameersbn/mysql:latest
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with full/remote access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-mysql:mysql \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

Here the image will also automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the mysql container as they are specified in the `docker run` command for the mysql container. This is made possible using the magic of docker links and works with the following images:

 - [mysql](https://hub.docker.com/_/mysql/)
 - [sameersbn/mysql](https://hub.docker.com/r/sameersbn/mysql/)
 - [centurylink/mysql](https://hub.docker.com/r/centurylink/mysql/)
 - [orchardup/mysql](https://hub.docker.com/r/orchardup/mysql/)

## Redis

GitLab uses the redis server for its key-value data store. The redis server connection details can be specified using environment variables.

### Internal Redis Server

The internal redis server has been removed from the image. Please use a [linked redis](#linking-to-redis-container) container or specify a [external redis](#external-redis-server) connection.

### External Redis Server

The image can be configured to use an external redis server. The configuration should be specified using environment variables while starting the GitLab image.

*Assuming that the redis server host is 192.168.1.100*

```bash
docker run --name gitlab -it --rm \
    --env 'REDIS_HOST=192.168.1.100' --env 'REDIS_PORT=6379' \
    sameersbn/gitlab:7.13.5
```

### Linking to Redis Container

You can link this image with a redis container to satisfy gitlab's redis requirement. The alias of the redis server container should be set to **redisio** while linking with the gitlab image.

To illustrate linking with a redis container, we will use the [sameersbn/redis](https://github.com/sameersbn/docker-redis) image. Please refer the [README](https://github.com/sameersbn/docker-redis/blob/master/README.md) of docker-redis for details.

First, lets pull the redis image from the docker index.

```bash
docker pull sameersbn/redis:latest
```

Lets start the redis container

```bash
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:latest
```

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-redis:redisio \
    sameersbn/gitlab:7.13.5
```

### Mail

The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of SMTP parameters that can be specified.

```bash
docker run --name gitlab -d \
    --env 'SMTP_USER=USER@gmail.com' --env 'SMTP_PASS=PASSWORD' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

### SSL

Access to the gitlab application can be secured using SSL so as to prevent unauthorized access to the data in your repositories. While a CA certified SSL certificate allows for verification of trust via the CA, a self signed certificates can also provide an equal level of trust verification as long as each client takes some additional steps to verify the identity of your website. I will provide instructions on achieving this towards the end of this section.

Jump to the [Using HTTPS with a load balancer](#using-https-with-a-load-balancer) section if you are using a load balancer such as hipache, haproxy or nginx.

To secure your application via SSL you basically need two things:
- **Private key (.key)**
- **SSL certificate (.crt)**

When using CA certified certificates, these files are provided to you by the CA. When using self-signed certificates you need to generate these files yourself. Skip to [Strengthening the server security](#strengthening-the-server-security) section if you are armed with CA certified SSL certificates.

#### Generation of Self Signed Certificates

Generation of self-signed SSL certificates involves a simple 3 step procedure.

**STEP 1**: Create the server private key

```bash
openssl genrsa -out gitlab.key 2048
```

**STEP 2**: Create the certificate signing request (CSR)

```bash
openssl req -new -key gitlab.key -out gitlab.csr
```

**STEP 3**: Sign the certificate using the private key and CSR

```bash
openssl x509 -req -days 3650 -in gitlab.csr -signkey gitlab.key -out gitlab.crt
```

Congratulations! you have now generated an SSL certificate that will be valid for 10 years.

#### Strengthening the server security

This section provides you with instructions to [strengthen your server security](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html). To achieve this we need to generate stronger DHE parameters.

```bash
openssl dhparam -out dhparam.pem 2048
```

#### Installation of the SSL Certificates

Out of the four files generated above, we need to install the `gitlab.key`, `gitlab.crt` and `dhparam.pem` files at the gitlab server. The CSR file is not needed, but do make sure you safely backup the file (in case you ever need it again).

The default path that the gitlab application is configured to look for the SSL certificates is at `/home/git/data/certs`, this can however be changed using the `SSL_KEY_PATH`, `SSL_CERTIFICATE_PATH` and `SSL_DHPARAM_PATH` configuration options.

If you remember from above, the `/home/git/data` path is the path of the [data store](#data-store), which means that we have to create a folder named certs inside `/srv/docker/gitlab/gitlab/` and copy the files into it and as a measure of security we will update the permission on the `gitlab.key` file to only be readable by the owner.

```bash
mkdir -p /srv/docker/gitlab/gitlab/certs
cp gitlab.key /srv/docker/gitlab/gitlab/certs/
cp gitlab.crt /srv/docker/gitlab/gitlab/certs/
cp dhparam.pem /srv/docker/gitlab/gitlab/certs/
chmod 400 /srv/docker/gitlab/gitlab/certs/gitlab.key
```

Great! we are now just one step away from having our application secured.

#### Enabling HTTPS support

HTTPS support can be enabled by setting the `GITLAB_HTTPS` option to `true`. Additionally, when using self-signed SSL certificates you need to the set `SSL_SELF_SIGNED` option to `true` as well. Assuming we are using self-signed certificates

```bash
docker run --name gitlab -d \
    --publish 10022:22 --publish 10080:80 --publish 10443:443 \
    --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_PORT=10443' \
    --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

In this configuration, any requests made over the plain http protocol will automatically be redirected to use the https protocol. However, this is not optimal when using a load balancer.

#### Configuring HSTS

HSTS if supported by the browsers makes sure that your users will only reach your sever via HTTPS. When the user comes for the first time it sees a header from the server which states for how long from now this site should only be reachable via HTTPS - that's the HSTS max-age value.

With `GITLAB_HTTPS_HSTS_MAXAGE` you can configure that value. The default value is `31536000` seconds. If you want to disable a already sent HSTS MAXAGE value, set it to `0`.

```bash
docker run --name gitlab -d \
 --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
 --env 'GITLAB_HTTPS_HSTS_MAXAGE=2592000' \
 --volume /srv/docker/gitlab/gitlab:/home/git/data \
 sameersbn/gitlab:7.13.5
```

If you want to completely disable HSTS set `GITLAB_HTTPS_HSTS_ENABLED` to `false`.

#### Using HTTPS with a load balancer

Load balancers like nginx/haproxy/hipache talk to backend applications over plain http and as such the installation of ssl keys and certificates are not required and should **NOT** be installed in the container. The SSL configuration has to instead be done at the load balancer.

However, when using a load balancer you **MUST** set `GITLAB_HTTPS` to `true`. Additionally you will need to set the `SSL_SELF_SIGNED` option to `true` if self signed SSL certificates are in use.

With this in place, you should configure the load balancer to support handling of https requests. But that is out of the scope of this document. Please refer to [Using SSL/HTTPS with HAProxy](http://seanmcgary.com/posts/using-sslhttps-with-haproxy) for information on the subject.

When using a load balancer, you probably want to make sure the load balancer performs the automatic http to https redirection. Information on this can also be found in the link above.

In summation, when using a load balancer, the docker command would look for the most part something like this:

```bash
docker run --name gitlab -d \
    --publish 10022:22 --publish 10080:80 \
    --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_PORT=443' \
    --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

Again, drop the `--env 'SSL_SELF_SIGNED=true'` option if you are using CA certified SSL certificates.

In case Gitlab responds to any kind of POST request (login, OAUTH, changing settings etc.) with a 422 HTTP Error, consider adding this to your reverse proxy configuration:

`proxy_set_header X-Forwarded-Ssl on;` (nginx format)

#### Establishing trust with your server

This section deals will self-signed ssl certificates. If you are using CA certified certificates, your done.

This section is more of a client side configuration so as to add a level of confidence at the client to be 100 percent sure they are communicating with whom they think they.

This is simply done by adding the servers certificate into their list of trusted certificates. On ubuntu, this is done by copying the `gitlab.crt` file to `/usr/local/share/ca-certificates/` and executing `update-ca-certificates`.

Again, this is a client side configuration which means that everyone who is going to communicate with the server should perform this configuration on their machine. In short, distribute the `gitlab.crt` file among your developers and ask them to add it to their list of trusted ssl certificates. Failure to do so will result in errors that look like this:

```bash
git clone https://git.local.host/gitlab-ce.git
fatal: unable to access 'https://git.local.host/gitlab-ce.git': server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none
```

You can do the same at the web browser. Instructions for installing the root certificate for firefox can be found [here](http://portal.threatpulse.com/docs/sol/Content/03Solutions/ManagePolicy/SSL/ssl_firefox_cert_ta.htm). You will find similar options chrome, just make sure you install the certificate under the authorities tab of the certificate manager dialog.

There you have it, thats all there is to it.

#### Installing Trusted SSL Server Certificates

If your GitLab CI server is using self-signed SSL certificates then you should make sure the GitLab CI server certificate is trusted on the GitLab server for them to be able to talk to each other.

The default path image is configured to look for the trusted SSL certificates is at `/home/git/data/certs/ca.crt`, this can however be changed using the `CA_CERTIFICATES_PATH` configuration option.

Copy the `ca.crt` file into the certs directory on the [datastore](#data-store). The `ca.crt` file should contain the root certificates of all the servers you want to trust. With respect to GitLab CI, this will be the contents of the gitlab_ci.crt file as described in the [README](https://github.com/sameersbn/docker-gitlab-ci/blob/master/README.md#ssl) of the [docker-gitlab-ci](https://github.com/sameersbn/docker-gitlab-ci) container.

By default, our own server certificate [gitlab.crt](#generation-of-self-signed-certificates) is added to the trusted certificates list.

### Deploy to a subdirectory (relative url root)

By default GitLab expects that your application is running at the root (eg. /). This section explains how to run your application inside a directory.

Let's assume we want to deploy our application to '/git'. GitLab needs to know this directory to generate the appropriate routes. This can be specified using the `GITLAB_RELATIVE_URL_ROOT` configuration option like so:

```bash
docker run --name gitlab -it --rm \
    --env 'GITLAB_RELATIVE_URL_ROOT=/git' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:7.13.5
```

GitLab will now be accessible at the `/git` path, e.g. `http://www.example.com/git`.

**Note**: *The `GITLAB_RELATIVE_URL_ROOT` parameter should always begin with a slash and* **SHOULD NOT** *have any trailing slashes.*

### OmniAuth Integration

GitLab leverages OmniAuth to allow users to sign in using Twitter, GitHub, and other popular services. Configuring OmniAuth does not prevent standard GitLab authentication or LDAP (if configured) from continuing to work. Users can choose to sign in using any of the configured mechanisms.

Refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/omniauth.html) for additional information.

#### Google

To enable the Google OAuth2 OmniAuth provider you must register your application with Google. Google will generate a client ID and secret key for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/google.html) for the procedure to generate the client ID and secret key with google.

Once you have the client ID and secret keys generated, configure them using the `OAUTH_GOOGLE_API_KEY` and `OAUTH_GOOGLE_APP_SECRET` environment variables respectively.

For example, if your client ID is `xxx.apps.googleusercontent.com` and client secret key is `yyy`, then adding `--env 'OAUTH_GOOGLE_API_KEY=xxx.apps.googleusercontent.com' --env 'OAUTH_GOOGLE_APP_SECRET=yyy'` to the docker run command enables support for Google OAuth.

You can also restrict logins to a single domain by adding `--env 'OAUTH_GOOGLE_RESTRICT_DOMAIN=example.com'`. This is particularly useful when combined with `--env 'OAUTH_ALLOW_SSO=true'` and `--env 'OAUTH_BLOCK_AUTO_CREATED_USERS=false'`.

#### Twitter

To enable the Twitter OAuth2 OmniAuth provider you must register your application with Twitter. Twitter will generate a API key and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/twitter.html) for the procedure to generate the API key and secret with twitter.

Once you have the API key and secret generated, configure them using the `OAUTH_TWITTER_API_KEY` and `OAUTH_TWITTER_APP_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `--env 'OAUTH_TWITTER_API_KEY=xxx' --env 'OAUTH_TWITTER_APP_SECRET=yyy'` to the docker run command enables support for Twitter OAuth.

#### GitHub

To enable the GitHub OAuth2 OmniAuth provider you must register your application with GitHub. GitHub will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/github.html) for the procedure to generate the Client ID and secret with github.

Once you have the Client ID and secret generated, configure them using the `OAUTH_GITHUB_API_KEY` and `OAUTH_GITHUB_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_GITHUB_API_KEY=xxx' --env 'OAUTH_GITHUB_APP_SECRET=yyy'` to the docker run command enables support for GitHub OAuth.

#### GitLab

To enable the GitLab OAuth2 OmniAuth provider you must register your application with GitLab. GitLab will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/gitlab.html) for the procedure to generate the Client ID and secret with GitLab.

Once you have the Client ID and secret generated, configure them using the `OAUTH_GITLAB_API_KEY` and `OAUTH_GITLAB_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_GITLAB_API_KEY=xxx' --env 'OAUTH_GITLAB_APP_SECRET=yyy'` to the docker run command enables support for GitLab OAuth.

#### BitBucket

To enable the BitBucket OAuth2 OmniAuth provider you must register your application with BitBucket. BitBucket will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/bitbucket.html) for the procedure to generate the Client ID and secret with BitBucket.

Once you have the Client ID and secret generated, configure them using the `OAUTH_BITBUCKET_API_KEY` and `OAUTH_BITBUCKET_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_BITBUCKET_API_KEY=xxx' --env 'OAUTH_BITBUCKET_APP_SECRET=yyy'` to the docker run command enables support for BitBucket OAuth.

#### SAML

GitLab can be configured to act as a SAML 2.0 Service Provider (SP). This allows GitLab to consume assertions from a SAML 2.0 Identity Provider (IdP) such as Microsoft ADFS to authenticate users. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/saml.html).

The following parameters have to be configured to enable SAML OAuth support in this image: `OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL`, `OAUTH_SAML_IDP_CERT_FINGERPRINT`, `OAUTH_SAML_IDP_SSO_TARGET_URL`, `OAUTH_SAML_ISSUER` and `OAUTH_SAML_NAME_IDENTIFIER_FORMAT`

Please refer to [Available Configuration Parameters](#available-configuration-parameters) for the default configurations of these parameters.

### External Issue Trackers

Since version `7.13.5` support for external issue trackers can be enabled in the "Service Templates" section of the settings panel.

If you are using the [docker-redmine](https://github.com/sameersbn/docker-redmine) image, you can *one up* the gitlab integration with redmine by adding `--volumes-from=gitlab` flag to the docker run command while starting the redmine container.

By using the above option the `/home/git/data/repositories` directory will be accessible by the redmine container and now you can add your git repository path to your redmine project. If, for example, in your gitlab server you have a project named `opensource/gitlab`, the bare repository will be accessible at `/home/git/data/repositories/opensource/gitlab.git` in the redmine container.

### Host UID / GID Mapping

Per default the container is configured to run gitlab as user and group `git` with `uid` and `gid` `1000`. The host possibly uses this ids for different purposes leading to unfavorable effects. From the host it appears as if the mounted data volumes are owned by the host's user/group `1000`.

Also the container processes seem to be executed as the host's user/group `1000`. The container can be configured to map the `uid` and `gid` of `git` to different ids on host by passing the environment variables `USERMAP_UID` and `USERMAP_GID`. The following command maps the ids to user and group `git` on the host.

```bash
docker run --name gitlab -it --rm [options] \
    --env "USERMAP_UID=$(id -u git)" --env "USERMAP_GID=$(id -g git)" \
    sameersbn/gitlab:7.13.5
```

When changing this mapping, all files and directories in the mounted data volume `/home/git/data` have to be re-owned by the new ids. This can be achieved automatically using the following command:

```bash
docker run --name gitlab -d [OPTIONS] \
    sameersbn/gitlab:7.13.5 app:sanitize
```

### Piwik

If you want to monitor your gitlab instance with [Piwik](http://piwik.org/), there are two options to setup: `PIWIK_URL` and `PIWIK_SITE_ID`.
These options should contain something like:

- `PIWIK_URL=piwik.example.org`
- `PIWIK_SITE_ID=42`

### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command. Alternately you can use docker-compose.*

Below is the complete list of available options that can be used to customize your gitlab installation.

- **DEBUG_ENTRYPOINT**: Set this to `true` to enable entrypoint debugging.
- **GITLAB_HOST**: The hostname of the GitLab server. Defaults to `localhost`
- **GITLAB_PORT**: The port of the GitLab server. This value indicates the public port on which the GitLab application will be accessible on the network and appropriately configures GitLab to generate the correct urls. It does not affect the port on which the internal nginx server will be listening on. Defaults to `443` if `GITLAB_HTTPS=true`, else defaults to `80`.
- **GITLAB_TIMEZONE**: Configure the timezone for the gitlab application. This configuration does not effect cron jobs. Defaults to `UTC`. See the list of [acceptable values](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html).
- **GITLAB_ROOT_PASSWORD**: The password for the root user. Defaults to `5iveL!fe`.
- **GITLAB_EMAIL**: The email address for the GitLab server. Defaults to `example@example.com`.
- **GITLAB_EMAIL_DISPLAY_NAME**: The name displayed in emails sent out by the GitLab mailer. Defaults to `GitLab`.
- **GITLAB_EMAIL_REPLY_TO**: The reply to address of emails sent out by GitLab. Defaults to the `noreply@example.com`.
- **GITLAB_EMAIL_ENABLED**: Enable or disable gitlab mailer. Defaults to the `SMTP_ENABLED` configuration.
- **GITLAB_USERNAME_CHANGE**: Enable or disable ability for users to change their username. Defaults is `true`.
- **GITLAB_CREATE_GROUP**: Enable or disable ability for users to create groups. Defaults is `true`.
- **GITLAB_PROJECTS_ISSUES**: Set if *issues* feature should be enabled by default for new projects. Defaults is `true`.
- **GITLAB_PROJECTS_MERGE_REQUESTS**: Set if *merge requests* feature should be enabled by default for new projects. Defaults is `true`.
- **GITLAB_PROJECTS_WIKI**: Set if *wiki* feature should be enabled by default for new projects. Defaults is `true`.
- **GITLAB_PROJECTS_SNIPPETS**: Set if *snippets* feature should be enabled by default for new projects. Defaults is `false`.
- **GITLAB_WEBHOOK_TIMEOUT**: Sets the timeout for webhooks. Defaults to `10` seconds.
- **GITLAB_SATELLITES_TIMEOUT**: Sets the timeout for satellites. Defaults to `30` seconds.
- **GITLAB_TIMEOUT**: Sets the timeout for git commands. Defaults to `10` seconds.
- **GITLAB_REPOS_DIR**: The git repositories folder in the container. Defaults to `/home/git/data/repositories`
- **GITLAB_BACKUP_DIR**: The backup folder in the container. Defaults to `/home/git/data/backups`
- **GITLAB_BACKUPS**: Setup cron job to automatic backups. Possible values `disable`, `daily`, `weekly` or `monthly`. Disabled by default
- **GITLAB_BACKUP_EXPIRY**: Configure how long (in seconds) to keep backups before they are deleted. By default when automated backups are disabled backups are kept forever (0 seconds), else the backups expire in 7 days (604800 seconds).
- **GITLAB_BACKUP_TIME**: Set a time for the automatic backups in `HH:MM` format. Defaults to `04:00`.
- **GITLAB_SSH_HOST**: The ssh host. Defaults to **GITLAB_HOST**.
- **GITLAB_SSH_PORT**: The ssh port number. Defaults to `22`.
- **GITLAB_RELATIVE_URL_ROOT**: The relative url of the GitLab server, e.g. `/git`. No default.
- **GITLAB_HTTPS**: Set to `true` to enable https support, disabled by default.
- **GITLAB_HTTPS_HSTS_ENABLED**: Advanced configuration option for turning off the HSTS configuration. Applicable only when SSL is in use. Defaults to `true`. See [#138](https://github.com/sameersbn/docker-gitlab/issues/138) for use case scenario.
- **GITLAB_HTTPS_HSTS_MAXAGE**: Advanced configuration option for setting the HSTS max-age in the gitlab nginx vHost configuration. Applicable only when SSL is in use. Defaults to `31536000`.
- **SSL_SELF_SIGNED**: Set to `true` when using self signed ssl certificates. `false` by default.
- **SSL_CERTIFICATE_PATH**: Location of the ssl certificate. Defaults to `/home/git/data/certs/gitlab.crt`
- **SSL_KEY_PATH**: Location of the ssl private key. Defaults to `/home/git/data/certs/gitlab.key`
- **SSL_DHPARAM_PATH**: Location of the dhparam file. Defaults to `/home/git/data/certs/dhparam.pem`
- **SSL_VERIFY_CLIENT**: Enable verification of client certificates using the `CA_CERTIFICATES_PATH` file. Defaults to `false`
- **CA_CERTIFICATES_PATH**: List of SSL certificates to trust. Defaults to `/home/git/data/certs/ca.crt`.
- **NGINX_WORKERS**: The number of nginx workers to start. Defaults to `1`.
- **NGINX_PROXY_BUFFERING**: Enable `proxy_buffering`. Defaults to `off`.
- **NGINX_ACCEL_BUFFERING**: Enable `X-Accel-Buffering` header. Default to `no`
- **NGINX_MAX_UPLOAD_SIZE**: Maximum acceptable upload size. Defaults to `20m`.
- **NGINX_X_FORWARDED_PROTO**: Advanced configuration option for the `proxy_set_header X-Forwarded-Proto` setting in the gitlab nginx vHost configuration. Defaults to `https` when `GITLAB_HTTPS` is `true`, else defaults to `$scheme`.
- **REDIS_HOST**: The hostname of the redis server. Defaults to `localhost`
- **REDIS_PORT**: The connection port of the redis server. Defaults to `6379`.
- **UNICORN_WORKERS**: The number of unicorn workers to start. Defaults to `3`.
- **UNICORN_TIMEOUT**: Sets the timeout of unicorn worker processes. Defaults to `60` seconds.
- **SIDEKIQ_CONCURRENCY**: The number of concurrent sidekiq jobs to run. Defaults to `25`
- **SIDEKIQ_SHUTDOWN_TIMEOUT**: Timeout for sidekiq shutdown. Defaults to `4`
- **SIDEKIQ_MEMORY_KILLER_MAX_RSS**: Non-zero value enables the SidekiqMemoryKiller. Defaults to `1000000`. For additional options refer [Configuring the MemoryKiller](http://doc.gitlab.com/ce/operations/sidekiq_memory_killer.html)
- **DB_TYPE**: The database type. Possible values: `mysql`, `postgres`. Defaults to `mysql`.
- **DB_HOST**: The database server hostname. Defaults to `localhost`.
- **DB_PORT**: The database server port. Defaults to `3306` for mysql and `5432` for postgresql.
- **DB_NAME**: The database database name. Defaults to `gitlabhq_production`
- **DB_USER**: The database database user. Defaults to `root`
- **DB_PASS**: The database database password. Defaults to no password
- **DB_POOL**: The database database connection pool count. Defaults to `10`.
- **SMTP_ENABLED**: Enable mail delivery via SMTP. Defaults to `true` if `SMTP_USER` is defined, else defaults to `false`.
- **SMTP_DOMAIN**: SMTP domain. Defaults to` www.gmail.com`
- **SMTP_HOST**: SMTP server host. Defaults to `smtp.gmail.com`.
- **SMTP_PORT**: SMTP server port. Defaults to `587`.
- **SMTP_USER**: SMTP username.
- **SMTP_PASS**: SMTP password.
- **SMTP_STARTTLS**: Enable STARTTLS. Defaults to `true`.
- **SMTP_TLS**: Enable SSL/TLS. Defaults to `false`.
- **SMTP_OPENSSL_VERIFY_MODE**: SMTP openssl verification mode. Accepted values are `none`, `peer`, `client_once` and `fail_if_no_peer_cert`. Defaults to `none`.
- **SMTP_AUTHENTICATION**: Specify the SMTP authentication method. Defaults to `login` if `SMTP_USER` is set.
- **SMTP_CA_ENABLED**: Enable custom CA certificates for SMTP email configuration. Defaults to `false`.
- **SMTP_CA_PATH**: Specify the `ca_path` parameter for SMTP email configuration. Defaults to `/home/git/data/certs`.
- **SMTP_CA_FILE**: Specify the `ca_file` parameter for SMTP email configuration. Defaults to `/home/git/data/certs/ca.crt`.
- **LDAP_ENABLED**: Enable LDAP. Defaults to `false`
- **LDAP_LABEL**: Label to show on login tab for LDAP server. Defaults to 'LDAP'
- **LDAP_HOST**: LDAP Host
- **LDAP_PORT**: LDAP Port. Defaults to `389`
- **LDAP_UID**: LDAP UID. Defaults to `sAMAccountName`
- **LDAP_METHOD**: LDAP method, Possible values are `ssl`, `tls` and `plain`. Defaults to `plain`
- **LDAP_BIND_DN**: No default.
- **LDAP_PASS**: LDAP password
- **LDAP_ACTIVE_DIRECTORY**: Specifies if LDAP server is Active Directory LDAP server. If your LDAP server is not AD, set this to `false`. Defaults to `true`,
- **LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN**: If enabled, GitLab will ignore everything after the first '@' in the LDAP username submitted by the user on login. Defaults to `false` if `LDAP_UID` is `userPrincipalName`, else `true`.
- **LDAP_BLOCK_AUTO_CREATED_USERS**: Locks down those users until they have been cleared by the admin. Defaults to `false`.
- **LDAP_BASE**: Base where we can search for users. No default.
- **LDAP_USER_FILTER**: Filter LDAP users. No default.
- **OAUTH_ENABLED**: Enable OAuth support. Defaults to `true` if any of the support OAuth providers is configured, else defaults to `false`.
- **OAUTH_AUTO_SIGN_IN_WITH_PROVIDER**: Automatically sign in with a specific OAuth provider without showing GitLab sign-in page. Accepted values are `google_oauth2`, `twitter`, `github`, `gitlab`, `bitbucket` and `saml`. No default.
- **OAUTH_ALLOW_SSO**: This allows users to login without having a user account first. User accounts will be created automatically when authentication was successful. Defaults to `false`.
- **OAUTH_BLOCK_AUTO_CREATED_USERS**: Locks down those users until they have been cleared by the admin. Defaults to `true`.
- **OAUTH_AUTO_LINK_LDAP_USER**: Look up new users in LDAP servers. If a match is found (same uid), automatically link the omniauth identity with the LDAP account. Defaults to `false`.
- **OAUTH_GOOGLE_API_KEY**: Google App Client ID. No defaults.
- **OAUTH_GOOGLE_APP_SECRET**: Google App Client Secret. No defaults.
- **OAUTH_GOOGLE_RESTRICT_DOMAIN**: Google App restricted domain. No defaults.
- **OAUTH_TWITTER_API_KEY**: Twitter App API key. No defaults.
- **OAUTH_TWITTER_APP_SECRET**: Twitter App API secret. No defaults.
- **OAUTH_GITHUB_API_KEY**: GitHub App Client ID. No defaults.
- **OAUTH_GITHUB_APP_SECRET**: GitHub App Client secret. No defaults.
- **OAUTH_GITLAB_API_KEY**: GitLab App Client ID. No defaults.
- **OAUTH_GITLAB_APP_SECRET**: GitLab App Client secret. No defaults.
- **OAUTH_BITBUCKET_API_KEY**: BitBucket App Client ID. No defaults.
- **OAUTH_BITBUCKET_APP_SECRET**: BitBucket App Client secret. No defaults.
- **OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL**: The URL at which the SAML assertion should be received. When `GITLAB_HTTPS=true`, defaults to `https://${GITLAB_HOST}/users/auth/saml/callback` else defaults to `http://${GITLAB_HOST}/users/auth/saml/callback`.
- **OAUTH_SAML_IDP_CERT_FINGERPRINT**: The SHA1 fingerprint of the certificate. No Defaults.
- **OAUTH_SAML_IDP_SSO_TARGET_URL**: The URL to which the authentication request should be sent. No defaults.
- **OAUTH_SAML_ISSUER**: The name of your application. When `GITLAB_HTTPS=true`, defaults to `https://${GITLAB_HOST}` else defaults to `http://${GITLAB_HOST}`.
- **OAUTH_SAML_NAME_IDENTIFIER_FORMAT**: Describes the format of the username required by GitLab, Defaults to `urn:oasis:names:tc:SAML:2.0:nameid-format:transient`
- **GITLAB_GRAVATAR_ENABLED**: Enables gravatar integration. Defaults to `true`.
- **GITLAB_GRAVATAR_HTTP_URL**: Sets a custom gravatar url. Defaults to `http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon`. This can be used for [Libravatar integration](http://doc.gitlab.com/ce/customization/libravatar.html).
- **GITLAB_GRAVATAR_HTTPS_URL**: Same as above, but for https. Defaults to `https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon`.
- **USERMAP_UID**: Sets the uid for user `git` to the specified uid. Defaults to `1000`.
- **USERMAP_GID**: Sets the gid for group `git` to the specified gid. Defaults to `USERMAP_UID` if defined, else defaults to `1000`.
- **GOOGLE_ANALYTICS_ID**: Google Analytics ID. No defaults.
- **PIWIK_URL**: Sets the Piwik URL. No defaults.
- **PIWIK_SITE_ID**: Sets the Piwik site ID. No defaults.
- **AWS_BACKUPS**: Enables automatic uploads to an Amazon S3 instance. Defaults to `false`.
- **AWS_BACKUP_REGION**: AWS region. No defaults.
- **AWS_BACKUP_ACCESS_KEY_ID**: AWS access key id. No defaults.
- **AWS_BACKUP_SECRET_ACCESS_KEY**: AWS secret access key. No defaults.
- **AWS_BACKUP_BUCKET**: AWS bucket for backup uploads. No defaults.
- **GITLAB_ROBOTS_OVERRIDE**: Override `robots.txt`. Defaults to `false`.
- **GITLAB_ROBOTS_PATH**: Location of `robots.txt`. See [www.robotstxt.org](http://www.robotstxt.org) for examples. Defaults to `robots.txt` which [prevents robots scanning gitlab](http://www.robotstxt.org/faq/prevent.html).

# Maintenance

## Creating backups

Gitlab defines a rake task to take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop gitlab && docker rm gitlab
```

Execute the rake task to create a backup.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:7.13.5 app:rake gitlab:backup:create
```

A backup will be created in the backups folder of the [Data Store](#data-store). You can change the location of the backups using the `GITLAB_CI_BACKUP_DIR` configuration parameter.

*P.S. Backups can also be generated on a running instance using `docker exec` as described in the [Rake Tasks](#rake-tasks) section. However, to avoid undesired side-effects, I advice against running backup and restore operations on a running instance.*

## Restoring Backups

Gitlab also defines a rake task to restore a backup.

Before performing a restore make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop gitlab && docker rm gitlab
```

Execute the rake task to restore a backup. Make sure you run the container in interactive mode `-it`.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:7.13.5 app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:7.13.5 app:rake gitlab:backup:restore BACKUP=1417624827
```

## Automated Backups

The image can be configured to automatically take backups `daily`, `weekly` or `monthly` using the `GITLAB_BACKUPS` configuration option.

Daily backups are created at `GITLAB_BACKUP_TIME` which defaults to `04:00` everyday. Weekly backups are created every Sunday at the same time as the daily backups. Monthly backups are created on the 1st of every month at the same time as the daily backups.

By default, when automated backups are enabled, backups are held for a period of 7 days. While when automated backups are disabled, the backups are held for an infinite period of time. This can behavior can be configured via the `GITLAB_BACKUP_EXPIRY` option.

### Amazon Web Services (AWS) Remote Backups

The image can be configured to automatically upload the backups to an AWS S3 bucket. To enable automatic AWS backups first add `--env 'AWS_BACKUPS=true'` to the docker run command. In addition `AWS_BACKUP_REGION` and `AWS_BACKUP_BUCKET` must be properly configured to point to the desired AWS location. Finally an IAM user must be configured with appropriate access permission and their AWS keys exposed through `AWS_BACKUP_ACCESS_KEY_ID` and `AWS_BACKUP_SECRET_ACCESS_KEY`.

More details about the appropriate IAM user properties can found on [doc.gitlab.com](http://doc.gitlab.com/ce/raketasks/backup_restore.html#upload-backups-to-remote-cloud-storage)

AWS uploads are performed alongside normal backups, both through the appropriate `app:rake` command and when an automatic backup is performed.

## Rake Tasks

The `app:rake` command allows you to run gitlab rake tasks. To run a rake task simply specify the task to be executed to the `app:rake` command. For example, if you want to gather information about GitLab and the system it runs on.

```bash
docker run --name gitlab -d [OPTIONS] \
    sameersbn/gitlab:7.13.5 app:rake gitlab:env:info
```

You can also use `docker exec` to run raketasks on running gitlab instance. For example,

```bash
docker exec -it gitlab sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
```

Similarly, to import bare repositories into GitLab project instance

```bash
docker run --name gitlab -d [OPTIONS] \
    sameersbn/gitlab:7.13.5 app:rake gitlab:import:repos
```

Or

```bash
docker exec -it gitlab sudo -u git -H bundle exec rake gitlab:import:repos RAILS_ENV=production
```

For a complete list of available rake tasks please refer https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks or the help section of your gitlab installation.

*P.S. Please avoid running the rake tasks for backup and restore operations on a running gitlab instance.*

## Upgrading

GitLabHQ releases new versions on the 22nd of every month, bugfix releases immediately follow. I update this project almost immediately when a release is made (at least it has been the case so far). If you are using the image in production environments I recommend that you delay updates by a couple of days after the gitlab release, allowing some time for the dust to settle down.

To upgrade to newer gitlab releases, simply follow this 4 step upgrade procedure.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/gitlab:7.13.5
```

- **Step 2**: Stop and remove the currently running image

```bash
docker stop gitlab
docker rm gitlab
```

- **Step 3**: Create a backup

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:x.x.x app:rake gitlab:backup:create
```

Replace `x.x.x` with the version you are upgrading from. For example, if you are upgrading from version `6.0.0`, set `x.x.x` to `6.0.0`

- **Step 4**: Start the image

```bash
docker run --name gitlab -d [OPTIONS] sameersbn/gitlab:7.13.5
```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it gitlab bash
```

# References
    * https://github.com/gitlabhq/gitlabhq
    * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
    * http://wiki.nginx.org/HttpSslModule
    * https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
    * https://github.com/gitlabhq/gitlab-recipes/blob/master/web-server/nginx/gitlab-ssl
    * https://github.com/jpetazzo/nsenter
    * https://jpetazzo.github.io/2014/03/23/lxc-attach-nsinit-nsenter-docker-0-9/
