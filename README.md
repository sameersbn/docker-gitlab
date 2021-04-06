[![](https://images.microbadger.com/badges/image/sameersbn/gitlab.svg)](http://microbadger.com/images/sameersbn/gitlab "Get your own image badge on microbadger.com")

# sameersbn/gitlab:13.10.2

- [Introduction](#introduction)
    - [Changelog](Changelog.md)
- [Contributing](#contributing)
- [Team](#team)
- [Issues](#issues)
- [Announcements](https://github.com/sameersbn/docker-gitlab/issues/39)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Data Store](#data-store)
    - [Database](#database)
        - [PostgreSQL (Recommended)](#postgresql)
            - [External PostgreSQL Server](#external-postgresql-server)
            - [Linking to PostgreSQL Container](#linking-to-postgresql-container)
            - [Upgrading PostgreSQL](#upgrading-postgresql)
    - [Redis](#redis)
        - [Internal Redis Server](#internal-redis-server)
        - [External Redis Server](#external-redis-server)
        - [Linking to Redis Container](#linking-to-redis-container)
    - [Mail](#mail)
        - [Reply by email](#reply-by-email)
    - [SSL](#ssl)
        - [Generation of a Self Signed Certificate](#generation-of-a-self-signed-certificate)
        - [Strengthening the server security](#strengthening-the-server-security)
        - [Installation of the SSL Certificates](#installation-of-the-ssl-certificates)
        - [Enabling HTTPS support](#enabling-https-support)
        - [Configuring HSTS](#configuring-hsts)
        - [Using HTTPS with a load balancer](#using-https-with-a-load-balancer)
        - [Establishing trust with your server](#establishing-trust-with-your-server)
        - [Installing Trusted SSL Server Certificates](#installing-trusted-ssl-server-certificates)
    - [Deploy to a subdirectory (relative url root)](#deploy-to-a-subdirectory-relative-url-root)
    - [OmniAuth Integration](#omniauth-integration)
        - [CAS3](#cas3)
        - [Authentiq](#authentiq)
        - [Google](#google)
        - [Twitter](#twitter)
        - [GitHub](#github)
        - [GitLab](#gitlab)
        - [BitBucket](#bitbucket)
        - [SAML](#saml)
        - [Crowd](#crowd)
        - [Microsoft Azure](#microsoft-azure)
        - [Generic OAuth2](#Generic-OAuth2)
    - [Gitlab Pages](#gitlab-pages)
    - [External Issue Trackers](#external-issue-trackers)
    - [Host UID / GID Mapping](#host-uid--gid-mapping)
    - [Piwik](#piwik)
    - [Exposing ssh port in dockerized gitlab-ce](docs/exposing-ssh-port.md)
    - [Available Configuration Parameters](#available-configuration-parameters)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
    - [Automated Backups](#automated-backups)
    - [Amazon Web Services (AWS) Remote Backups](#amazon-web-services-aws-remote-backups)
    - [Google Cloud Storage (GCS) Remote Backups](#google-cloud-storage-gcs-remote-backup)
    - [Rake Tasks](#rake-tasks)
    - [Import Repositories](#import-repositories)
    - [Upgrading](#upgrading)
    - [Shell Access](#shell-access)
- [Monitoring](#monitoring)
    - [Health Check](#health-check)
- [Container Registry](docs/container_registry.md)
- [Deploy in Docker Swarm mode, with HTTPS handled by Traefik proxy and Docker Registry](docs/docker-swarm-traefik-registry.md)
- [References](#references)

# Introduction

Dockerfile to build a [GitLab](https://about.gitlab.com/) image for the [Docker](https://www.docker.com/products/docker-engine) opensource container platform.

GitLab CE is set up in the Docker image using the [install from source](https://docs.gitlab.com/ce/install/installation.html) method as documented in the the official GitLab documentation.

For other methods to install GitLab please refer to the [Official GitLab Installation Guide](https://about.gitlab.com/install/) which includes a [GitLab image for Docker](https://docs.gitlab.com/omnibus/docker/).

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Be a part of the community and help resolve [Issues](https://github.com/sameersbn/docker-gitlab/issues)
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

# Team

- Niclas Mietz ([solidnerd](https://github.com/solidnerd))
- Sameer Naik ([sameersbn](https://github.com/sameersbn))

See [Contributors](../../graphs/contributors) for the complete list developers that have contributed to this project.

# Issues

Docker is a relatively new project and is active being developed and tested by a thriving community of developers and testers and every release of docker features many enhancements and bugfixes.

Given the nature of the development and release cycle it is very important that you have the latest version of docker installed because any issue that you encounter might have already been fixed with a newer docker release.

Install the most recent version of the Docker Engine for your platform using the [official Docker releases](http://docs.docker.com/engine/installation/), which can also be installed using:

```bash
wget -qO- https://get.docker.com/ | sh
```

Fedora and RHEL/CentOS users should try disabling selinux with `setenforce 0` and check if resolves the issue. If it does than there is not much that I can help you with. You can either stick with selinux disabled (not recommended by redhat) or switch to using ubuntu.

You may also set `DEBUG=true` to enable debugging of the entrypoint script, which could help you pin point any configuration issues.

If using the latest docker version and/or disabling selinux does not fix the issue then please file a issue request on the [issues](https://github.com/sameersbn/docker-gitlab/issues) page.

In your issue report please make sure you provide the following information:

- The host distribution and release version.
- Output of the `docker version` command
- Output of the `docker info` command
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Prerequisites

Your docker host needs to have 1GB or more of available RAM to run GitLab. Please refer to the GitLab [hardware requirements](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/requirements.md#hardware-requirements) documentation for additional information.

# Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/sameersbn/gitlab) and is the recommended method of installation.

```bash
docker pull sameersbn/gitlab:13.10.2
```

You can also pull the `latest` tag which is built from the repository *HEAD*

```bash
docker pull sameersbn/gitlab:latest
```

Alternatively you can build the image locally.

```bash
docker build -t sameersbn/gitlab github.com/sameersbn/docker-gitlab
```

# Quick Start

The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/).

```bash
wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.yml
```

Generate random strings that are at least `64` characters long for each of `GITLAB_SECRETS_OTP_KEY_BASE`, `GITLAB_SECRETS_DB_KEY_BASE`, and `GITLAB_SECRETS_SECRET_KEY_BASE`. These values are used for the following:

- `GITLAB_SECRETS_OTP_KEY_BASE` is used to encrypt 2FA secrets in the database. If you lose or rotate this secret, none of your users will be able to log in using 2FA.
- `GITLAB_SECRETS_DB_KEY_BASE` is used to encrypt CI secret variables, as well as import credentials, in the database. If you lose or rotate this secret, you will not be able to use existing CI secrets.
- `GITLAB_SECRETS_SECRET_KEY_BASE` is used for password reset links, and other 'standard' auth features. If you lose or rotate this secret, password reset tokens in emails will reset.

> **Tip**: You can generate a random string using `pwgen -Bsv1 64` and assign it as the value of `GITLAB_SECRETS_DB_KEY_BASE`.

Start GitLab using:

```bash
docker-compose up
```

Alternatively, you can manually launch the `gitlab` container and the supporting `postgresql` and `redis` containers by following this three step guide.

Step 1. Launch a postgresql container

```bash
docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --env 'DB_EXTENSION=pg_trgm' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:12-20200524
```

Step 2. Launch a redis container

```bash
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:4.0.9-2
```

Step 3. Launch the gitlab container

```bash
docker run --name gitlab -d \
    --link gitlab-postgresql:postgresql --link gitlab-redis:redisio \
    --publish 10022:22 --publish 10080:80 \
    --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022' \
    --env 'GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alpha-numeric-string' \
    --env 'GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alpha-numeric-string' \
    --env 'GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alpha-numeric-string' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

*Please refer to [Available Configuration Parameters](#available-configuration-parameters) to understand `GITLAB_PORT` and other configuration options*

__NOTE__: Please allow a couple of minutes for the GitLab application to start.

Point your browser to `http://localhost:10080` and set a password for the `root` user account.

You should now have the GitLab application up and ready for testing. If you want to use this image in production then please read on.

*The rest of the document will use the docker command line. You can quite simply adapt your configuration into a `docker-compose.yml` file if you wish to do so.*

# Configuration

## Data Store

GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount a volume at,

* `/home/git/data`

Note that if you are using the `docker-compose` approach, this has already been done for you.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/gitlab/gitlab
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/gitlab
```

Volumes can be mounted in docker by specifying the `-v` option in the docker run command.

```bash
docker run --name gitlab -d \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

## Database

GitLab uses a database backend to store its data. You can configure this image to use PostgreSQL.

*Note: GitLab requieres PostgreSQL now. So use an older image < 12.1 or migrate to PostgresSQL*

### PostgreSQL

*NOTE:* version 13.7.0 and later requires PostgreSQL version 12.x

#### External PostgreSQL Server

The image also supports using an external PostgreSQL Server. This is also controlled via environment variables.

```sql
CREATE ROLE gitlab with LOGIN CREATEDB PASSWORD 'password';
CREATE DATABASE gitlabhq_production;
GRANT ALL PRIVILEGES ON DATABASE gitlabhq_production to gitlab;
```

Additionally since GitLab `8.6.0` the `pg_trgm` extension should also be loaded for the `gitlabhq_production` database.

We are now ready to start the GitLab application.

*Assuming that the PostgreSQL server host is 192.168.1.100*

```bash
docker run --name gitlab -d \
    --env 'DB_HOST=192.168.1.100' \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

#### Linking to PostgreSQL Container

You can link this image with a postgresql container for the database requirements. The alias of the postgresql server container should be set to **postgresql** while linking with the gitlab image.

If a postgresql container is linked, only the `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a postgresql container, we will use the [sameersbn/postgresql](https://github.com/sameersbn/docker-postgresql) image. When using postgresql image in production you should mount a volume for the postgresql data store. Please refer the [README](https://github.com/sameersbn/docker-postgresql/blob/master/README.md) of docker-postgresql for details.

First, lets pull the postgresql image from the docker index.

```bash
docker pull sameersbn/postgresql:12-20200524
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
    --env 'DB_EXTENSION=pg_trgm' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:12-20200524
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-postgresql:postgresql \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

Here the image will also automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the postgresql container as they are specified in the `docker run` command for the postgresql container. This is made possible using the magic of docker links and works with the following images:

 - [postgres](https://hub.docker.com/_/postgres/)
 - [sameersbn/postgresql](https://quay.io/repository/sameersbn/postgresql/)
 - [orchardup/postgresql](https://hub.docker.com/r/orchardup/postgresql/)
 - [paintedfox/postgresql](https://hub.docker.com/r/paintedfox/postgresql/)

#### Upgrading PostgreSQL

When this Gitlab image upgrades its dependency on specific version of PostgreSQL you will need to make sure to use corresponding version of PostgreSQL.

If you are setting a brand new install, there is no data migration involved. However, if you already have an existing setup, the PostgreSQL data will need to be migrated as you are upgrading the version of PostgreSQL.

If you are using PostgreSQL image other than [sameersbn/postgresql](https://quay.io/repository/sameersbn/postgresql/) you will need make sure that the image you are using can handle migration itself, **or**, you will need to migrate the data yourself before starting newer version of PostgreSQL.

Following project provides Docker image that handles migration of PostgreSQL data: [tianon/postgres-upgrade](https://hub.docker.com/r/tianon/postgres-upgrade/)

After migration of the data, verify that other PostgreSQL configuration files in its data folder are copied over as well. One such file is `pg_hba.conf`, it will need to be copied from old version data folder into new version data folder.

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
    sameersbn/gitlab:13.10.2
```

### Linking to Redis Container

You can link this image with a redis container to satisfy gitlab's redis requirement. The alias of the redis server container should be set to **redisio** while linking with the gitlab image.

To illustrate linking with a redis container, we will use the [sameersbn/redis](https://github.com/sameersbn/docker-redis) image. Please refer the [README](https://github.com/sameersbn/docker-redis/blob/master/README.md) of docker-redis for details.

First, lets pull the redis image from the docker index.

```bash
docker pull sameersbn/redis:4.0.9-2
```

Lets start the redis container

```bash
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:4.0.9-2
```

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-redis:redisio \
    sameersbn/gitlab:13.10.2
```

### Mail

The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

If you are using Gmail then all you need to do is:

```bash
docker run --name gitlab -d \
    --env 'SMTP_USER=USER@gmail.com' --env 'SMTP_PASS=PASSWORD' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of SMTP parameters that can be specified.

#### Reply by email

Since version `8.0.0` GitLab adds support for commenting on issues by replying to emails.

To enable this feature you need to provide IMAP configuration parameters that will allow GitLab to connect to your mail server and read mails. Additionally, you may need to specify `GITLAB_INCOMING_EMAIL_ADDRESS` if your incoming email address is not the same as the `IMAP_USER`.

If your email provider supports email [sub-addressing](https://en.wikipedia.org/wiki/Email_address#Sub-addressing) then you should add the `+%{key}` placeholder after the user part of the email address, eg. `GITLAB_INCOMING_EMAIL_ADDRESS=reply+%{key}@example.com`. Please read the [documentation on reply by email](http://doc.gitlab.com/ce/incoming_email/README.html) to understand the requirements for this feature.

If you are using Gmail then all you need to do is:

```bash
docker run --name gitlab -d \
    --env 'IMAP_USER=USER@gmail.com' --env 'IMAP_PASS=PASSWORD' \
    --env 'GITLAB_INCOMING_EMAIL_ADDRESS=USER+%{key}@gmail.com' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of IMAP parameters that can be specified.

### SSL

Access to the gitlab application can be secured using SSL so as to prevent unauthorized access to the data in your repositories. While a CA certified SSL certificate allows for verification of trust via the CA, a self signed certificate can also provide an equal level of trust verification as long as each client takes some additional steps to verify the identity of your website. I will provide instructions on achieving this towards the end of this section.

Jump to the [Using HTTPS with a load balancer](#using-https-with-a-load-balancer) section if you are using a load balancer such as hipache, haproxy or nginx.

To secure your application via SSL you basically need two things:
- **Private key (.key)**
- **SSL certificate (.crt)**

When using CA certified certificates, these files are provided to you by the CA. When using self-signed certificates you need to generate these files yourself. Skip to [Strengthening the server security](#strengthening-the-server-security) section if you are armed with CA certified SSL certificates.

#### Generation of a Self Signed Certificate

Generation of a self-signed SSL certificate involves a simple 3-step procedure:

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

Congratulations! You now have a self-signed SSL certificate valid for 10 years.

#### Strengthening the server security

This section provides you with instructions to [strengthen your server security](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html). To achieve this we need to generate stronger DHE parameters.

```bash
openssl dhparam -out dhparam.pem 2048
```

#### Installation of the SSL Certificates

Out of the four files generated above, we need to install the `gitlab.key`, `gitlab.crt` and `dhparam.pem` files at the gitlab server. The CSR file is not needed, but do make sure you safely backup the file (in case you ever need it again).

The default path that the gitlab application is configured to look for the SSL certificates is at `/home/git/data/certs`, this can however be changed using the `SSL_KEY_PATH`, `SSL_CERTIFICATE_PATH` and `SSL_DHPARAM_PATH` configuration options.

If you remember from above, the `/home/git/data` path is the path of the [data store](#data-store), which means that we have to create a folder named `certs/` inside `/srv/docker/gitlab/gitlab/` and copy the files into it and as a measure of security we'll update the permission on the `gitlab.key` file to only be readable by the owner.

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
    sameersbn/gitlab:13.10.2
```

In this configuration, any requests made over the plain http protocol will automatically be redirected to use the https protocol. However, this is not optimal when using a load balancer.

#### Configuring HSTS

HSTS if supported by the browsers makes sure that your users will only reach your sever via HTTPS. When the user comes for the first time it sees a header from the server which states for how long from now this site should only be reachable via HTTPS - that's the HSTS max-age value.

With `NGINX_HSTS_MAXAGE` you can configure that value. The default value is `31536000` seconds. If you want to disable a already sent HSTS MAXAGE value, set it to `0`.

```bash
docker run --name gitlab -d \
 --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
 --env 'NGINX_HSTS_MAXAGE=2592000' \
 --volume /srv/docker/gitlab/gitlab:/home/git/data \
 sameersbn/gitlab:13.10.2
```

If you want to completely disable HSTS set `NGINX_HSTS_ENABLED` to `false`.

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
    sameersbn/gitlab:13.10.2
```

Again, drop the `--env 'SSL_SELF_SIGNED=true'` option if you are using CA certified SSL certificates.

In case GitLab responds to any kind of POST request (login, OAUTH, changing settings etc.) with a 422 HTTP Error, consider adding this to your reverse proxy configuration:

`proxy_set_header X-Forwarded-Ssl on;` (nginx format)

#### Establishing trust with your server

This section deals will self-signed ssl certificates. If you are using CA certified certificates, your done.

This section is more of a client side configuration so as to add a level of confidence at the client to be 100 percent sure they are communicating with whom they think they.

This is simply done by adding the servers certificate into their list of trusted certificates. On ubuntu, this is done by copying the `gitlab.crt` file to `/usr/local/share/ca-certificates/` and executing `update-ca-certificates`.

Again, this is a client side configuration which means that everyone who is going to communicate with the server should perform this configuration on their machine. In short, distribute the `gitlab.crt` file among your developers and ask them to add it to their list of trusted ssl certificates. Failure to do so will result in errors that look like this:

```bash
git clone https://git.local.host/gitlab-foss.git
fatal: unable to access 'https://git.local.host/gitlab-foss.git': server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none
```

You can do the same at the web browser. Instructions for installing the root certificate for firefox can be found [here](http://portal.threatpulse.com/docs/sol/Content/03Solutions/ManagePolicy/SSL/ssl_firefox_cert_ta.htm). You will find similar options chrome, just make sure you install the certificate under the authorities tab of the certificate manager dialog.

There you have it, that's all there is to it.

#### Installing Trusted SSL Server Certificates

If your GitLab CI server is using self-signed SSL certificates then you should make sure the GitLab CI server certificate is trusted on the GitLab server for them to be able to talk to each other.

The default path image is configured to look for the trusted SSL certificates is at `/home/git/data/certs/ca.crt`, this can however be changed using the `SSL_CA_CERTIFICATES_PATH` configuration option.

Copy the `ca.crt` file into the certs directory on the [datastore](#data-store). The `ca.crt` file should contain the root certificates of all the servers you want to trust. With respect to GitLab CI, this will be the contents of the gitlab_ci.crt file as described in the [README](https://github.com/sameersbn/docker-gitlab-ci/blob/master/README.md#ssl) of the [docker-gitlab-ci](https://github.com/sameersbn/docker-gitlab-ci) container.

By default, our own server certificate [gitlab.crt](#generation-of-self-signed-certificate) is added to the trusted certificates list.

### Deploy to a subdirectory (relative url root)

By default GitLab expects that your application is running at the root (eg. /). This section explains how to run your application inside a directory.

Let's assume we want to deploy our application to '/git'. GitLab needs to know this directory to generate the appropriate routes. This can be specified using the `GITLAB_RELATIVE_URL_ROOT` configuration option like so:

```bash
docker run --name gitlab -it --rm \
    --env 'GITLAB_RELATIVE_URL_ROOT=/git' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:13.10.2
```

GitLab will now be accessible at the `/git` path, e.g. `http://www.example.com/git`.

**Note**: *The `GITLAB_RELATIVE_URL_ROOT` parameter should always begin with a slash and* **SHOULD NOT** *have any trailing slashes.*

### OmniAuth Integration

GitLab leverages OmniAuth to allow users to sign in using Twitter, GitHub, and other popular services. Configuring OmniAuth does not prevent standard GitLab authentication or LDAP (if configured) from continuing to work. Users can choose to sign in using any of the configured mechanisms.

Refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/omniauth.html) for additional information.

#### CAS3

To enable the CAS OmniAuth provider you must register your application with your CAS instance. This requires the service URL GitLab will supply to CAS. It should be something like: https://git.example.com:443/users/auth/cas3/callback?url. By default handling for SLO is enabled, you only need to configure CAS for backchannel logout.

For example, if your cas server url is `https://sso.example.com`, then adding `--env 'OAUTH_CAS3_SERVER=https://sso.example.com'` to the docker run command enables support for CAS3 OAuth. Please refer to [Available Configuration Parameters](#available-configuration-parameters) for additional CAS3 configuration parameters.

#### Authentiq

To enable the Authentiq OmniAuth provider for passwordless authentication you must register an application with [Authentiq](https://www.authentiq.com/). Please refer to the GitLab [documentation](https://docs.gitlab.com/ce/administration/auth/authentiq.html) for the procedure to generate the client ID and secret key with Authentiq.

Once you have the API client id and client secret generated, configure them using the `OAUTH_AUTHENTIQ_CLIENT_ID` and `OAUTH_AUTHENTIQ_CLIENT_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `--env 'OAUTH_AUTHENTIQ_CLIENT_ID=xxx' --env 'OAUTH_AUTHENTIQ_CLIENT_SECRET=yyy'` to the docker run command enables support for Authentiq OAuth.

You may want to specify `OAUTH_AUTHENTIQ_REDIRECT_URI` as well. The OAuth scope can be altered as well with `OAUTH_AUTHENTIQ_SCOPE` (defaults to `'aq:name email~rs address aq:push'`).

#### Google

To enable the Google OAuth2 OmniAuth provider you must register your application with Google. Google will generate a client ID and secret key for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/google.html) for the procedure to generate the client ID and secret key with google.

Once you have the client ID and secret keys generated, configure them using the `OAUTH_GOOGLE_API_KEY` and `OAUTH_GOOGLE_APP_SECRET` environment variables respectively.

For example, if your client ID is `xxx.apps.googleusercontent.com` and client secret key is `yyy`, then adding `--env 'OAUTH_GOOGLE_API_KEY=xxx.apps.googleusercontent.com' --env 'OAUTH_GOOGLE_APP_SECRET=yyy'` to the docker run command enables support for Google OAuth.

You can also restrict logins to a single domain by adding `--env "OAUTH_GOOGLE_RESTRICT_DOMAIN='example.com'"`.

#### Facebook

To enable the Facebook OAuth2 OmniAuth provider you must register your application with Facebook. Facebook will generate a API key and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/facebook.html) for the procedure to generate the API key and secret.

Once you have the API key and secret generated, configure them using the `OAUTH_FACEBOOK_API_KEY` and `OAUTH_FACEBOOK_APP_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `--env 'OAUTH_FACEBOOK_API_KEY=xxx' --env 'OAUTH_FACEBOOK_APP_SECRET=yyy'` to the docker run command enables support for Facebook OAuth.

#### Twitter

To enable the Twitter OAuth2 OmniAuth provider you must register your application with Twitter. Twitter will generate a API key and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/twitter.html) for the procedure to generate the API key and secret with twitter.

Once you have the API key and secret generated, configure them using the `OAUTH_TWITTER_API_KEY` and `OAUTH_TWITTER_APP_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `--env 'OAUTH_TWITTER_API_KEY=xxx' --env 'OAUTH_TWITTER_APP_SECRET=yyy'` to the docker run command enables support for Twitter OAuth.

#### GitHub

To enable the GitHub OAuth2 OmniAuth provider you must register your application with GitHub. GitHub will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/github.html) for the procedure to generate the Client ID and secret with github.

Once you have the Client ID and secret generated, configure them using the `OAUTH_GITHUB_API_KEY` and `OAUTH_GITHUB_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_GITHUB_API_KEY=xxx' --env 'OAUTH_GITHUB_APP_SECRET=yyy'` to the docker run command enables support for GitHub OAuth.

Users of GitHub Enterprise may want to specify `OAUTH_GITHUB_URL` and `OAUTH_GITHUB_VERIFY_SSL` as well.

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

The following parameters have to be configured to enable SAML OAuth support in this image: `OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL`, `OAUTH_SAML_IDP_CERT_FINGERPRINT`, `OAUTH_SAML_IDP_SSO_TARGET_URL`, `OAUTH_SAML_ISSUER` and `OAUTH_SAML_NAME_IDENTIFIER_FORMAT`.

You can also override the default "Sign in with" button label with `OAUTH_SAML_LABEL`.

Please refer to [Available Configuration Parameters](#available-configuration-parameters) for the default configurations of these parameters.

#### Crowd

To enable the Crowd server OAuth2 OmniAuth provider you must register your application with Crowd server.

Configure GitLab to enable access the Crowd server by specifying the `OAUTH_CROWD_SERVER_URL`, `OAUTH_CROWD_APP_NAME` and `OAUTH_CROWD_APP_PASSWORD` environment variables.

#### Auth0

To enable the Auth0 OmniAuth provider you must register your application with [auth0](https://auth0.com/).

Configure the following environment variables `OAUTH_AUTH0_CLIENT_ID`, `OAUTH_AUTH0_CLIENT_SECRET` and `OAUTH_AUTH0_DOMAIN` to complete the integration.

#### Microsoft Azure

To enable the Microsoft Azure OAuth2 OmniAuth provider you must register your application with Azure. Azure will generate a Client ID, Client secret and Tenant ID for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/azure.html) for the procedure.

Once you have the Client ID, Client secret and Tenant ID generated, configure them using the `OAUTH_AZURE_API_KEY`, `OAUTH_AZURE_API_SECRET` and `OAUTH_AZURE_TENANT_ID` environment variables respectively.

For example, if your Client ID is `xxx`, the Client secret is `yyy` and the Tenant ID is `zzz`, then adding `--env 'OAUTH_AZURE_API_KEY=xxx' --env 'OAUTH_AZURE_API_SECRET=yyy' --env 'OAUTH_AZURE_TENANT_ID=zzz'` to the docker run command enables support for Microsoft Azure OAuth.

#### Generic OAuth2

To enable the Generic OAuth2 provider, you must register your application with your provider. You also need to confirm OAuth2 provider app's ID and secret, the client options and the user's response structure.

As an example this code has been tested with Keycloak, with the following variables: `OAUTH2_GENERIC_APP_ID`, `OAUTH2_GENERIC_APP_SECRET`, `OAUTH2_GENERIC_CLIENT_SITE`, `OAUTH2_GENERIC_CLIENT_USER_INFO_URL`, `OAUTH2_GENERIC_CLIENT_AUTHORIZE_URL`, `OAUTH2_GENERIC_CLIENT_TOKEN_URL`, `OAUTH2_GENERIC_CLIENT_END_SESSION_ENDPOINT`, `OAUTH2_GENERIC_ID_PATH`, `OAUTH2_GENERIC_USER_UID`, `OAUTH2_GENERIC_USER_NAME`, `OAUTH2_GENERIC_USER_EMAIL`, `OAUTH2_GENERIC_NAME`,

See [GitLab documentation](https://docs.gitlab.com/ee/integration/oauth2_generic.html#sign-into-gitlab-with-almost-any-oauth2-provider) and [Omniauth-oauth2-generic documentation](https://gitlab.com/satorix/omniauth-oauth2-generic) for more details.

### Gitlab Pages

Gitlab Pages allows a user to host static websites from a project. Gitlab pages can be enabled with setting the envrionment variable `GITLAB_PAGES_ENABLED` to `true`.

### Gitlab Pages Access Control

Since version `11.5.0` Gitlab pages supports access control. This allows only access to a published website if you are a project member, or have access to a certain project.

Gitlab pages access control requires additional configuration before activating it through the variable `GITLAB_PAGES_ACCESS_CONTROL`.

Gitab pages access control makes use of the Gitlab OAuth Module.

 - Goto the Gitlab Admin area
 - Select `Applications` in the menu
 - Create `New Application`
   - Name: `Gitlab Pages`
   - Scopes:
     - api
   - Trusted: NO (Do not select)
   - Redirect URI: https://projects.<GITLAB_PAGES_DOMAIN>/auth

Note about the `Redirect URI`; this can be tricky to configure or figure out, What needs to be achieved is to following, the redirect URI needs to end up at the `gitlab-pages` daemon with the `/auth` endpoint.

This means that if you run your gitlab pages at domain `pages.example.io` this will be a wilcard domain where your projects are created based on their namespace. The best trick is to enter a NON-Existing gitlab project pages URI as the redirect URI.

In the example above; the pages domain `projects` has been chosen. This will cause the nginx, either the built in or your own loadbalancer to redirect `*.<GITLAB_PAGES_DOMAIN>` to the `gitlab-pages` daemon. Which will trigger the pages endpoint.

Make sure to choose own which does not exist and make sure that the request is routed to the `gitlab-pages` daemon if you are using your own HTTP load balancer in front of Gitlab.

After creating the OAuth application endpoint for the Gitlab Pages Daemon. Gitlab pages access control can now be enabled.

Add to following environment variables to your Gitlab Container.

| Variable | R/O | Description |
|----------|-----|-------------|
| GITLAB_PAGES_ACCESS_CONTROL | Required | Set to `true` to enable access control. |
| GITLAB_PAGES_ACCESS_SECRET | Optional | Secret Hash, minimal 32 characters, if omitted, it will be auto generated. |
| GITLAB_PAGES_ACCESS_CONTROL_SERVER | Required | Gitlab instance URI, example: `https://gitlab.example.io` |
| GITLAB_PAGES_ACCESS_CLIENT_ID | Required | Client ID from earlier generated OAuth application |
| GITLAB_PAGES_ACCESS_CLIENT_SECRET | Required | Client Secret from earlier genereated OAuth application |
| GITLAB_PAGES_ACCESS_REDIRECT_URI | Required | Redirect URI, non existing pages domain to redirect to pages daemon, `https://projects.example.io` |

After you have enabled the gitlab pages access control. When you go to a project `General Settings` -> `Permissions` you can choose the pages persmission level for the project.


### External Issue Trackers

Since version `7.10.0` support for external issue trackers can be enabled in the "Service Templates" section of the settings panel.

If you are using the [docker-redmine](https://github.com/sameersbn/docker-redmine) image, you can *one up* the gitlab integration with redmine by adding `--volumes-from=gitlab` flag to the docker run command while starting the redmine container.

By using the above option the `/home/git/data/repositories` directory will be accessible by the redmine container and now you can add your git repository path to your redmine project. If, for example, in your gitlab server you have a project named `opensource/gitlab`, the bare repository will be accessible at `/home/git/data/repositories/opensource/gitlab.git` in the redmine container.

### Host UID / GID Mapping

Per default the container is configured to run gitlab as user and group `git` with `uid` and `gid` `1000`. The host possibly uses this ids for different purposes leading to unfavorable effects. From the host it appears as if the mounted data volumes are owned by the host's user/group `1000`.

Also the container processes seem to be executed as the host's user/group `1000`. The container can be configured to map the `uid` and `gid` of `git` to different ids on host by passing the environment variables `USERMAP_UID` and `USERMAP_GID`. The following command maps the ids to user and group `git` on the host.

```bash
docker run --name gitlab -it --rm [options] \
    --env "USERMAP_UID=$(id -u git)" --env "USERMAP_GID=$(id -g git)" \
    sameersbn/gitlab:13.10.2
```

When changing this mapping, all files and directories in the mounted data volume `/home/git/data` have to be re-owned by the new ids. This can be achieved automatically using the following command:

```bash
docker run --name gitlab -d [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:sanitize
```

### Piwik

If you want to monitor your gitlab instance with [Piwik](http://piwik.org/), there are two options to setup: `PIWIK_URL` and `PIWIK_SITE_ID`.
These options should contain something like:

- `PIWIK_URL=piwik.example.org`
- `PIWIK_SITE_ID=42`


### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command. Alternatively you can use docker-compose. docker-compose users and Docker Swarm mode users can also use the [secrets and config file options](#docker-secrets-and-configs)*


Below is the complete list of available options that can be used to customize your gitlab installation.

| Parameter | Description |
|-----------|-------------|
| `DEBUG` | Set this to `true` to enable entrypoint debugging. |
| `GITLAB_HOST` | The hostname of the GitLab server. Defaults to `localhost` |
| `GITLAB_CI_HOST` | If you are migrating from GitLab CI use this parameter to configure the redirection to the GitLab service so that your existing runners continue to work without any changes. No defaults. |
| `GITLAB_PORT` | The port of the GitLab server. This value indicates the public port on which the GitLab application will be accessible on the network and appropriately configures GitLab to generate the correct urls. It does not affect the port on which the internal nginx server will be listening on. Defaults to `443` if `GITLAB_HTTPS=true`, else defaults to `80`. |
| `GITLAB_SECRETS_DB_KEY_BASE` | Encryption key for GitLab CI secret variables, as well as import credentials, in the database. Ensure that your key is at least 32 characters long and that you don't lose it. You can generate one using `pwgen -Bsv1 64`. If you are migrating from GitLab CI, you need to set this value to the value of `GITLAB_CI_SECRETS_DB_KEY_BASE`. No defaults. |
| `GITLAB_SECRETS_SECRET_KEY_BASE` | Encryption key for session secrets. Ensure that your key is at least 64 characters long and that you don't lose it. This secret can be rotated with minimal impact - the main effect is that previously-sent password reset emails will no longer work. You can generate one using `pwgen -Bsv1 64`. No defaults. |
| `GITLAB_SECRETS_OTP_KEY_BASE` |  Encryption key for OTP related stuff with  GitLab. Ensure that your key is at least 64 characters long and that you don't lose it. **If you lose or change this secret, 2FA will stop working for all users.** You can generate one using `pwgen -Bsv1 64`. No defaults. |
| `GITLAB_TIMEZONE` | Configure the timezone for the gitlab application. This configuration does not effect cron jobs. Defaults to `UTC`. See the list of [acceptable values](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html). |
| `GITLAB_ROOT_PASSWORD` | The password for the root user on firstrun. Defaults to `5iveL!fe`. GitLab requires this to be at least **8 characters long**. |
| `GITLAB_ROOT_EMAIL` | The email for the root user on firstrun. Defaults to `admin@example.com` |
| `GITLAB_EMAIL` | The email address for the GitLab server. Defaults to value of `SMTP_USER`, else defaults to `example@example.com`. |
| `GITLAB_EMAIL_DISPLAY_NAME` | The name displayed in emails sent out by the GitLab mailer. Defaults to `GitLab`. |
| `GITLAB_EMAIL_REPLY_TO` | The reply-to address of emails sent out by GitLab. Defaults to value of `GITLAB_EMAIL`, else defaults to `noreply@example.com`. |
| `GITLAB_EMAIL_SUBJECT_SUFFIX` | The e-mail subject suffix used in e-mails sent by GitLab. No defaults. |
| `GITLAB_EMAIL_ENABLED` | Enable or disable gitlab mailer. Defaults to the `SMTP_ENABLED` configuration. |
| `GITLAB_EMAIL_SMIME_ENABLE` | Enable or disable email S/MIME signing. Defaults is `false`. |
| `GITLAB_EMAIL_SMIME_KEY_FILE` | Specifies the path to a S/MIME private key file in PEM format, unencrypted. Defaults to ``. |
| `GITLAB_EMAIL_SMIME_CERT_FILE` | Specifies the path to a S/MIME public certificate key in PEM format. Defaults to ``. |
| `GITLAB_DEFAULT_THEME` | Default theme ID, by default 2. (1 - Indigo, 2 - Dark, 3 - Light, 4 - Blue, 5 - Green, 6 - Light Indigo, 7 - Light Blue, 8 - Light Green, 9 - Red, 10 - Light Red) |
| `GITLAB_INCOMING_EMAIL_ADDRESS` | The incoming email address for reply by email. Defaults to the value of `IMAP_USER`, else defaults to `reply@example.com`. Please read the [reply by email](http://doc.gitlab.com/ce/incoming_email/README.html) documentation to currently set this parameter. |
| `GITLAB_INCOMING_EMAIL_ENABLED` | Enable or disable gitlab reply by email feature. Defaults to the value of `IMAP_ENABLED`. |
| `GITLAB_SIGNUP_ENABLED` | Enable or disable user signups (first run only). Default is `true`. |
| `GITLAB_IMPERSONATION_ENABLED` | Enable or disable impersonation. Defaults to `true`. |
| `GITLAB_PROJECTS_LIMIT` | Set default projects limit. Defaults to `100`. |
| `GITLAB_USERNAME_CHANGE` | Enable or disable ability for users to change their username. Defaults to `true`. |
| `GITLAB_CREATE_GROUP` | Enable or disable ability for users to create groups. Defaults to `true`. |
| `GITLAB_PROJECTS_ISSUES` | Set if *issues* feature should be enabled by default for new projects. Defaults to `true`. |
| `GITLAB_PROJECTS_MERGE_REQUESTS` | Set if *merge requests* feature should be enabled by default for new projects. Defaults to `true`. |
| `GITLAB_PROJECTS_WIKI` | Set if *wiki* feature should be enabled by default for new projects. Defaults to `true`. |
| `GITLAB_PROJECTS_SNIPPETS` | Set if *snippets* feature should be enabled by default for new projects. Defaults to `false`. |
| `GITLAB_PROJECTS_BUILDS` | Set if *builds* feature should be enabled by default for new projects. Defaults to `true`. |
| `GITLAB_PROJECTS_CONTAINER_REGISTRY` | Set if *container_registry* feature should be enabled by default for new projects. Defaults to `true`. |
| `GITLAB_WEBHOOK_TIMEOUT` | Sets the timeout for webhooks. Defaults to `10` seconds. |
| `GITLAB_NOTIFY_ON_BROKEN_BUILDS` | Enable or disable broken build notification emails. Defaults to `true` |
| `GITLAB_NOTIFY_PUSHER` | Add pusher to recipients list of broken build notification emails. Defaults to `false` |
| `GITLAB_REPOS_DIR` | The git repositories folder in the container. Defaults to `/home/git/data/repositories` |
| `GITLAB_BACKUP_DIR` | The backup folder in the container. Defaults to `/home/git/data/backups` |
| `GITLAB_BACKUP_DIR_CHOWN` | Optionally change ownership of backup files on start-up. Defaults to `true` |
| `GITLAB_BACKUP_DIR_GROUP` | Optionally group backups into a subfolder. Can also be used to place backups in to a subfolder on remote storage. Not used by default. |
| `GITLAB_BUILDS_DIR` | The build traces directory. Defaults to `/home/git/data/builds` |
| `GITLAB_DOWNLOADS_DIR` | The repository downloads directory. A temporary zip is created in this directory when users click **Download Zip** on a project. Defaults to `/home/git/data/tmp/downloads`. |
| `GITLAB_SHARED_DIR` | The directory to store the build artifacts. Defaults to `/home/git/data/shared` |
| `GITLAB_ARTIFACTS_ENABLED` | Enable/Disable GitLab artifacts support. Defaults to `true`. |
| `GITLAB_ARTIFACTS_DIR` | Directory to store the artifacts. Defaults to `$GITLAB_SHARED_DIR/artifacts` |
| `AWS_ACCESS_KEY_ID`| Default AWS access key to be used for object store. Defaults to `AWS_ACCESS_KEY_ID`|
| `AWS_SECRET_ACCESS_KEY`| Default AWS access key to be used for object store. Defaults to `AWS_SECRET_ACCESS_KEY`|
| `GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`| Default Google project to use for Object Store.|
| `GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`| Default Google service account email to use for Object Store.|
| `GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION`| Default Google key file Defaults to `/gcs/key.json`|
| `GITLAB_OBJECT_STORE_CONNECTION_PROVIDER`| Default object store connection provider. Defaults to `AWS`|
| `GITLAB_ARTIFACTS_OBJECT_STORE_ENABLED` | Enables Object Store for Artifacts that will be remote stored. Defaults to `false` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_REMOTE_DIRECTORY` | Bucket name to store the artifacts. Defaults to `artifacts` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_DIRECT_UPLOAD` | Set to true to enable direct upload of Artifacts without the need of local shared storage.  Defaults to `false` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_BACKGROUND_UPLOAD` | Temporary option to limit automatic upload. Defaults to `false` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_PROXY_DOWNLOAD` | Passthrough all downloads via GitLab instead of using Redirects to Object Storage. Defaults to `false` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_PROVIDER` | Connection Provider for the Object Store. (`AWS` or `Google`) Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_PROVIDER` (`AWS`) |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_ACCESS_KEY_ID` | AWS Access Key ID for the Bucket. Defaults to `$AWS_ACCESS_KEY_ID` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key. Defaults to `$AWS_SECRET_ACCESS_KEY` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_REGION` | AWS Region. Defaults to `us-east-1` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_HOST` | Configure this for an compatible AWS host like minio. Defaults to `s3.amazonaws.com` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_ENDPOINT` | AWS Endpoint like `http://127.0.0.1:9000`. Defaults to `nil` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_PATH_STYLE` | Changes AWS Path Style to 'host/bucket_name/object' instead of 'bucket_name.host/object'. Defaults to `true` |
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`| Google project. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`|
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`| Google service account. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`|
| `GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION`| Default Google key file. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION` (`/gcs/key.json`)|
| `GITLAB_PIPELINE_SCHEDULE_WORKER_CRON` | Cron notation for the GitLab pipeline schedule worker. Defaults to `'19 * * * *'` |
| `GITLAB_LFS_ENABLED` | Enable/Disable Git LFS support. Defaults to `true`. |
| `GITLAB_LFS_OBJECTS_DIR` | Directory to store the lfs-objects. Defaults to `$GITLAB_SHARED_DIR/lfs-objects` |
| `GITLAB_LFS_OBJECT_STORE_ENABLED` | Enables Object Store for LFS that will be remote stored. Defaults to `false` |
| `GITLAB_LFS_OBJECT_STORE_REMOTE_DIRECTORY` | Bucket name to store the LFS. Defaults to `lfs-object` |
| `GITLAB_LFS_OBJECT_STORE_BACKGROUND_UPLOAD` | Temporary option to limit automatic upload. Defaults to `false` |
| `GITLAB_LFS_OBJECT_STORE_PROXY_DOWNLOAD` | Passthrough all downloads via GitLab instead of using Redirects to Object Storage. Defaults to `false` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_PROVIDER` | Connection Provider for the Object Store. (`AWS` or `Google`) Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_PROVIDER` (`AWS`) |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_ACCESS_KEY_ID` | AWS Access Key ID for the Bucket. Defaults to `AWS_ACCESS_KEY_ID` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key. Defaults to `AWS_SECRET_ACCESS_KEY` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_REGION` | AWS Region. Defaults to `us-east-1` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_HOST` | Configure this for an compatible AWS host like minio. Defaults to `s3.amazonaws.com` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_ENDPOINT` | AWS Endpoint like `http://127.0.0.1:9000`. Defaults to `nil` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_PATH_STYLE` | Changes AWS Path Style to 'host/bucket_name/object' instead of 'bucket_name.host/object'. Defaults to `true` |
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`| Google project. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`|
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`| Google service account. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`|
| `GITLAB_LFS_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION`| Default Google key file. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION` (`/gcs/key.json`)|
| `GITLAB_UPLOADS_STORAGE_PATH` | The location where uploads objects are stored. Defaults to `$GITLAB_SHARED_DIR/public`. |
| `GITLAB_UPLOADS_BASE_DIR` | Mapping for the `GITLAB_UPLOADS_STORAGE_PATH`. Defaults to `uploads/-/system` |
| `GITLAB_UPLOADS_OBJECT_STORE_ENABLED` | Enables Object Store for UPLOADS that will be remote stored. Defaults to `false` |
| `GITLAB_UPLOADS_OBJECT_STORE_REMOTE_DIRECTORY` | Bucket name to store the UPLOADS. Defaults to `uploads` |
| `GITLAB_UPLOADS_OBJECT_STORE_BACKGROUND_UPLOAD` | Temporary option to limit automatic upload. Defaults to `false` |
| `GITLAB_UPLOADS_OBJECT_STORE_PROXY_DOWNLOAD` | Passthrough all downloads via GitLab instead of using Redirects to Object Storage. Defaults to `false` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_PROVIDER` | Connection Provider for the Object Store. (`AWS` or `Google`) Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_PROVIDER` (`AWS`) |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_ACCESS_KEY_ID` | AWS Access Key ID for the Bucket. Defaults to `AWS_ACCESS_KEY_ID` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key. Defaults to `AWS_SECRET_ACCESS_KEY` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_REGION` | AWS Region. Defaults to `us-east-1` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_HOST` | Configure this for an compatible AWS host like minio. Defaults to `s3.amazonaws.com` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_ENDPOINT` | AWS Endpoint like `http://127.0.0.1:9000`. Defaults to `nil` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_PATH_STYLE` | Changes AWS Path Style to 'host/bucket_name/object' instead of 'bucket_name.host/object'. Defaults to `true` |
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`| Google project. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_PROJECT`|
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`| Google service account. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_CLIENT_EMAIL`|
| `GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION`| Default Google key file. Defaults to `$GITLAB_OBJECT_STORE_CONNECTION_GOOGLE_JSON_KEY_LOCATION` (`/gcs/key.json`)|
| `GITLAB_MATTERMOST_ENABLED` | Enable/Disable GitLab Mattermost for *Add Mattermost button*. Defaults to `false`. |
| `GITLAB_MATTERMOST_URL` | Sets Mattermost URL. Defaults to `https://mattermost.example.com`. |
| `GITLAB_BACKUP_SCHEDULE` | Setup cron job to automatic backups. Possible values `disable`, `daily`, `weekly` or `monthly`. Disabled by default |
| `GITLAB_BACKUP_EXPIRY` | Configure how long (in seconds) to keep backups before they are deleted. By default when automated backups are disabled backups are kept forever (0 seconds), else the backups expire in 7 days (604800 seconds). |
| `GITLAB_BACKUP_PG_SCHEMA` | Specify the PostgreSQL schema for the backups. No defaults, which means that all schemas will be backed up. see #524 |
| `GITLAB_BACKUP_ARCHIVE_PERMISSIONS` | Sets the permissions of the backup archives. Defaults to `0600`. [See](http://doc.gitlab.com/ce/raketasks/backup_restore.html#backup-archive-permissions) |
| `GITLAB_BACKUP_TIME` | Set a time for the automatic backups in `HH:MM` format. Defaults to `04:00`. |
| `GITLAB_BACKUP_SKIP` | Specified sections are skipped by the backups. Defaults to empty, i.e. `lfs,uploads`. [See](http://doc.gitlab.com/ce/raketasks/backup_restore.html#create-a-backup-of-the-gitlab-system) |
| `GITLAB_SSH_HOST` | The ssh host. Defaults to **GITLAB_HOST**. |
| `GITLAB_SSH_LISTEN_PORT` | The ssh port for SSHD to listen on. Defaults to `22` |
| `GITLAB_SSH_MAXSTARTUPS` | The ssh "MaxStartups" parameter, defaults to `10:30:60`. |
| `GITLAB_SSH_PORT` | The ssh port number. Defaults to `$GITLAB_SSH_LISTEN_PORT`. |
| `GITLAB_RELATIVE_URL_ROOT` | The relative url of the GitLab server, e.g. `/git`. No default. |
| `GITLAB_TRUSTED_PROXIES` | Add IP address reverse proxy to trusted proxy list, otherwise users will appear signed in from that address. Currently only a single entry is permitted. No defaults. |
| `GITLAB_REGISTRY_ENABLED` | Enables the GitLab Container Registry. Defaults to `false`. |
| `GITLAB_REGISTRY_HOST` | Sets the GitLab Registry Host. Defaults to `registry.example.com` |
| `GITLAB_REGISTRY_PORT` | Sets the GitLab Registry Port. Defaults to `443`. |
| `GITLAB_REGISTRY_API_URL` | Sets the GitLab Registry API URL. Defaults to `http://localhost:5000` |
| `GITLAB_REGISTRY_KEY_PATH` | Sets the GitLab Registry Key Path. Defaults to `config/registry.key` |
| `GITLAB_REGISTRY_DIR` | Directory to store the container images will be shared with registry. Defaults to `$GITLAB_SHARED_DIR/registry` |
| `GITLAB_REGISTRY_ISSUER` | Sets the GitLab Registry Issuer. Defaults to `gitlab-issuer`. |
| `GITLAB_REGISTRY_GENERATE_INTERNAL_CERTIFICATES` | Set to `true` to generate SSL internal Registry keys. Used to communicate between a Docker Registry and GitLab. It will generate a self-signed certificate key at the location given by `$GITLAB_REGISTRY_KEY_PATH`, e.g. `/certs/registry.key`. And will generate the certificate file at the same location, with the same name, but changing the extension from `key` to `crt`, e.g. `/certs/registry.crt` |
| `GITLAB_PAGES_ENABLED` | Enables the GitLab Pages. Defaults to `false`. |
| `GITLAB_PAGES_DOMAIN` | Sets the GitLab Pages Domain. Defaults to `example.com` |
| `GITLAB_PAGES_DIR` | Sets GitLab Pages directory where all pages will be stored. Defaults to `$GITLAB_SHARED_DIR/pages` |
| `GITLAB_PAGES_PORT`| Sets GitLab Pages Port that will be used in NGINX. Defaults to `80` |
| `GITLAB_PAGES_HTTPS` | Sets GitLab Pages to HTTPS and the gitlab-pages-ssl config will be used. Defaults to `false` |
| `GITLAB_PAGES_ARTIFACTS_SERVER` | Set to `true` to enable pages artifactsserver, enabled by default. |
| `GITLAB_PAGES_ARTIFACTS_SERVER_URL` | If `GITLAB_PAGES_ARTIFACTS_SERVER` is enabled, set to API endpoint for GitLab Pages (e.g. `https://example.com/api/v4`). No default. |
| `GITLAB_PAGES_EXTERNAL_HTTP` | Sets GitLab Pages external http to receive request on an independen port. Disabled by default |
| `GITLAB_PAGES_EXTERNAL_HTTPS` | Sets GitLab Pages external https to receive request on an independen port. Disabled by default |
| `GITLAB_PAGES_ACCESS_CONTROL` | Set to `true` to enable access control for pages. Allows access to a Pages site to be controlled based on a user’s membership to that project. Disabled by default. |
| `GITLAB_PAGES_NGINX_PROXY` | Disable the nginx proxy for gitlab pages, defaults to `true`. When set to `false` this will turn off the nginx proxy to the gitlab pages daemon, used when the user provides their own http load balancer in combination with a gitlab pages custom domain setup. |
| `GITLAB_PAGES_ACCESS_SECRET` | Secret Hash, minimal 32 characters, if omitted, it will be auto generated. |
| `GITLAB_PAGES_ACCESS_CONTROL_SERVER` | Gitlab instance URI, example: `https://gitlab.example.io` |
| `GITLAB_PAGES_ACCESS_CLIENT_ID` | Client ID from earlier generated OAuth application |
| `GITLAB_PAGES_ACCESS_CLIENT_SECRET` | Client Secret from earlier genereated OAuth application |
| `GITLAB_PAGES_ACCESS_REDIRECT_URI` | Redirect URI, non existing pages domain to redirect to pages daemon, `https://projects.example.io/auth` |
| `GITLAB_HTTPS` | Set to `true` to enable https support, disabled by default. |
| `GITALY_CLIENT_PATH` | Set default path for gitaly. defaults to `/home/git/gitaly` |
| `GITALY_TOKEN` | Set a gitaly token, blank by default. |
| `GITLAB_MONITORING_UNICORN_SAMPLER_INTERVAL` | Time between sampling of unicorn socket metrics, in seconds, defaults to `10` |
| `GITLAB_MONITORING_IP_WHITELIST` | IP whitelist to access monitoring endpoints, defaults to `0.0.0.0/8` |
| `GITLAB_MONITORING_SIDEKIQ_EXPORTER_ENABLED` | Set to `true` to enable the sidekiq exporter, enabled by default. |
| `GITLAB_MONITORING_SIDEKIQ_EXPORTER_ADDRESS` | Sidekiq exporter address, defaults to `0.0.0.0` |
| `GITLAB_MONITORING_SIDEKIQ_EXPORTER_PORT` | Sidekiq exporter port, defaults to `3807` |
| `SSL_SELF_SIGNED` | Set to `true` when using self signed ssl certificates. `false` by default. |
| `SSL_CERTIFICATE_PATH` | Location of the ssl certificate. Defaults to `/home/git/data/certs/gitlab.crt` |
| `SSL_KEY_PATH` | Location of the ssl private key. Defaults to `/home/git/data/certs/gitlab.key` |
| `SSL_DHPARAM_PATH` | Location of the dhparam file. Defaults to `/home/git/data/certs/dhparam.pem` |
| `SSL_VERIFY_CLIENT` | Enable verification of client certificates using the `SSL_CA_CERTIFICATES_PATH` file or setting this variable to `on`. Defaults to `off` |
| `SSL_CA_CERTIFICATES_PATH` | List of SSL certificates to trust. Defaults to `/home/git/data/certs/ca.crt`. |
| `SSL_REGISTRY_KEY_PATH` | Location of the ssl private key for gitlab container registry. Defaults to `/home/git/data/certs/registry.key` |
| `SSL_REGISTRY_CERT_PATH` | Location of the ssl certificate for the gitlab container registry. Defaults to `/home/git/data/certs/registry.crt` |
| `SSL_PAGES_KEY_PATH` | Location of the ssl private key for gitlab pages. Defaults to `/home/git/data/certs/pages.key` |
| `SSL_PAGES_CERT_PATH` | Location of the ssl certificate for the gitlab pages. Defaults to `/home/git/data/certs/pages.crt` |
| `SSL_CIPHERS` | List of supported SSL ciphers: Defaults to `ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4` |
| `SSL_PROTOCOLS` | List of supported SSL protocols: Defaults to `TLSv1 TLSv1.1 TLSv1.2 TLSv1.3` |
| `SSL_PAGES_CIPHERS` | List of supported SSL ciphers for the gitlab pages: Defaults to `SSL_CIPHERS` |
| `SSL_PAGES_PROTOCOLS` | List of supported SSL protocols for the gitlab pages: Defaults to `SSL_PROTOCOLS` |
| `SSL_REGISTRY_CIPHERS` | List of supported SSL ciphers for gitlab container registry: Defaults to `SSL_CIPHERS` |
| `SSL_REGISTRY_PROTOCOLS` | List of supported SSL protocols for gitlab container registry: Defaults to `SSL_PROTOCOLS` |
| `NGINX_WORKERS` | The number of nginx workers to start. Defaults to `1`. |
| `NGINX_SERVER_NAMES_HASH_BUCKET_SIZE` | Sets the bucket size for the server names hash tables. This is needed when you have long server_names or your an error message from nginx like *nginx: [emerg] could not build server_names_hash, you should increase server_names_hash_bucket_size:..*. It should be only increment by a power of 2. Defaults to `32`. |
| `NGINX_HSTS_ENABLED` | Advanced configuration option for turning off the HSTS configuration. Applicable only when SSL is in use. Defaults to `true`. See [#138](https://github.com/sameersbn/docker-gitlab/issues/138) for use case scenario. |
| `NGINX_HSTS_MAXAGE` | Advanced configuration option for setting the HSTS max-age in the gitlab nginx vHost configuration. Applicable only when SSL is in use. Defaults to `31536000`. |
| `NGINX_PROXY_BUFFERING` | Enable `proxy_buffering`. Defaults to `off`. |
| `NGINX_ACCEL_BUFFERING` | Enable `X-Accel-Buffering` header. Default to `no` |
| `NGINX_X_FORWARDED_PROTO` | Advanced configuration option for the `proxy_set_header X-Forwarded-Proto` setting in the gitlab nginx vHost configuration. Defaults to `https` when `GITLAB_HTTPS` is `true`, else defaults to `$scheme`. |
| `NGINX_REAL_IP_RECURSIVE` | set to `on` if docker container runs behind a reverse proxy,you may not want the IP address of the proxy to show up as the client address. `off` by default. |
| `NGINX_REAL_IP_TRUSTED_ADDRESSES` | You can have NGINX look for a different address to use by adding your reverse proxy to the `NGINX_REAL_IP_TRUSTED_ADDRESSES`. Currently only a single entry is permitted. No defaults. |
| `REDIS_HOST` | The hostname of the redis server. Defaults to `localhost` |
| `REDIS_PORT` | The connection port of the redis server. Defaults to `6379`. |
| `REDIS_DB_NUMBER` | The redis database number. Defaults to '0'. |
| `PUMA_WORKERS` | The number of puma workers to start. Defaults to `3`. |
| `PUMA_TIMEOUT` | Sets the timeout of puma worker processes. Defaults to `60` seconds. |
| `PUMA_THREADS_MIN` | The number of puma minimum threads. Defaults to `1`. |
| `PUMA_THREADS_MAX` | The number of puma maximum threads. Defaults to `16`. |
| `PUMA_PER_WORKER_MAX_MEMORY_MB` | Maximum memory size of per puma worker process. Defaults to `1024`. |
| `PUMA_MASTER_MAX_MEMORY_MB` | Maximum memory size of puma master process. Defaults to `800`. |
| `SIDEKIQ_CONCURRENCY` | The number of concurrent sidekiq jobs to run. Defaults to `25` |
| `SIDEKIQ_SHUTDOWN_TIMEOUT` | Timeout for sidekiq shutdown. Defaults to `4` |
| `SIDEKIQ_MEMORY_KILLER_MAX_RSS` | Non-zero value enables the SidekiqMemoryKiller. Defaults to `1000000`. For additional options refer [Configuring the MemoryKiller](http://doc.gitlab.com/ce/operations/sidekiq_memory_killer.html) |
| `GITLAB_SIDEKIQ_LOG_FORMAT` | Sidekiq log format that will be used. Defaults to `json` |
| `DB_ADAPTER` | The database type. Currently only postgresql is supported. Over 12.1 postgres force. Possible values: `postgresql`. Defaults to `postgresql`. |
| `DB_ENCODING` | The database encoding. For `DB_ADAPTER` values `postresql` this parameter defaults and `utf8` respectively. |
| `DB_HOST` | The database server hostname. Defaults to `localhost`. |
| `DB_PORT` | The database server port. Defaults to `5432` for postgresql. |
| `DB_NAME` | The database database name. Defaults to `gitlabhq_production` |
| `DB_USER` | The database database user. Defaults to `root` |
| `DB_PASS` | The database database password. Defaults to no password |
| `DB_POOL` | The database database connection pool count. Defaults to `10`. |
| `DB_PREPARED_STATEMENTS` | Whether use database prepared statements. No defaults. But set to `false` if you want to use with [PgBouncer](https://pgbouncer.github.io/) |
| `SMTP_ENABLED` | Enable mail delivery via SMTP. Defaults to `true` if `SMTP_USER` is defined, else defaults to `false`. |
| `SMTP_DOMAIN` | SMTP domain. Defaults to` www.gmail.com` |
| `SMTP_HOST` | SMTP server host. Defaults to `smtp.gmail.com`. |
| `SMTP_PORT` | SMTP server port. Defaults to `587`. |
| `SMTP_USER` | SMTP username. |
| `SMTP_PASS` | SMTP password. |
| `SMTP_STARTTLS` | Enable STARTTLS. Defaults to `true`. |
| `SMTP_TLS` | Enable SSL/TLS. Defaults to `false`. |
| `SMTP_OPENSSL_VERIFY_MODE` | SMTP openssl verification mode. Accepted values are `none`, `peer`, `client_once` and `fail_if_no_peer_cert`. Defaults to `none`. |
| `SMTP_AUTHENTICATION` | Specify the SMTP authentication method. Defaults to `login` if `SMTP_USER` is set. |
| `SMTP_CA_ENABLED` | Enable custom CA certificates for SMTP email configuration. Defaults to `false`. |
| `SMTP_CA_PATH` | Specify the `ca_path` parameter for SMTP email configuration. Defaults to `/home/git/data/certs`. |
| `SMTP_CA_FILE` | Specify the `ca_file` parameter for SMTP email configuration. Defaults to `/home/git/data/certs/ca.crt`. |
| `IMAP_ENABLED` | Enable mail delivery via IMAP. Defaults to `true` if `IMAP_USER` is defined, else defaults to `false`. |
| `IMAP_HOST` | IMAP server host. Defaults to `imap.gmail.com`. |
| `IMAP_PORT` | IMAP server port. Defaults to `993`. |
| `IMAP_USER` | IMAP username. |
| `IMAP_PASS` | IMAP password. |
| `IMAP_SSL` | Enable SSL. Defaults to `true`. |
| `IMAP_STARTTLS` | Enable STARTSSL. Defaults to `false`. |
| `IMAP_MAILBOX` | The name of the mailbox where incoming mail will end up. Defaults to `inbox`. |
| `LDAP_ENABLED` | Enable LDAP. Defaults to `false` |
| `LDAP_LABEL` | Label to show on login tab for LDAP server. Defaults to 'LDAP' |
| `LDAP_HOST` | LDAP Host |
| `LDAP_PORT` | LDAP Port. Defaults to `389` |
| `LDAP_UID` | LDAP UID. Defaults to `sAMAccountName` |
| `LDAP_METHOD` | LDAP method, Possible values are `simple_tls`, `start_tls` and `plain`. Defaults to `plain` |
| `LDAP_VERIFY_SSL` | LDAP verify ssl certificate for installations that are using `LDAP_METHOD: 'simple_tls'` or `LDAP_METHOD: 'start_tls'`. Defaults to `true` |
| `LDAP_CA_FILE` | Specifies the path to a file containing a PEM-format CA certificate. Defaults to `` |
| `LDAP_SSL_VERSION` | Specifies the SSL version for OpenSSL to use, if the OpenSSL default is not appropriate. Example: 'TLSv1_1'. Defaults to `` |
| `LDAP_BIND_DN` | No default. |
| `LDAP_PASS` | LDAP password |
| `LDAP_TIMEOUT` | Timeout, in seconds, for LDAP queries. Defaults to `10`. |
| `LDAP_ACTIVE_DIRECTORY` | Specifies if LDAP server is Active Directory LDAP server. If your LDAP server is not AD, set this to `false`. Defaults to `true`, |
| `LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN` | If enabled, GitLab will ignore everything after the first '@' in the LDAP username submitted by the user on login. Defaults to `false` if `LDAP_UID` is `userPrincipalName`, else `true`. |
| `LDAP_BLOCK_AUTO_CREATED_USERS` | Locks down those users until they have been cleared by the admin. Defaults to `false`. |
| `LDAP_BASE` | Base where we can search for users. No default. |
| `LDAP_USER_FILTER` | Filter LDAP users. No default. |
| `LDAP_USER_ATTRIBUTE_USERNAME` | Attribute fields for the identification of a user. Default to `['uid', 'userid', 'sAMAccountName']` |
| `LDAP_USER_ATTRIBUTE_MAIL` | Attribute fields for the shown mail address. Default to `['mail', 'email', 'userPrincipalName']` |
| `LDAP_USER_ATTRIBUTE_NAME` | Attribute field for the used username of a user. Default to `cn`. |
| `LDAP_USER_ATTRIBUTE_FIRSTNAME` | Attribute field for the forename of a user. Default to `givenName` |
| `LDAP_USER_ATTRIBUTE_LASTNAME` |  Attribute field for the surname of a user. Default to `sn` |
| `LDAP_LOWERCASE_USERNAMES` | GitLab will lower case the username for the LDAP Server. Defaults to `false` |
| `OAUTH_ENABLED` | Enable OAuth support. Defaults to `true` if any of the support OAuth providers is configured, else defaults to `false`. |
| `OAUTH_AUTO_SIGN_IN_WITH_PROVIDER` | Automatically sign in with a specific OAuth provider without showing GitLab sign-in page. Accepted values are `cas3`, `github`, `bitbucket`, `gitlab`, `google_oauth2`, `facebook`, `twitter`, `saml`, `crowd`, `auth0` and `azure_oauth2`. No default. |
| `OAUTH_ALLOW_SSO` | Comma separated list of oauth providers for single sign-on. This allows users to login without having a user account. The account is created automatically when authentication is successful. Accepted values are `cas3`, `github`, `bitbucket`, `gitlab`, `google_oauth2`, `facebook`, `twitter`, `saml`, `crowd`, `auth0` and `azure_oauth2`. No default. |
| `OAUTH_BLOCK_AUTO_CREATED_USERS` | Locks down those users until they have been cleared by the admin. Defaults to `true`. |
| `OAUTH_AUTO_LINK_LDAP_USER` | Look up new users in LDAP servers. If a match is found (same uid), automatically link the omniauth identity with the LDAP account. Defaults to `false`. |
| `OAUTH_AUTO_LINK_SAML_USER` | Allow users with existing accounts to login and auto link their account via SAML login, without having to do a manual login first and manually add SAML. Defaults to `false`. |
| `OAUTH_EXTERNAL_PROVIDERS` | Comma separated list if oauth providers to disallow access to `internal` projects. Users creating accounts via these providers will have access internal projects. Accepted values are `cas3`, `github`, `bitbucket`, `gitlab`, `google_oauth2`, `facebook`, `twitter`, `saml`, `crowd`, `auth0` and `azure_oauth2`. No default. |
| `OAUTH_CAS3_LABEL` | The "Sign in with" button label. Defaults to "cas3". |
| `OAUTH_CAS3_SERVER` | CAS3 server URL. No defaults. |
| `OAUTH_CAS3_DISABLE_SSL_VERIFICATION` | Disable CAS3 SSL verification. Defaults to `false`. |
| `OAUTH_CAS3_LOGIN_URL` | CAS3 login URL. Defaults to `/cas/login` |
| `OAUTH_CAS3_VALIDATE_URL` | CAS3 validation URL. Defaults to `/cas/p3/serviceValidate` |
| `OAUTH_CAS3_LOGOUT_URL` | CAS3 logout URL. Defaults to `/cas/logout` |
| `OAUTH_GOOGLE_API_KEY` | Google App Client ID. No defaults. |
| `OAUTH_GOOGLE_APP_SECRET` | Google App Client Secret. No defaults. |
| `OAUTH_GOOGLE_RESTRICT_DOMAIN` | List of Google App restricted domains. Value is comma separated list of single quoted groups. Example: `'exemple.com','exemple2.com'`. No defaults. |
| `OAUTH_FACEBOOK_API_KEY` | Facebook App API key. No defaults. |
| `OAUTH_FACEBOOK_APP_SECRET` | Facebook App API secret. No defaults. |
| `OAUTH_TWITTER_API_KEY` | Twitter App API key. No defaults. |
| `OAUTH_TWITTER_APP_SECRET` | Twitter App API secret. No defaults. |
| `OAUTH_AUTHENTIQ_CLIENT_ID` | authentiq Client ID. No defaults. |
| `OAUTH_AUTHENTIQ_CLIENT_SECRET` | authentiq Client secret. No defaults. |
| `OAUTH_AUTHENTIQ_SCOPE` | Scope of Authentiq Application Defaults to `'aq:name email~rs address aq:push'`|
| `OAUTH_AUTHENTIQ_REDIRECT_URI` |  Callback URL for Authentiq. No defaults. |
| `OAUTH_GITHUB_API_KEY` | GitHub App Client ID. No defaults. |
| `OAUTH_GITHUB_APP_SECRET` | GitHub App Client secret. No defaults. |
| `OAUTH_GITHUB_URL` | Url to the GitHub Enterprise server. Defaults to https://github.com |
| `OAUTH_GITHUB_VERIFY_SSL` | Enable SSL verification while communicating with the GitHub server. Defaults to `true`. |
| `OAUTH_GITLAB_API_KEY` | GitLab App Client ID. No defaults. |
| `OAUTH_GITLAB_APP_SECRET` | GitLab App Client secret. No defaults. |
| `OAUTH_BITBUCKET_API_KEY` | BitBucket App Client ID. No defaults. |
| `OAUTH_BITBUCKET_APP_SECRET` | BitBucket App Client secret. No defaults. |
| `OAUTH_BITBUCKET_URL` | Bitbucket URL. Defaults: https://bitbucket.org/ |
| `OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL` | The URL at which the SAML assertion should be received. When `GITLAB_HTTPS=true`, defaults to `https://${GITLAB_HOST}/users/auth/saml/callback` else defaults to `http://${GITLAB_HOST}/users/auth/saml/callback`. |
| `OAUTH_SAML_IDP_CERT_FINGERPRINT` | The SHA1 fingerprint of the certificate. No Defaults. |
| `OAUTH_SAML_IDP_SSO_TARGET_URL` | The URL to which the authentication request should be sent. No defaults. |
| `OAUTH_SAML_ISSUER` | The name of your application. When `GITLAB_HTTPS=true`, defaults to `https://${GITLAB_HOST}` else defaults to `http://${GITLAB_HOST}`. |
| `OAUTH_SAML_LABEL` | The "Sign in with" button label. Defaults to "Our SAML Provider". |
| `OAUTH_SAML_NAME_IDENTIFIER_FORMAT` | Describes the format of the username required by GitLab, Defaults to `urn:oasis:names:tc:SAML:2.0:nameid-format:transient` |
| `OAUTH_SAML_GROUPS_ATTRIBUTE` | Map groups attribute in a SAMLResponse to external groups. No defaults. |
| `OAUTH_SAML_EXTERNAL_GROUPS` | List of external groups in a SAMLResponse. Value is comma separated list of single quoted groups. Example: `'group1','group2'`. No defaults. |
| `OAUTH_SAML_ATTRIBUTE_STATEMENTS_EMAIL` | Map 'email' attribute name in a SAMLResponse to entries in the OmniAuth info hash, No defaults. See [GitLab documentation](http://doc.gitlab.com/ce/integration/saml.html#attribute_statements) for more details. |
| `OAUTH_SAML_ATTRIBUTE_STATEMENTS_USERNAME` | Map 'username' attribute in a SAMLResponse to entries in the OmniAuth info hash, No defaults. See [GitLab documentation](http://doc.gitlab.com/ce/integration/saml.html#attribute_statements) for more details. |
| `OAUTH_SAML_ATTRIBUTE_STATEMENTS_NAME` | Map 'name' attribute in a SAMLResponse to entries in the OmniAuth info hash, No defaults. See [GitLab documentation](http://doc.gitlab.com/ce/integration/saml.html#attribute_statements) for more details. |
| `OAUTH_SAML_ATTRIBUTE_STATEMENTS_FIRST_NAME` | Map 'first_name' attribute in a SAMLResponse to entries in the OmniAuth info hash, No defaults. See [GitLab documentation](http://doc.gitlab.com/ce/integration/saml.html#attribute_statements) for more details. |
| `OAUTH_SAML_ATTRIBUTE_STATEMENTS_LAST_NAME` | Map 'last_name' attribute in a SAMLResponse to entries in the OmniAuth info hash, No defaults. See [GitLab documentation](http://doc.gitlab.com/ce/integration/saml.html#attribute_statements) for more details. |
| `OAUTH_CROWD_SERVER_URL` | Crowd server url. No defaults. |
| `OAUTH_CROWD_APP_NAME` | Crowd server application name. No defaults. |
| `OAUTH_CROWD_APP_PASSWORD` | Crowd server application password. No defaults. |
| `OAUTH_AUTH0_CLIENT_ID` | Auth0 Client ID. No defaults. |
| `OAUTH_AUTH0_CLIENT_SECRET` | Auth0 Client secret. No defaults. |
| `OAUTH_AUTH0_DOMAIN` | Auth0 Domain. No defaults. |
| `OAUTH_AUTH0_SCOPE` | Auth0 Scope. Defaults to `openid profile email`. |
| `OAUTH_AZURE_API_KEY` | Azure Client ID. No defaults. |
| `OAUTH_AZURE_API_SECRET` | Azure Client secret. No defaults. |
| `OAUTH_AZURE_TENANT_ID` | Azure Tenant ID. No defaults. |
| `OAUTH2_GENERIC_APP_ID` | Your OAuth2 App ID. No defaults. |
| `OAUTH2_GENERIC_APP_SECRET` | Your OAuth2 App Secret. No defaults. |
| `OAUTH2_GENERIC_CLIENT_SITE` | The OAuth2 generic client site. No defaults |
| `OAUTH2_GENERIC_CLIENT_USER_INFO_URL` | The OAuth2 generic client user info url. No defaults |
| `OAUTH2_GENERIC_CLIENT_AUTHORIZE_URL` | The OAuth2 generic client authorize url. No defaults |
| `OAUTH2_GENERIC_CLIENT_TOKEN_URL` | The OAuth2 generic client token url. No defaults|
| `OAUTH2_GENERIC_CLIENT_END_SESSION_ENDPOINT` | The OAuth2 generic client end session endpoint. No defaults |
| `OAUTH2_GENERIC_ID_PATH` | The OAuth2 generic id path. No defaults |
| `OAUTH2_GENERIC_USER_UID` | The OAuth2 generic user id path. No defaults |
| `OAUTH2_GENERIC_USER_NAME` | The OAuth2 generic user name. No defaults |
| `OAUTH2_GENERIC_USER_EMAIL` | The OAuth2 generic user email. No defaults |
| `OAUTH2_GENERIC_NAME` | The name of your OAuth2 provider. No defaults |
| `GITLAB_GRAVATAR_ENABLED` | Enables gravatar integration. Defaults to `true`. |
| `GITLAB_GRAVATAR_HTTP_URL` | Sets a custom gravatar url. Defaults to `http://www.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon`. This can be used for [Libravatar integration](http://doc.gitlab.com/ce/customization/libravatar.html). |
| `GITLAB_GRAVATAR_HTTPS_URL` | Same as above, but for https. Defaults to `https://secure.gravatar.com/avatar/%{hash}?s=%{size}&d=identicon`. |
| `USERMAP_UID` | Sets the uid for user `git` to the specified uid. Defaults to `1000`. |
| `USERMAP_GID` | Sets the gid for group `git` to the specified gid. Defaults to `USERMAP_UID` if defined, else defaults to `1000`. |
| `GOOGLE_ANALYTICS_ID` | Google Analytics ID. No defaults. |
| `PIWIK_URL` | Sets the Piwik URL. No defaults. |
| `PIWIK_SITE_ID` | Sets the Piwik site ID. No defaults. |
| `AWS_BACKUPS` | Enables automatic uploads to an Amazon S3 instance. Defaults to `false`. |
| `AWS_BACKUP_REGION` | AWS region. No defaults. |
| `AWS_BACKUP_ENDPOINT` | AWS endpoint. No defaults. |
| `AWS_BACKUP_ACCESS_KEY_ID` | AWS access key id. No defaults. |
| `AWS_BACKUP_SECRET_ACCESS_KEY` | AWS secret access key. No defaults. |
| `AWS_BACKUP_BUCKET` | AWS bucket for backup uploads. No defaults. |
| `AWS_BACKUP_MULTIPART_CHUNK_SIZE` | Enables mulitpart uploads when file size reaches a defined size. See at [AWS S3 Docs](http://docs.aws.amazon.com/AmazonS3/latest/dev/uploadobjusingmpu.html) |
| `AWS_BACKUP_ENCRYPTION`     | Turns on AWS Server-Side Encryption.  Defaults to `false`. See at [AWS S3 Docs](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingServerSideEncryption.html) |
| `AWS_BACKUP_STORAGE_CLASS` | Configure the storage class for the item. Defaults to `STANDARD`  See at [AWS S3 Docs](http://docs.aws.amazon.com/AmazonS3/latest/dev/storage-class-intro.html) |
| `AWS_BACKUP_SIGNATURE_VERSION` | Configure the storage signature version. Defaults to `4`  See at [AWS S3 Docs](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingAWSSDK.html#specify-signature-version) |
| `GCS_BACKUPS` | Enables automatic uploads to an Google Cloud Storage (GCS) instance. Defaults to `false`.  |
| `GCS_BACKUP_ACCESS_KEY_ID` | GCS access key id. No defaults |
| `GCS_BACKUP_SECRET_ACCESS_KEY` | GCS secret access key. No defaults |
| `GCS_BACKUP_BUCKET` | GCS bucket for backup uploads. No defaults |
| `GITLAB_ROBOTS_PATH` | Location of custom `robots.txt`. Uses GitLab's default `robots.txt` configuration by default. See [www.robotstxt.org](http://www.robotstxt.org) for examples. |
| `RACK_ATTACK_ENABLED` | Enable/disable rack middleware for blocking & throttling abusive requests Defaults to `true`. |
| `RACK_ATTACK_WHITELIST` | Always allow requests from whitelisted host. Defaults to `127.0.0.1` |
| `RACK_ATTACK_MAXRETRY` | Number of failed auth attempts before which an IP should be banned. Defaults to `10` |
| `RACK_ATTACK_FINDTIME` | Number of seconds before resetting the per IP auth attempt counter. Defaults to `60`. |
| `RACK_ATTACK_BANTIME` | Number of seconds an IP should be banned after too many auth attempts. Defaults to `3600`. |
| `GITLAB_WORKHORSE_TIMEOUT` | Timeout for gitlab workhorse http proxy. Defaults to `5m0s`. |
| `SENTRY_ENABLED` | Enables Error Reporting and Logging with Sentry. Defaults to `false`. |
| `SENTRY_DSN` | Sentry DSN. No defaults. |
| `SENTRY_CLIENTSIDE_DSN` | Sentry clientside DSN. No defaults. |
| `SENTRY_ENVIRONMENT` | Sentry environment. Defaults to `production`. |

### Docker secrets and configs

All the above environment variables can be put into a [secrets](https://docs.docker.com/compose/compose-file/#secrets) or [config](https://docs.docker.com/compose/compose-file/#configs) file
and then both docker-compose and Docker Swarm can import them into your gitlab container.

On startup, the gitlab container will source env vars from a config file labeled `gitlab-config`, and then a secrets file labeled `gitlab-secrets` (both mounted in the default locations).

See the example [`contrib/docker-swarm/docker-compose.yml`](./contrib/docker-swarm/docker-compose.yml) file, and the
example `gitlab.configs` and `gitlab.secrets` file.
You may as well choose file names other than the example source files (`gitlab.configs` and `gitlab.secrets`) and update
the `file: ./gitlab.configs` and `file: ./gitlab.secrets` references accordingly. But do not alter the config
keys [`gitlab-configs`](contrib/docker-swarm/docker-compose.yml#L158) and
[`gitlab-secrets`](contrib/docker-swarm/docker-compose.yml#L162) as they are currently
[hardcoded](./assets/runtime/functions#L4:L9) and thus must be kept as in the example.

If you're not using one of these files, then don't include its entry in the docker-compose file.

# Maintenance

## Creating backups

GitLab defines a rake task to take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop gitlab && docker rm gitlab
```

Execute the rake task to create a backup.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:backup:create
```

A backup will be created in the backups folder of the [Data Store](#data-store). You can change the location of the backups using the `GITLAB_BACKUP_DIR` configuration parameter.

*P.S. Backups can also be generated on a running instance using `docker exec` as described in the [Rake Tasks](#rake-tasks) section. However, to avoid undesired side-effects, I advice against running backup and restore operations on a running instance.*

When using `docker-compose` you may use the following command to execute the backup.

```bash
docker-compose rm -sf gitlab
docker-compose run --rm gitlab app:rake gitlab:backup:create
```

Afterwards you can bring your Instance back with the following command:

```bash
docker-compose up -d
```

## Restoring Backups

GitLab also defines a rake task to restore a backup.

Before performing a restore make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop gitlab && docker rm gitlab
```

If this is a fresh database that you're doing the restore on, first
you need to prepare the database:

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake db:setup
```

Execute the rake task to restore a backup. Make sure you run the container in interactive mode `-it`.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp, date and version of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:backup:restore BACKUP=1515629493_2020_12_06_13.0.6
```

When using `docker-compose` you may use the following command to execute the restore.

```bash
docker-compose run --rm gitlab app:rake gitlab:backup:restore # List available backups
docker-compose run --rm gitlab app:rake gitlab:backup:restore BACKUP=1515629493_2020_12_06_13.10.0 # Choose to restore from 1515629493
```


## Host Key Backups (ssh)

SSH keys are not backed up in the normal gitlab backup process. You
will need to backup the `ssh/` directory in the data volume by hand
and you will want to restore it prior to doing a gitlab restore.

## Automated Backups

The image can be configured to automatically take backups `daily`, `weekly` or `monthly` using the `GITLAB_BACKUP_SCHEDULE` configuration option.

Daily backups are created at `GITLAB_BACKUP_TIME` which defaults to `04:00` everyday. Weekly backups are created every Sunday at the same time as the daily backups. Monthly backups are created on the 1st of every month at the same time as the daily backups.

By default, when automated backups are enabled, backups are held for a period of 7 days. While when automated backups are disabled, the backups are held for an infinite period of time. This behavior can be configured via the `GITLAB_BACKUP_EXPIRY` option.

### Amazon Web Services (AWS) Remote Backups

The image can be configured to automatically upload the backups to an AWS S3 bucket. To enable automatic AWS backups first add `--env 'AWS_BACKUPS=true'` to the docker run command. In addition `AWS_BACKUP_REGION` and `AWS_BACKUP_BUCKET` must be properly configured to point to the desired AWS location. Finally an IAM user must be configured with appropriate access permission and their AWS keys exposed through `AWS_BACKUP_ACCESS_KEY_ID` and `AWS_BACKUP_SECRET_ACCESS_KEY`.

More details about the appropriate IAM user properties can found on [doc.gitlab.com](http://doc.gitlab.com/ce/raketasks/backup_restore.html#upload-backups-to-remote-cloud-storage)

For remote backup to selfhosted s3 compatible storage, use `AWS_BACKUP_ENDPOINT`.

AWS uploads are performed alongside normal backups, both through the appropriate `app:rake` command and when an automatic backup is performed.

### Google Cloud Storage (GCS) Remote Backups

The image can be configured to automatically upload the backups to an Google Cloud Storage bucket. To enable automatic GCS backups first add `--env 'GCS_BACKUPS=true'` to the docker run command. In addition `GCS_BACKUP_BUCKET` must be properly configured to point to the desired GCS location.
Finally a couple of `Interoperable storage access keys` user must be created and their keys exposed through `GCS_BACKUP_ACCESS_KEY_ID` and `GCS_BACKUP_SECRET_ACCESS_KEY`.

More details about the Cloud storage interoperability  properties can found on [cloud.google.com/storage](https://cloud.google.com/storage/docs/interoperability)

GCS uploads are performed alongside normal backups, both through the appropriate `app:rake` command and when an automatic backup is performed.

## Rake Tasks

The `app:rake` command allows you to run gitlab rake tasks. To run a rake task simply specify the task to be executed to the `app:rake` command. For example, if you want to gather information about GitLab and the system it runs on.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:env:info
```

You can also use `docker exec` to run raketasks on running gitlab instance. For example,

```bash
docker exec --user git -it gitlab bundle exec rake gitlab:env:info RAILS_ENV=production
```

Similarly, to import bare repositories into GitLab project instance

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:import:repos
```

Or

```bash
docker exec -it gitlab sudo -HEu git bundle exec rake gitlab:import:repos RAILS_ENV=production
```

For a complete list of available rake tasks please refer https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks or the help section of your gitlab installation.

*P.S. Please avoid running the rake tasks for backup and restore operations on a running gitlab instance.*

To use the `app:rake` command with `docker-compose` use the following command.

```bash
# For stopped instances
docker-compose run --rm gitlab app:rake gitlab:env:info
docker-compose run --rm gitlab app:rake gitlab:import:repos

# For running instances
docker-compose exec --user git gitlab bundle exec rake gitlab:env:info RAILS_ENV=production
docker-compose exec gitlab sudo -HEu git bundle exec rake gitlab:import:repos RAILS_ENV=production
```

## Import Repositories

Copy all the **bare** git repositories to the `repositories/` directory of the [data store](#data-store) and execute the `gitlab:import:repos` rake task like so:

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:import:repos
```

Watch the logs and your repositories should be available into your new gitlab container.

See [Rake Tasks](#rake-tasks) for more information on executing rake tasks.
Usage when using `docker-compose` can also be found there.

## Upgrading

> **Important Notice**
>
> Since GitLab release `8.6.0` PostgreSQL users should enable `pg_trgm` extension on the GitLab database. Refer to GitLab's [Postgresql Requirements](http://doc.gitlab.com/ce/install/requirements.html#postgresql-requirements) for more information
>
> If you're using `sameersbn/postgresql` then please upgrade to `sameersbn/postgresql:12-20200524` or later and add `DB_EXTENSION=pg_trgm,btree_gist` to the environment of the PostgreSQL container (see: https://github.com/sameersbn/docker-gitlab/blob/master/docker-compose.yml#L8).
>
> As of version 13.7.0, the required PostgreSQL is version 12.x. If you're using PostgreSQL image other than the above, please review section [Upgrading PostgreSQL](#upgrading-postgresql).

GitLabHQ releases new versions on the 22nd of every month, bugfix releases immediately follow. I update this project almost immediately when a release is made (at least it has been the case so far). If you are using the image in production environments I recommend that you delay updates by a couple of days after the gitlab release, allowing some time for the dust to settle down.

To upgrade to newer gitlab releases, simply follow this 4 step upgrade procedure.

> **Note**
>
> Upgrading to `sameersbn/gitlab:13.10.2` from `sameersbn/gitlab:7.x.x` can cause issues. It is therefore required that you first upgrade to `sameersbn/gitlab:8.0.5-1` before upgrading to `sameersbn/gitlab:8.1.0` or higher.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/gitlab:13.10.2
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

> **Note**: Since GitLab `8.0.0` you need to provide the `GITLAB_SECRETS_DB_KEY_BASE` parameter while starting the image.

> **Note**: Since GitLab `8.11.0` you need to provide the `GITLAB_SECRETS_SECRET_KEY_BASE` and `GITLAB_SECRETS_OTP_KEY_BASE` parameters while starting the image. These should initially both have the same value as the contents of the `/home/git/data/.secret` file. See [Available Configuration Parameters](#available-configuration-parameters) for more information on these parameters.

```bash
docker run --name gitlab -d [OPTIONS] sameersbn/gitlab:13.10.2
```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it gitlab bash
```

# Monitoring

You can monitor your GitLab instance status as described in the [official documentation](https://docs.gitlab.com/ee/user/admin_area/monitoring/health_check.html), for example:

```bash
curl 'https://gitlab.example.com/-/liveness'
```

On success, the endpoint will return a `200` HTTP status code, and a response like below.

```bash
{
   "status": "ok"
}
```

To do that you will need to set the environment variable `GITLAB_MONITORING_IP_WHITELIST` to allow your IP or subnet to make requests to your GitLab instance.

## Health Check

You can also set your `docker-compose.yml` [healthcheck](https://docs.docker.com/compose/compose-file/compose-file-v2/#healthcheck) configuration to make periodic checks:

```yml
version: '2.3'

services:
  gitlab:
    image: sameersbn/gitlab:13.10.2
    healthcheck:
      test: ["CMD", "/usr/local/sbin/healthcheck"]
      interval: 1m
      timeout: 5s
      retries: 5
      start_period: 2m
```

Then you will be able to consult the healthcheck log by executing:

```bash
docker inspect --format "{{json .State.Health }}" $(docker-compose ps -q gitlab) | jq
```

# References

* https://github.com/gitlabhq/gitlabhq
* https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
* http://wiki.nginx.org/HttpSslModule
* https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
* https://github.com/gitlabhq/gitlab-recipes/blob/master/web-server/nginx/gitlab-ssl
* https://github.com/jpetazzo/nsenter
* https://jpetazzo.github.io/2014/03/23/lxc-attach-nsinit-nsenter-docker-0-9/
