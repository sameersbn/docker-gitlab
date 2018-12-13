+++
title = "Postgresql Configuration"
description = "Postgresql Configuration"
category = ["configuration", "database"]
tags = ["configuration", "database", "db", "postgresql", "postgres"]
+++

# External PostgreSQL

The image also supports using an external PostgreSQL Server. This is also controlled via environment variables.

The database can be created with the following commands.

```sql
CREATE ROLE gitlab with LOGIN CREATEDB PASSWORD 'password';
CREATE DATABASE gitlabhq_production;
GRANT ALL PRIVILEGES ON DATABASE gitlabhq_production to gitlab;
CREATE EXTENSION pg_trgm;
```

{{%panel header="note" %}}Since GitLab `8.6.0` the `pg_trgm` extension must be loaded for the `gitlabhq_production` database.{{%/panel%}}

We are now ready to start the GitLab application.

*Assuming that the PostgreSQL server host is 192.168.1.100*

```bash
docker run --name gitlab -d \
    --env 'DB_ADAPTER=postgresql' --env 'DB_HOST=192.168.1.100' \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

# Linking to PostgreSQL Container

You can link this image with a postgresql container for the database requirements. The alias of the postgresql server container should be set to **postgresql** while linking with the gitlab image.

If a postgresql container is linked, only the `DB_ADAPTER`, `DB_HOST` and `DB_PORT` settings are automatically retrieved using the linkage. You may still need to set other database connection parameters such as the `DB_NAME`, `DB_USER`, `DB_PASS` and so on.

To illustrate linking with a postgresql container, we will use the [sameersbn/postgresql](https://github.com/sameersbn/docker-postgresql) image. When using postgresql image in production you should mount a volume for the postgresql data store. Please refer the [README](https://github.com/sameersbn/docker-postgresql/blob/master/README.md) of docker-postgresql for details.

First, lets pull the postgresql image from the docker index.

```bash
docker pull sameersbn/postgresql:10
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
    sameersbn/postgresql:10
```

The above command will create a database named `gitlabhq_production` and also create a user named `gitlab` with the password `password` with access to the `gitlabhq_production` database.

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-postgresql:postgresql \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

Here the image will also automatically fetch the `DB_NAME`, `DB_USER` and `DB_PASS` variables from the postgresql container as they are specified in the `docker run` command for the postgresql container. This is made possible using the magic of docker links and works with the following images:

 - [postgres](https://hub.docker.com/_/postgres/)
 - [sameersbn/postgresql](https://quay.io/repository/sameersbn/postgresql/)
 - [orchardup/postgresql](https://hub.docker.com/r/orchardup/postgresql/)
 - [paintedfox/postgresql](https://hub.docker.com/r/paintedfox/postgresql/)
