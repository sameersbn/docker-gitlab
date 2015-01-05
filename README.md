# Table of Contents
- [Introduction](#introduction)
    - [Version](#version)
    - [Changelog](Changelog.md)
- [Hardware Requirements](#hardware-requirements)
    - [CPU](#cpu)
    - [Memory](#memory)
    - [Storage](#storage)
- [Supported Web Browsers](#supported-web-browsers)
- [Contributing](#contributing)
- [Issues](#issues)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Data Store](#data-store)
  - [Database](#database)
    - [MySQL](#mysql)
      - [Internal MySQL Server](#internal-mysql-server)
      - [External MySQL Server](#external-mysql-server)
      - [Linking to MySQL Container](#linking-to-mysql-container)
    - [PostgreSQL (Recommended)](#postgresql)
      - [External PostgreSQL Server](#external-postgresql-server)
      - [Linking to PostgreSQL Container](#linking-to-postgresql-container)
  - [Redis](#redis)
    - [Internal Redis Server](#internal-redis-server)
    - [External Redis Server](#external-redis-server)
    - [Linking to Redis Container](#linking-to-redis-container)
  - [Mail](#mail)
  - [SSL](#ssl)
    - [Generation of Self Signed Certificates](#generation-of-self-signed-certificates)
    - [Strengthening the server security](#strengthening-the-server-security)
    - [Installation of the Certificates](#installation-of-the-certificates)
    - [Enabling HTTPS support](#enabling-https-support)
    - [Configuring HSTS](#configuring-hsts)
    - [Using HTTPS with a load balancer](#using-https-with-a-load-balancer)
    - [Establishing trust with your server](#establishing-trust-with-your-server)
    - [Installing Trusted SSL Server Certificates](#installing-trusted-ssl-server-certificates)
  - [Deploy to a subdirectory (relative url root)](#deploy-to-a-subdirectory-relative-url-root)
  - [Putting it all together](#putting-it-all-together)
  - [OmniAuth Integration](#omniauth-integration)
    - [Google](#google)
    - [Twitter](#twitter)
    - [GitHub](#github)
  - [External Issue Trackers](#external-issue-trackers)
    - [Redmine](#redmine)
    - [Jira](#jira)
  - [Mapping host user and group](#mapping-host-user-and-group)
  - [Piwik](#piwik)
  - [Available Configuration Parameters](#available-configuration-parameters)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
    - [Automated Backups](#automated-backups)
    - [Shell Access](#shell-access)
- [Upgrading](#upgrading)
- [Rake Tasks](#rake-tasks)
- [Announcements](https://github.com/sameersbn/docker-gitlab/issues/39)
- [References](#references)

# Introduction

Dockerfile to build a GitLab container image.

## Version

Current Version: **7.6.2**

# Hardware Requirements

## CPU

- 1 core works for under 100 users but the responsiveness might suffer
- 2 cores is the recommended number of cores and supports up to 100 users
- 4 cores supports up to 1,000 users
- 8 cores supports up to 10,000 users

## Memory

- 512MB is too little memory, GitLab will be very slow and you will need 250MB of swap
- 768MB is the minimal memory size but we advise against this
- 1GB supports up to 100 users (with individual repositories under 250MB, otherwise git memory usage necessitates using swap space)
- **2GB** is the **recommended** memory size and supports up to 1,000 users
- 4GB supports up to 10,000 users

## Storage

The necessary hard drive space largely depends on the size of the repos you want to store in GitLab. But as a *rule of thumb* you should have at least twice as much free space as your all repos combined take up. You need twice the storage because [GitLab satellites](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/structure.md) contain an extra copy of each repo.

If you want to be flexible about growing your hard drive space in the future consider mounting it using LVM so you can add more hard drives when you need them.

Apart from a local hard drive you can also mount a volume that supports the network file system (NFS) protocol. This volume might be located on a file server, a network attached storage (NAS) device, a storage area network (SAN) or on an Amazon Web Services (AWS) Elastic Block Store (EBS) volume.

If you have enough RAM memory and a recent CPU the speed of GitLab is mainly limited by hard drive seek times. Having a fast drive (7200 RPM and up) or a solid state drive (SSD) will improve the responsiveness of GitLab.

# Supported Web Browsers

- Chrome (Latest stable version)
- Firefox (Latest released version)
- Safari 7+ (Know problem: required fields in html5 do not work)
- Opera (Latest released version)
- IE 10+

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/sameersbn/docker-gitlab/issues) they may encounter
- Send me a tip via [Bitcoin](https://www.coinbase.com/sameersbn) or using [Gratipay](https://gratipay.com/sameersbn/)

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

If using the latest docker version and/or disabling selinux does not fix the issue then please file a issue request on the [issues](https://github.com/sameersbn/docker-gitlab/issues) page.

In your issue report please make sure you provide the following information:

- The host distribution and release version.
- Output of the `docker version` command
- Output of the `docker info` command
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Installation

Pull the image from the docker index. This is the recommended method of installation as it is easier to update image. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull sameersbn/gitlab:7.6.2
```

You can also pull the `latest` tag which is built from the repository *HEAD*

```bash
docker pull sameersbn/gitlab:latest
```

Alternately you can build the image locally.

```bash
git clone https://github.com/sameersbn/docker-gitlab.git
cd docker-gitlab
docker build --tag="$USER/gitlab" .
```

# Quick Start

You can launch the image using the docker command line,

```bash
docker run --name='gitlab' -it --rm \
-e 'GITLAB_PORT=10080' -e 'GITLAB_SSH_PORT=10022' \
-p 10022:22 -p 10080:80 \
-v /var/run/docker.sock:/run/docker.sock \
-v $(which docker):/bin/docker \
sameersbn/gitlab:7.6.2
```

Or you can use [fig](http://www.fig.sh/). Assuming you have fig installed,

```bash
wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/fig.yml
fig up
```

*The rest of the document will use the docker command line. You can quite simply adapt your configuration into a fig.yml file if you wish to do so.*

__NOTE__: Please allow a couple of minutes for the GitLab application to start.

Point your browser to `http://localhost:10080` and login using the default username and password:

* username: **root**
* password: **5iveL!fe**

You should now have the GitLab application up and ready for testing. If you want to use this image in production the please read on.

# Configuration

## Data Store

GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount a volume at,

* `/home/git/data`

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /opt/gitlab/data
sudo chcon -Rt svirt_sandbox_file_t /opt/gitlab/data
```

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
docker run --name=gitlab -d \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

## Database

GitLab uses a database backend to store its data. You can configure this image to use either MySQL or PostgreSQL.

*Note: GitLab HQ recommends using PostgreSQL over MySQL*

### MySQL

#### Internal MySQL Server

The internal mysql server has been removed from the image. Please use a [linked mysql](#linking-to-mysql-container) container or specify a connection to a [external mysql](#external-mysql-server) server.

If you have been using the internal mysql server follow these instructions to migrate to a linked mysql container:

Assuming that your mysql data is available at `/opt/gitlab/mysql`

```bash
docker run --name=mysql -d \
  -v /opt/gitlab/mysql:/var/lib/mysql \
  sameersbn/mysql:latest
```

This will start a mysql container with your existing mysql data. Now login to the mysql container and create a user for the existing `gitlabhq_production` database.

All you need to do now is link this mysql container to the gitlab ci container using the `--link mysql:mysql` option and provide the `DB_NAME`, `DB_USER` and `DB_PASS` parameters.

Refer to [Linking to MySQL Container](#linking-to-mysql-container) for more information.

#### External MySQL Server

The image can be configured to use an external MySQL database instead of starting a MySQL server internally. The database configuration should be specified using environment variables while starting the GitLab image.

Before you start the GitLab image create user and database for gitlab.

```sql
CREATE USER 'gitlab'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT ALL PRIVILEGES ON `gitlabhq_production`.* TO 'gitlab'@'%.%.%.%';
```

We are now ready to start the GitLab application.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run --name=gitlab -d \
  -e 'DB_HOST=192.168.1.100' -e 'DB_NAME=gitlabhq_production' -e 'DB_USER=gitlab' -e 'DB_PASS=password' \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
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
mkdir -p /opt/mysql/data
sudo chcon -Rt svirt_sandbox_file_t /opt/mysql/data
```

The run command looks like this.

```bash
docker run --name=mysql -d \
  -e 'DB_NAME=gitlabhq_production' -e 'DB_USER=gitlab' -e 'DB_PASS=password' \
	-v /opt/mysql/data:/var/lib/mysql \
	sameersbn/mysql:latest
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with full/remote access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name=gitlab -d --link mysql:mysql \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

The image will automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the mysql container using the magic of docker links and works with the following images:
 - [sameersbn/mysql](https://registry.hub.docker.com/u/sameersbn/mysql/)
 - [centurylink/mysql](https://registry.hub.docker.com/u/centurylink/mysql/)
 - [orchardup/mysql](https://registry.hub.docker.com/u/orchardup/mysql/)

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
docker run --name=gitlab -d \
  -e 'DB_TYPE=postgres' -e 'DB_HOST=192.168.1.100' -e 'DB_NAME=gitlabhq_production' -e 'DB_USER=gitlab' -e 'DB_PASS=password' \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

#### Linking to PostgreSQL Container

You can link this image with a postgresql container for the database requirements. The alias of the postgresql server container should be set to **postgresql** while linking with the gitlab image.

If a postgresql container is linked, only the `DB_TYPE`, `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a postgresql container, we will use the [sameersbn/postgresql](https://github.com/sameersbn/docker-postgresql) image. When using postgresql image in production you should mount a volume for the postgresql data store. Please refer the [README](https://github.com/sameersbn/docker-postgresql/blob/master/README.md) of docker-postgresql for details.

First, lets pull the postgresql image from the docker index.

```bash
docker pull sameersbn/postgresql:latest
```

For data persistence lets create a store for the postgresql and start the container.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /opt/postgresql/data
sudo chcon -Rt svirt_sandbox_file_t /opt/postgresql/data
```

The run command looks like this.

```bash
docker run --name=postgresql -d \
  -e 'DB_NAME=gitlabhq_production' -e 'DB_USER=gitlab' -e 'DB_PASS=password' \
  -v /opt/postgresql/data:/var/lib/postgresql \
  sameersbn/postgresql:latest
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name=gitlab -d --link postgresql:postgresql \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

The image will automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the postgresql container using the magic of docker links and works with the following images:
 - [sameersbn/postgresql](https://registry.hub.docker.com/u/sameersbn/postgresql/)
 - [orchardup/postgresql](https://registry.hub.docker.com/u/orchardup/postgresql/)
 - [paintedfox/postgresql](https://registry.hub.docker.com/u/paintedfox/postgresql/)

## Redis

GitLab uses the redis server for its key-value data store. The redis server connection details can be specified using environment variables.

### Internal Redis Server

The internal redis server has been removed from the image. Please use a [linked redis](#linking-to-redis-container) container or specify a [external redis](#external-redis-server) connection.

### External Redis Server

The image can be configured to use an external redis server instead of starting a redis server internally. The configuration should be specified using environment variables while starting the GitLab image.

*Assuming that the redis server host is 192.168.1.100*

```bash
docker run --name=gitlab -it --rm \
  -e 'REDIS_HOST=192.168.1.100' -e 'REDIS_PORT=6379' \
  sameersbn/gitlab:7.6.2
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
docker run --name=redis -d sameersbn/redis:latest
```

We are now ready to start the GitLab application.

```bash
docker run --name=gitlab -d --link redis:redisio \
  sameersbn/gitlab:7.6.2
```

### Mail

The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of SMTP parameters that can be specified.

```bash
docker run --name=gitlab -d \
  -e 'SMTP_USER=USER@gmail.com' -e 'SMTP_PASS=PASSWORD' \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

### SSL

Access to the gitlab application can be secured using SSL so as to prevent unauthorized access to the data in your repositories. While a CA certified SSL certificate allows for verification of trust via the CA, a self signed certificates can also provide an equal level of trust verification as long as each client takes some additional steps to verify the identity of your website. I will provide instructions on achieving this towards the end of this section.

To secure your application via SSL you basically need two things:
- **Private key (.key)**
- **SSL certificate (.crt)**

When using CA certified certificates, these files are provided to you by the CA. When using self-signed certificates you need to generate these files yourself. Skip the following section if you are armed with CA certified SSL certificates.

Jump to the [Using HTTPS with a load balancer](#using-https-with-a-load-balancer) section if you are using a load balancer such as hipache, haproxy or nginx.

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
openssl x509 -req -days 365 -in gitlab.csr -signkey gitlab.key -out gitlab.crt
```

Congratulations! you have now generated an SSL certificate thats valid for 365 days.

#### Strengthening the server security

This section provides you with instructions to [strengthen your server security](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html). To achieve this we need to generate stronger DHE parameters.

```bash
openssl dhparam -out dhparam.pem 2048
```

#### Installation of the SSL Certificates

Out of the four files generated above, we need to install the `gitlab.key`, `gitlab.crt` and `dhparam.pem` files at the gitlab server. The CSR file is not needed, but do make sure you safely backup the file (in case you ever need it again).

The default path that the gitlab application is configured to look for the SSL certificates is at `/home/git/data/certs`, this can however be changed using the `SSL_KEY_PATH`, `SSL_CERTIFICATE_PATH` and `SSL_DHPARAM_PATH` configuration options.

If you remember from above, the `/home/git/data` path is the path of the [data store](#data-store), which means that we have to create a folder named certs inside `/opt/gitlab/data/` and copy the files into it and as a measure of security we will update the permission on the `gitlab.key` file to only be readable by the owner.

```bash
mkdir -p /opt/gitlab/data/certs
cp gitlab.key /opt/gitlab/data/certs/
cp gitlab.crt /opt/gitlab/data/certs/
cp dhparam.pem /opt/gitlab/data/certs/
chmod 400 /opt/gitlab/data/certs/gitlab.key
```

Great! we are now just one step away from having our application secured.

#### Enabling HTTPS support

HTTPS support can be enabled by setting the `GITLAB_HTTPS` option to `true`. Additionally, when using self-signed SSL certificates you need to the set `SSL_SELF_SIGNED` option to `true` as well. Assuming we are using self-signed certificates

```bash
docker run --name=gitlab -d \
  -e 'GITLAB_HTTPS=true' -e 'SSL_SELF_SIGNED=true' \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

In this configuration, any requests made over the plain http protocol will automatically be redirected to use the https protocol. However, this is not optimal when using a load balancer.

#### Configuring HSTS

HSTS if supported by the browsers makes sure that your users will only reach your sever via HTTPS. When the user comes for the first time it sees a header from the server which states for how long from now this site should only be reachable via HTTPS - that's the HSTS max-age value.

With `GITLAB_HTTPS_HSTS_MAXAGE` you can configure that value. The default value is `31536000` seconds. If you want to disable a already sent HSTS MAXAGE value, set it to `0`.

```bash
docker run --name=gitlab -d \
 -e 'GITLAB_HTTPS=true' -e 'SSL_SELF_SIGNED=true' \
 -e 'GITLAB_HTTPS_HSTS_MAXAGE=2592000'
 -v /opt/gitlab/data:/home/git/data \
 sameersbn/gitlab:7.6.2
```

If you want to completely disable HSTS set `GITLAB_HTTPS_HSTS_ENABLED` to `false`.

#### Using HTTPS with a load balancer

Load balancers like nginx/haproxy/hipache talk to backend applications over plain http and as such the installation of ssl keys and certificates are not required and should **NOT** be installed in the container. The SSL configuration has to instead be done at the load balancer.

However, when using a load balancer you **MUST** set `GITLAB_HTTPS` to `true`. Additionally you will need to set the `SSL_SELF_SIGNED` option to `true` if self signed SSL certificates are in use.

With this in place, you should configure the load balancer to support handling of https requests. But that is out of the scope of this document. Please refer to [Using SSL/HTTPS with HAProxy](http://seanmcgary.com/posts/using-sslhttps-with-haproxy) for information on the subject.

When using a load balancer, you probably want to make sure the load balancer performs the automatic http to https redirection. Information on this can also be found in the link above.

In summation, when using a load balancer, the docker command would look for the most part something like this:

```bash
docker run --name=gitlab -d -p 10022:22 -p 10080:80 \
  -e 'GITLAB_SSH_PORT=10022' -e 'GITLAB_PORT=443' \
  -e 'GITLAB_HTTPS=true' -e 'SSL_SELF_SIGNED=true' \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

Again, drop the `-e 'SSL_SELF_SIGNED=true'` option if you are using CA certified SSL certificates.

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
docker run --name=gitlab -it --rm \
  -e 'GITLAB_RELATIVE_URL_ROOT=/git' \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:7.6.2
```

GitLab will now be accessible at the `/git` path, e.g. `http://www.example.com/git`.

**Note**: *The `GITLAB_RELATIVE_URL_ROOT` parameter should always begin with a slash and **SHOULD NOT** have any trailing slashes.*

### Putting it all together

```bash
docker run --name=gitlab -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql \
  -e 'GITLAB_HOST=git.local.host' -e 'GITLAB_EMAIL=gitlab@local.host' \
  -e 'SMTP_USER=USER@gmail.com' -e 'SMTP_PASS=PASSWORD' \
  sameersbn/gitlab:7.6.2
```

If you are using an external mysql database

```bash
docker run --name=gitlab -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -e 'DB_HOST=192.168.1.100' -e 'DB_NAME=gitlabhq_production' -e 'DB_USER=gitlab' -e 'DB_PASS=password' \
  -e 'GITLAB_HOST=git.local.host' -e 'GITLAB_EMAIL=gitlab@local.host' \
  -e 'SMTP_USER=USER@gmail.com' -e 'SMTP_PASS=PASSWORD' \
  sameersbn/gitlab:7.6.2
```

### OmniAuth Integration

GitLab leverages OmniAuth to allow users to sign in using Twitter, GitHub, and other popular services. Configuring OmniAuth does not prevent standard GitLab authentication or LDAP (if configured) from continuing to work. Users can choose to sign in using any of the configured mechanisms.

Refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/omniauth.html) for additional information.

#### Google

To enable the Google OAuth2 OmniAuth provider you must register your application with Google. Google will generate a client ID and secret key for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/google.html) for the procedure to generate the client ID and secret key with google.

Once you have the client ID and secret keys generated, configure them using the `OAUTH_GOOGLE_API_KEY` and `OAUTH_GOOGLE_APP_SECRET` environment variables respectively.

For example, if your client ID is `xxx.apps.googleusercontent.com` and client secret key is `yyy`, then adding `-e 'OAUTH_GOOGLE_API_KEY=xxx.apps.googleusercontent.com' -e 'OAUTH_GOOGLE_APP_SECRET=yyy'` to the docker run command enables support for Google OAuth.

You can also restrict logins to a single domain by adding `-e 'OAUTH_GOOGLE_RESTRICT_DOMAIN=example.com'`. This is particularly useful when combined with `-e 'OAUTH_ALLOW_SSO=true'` and `-e 'OAUTH_BLOCK_AUTO_CREATED_USERS=false'`.

#### Twitter

To enable the Twitter OAuth2 OmniAuth provider you must register your application with Twitter. Twitter will generate a API key and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/twitter.html) for the procedure to generate the API key and secret with twitter.

Once you have the API key and secret generated, configure them using the `OAUTH_TWITTER_API_KEY` and `OAUTH_TWITTER_APP_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `-e 'OAUTH_TWITTER_API_KEY=xxx' -e 'OAUTH_TWITTER_APP_SECRET=yyy'` to the docker run command enables support for Twitter OAuth.

#### GitHub

To enable the GitHub OAuth2 OmniAuth provider you must register your application with GitHub. GitHub will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/github.html) for the procedure to generate the Client ID and secret with github.

Once you have the Client ID and secret generated, configure them using the `OAUTH_GITHUB_API_KEY` and `OAUTH_GITHUB_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `-e 'OAUTH_GITHUB_API_KEY=xxx' -e 'OAUTH_GITHUB_APP_SECRET=yyy'` to the docker run command enables support for GitHub OAuth.

### External Issue Trackers

GitLab can be configured to use third party issue trackers such as Redmine and Atlassian Jira. Use of third party issue trackers have to be configured on a per project basis from the project settings page. This means that the GitLab's issue tracker is always the default tracker unless specified otherwise.

#### Redmine

Support for issue tracking using Redmine can be added by specifying the complete URL of the Redmine web server in the `REDMINE_URL` configuration option.

For example, if your Redmine server is accessible at `https://redmine.example.com`, then adding `-e 'REDMINE_URL=https://redmine.example.com'` to the docker run command enables Redmine support in GitLab

If you are using the [docker-redmine](https://github.com/sameersbn/docker-redmine) image, then you can *one up* the gitlab integration with redmine by adding `--volumes-from=gitlab` flag to the docker run command while starting the redmine container.

By using the above option the `/home/git/data/repositories` directory will be accessible by the redmine container and now you can add your git repository path to your redmine project. If, for example, in your gitlab server you have a project named `opensource/gitlab`, the bare repository will be accessible at `/home/git/data/repositories/opensource/gitlab.git`.

#### Jira

Support for issue tracking using Jira can be added by specifying the complete URL of the Jira web server in the `JIRA_URL` configuration option.

For example, if your Jira server is accessible at `https://jira.example.com`, then adding `-e 'JIRA_URL=https://jira.example.com'` to the docker run command enables Jira support in GitLab

### Host UID / GID Mapping

Per default the container is configured to run gitlab as user and group `git` with `uid` and `gid` `1000`. The host possibly uses this ids for different purposes leading to unfavorable effects. From the host it appears as if the mounted data volumes are owned by the host's user/group `1000`.

Also the container processes seem to be executed as the host's user/group `1000`. The container can be configured to map the `uid` and `gid` of `git` to different ids on host by passing the environment variables `USERMAP_UID` and `USERMAP_GID`. The following command maps the ids to user and group `git` on the host.

```bash
docker run --name=gitlab -it --rm [options] \
  -e "USERMAP_UID=$(id -u git)" -e "USERMAP_GID=$(id -g git)" \
  sameersbn/gitlab:7.6.2
```

When changing this mapping, all files and directories in the mounted data volume `/home/git/data` have to be re-owned by the new ids. This can be achieved automatically using the following command:

```bash
docker run --name=gitlab -d [OPTIONS] \
  sameersbn/gitlab:7.6.2 app:sanitize
```

### Piwik

If you want to monitor your gitlab instance with [Piwik](http://piwik.org/), there are two options to setup: `PIWIK_URL` and `PIWIK_SITE_ID`.
These options should contain something like:

- `PIWIK_URL=piwik.example.org`
- `PIWIK_SITE_ID=42`

### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command. Alternately you can use fig.*

Below is the complete list of available options that can be used to customize your gitlab installation.

- **GITLAB_HOST**: The hostname of the GitLab server. Defaults to `localhost`
- **GITLAB_PORT**: The port of the GitLab server. Defaults to `80` for plain http and `443` when https is enabled.
- **GITLAB_TIMEZONE**: Configure the timezone for the gitlab application. This configuration does not effect cron jobs. Defaults to `UTC`.
- **GITLAB_EMAIL**: The email address for the GitLab server.  Defaults to `example@example.com`.
- **GITLAB_EMAIL_ENABLED**: Enable or disable gitlab mailer. Defaults to the `SMTP_ENABLED` configuration.
- **GITLAB_SIGNUP**: Enable or disable user signups. Default is `false`.
- **GITLAB_SIGNIN**: If set to `false`, standard login form won't be shown on the sign-in page. Default is `true`.
- **GITLAB_PROJECTS_LIMIT**: Set default projects limit. Defaults to `100`.
- **GITLAB_USERNAME_CHANGE**: Enable or disable ability for users to change their username. Defaults is `true`.
- **GITLAB_CREATE_GROUP**: Enable or disable ability for users to create groups. Defaults is `true`.
- **GITLAB_PROJECTS_VISIBILITY**: Set default projects visibility level. Possible values `public`, `private` and `internal`. Defaults to `private`.
- **GITLAB_RESTRICTED_VISIBILITY**: Comma separated list of visibility levels to restrict non-admin users to set. Possible visibility options are `public`, `private` and `internal`.
- **GITLAB_WEBHOOK_TIMEOUT**: Sets the timeout for webhooks. Defaults to `10` seconds.
- **GITLAB_GRAVATAR_ENABLED**: Enable or disable use of gravatar.com for user avatar. Defaults to `true`
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
- **NGINX_MAX_UPLOAD_SIZE**: Maximum acceptable upload size. Defaults to `20m`.
- **NGINX_X_FORWARDED_PROTO**: Advanced configuration option for the `proxy_set_header X-Forwarded-Proto` setting in the gitlab nginx vHost configuration. Defaults to `https` when `GITLAB_HTTPS` is `true`, else defaults to `$scheme`.
- **REDIS_HOST**: The hostname of the redis server. Defaults to `localhost`
- **REDIS_PORT**: The connection port of the redis server. Defaults to `6379`.
- **UNICORN_WORKERS**: The number of unicorn workers to start. Defaults to `2`.
- **UNICORN_TIMEOUT**: Sets the timeout of unicorn worker processes. Defaults to `60` seconds.
- **SIDEKIQ_CONCURRENCY**: The number of concurrent sidekiq jobs to run. Defaults to `25`
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
- **SMTP_OPENSSL_VERIFY_MODE**: SMTP openssl verification mode. Accepted values are `none`, `peer`, `client_once` and `fail_if_no_peer_cert`. SSL certificate verification is performed by default.
- **SMTP_AUTHENTICATION**: Specify the SMTP authentication method. Defaults to `login` if `SMTP_USER` is set.
- **LDAP_ENABLED**: Enable LDAP. Defaults to `false`
- **LDAP_HOST**: LDAP Host
- **LDAP_PORT**: LDAP Port. Defaults to `636`
- **LDAP_UID**: LDAP UID. Defaults to `sAMAccountName`
- **LDAP_METHOD**: LDAP method, Possible values are `ssl`, `tls` and `plain`. Defaults to `ssl`
- **LDAP_BIND_DN**: No default.
- **LDAP_PASS**: LDAP password
- **LDAP_ACTIVE_DIRECTORY**: Specifies if LDAP server is Active Directory LDAP server. If your LDAP server is not AD, set this to `false`. Defaults to `true`,
- **LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN**: If enabled, GitLab will ignore everything after the first '@' in the LDAP username submitted by the user on login. Defaults to `false` if `LDAP_UID` is `userPrincipalName`, else `true`.
- **LDAP_BASE**: Base where we can search for users. No default.
- **LDAP_USER_FILTER**: Filter LDAP users. No default.
- **OAUTH_ALLOW_SSO**: This allows users to login without having a user account first. User accounts will be created automatically when authentication was successful. Defaults to `false`.
- **OAUTH_BLOCK_AUTO_CREATED_USERS**: Locks down those users until they have been cleared by the admin. Defaults to `true`.
- **OAUTH_GOOGLE_API_KEY**: Google App Client ID. No defaults.
- **OAUTH_GOOGLE_APP_SECRET**: Google App Client Secret. No defaults.
- **OAUTH_GOOGLE_RESTRICT_DOMAIN**: Google App restricted domain. No defaults.
- **OAUTH_TWITTER_API_KEY**: Twitter App API key. No defaults.
- **OAUTH_TWITTER_APP_SECRET**: Twitter App API secret. No defaults.
- **OAUTH_GITHUB_API_KEY**: GitHub App Client ID. No defaults.
- **OAUTH_GITHUB_APP_SECRET**: GitHub App Client secret. No defaults.
- **REDMINE_URL**: Location of the redmine server, e.g. `-e 'REDMINE_URL=https://redmine.example.com'`. No defaults.
- **JIRA_URL**: Location of the jira server, e.g. `-e 'JIRA_URL=https://jira.example.com'`. No defaults.
- **USERMAP_UID**: Sets the uid for user `git` to the specified uid. Defaults to `1000`.
- **USERMAP_GID**: Sets the gid for group `git` to the specified gid. Defaults to `USERMAP_UID` if defined, else defaults to `1000`.
- **GOOGLE_ANALYTICS_ID**: Google Analytics ID. No defaults.
- **PIWIK_URL**: Sets the Piwik URL. No defaults.
- **PIWIK_SITE_ID**: Sets the Piwik site ID. No defaults.

# Maintenance

## Creating backups

Gitlab defines a rake task to easily take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup, please make sure that the gitlab image is not running for obvious reasons

```bash
docker stop gitlab
```

To take a backup all you need to do is run the gitlab rake task to create a backup.

```bash
docker run --name=gitlab -it --rm [OPTIONS] \
  sameersbn/gitlab:7.6.2 app:rake gitlab:backup:create
```

A backup will be created in the backups folder of the [Data Store](#data-store). You can change that behavior by setting your own path within the container. To do so you have to pass the argument `-e "GITLAB_BACKUP_DIR:/path/to/backups"` to the docker run command.

## Restoring Backups

Gitlab defines a rake task to easily restore a backup of your gitlab installation. Before performing the restore operation please make sure that the gitlab image is not running.

```bash
docker stop gitlab
```

To restore a backup, run the image in interactive (-it) mode and pass the "app:restore" command to the container image.

```bash
docker run --name=gitlab -it --rm [OPTIONS] \
  sameersbn/gitlab:7.6.2 app:rake gitlab:backup:restore
```

The restore operation will list all available backups in reverse chronological order. Select the backup you want to restore and gitlab will do its job.

To avoid user interaction in the restore operation, you can specify the timestamp of the specific backup using the `BACKUP` argument to the rake task.

```bash
docker run --name=gitlab -it --rm [OPTIONS] \
  sameersbn/gitlab:7.6.2 app:rake gitlab:backup:restore BACKUP=1417624827
```

## Automated Backups

The image can be configured to automatically take backups on a daily, weekly or monthly basis. Adding `-e 'GITLAB_BACKUPS=daily'` to the docker run command will enable daily backups. Adding `-e 'GITLAB_BACKUPS=weekly'` or `-e 'GITLAB_BACKUPS=monthly'` will enable weekly or monthly backups.

Daily backups are created at `GITLAB_BACKUP_TIME` which defaults to `04:00` everyday. Weekly backups are created every Sunday at the same time as the daily backups. Monthly backups are created on the 1st of every month at the same time as the daily backups.

By default, when automated backups are enabled, backups are held for a period of 7 days. While when automated backups are disabled, the backups are held for an infinite period of time. This can behavior can be configured via the `GITLAB_BACKUP_EXPIRY` option.

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it gitlab bash
```

If you are using an older version of docker, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install `nsenter` execute the following command on your host,

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter gitlab
```

For more information refer https://github.com/jpetazzo/nsenter

# Upgrading

GitLabHQ releases new versions on the 22nd of every month, bugfix releases immediately follow. I update this project almost immediately when a release is made (at least it has been the case so far). If you are using the image in production environments I recommend that you delay updates by a couple of days after the gitlab release, allowing some time for the dust to settle down.

To upgrade to newer gitlab releases, simply follow this 4 step upgrade procedure.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/gitlab:7.6.2
```

- **Step 2**: Stop and remove the currently running image

```bash
docker stop gitlab
docker rm gitlab
```

- **Step 3**: Create a backup

```bash
docker run --name=gitlab -it --rm [OPTIONS] \
  sameersbn/gitlab:xx.xx.xx app:rake gitlab:backup:create
```

Replace **xx.xx.xx** with the version you are upgrading from. For example, if you are upgrading from version `6.0.0`, set `xx.xx.xx` to `6.0.0`

- **Step 4**: Start the image

```bash
docker run --name=gitlab -d [OPTIONS] sameersbn/gitlab:7.6.2
```

## Rake Tasks

The `app:rake` command allows you to run gitlab rake tasks. To run a rake task simply specify the task to be executed to the `app:rake` command. For example, if you want to gather information about GitLab and the system it runs on.

```bash
docker run --name=gitlab -d [OPTIONS] \
  sameersbn/gitlab:7.6.2 app:rake gitlab:env:info
```

Similarly, to import bare repositories into GitLab project instance

```bash
docker run --name=gitlab -d [OPTIONS] \
  sameersbn/gitlab:7.6.2 app:rake gitlab:import:repos
```

For a complete list of available rake tasks please refer https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks or the help section of your gitlab installation.

# References
  * https://github.com/gitlabhq/gitlabhq
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/requirements.md
  * http://wiki.nginx.org/HttpSslModule
  * https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  * https://github.com/gitlabhq/gitlab-recipes/blob/master/web-server/nginx/gitlab-ssl
  * https://github.com/jpetazzo/nsenter
  * https://jpetazzo.github.io/2014/03/23/lxc-attach-nsinit-nsenter-docker-0-9/
