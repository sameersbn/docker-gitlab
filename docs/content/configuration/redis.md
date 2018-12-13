+++
title = "Redis Configuration"
description = "Redis Configuration"
category = ["configuration"]
tags = ["configuration", "redis"]
+++

GitLab uses the redis server for its key-value data store. The redis server connection details can be specified using environment variables.

# Internal Redis Server

The internal redis server has been removed from the image. Please use a [linked redis](#linking-to-redis-container) container or specify a [external redis](#external-redis-server) connection.

# External Redis Server

The image can be configured to use an external redis server. The configuration should be specified using environment variables while starting the GitLab image.

*Assuming that the redis server host is 192.168.1.100*

```bash
docker run --name gitlab -it --rm \
    --env 'REDIS_HOST=192.168.1.100' --env 'REDIS_PORT=6379' \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

# Linking to Redis Container

You can link this image with a redis container to satisfy gitlab's redis requirement. The alias of the redis server container should be set to **redisio** while linking with the gitlab image.

To illustrate linking with a redis container, we will use the [sameersbn/redis](https://github.com/sameersbn/docker-redis) image. Please refer the [README](https://github.com/sameersbn/docker-redis/blob/master/README.md) of docker-redis for details.

First, lets pull the redis image from the docker index.

```bash
docker pull sameersbn/redis:4.0.9-1
```

Lets start the redis container

```bash
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:4.0.9-1
```

We are now ready to start the GitLab application.

```bash
docker run --name gitlab -d --link gitlab-redis:redisio \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```
