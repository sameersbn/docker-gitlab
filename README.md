# Table of Contents
- [Introduction](#introduction)
    - [Version](#version)
    - [Changelog](Changelog.md)
- [Hardware Requirements](#hardware-requirements)
    - [CPU](#cpu)
    - [Memory](#memory)
    - [Storage](#storage)
- [Supported Web Browsers](#supported-web-browsers)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Data Store](#data-store)
    - [Database](#database)
        - [MySQL](#mysql)
            - [Internal MySQL Server](#internal-mysql-server)
            - [External MySQL Server](#external-mysql-server)
            - [Linking to MySQL Container](#linking-to-mysql-container)
        - [PostgreSQL](#postgresql)
            - [External PostgreSQL Server](#external-postgresql-server)
            - [Linking to PostgreSQL Container](#linking-to-postgresql-container)
    - [Redis](#redis)
      - [Internal Redis Server](#internal-redis-server)
      - [External Redis Server](#external-redis-server)
      - [Linking to Redis Container](#linking-to-redis-container)
    - [Mail](#mail)
    - [Putting it all together](#putting-it-all-together)
    - [Available Configuration Parameters](#available-configuration-parameters)
- [Maintenance](#maintenance)
    - [SSH Login](#ssh-login)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
    - [Automated Backups](#automated-backups)
- [Upgrading](#upgrading)
- [Rake Tasks](#rake-tasks)
- Links
  - [Announcements](https://github.com/sameersbn/docker-gitlab/issues/39)
  - [Issues](https://github.com/sameersbn/docker-gitlab/issues)
- [References](#references)

# Introduction
Dockerfile to build a GitLab container image.

## Version
Current Version: 6.8.0

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

The necessary hard drive space largely depends on the size of the repos you want
to store in GitLab. But as a *rule of thumb* you should have at least twice as much
free space as your all repos combined take up. You need twice the storage because [GitLab satellites](https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/structure.md) contain an extra copy of each repo.

If you want to be flexible about growing your hard drive space in the future consider mounting it using LVM so you can add more hard drives when you need them.

Apart from a local hard drive you can also mount a volume that supports the network file system (NFS) protocol. This volume might be located on a file server, a network attached storage (NAS) device, a storage area network (SAN) or on an Amazon Web Services (AWS) Elastic Block Store (EBS) volume.

If you have enough RAM memory and a recent CPU the speed of GitLab is mainly limited by hard drive seek times. Having a fast drive (7200 RPM and up) or a solid state drive (SSD) will improve the responsiveness of GitLab.

# Supported Web Browsers

- Chrome (Latest stable version)
- Firefox (Latest released version)
- Safari 7+ (Know problem: required fields in html5 do not work)
- Opera (Latest released version)
- IE 10+

# Installation

Pull the latest version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull sameersbn/gitlab:latest
```

Since version 6.3.0, the image builds are being tagged. You can now pull a particular version of gitlab by specifying the version number. For example,

```bash
docker pull sameersbn/gitlab:6.8.0
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/sameersbn/docker-gitlab.git
cd docker-gitlab
docker build --tag="$USER/gitlab" .
```

# Quick Start
Run the gitlab image

```
docker run -name gitlab -d sameersbn/gitlab:latest
GITLAB_IP=$(docker inspect gitlab | grep IPAddres | awk -F'"' '{print $4}')
```

Access the GitLab application

```bash
xdg-open "http://${GITLAB_IP}"
```

__NOTE__: Please allow a minute or two for the GitLab application to start.

Login using the default username and password:

* username: admin@local.host
* password: 5iveL!fe

You should now have the GitLab application up and ready for testing. If you want to use this image in production the please read on.

# Configuration

## Data Store
GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount a volume at,

* /home/git/data

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
mkdir /opt/gitlab/data
docker run --name=gitlab -d \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest
```

## Database
GitLab uses a database backend to store its data.

### MySQL

#### Internal MySQL Server

> **Warning**
>
> The internal mysql server will soon be removed from the image.

> Please use a linked [mysql](#linking-to-mysql-container) or
> [postgresql](#linking-to-postgresql-container) container instead.
> Or else connect with an external [mysql](#external-mysql-server) or
> [postgresql](#external-postgresql-server) server.

> You've been warned.

This docker image is configured to use a MySQL database backend. The database connection can be configured using environment variables. If not specified, the image will start a mysql server internally and use it. However in this case, the data stored in the mysql database will be lost if the container is stopped/deleted. To avoid this you should mount a volume at /var/lib/mysql.

```bash
mkdir /opt/gitlab/mysql
docker run --name=gitlab -d \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql sameersbn/gitlab:latest
```

This will make sure that the data stored in the database is not lost when the image is stopped and started again.

#### External MySQL Server
The image can be configured to use an external MySQL database instead of starting a MySQL server internally. The database configuration should be specified using environment variables while starting the GitLab image.

Before you start the GitLab image create user and database for gitlab.

```sql
CREATE USER 'gitlab'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'%.%.%.%';
```

To make sure the database is initialized start the container with **app:rake gitlab:setup** option.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run --name=gitlab -i -t --rm \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest app:rake gitlab:setup
```

**NOTE: The above setup is performed only for the first run**.

This will initialize the gitlab database. Now that the database is initialized, start the container normally.

```bash
docker run --name=gitlab -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest
```

#### Linking to MySQL Container
You can link this image with a mysql container for the database requirements. The alias of the mysql server container should be set to **mysql** while linking with the gitlab image.

If a mysql container is linked, only the DB_HOST and DB_PORT settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the DB_NAME, DB_USER, DB_PASS and so on.

To illustrate linking with a mysql container, we will use the [sameersbn/mysql](https://github.com/sameersbn/docker-mysql) image. When using docker-mysql in production you should mount a volume for the mysql data store. Please refer the [README](https://github.com/sameersbn/docker-mysql/blob/master/README.md) of docker-mysql for details.

First, lets pull the mysql image from the docker index.
```bash
docker pull sameersbn/mysql:latest
```

For data persistence lets create a store for the mysql and start the container.
```bash
mkdir -p /opt/mysql/data
docker run --name=mysql -d \
	-v /opt/mysql/data:/var/lib/mysql \
	sameersbn/mysql:latest
```

You should now have the mysql server running. By default the sameersbn/mysql image does not assign a password for the root user and allows remote connections for the root user from the 172.17.%.% address space. This means you can login to the mysql server from the host as the root user.

Now, lets login to the mysql server and create a user and database for the GitLab application.

```bash
mysql -uroot -h $(docker inspect mysql | grep IPAddres | awk -F'"' '{print $4}')
```

```sql
CREATE USER 'gitlab'@'172.17.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'172.17.%.%';
FLUSH PRIVILEGES;
```

Now that we have the database created for gitlab, lets install the database schema. This is done by starting the gitlab container with the **app:rake gitlab:setup** command.

```bash
docker run --name=gitlab -i -t --rm --link mysql:mysql \
  -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "DB_NAME=gitlabhq_production" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest app:rake gitlab:setup
```

**NOTE: The above setup is performed only for the first run**.

We are now ready to start the GitLab application.

```bash
docker run --name=gitlab -d --link mysql:mysql \
  -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "DB_NAME=gitlabhq_production" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest
```

### PostgreSQL

#### External PostgreSQL Server
The image also supports using an external PostgreSQL Server. This is also controlled via environment variables.

```sql
CREATE ROLE gitlab with LOGIN CREATEDB PASSWORD 'password';
CREATE DATABASE gitlabhq_production;
GRANT ALL PRIVILEGES ON DATABASE gitlabhq_production to gitlab;
```

To make sure the database is initialized start the container with **app:rake gitlab:setup** option.

*Assuming that the PostgreSQL server host is 192.168.1.100*

```bash
docker run --name=gitlab -i -t --rm \
  -e "DB_TYPE=postgres" -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest app:rake gitlab:setup
```

**NOTE: The above setup is performed only for the first run**.

This will initialize the gitlab database. Now that the database is initialized, start the container normally.

```bash
docker run --name=gitlab -d \
  -e "DB_TYPE=postgres" -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest
```

#### Linking to PostgreSQL Container
You can link this image with a postgresql container for the database requirements. The alias of the postgresql server container should be set to **postgresql** while linking with the gitlab image.

If a postgresql container is linked, only the DB_HOST and DB_PORT settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the DB_NAME, DB_USER, DB_PASS and so on.

To illustrate linking with a postgresql container, we will use the [sameersbn/postgresql](https://github.com/sameersbn/docker-postgresql) image. When using postgresql image in production you should mount a volume for the postgresql data store. Please refer the [README](https://github.com/sameersbn/docker-postgresql/blob/master/README.md) of docker-postgresql for details.

First, lets pull the postgresql image from the docker index.
```bash
docker pull sameersbn/postgresql:latest
```

For data persistence lets create a store for the postgresql and start the container.
```bash
mkdir -p /opt/postgresql/data
docker run --name=postgresql -d \
  -v /opt/postgresql/data:/var/lib/postgresql \
  sameersbn/postgresql:latest
```

You should now have the postgresql server running. The password for the postgres user can be found in the logs of the postgresql image.

```bash
docker logs postgresql
```

Now, lets login to the postgresql server and create a user and database for the GitLab application.

```bash
POSTGRESQL_IP=$(docker inspect postgresql | grep IPAddres | awk -F'"' '{print $4}')
psql -U postgres -h ${POSTGRESQL_IP}
```

```sql
CREATE ROLE gitlab with LOGIN CREATEDB PASSWORD 'password';
CREATE DATABASE gitlabhq_production;
GRANT ALL PRIVILEGES ON DATABASE gitlabhq_production to gitlab;
```

Now that we have the database created for gitlab, lets install the database schema. This is done by starting the gitlab container with the **app:rake gitlab:setup** command.

```bash
docker run --name=gitlab -i -t --rm --link postgresql:postgresql \
  -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "DB_NAME=gitlabhq_production" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest app:rake gitlab:setup
```

**NOTE: The above setup is performed only for the first run**.

We are now ready to start the GitLab application.

```bash
docker run --name=gitlab -d --link postgresql:postgresql \
  -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "DB_NAME=gitlabhq_production" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest
```

## Redis

### Internal Redis Server

> **Warning**
>
> The internal redis server will soon be removed from the image.

> Please use a linked [redis](#linking-to-redis-container) container
> or a external [redis](#external-redis-server) server

> You've been warned.

GitLab uses the redis server for its key-value data store. The redis server connection details can be specified using environment variables. If not specified, the  starts a redis server internally, no additional configuration is required.

### External Redis Server
The image can be configured to use an external redis server instead of starting a redis server internally. The configuration should be specified using environment variables while starting the GitLab image.

*Assuming that the redis server host is 192.168.1.100*

```bash
docker run --name=gitlab -i -t --rm \
  -e "REDIS_HOST=192.168.1.100" -e "REDIS_PORT=6379" \
  sameersbn/gitlab:latest
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
  sameersbn/gitlab:latest
```

### Mail
The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

The following environment variables need to be specified to get mail support to work.

* SMTP_DOMAIN (defaults to www.gmail.com)
* SMTP_HOST (defaults to smtp.gmail.com)
* SMTP_PORT (defaults to 587)
* SMTP_USER
* SMTP_PASS
* SMTP_STARTTLS (defaults to true)
* SMTP_AUTHENTICATION (defaults to :login)

```bash
docker run --name=gitlab -d \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab:latest
```

### Putting it all together

```bash
docker run --name=gitlab -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  sameersbn/gitlab:latest
```

If you are using an external mysql database

```bash
docker run --name=gitlab -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  sameersbn/gitlab:latest
```

### Available Configuration Parameters

Below is the complete list of available options that can be used to customize your gitlab installation.

- **GITLAB_HOST**: The hostname of the GitLab server. Defaults to localhost
- **GITLAB_PORT**: The port of the GitLab server. Defaults to 80
- **GITLAB_EMAIL**: The email address for the GitLab server. Defaults to gitlab@localhost.
- **GITLAB_SUPPORT**: The support email address for the GitLab server. Defaults to support@localhost.
- **GITLAB_SIGNUP**: Enable or disable user signups. Default is false.
- **GITLAB_PROJECTS_LIMIT**: Set default projects limit. Defaults to 10.
- **GITLAB_BACKUPS**: Setup cron job to automatic backups. Possible values disable, daily or monthly. Disabled by default
- **GITLAB_BACKUP_EXPIRY**: Configure how long to keep backups before they are deleted. By default when automated backups are disabled backups are kept forever (0 seconds), else the backups expire in 7 days (604800 seconds).
- **GITLAB_SHELL_SSH_PORT**: The ssh port number. Defaults to 22.
- **REDIS_HOST**: The hostname of the redis server. Defaults to localhost
- **REDIS_PORT**: The connection port of the redis server. Defaults to 6379.
- **UNICORN_WORKERS**: The number of unicorn workers to start. Defaults to 2.
- **UNICORN_TIMEOUT**: Sets the timeout of unicorn worker processes. Defaults to 60 seconds.
- **SIDEKIQ_CONCURRENCY**: The number of concurrent sidekiq jobs to run. Defaults to 5
- **DB_TYPE**: The database type. Possible values: mysql, postgres. Defaults to mysql.
- **DB_HOST**: The database server hostname. Defaults to localhost.
- **DB_PORT**: The database server port. Defaults to 3306 for mysql and 5432 for postgresql.
- **DB_NAME**: The database database name. Defaults to gitlabhq_production
- **DB_USER**: The database database user. Defaults to root
- **DB_PASS**: The database database password. Defaults to no password
- **DB_POOL**: The database database connection pool count. Defaults to 10.
- **SMTP_DOMAIN**: SMTP domain. Defaults to www.gmail.com
- **SMTP_HOST**: SMTP server host. Defaults to smtp.gmail.com.
- **SMTP_PORT**: SMTP server port. Defaults to 587.
- **SMTP_USER**: SMTP username.
- **SMTP_PASS**: SMTP password.
- **SMTP_STARTTLS**: Enable STARTTLS. Defaults to true.
- **SMTP_AUTHENTICATION**: Specify the SMTP authentication method. Defaults to :login.
- **LDAP_ENABLED**: Enable LDAP. Defaults to false
- **LDAP_HOST**: LDAP Host
- **LDAP_PORT**: LDAP Port. Defaults to 636
- **LDAP_UID**: LDAP UID. Defaults to sAMAccountName
- **LDAP_METHOD**: LDAP method, Possible values are ssl, tls and plain. Defaults to ssl
- **LDAP_BIND_DN**: No default.
- **LDAP_PASS**: LDAP password
- **LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN**: If enabled, GitLab will ignore everything after the first '@' in the LDAP username submitted by the user on login. Defaults to false if LDAP_UID is userPrincipalName, else true.
- **LDAP_BASE**: Base where we can search for users. No default.
- **LDAP_USER_FILTER**: Filter LDAP users. No default.

# Maintenance

## SSH Login
There are two methods to gain root login to the container, the first method is to add your public rsa key to the authorized_keys file and build the image.

The second method is use the dynamically generated password. Every time the container is started a random password is generated using the pwgen tool and assigned to the root user. This password can be fetched from the docker logs.

```bash
docker logs gitlab 2>&1 | grep '^User: ' | tail -n1
```
This password is not persistent and changes every time the image is executed.

## Creating backups

Gitlab defines a rake task to easily take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup, please make sure that the gitlab image is not running for obvious reasons

```bash
docker stop gitlab
```

To take a backup all you need to do is run the gitlab rake task to create a backup.

```bash
docker run --name=gitlab -i -t --rm [OPTIONS] \
  sameersbn/gitlab:latest app:rake gitlab:backup:create
```

A backup will be created in the backups folder of the [Data Store](#data-store)

## Restoring Backups

Gitlab defines a rake task to easily restore a backup of your gitlab installation. Before performing the restore operation please make sure that the gitlab image is not running.

```bash
docker stop gitlab
```

To restore a backup, run the image in interactive (-i -t) mode and pass the "app:restore" command to the container image.

```bash
docker run --name=gitlab -i -t --rm [OPTIONS] \
  sameersbn/gitlab:latest app:rake gitlab:backup:restore
```

The restore operation will list all available backups in reverse chronological order. Select the backup you want to restore and gitlab will do its job.

## Automated Backups

The image can be configured to automatically take backups on a daily or monthly basis. Adding -e "GITLAB_BACKUPS=daily" to the docker run command will enable daily backups, while -e "GITLAB_BACKUPS=monthly" will enable monthly backups.

Daily backups are created at 4 am (UTC) everyday, while monthly backups are created on the 1st of every month at the same time as the daily backups.

By default, when automated backups are enabled, backups are held for a period of 7 days. While when automated backups are disabled, the backups are held for an infinite period of time. This can behaviour can be configured via the GITLAB_BACKUP_EXPIRY option.

# Upgrading

GitLabHQ releases new versions on the 22nd of every month, bugfix releases immediately follow. I update this project almost immediately when a release is made (at least it has been the case so far). If you are using the image in production environments I recommend that you delay updates by a couple of days after the gitlab release, allowing some time for the dust to settle down.

To upgrade to newer gitlab releases, simply follow this 5 step upgrade procedure.

- **Step 1**: Stop the currently running image

```bash
docker stop gitlab
```

- **Step 2**: Backup the application data.

```bash
docker run --name=gitlab -i -t --rm [OPTIONS] \
  sameersbn/gitlab:latest app:rake gitlab:backup:create
```

- **Step 3**: Update the docker image.

```bash
docker pull sameersbn/gitlab:latest
```

- **Step 4**: Migrate the database.

```bash
docker run --name=gitlab -i -t --rm [OPTIONS] \
  sameersbn/gitlab:latest app:rake db:migrate
```

- **Step 5**: Start the image

```bash
docker run --name=gitlab -d [OPTIONS] sameersbn/gitlab:latest
```

## Rake Tasks

The app:rake command allows you to run gitlab rake tasks. To run a rake task simply specify the task to be executed to the app:rake command. For example, if you want to gather information about GitLab and the system it runs on.

```bash
docker run --name=gitlab -d [OPTIONS] \
  sameersbn/gitlab:latest app:rake gitlab:env:info
```

Similarly, to import bare repositories into GitLab project instance

```bash
docker run --name=gitlab -d [OPTIONS] \
  sameersbn/gitlab:latest app:rake gitlab:import:repos
```

For a complete list of available rake tasks please refer https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks or the help section of your gitlab installation.

# References
  * https://github.com/gitlabhq/gitlabhq
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/requirements.md
