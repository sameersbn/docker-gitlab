+++
title = "MySQL Configuration"
description = "MySQL Configuration"
category = ["configuration", "database"]
tags = ["configuration", "database", "db", "mysql"]
+++

# Internal MySQL Server

The internal mysql server has been removed from the image. Please use a [linked mysql](#linking-to-mysql-container) container or specify a connection to a [external mysql](#external-mysql-server) server.

If you have been using the internal mysql server follow these instructions to migrate to a linked mysql container:

Assuming that your mysql data is available at `/srv/docker/gitlab/mysql`

```bash
docker run --name gitlab-mysql -d \
    --volume /srv/docker/gitlab/mysql:/var/lib/mysql \
    sameersbn/mysql:5.7.22-1
```

This will start a mysql container with your existing mysql data. Now login to the mysql container and create a user for the existing `gitlabhq_production` database.

All you need to do now is link this mysql container to the gitlab ci container using the `--link gitlab-mysql:mysql` option and provide the `DB_NAME`, `DB_USER` and `DB_PASS` parameters.

Refer to [Linking to MySQL Container](#linking-to-mysql-container) for more information.

# External MySQL Server

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
    --env 'DB_ADAPTER=mysql2' --env 'DB_HOST=192.168.1.100' \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

# Linking to MySQL Container

You can link this image with a mysql container for the database requirements. The alias of the mysql server container should be set to **mysql** while linking with the gitlab image.

If a mysql container is linked, only the `DB_ADAPTER`, `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a mysql container, we will use the [sameersbn/mysql](https://github.com/sameersbn/docker-mysql) image. When using docker-mysql in production you should mount a volume for the mysql data store. Please refer the [README](https://github.com/sameersbn/docker-mysql/blob/master/README.md) of docker-mysql for details.

First, lets pull the mysql image from the docker index.

```bash
docker pull sameersbn/mysql:5.7.22-1
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
    sameersbn/mysql:5.7.22-1
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with full/remote access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-mysql:mysql \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

Here the image will also automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the mysql container as they are specified in the `docker run` command for the mysql container. This is made possible using the magic of docker links and works with the following images:

 - [mysql](https://hub.docker.com/_/mysql/)
 - [sameersbn/mysql](https://quay.io/repository/sameersbn/mysql/)
 - [centurylink/mysql](https://hub.docker.com/r/centurylink/mysql/)
 - [orchardup/mysql](https://hub.docker.com/r/orchardup/mysql/)
