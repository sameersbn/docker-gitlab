# Table of Contents
- [Introduction](#introduction)
    - [Version](#version)
- [Hardware Requirements](#hardware-requirements)
    - [CPU](#cpu)
    - [Memory](#memory)
    - [Storage](#storage)
- [Supported Web Browsers](#supported-web-browsers)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Mounting Volumes](#mounting-volumes)
    - [Configuring Database](#configuring-database)
        - [MySQL](#mysql)
            - [Internal MySQL Server](#internal-mysql-server)
            - [External MySQL Server](#external-mysql-server)
        - [PostgreSQL]($postgresql)
            - [External PostgreSQL Server](#external-postgresql-server)
    - [Configuring Mail](#configuring-mail)
    - [Putting it all together](#putting-it-all-together)
- [Taking Backups](#taking-backups)
- [Restoring Backups](#restoring-backups)
- [Upgrading](#upgrading)
- [Configuration Parameters](#configuration-parameters)
- [References](#references)

# Introduction
Dockerfile to build a GitLab container image.

## Version
Current Version: 6.6.1

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
free space as your all repos combined take up. You need twice the storage because [GitLab satellites](structure.md) contain an extra copy of each repo.

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
docker pull sameersbn/gitlab
```

Since version 6.5.0, the image builds are being tagged. You can now pull a particular version of gitlab by specifying the version number. For example,

```bash
docker pull sameersbn/gitlab:6.6.1
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/sameersbn/docker-gitlab.git
cd docker-gitlab
sudo docker build -t="$USER/gitlab" .
```

# Quick Start
Run the gitlab image

```bash
GITLAB=$(sudo docker run -d sameersbn/gitlab)
GITLAB_IP=$(sudo docker inspect $GITLAB | grep IPAddres | awk -F'"' '{print $4}')
```

Access the GitLab application

```bash
xdg-open "http://${GITLAB_IP}"
```

__NOTE__: Please allow a minute or two for the GitLab application to start.

Login using the default username and password:

* username: admin@local.host
* password: 5iveL!fe

You should now have GitLab ready for testing. If you want to use GitLab for more than just testing then please read the **Advanced Options** section.

# Configuration

## Mounting volumes
GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount volumes at.

* /home/git/data

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
mkdir /opt/gitlab/data
docker run -d \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

## Configuring Database
GitLab uses a database backend to store its data.

### MySQL

#### Internal MySQL Server
This docker image is configured to use a MySQL database backend. The database connection can be configured using environment variables. If not specified, the image will start a mysql server internally and use it. However in this case, the data stored in the mysql database will be lost if the container is stopped/deleted. To avoid this you should mount a volume at /var/lib/mysql.

```bash
mkdir /opt/gitlab/mysql
docker run -d \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql sameersbn/gitlab
```

This will make sure that the data stored in the database is not lost when the image is stopped and started again.

#### External MySQL Server
The image can be configured to use an external MySQL database instead of starting a MySQL server internally. The database configuration should be specified using environment variables while starting the GitLab image.

Before you start the GitLab image create user and database for gitlab.

```bash
mysql -uroot -p
CREATE USER 'gitlab'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'%.%.%.%';
```

To make sure the database is initialized start the container with **app:db:initialize** option.

**NOTE: This should be done only for the first run**.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:db:initialize
```

This will initialize the gitlab database. Now that the database is initialized, start the container without the initialize command.

```bash
docker run -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

### PostgreSQL

#### External PostgreSQL Server
The image also supports using an external PostgreSQL Server. This is also controlled via environment variables.

```bash
createuser gitlab
createdb -O gitlab gitlabhq_production
```

To make sure the database is initialized start the container with **app:db:initialize** option.

**NOTE: This should be done only for the first run**.

*Assuming that the PostgreSQL server host is 192.168.1.100*

```bash
docker run -d \
  -e "DB_TYPE=postgres" -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:db:initialize
```

This will initialize the gitlab database. Now that the database is initialized, start the container without the initialize command.

```bash
docker run -d \
  -e "DB_TYPE=postgres" -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

### Configuring Mail
The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

The following environment variables need to be specified to get mail support to work.

* SMTP_HOST (defaults to smtp.gmail.com)
* SMTP_PORT (defaults to 587)
* SMTP_USER
* SMTP_PASS

```bash
docker run -d \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

If you are not using google mail, then please configure the  SMTP host and port using the SMTP_HOST and SMTP_PORT configuration parameters.

__NOTE:__

I have only tested standard gmail and google apps login. I expect that the currently provided configuration parameters should be sufficient for most users. If this is not the case, then please let me know.

### Putting it all together

```bash
docker run -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  sameersbn/gitlab
```

If you are using an external mysql database

```bash
docker run -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  sameersbn/gitlab
```

## Taking backups

Gitlab defines a rake task to easily take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup, please make sure that the gitlab image is not running for obvious reasons

```bash
docker stop <container-id>
```

To take a backup all you need to do is pass the "app:backup" command to the container image.

```bash
  docker run -i -t -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:backup
```

## Restoring Backups

Gitlab defines a rake task to easily restore a backup of your gitlab installation. Before performing the restore operation please make sure that the gitlab image is not running.

```bash
docker stop <container-id>
```

To restore a backup, run the image in interactive (-i -t) mode and pass the "app:restore" command to the container image.

```bash
  docker run -i -t -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:restore
```

The restore operation will list all available backups in reverse chronological order. Select the backup you want to restore and gitlab will do its job.

## Upgrading

If you upgrading from previous version, please make sure you run the container with **app:db:migrate** command.

**Step 1: Stop the currently running image**

```bash
docker stop <container-id>
```

**Step 2: Backup the application data.**

```bash
docker run -i -t [OPTIONS] sameersbn/gitlab app:backup
```

**Step 3: Update the docker image.**

```bash
docker pull sameersbn/gitlab
```

**Step 4: Migrate the database.**

```bash
docker run -i -t [OPTIONS] sameersbn/gitlab app:db:migrate
```

**Step 5: Start the image**

```bash
docker run -i -d [OPTIONS] sameersbn/gitlab
```

### Configuration Parameters
Below is the complete list of parameters that can be set using environment variables.

* GITLAB_HOST

        The hostname of the GitLab server. Defaults to localhost

* GITLAB_EMAIL

        The email address for the GitLab server. Defaults to gitlab@localhost.

* GITLAB_SUPPORT

        The support email address for the GitLab server. Defaults to support@localhost.

* GITLAB_SIGNUP

        Enable or disable gitlab user signup. Default is false. To enable user signup add '-e GITLAB_SIGNUP="true"' to the docker run command parameters.

* REDIS_HOST

        The hostname of the redis server. Defaults to localhost

* REDIS_PORT

        The connection port of the redis server. Defaults to 6379.

* UNICORN_WORKERS

        The number of unicorn workers to start. Defaults to 2.

* UNICORN_TIMEOUT

        Sets the timeout of unicorn worker processes. Defaults to 60 seconds.

* SIDEKIQ_CONCURRENCY

        The number of concurrent sidekiq jobs to run. Defaults to 5

* DB_TYPE

        The database type. Possible values: mysql, postgres. Defaults to mysql.

* DB_HOST

        The database server hostname. Defaults to localhost.

* DB_NAME

        The database database name. Defaults to gitlabhq_production

* DB_USER

        The database database user. Defaults to root

* DB_PASS

        The database database password. Defaults to no password

* DB_POOL

        The database database connection pool count. Defaults to 10.

* SMTP_HOST

        SMTP server host. Defaults to smtp.gmail.com.

* SMTP_PORT

        SMTP server port. Defaults to 587.

* SMTP_USER

        SMTP username.

* SMTP_PASS

        SMTP password.

## References
  * https://github.com/gitlabhq/gitlabhq
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
  * https://rtcamp.com/tutorials/linux/ubuntu-postfix-gmail-smtp
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/requirements.md
