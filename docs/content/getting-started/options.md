+++
title = "Run Options"
description = "How to use [Options]"
category = ["getting started"]
tags = ["getting started", "installation", "options"]
weight = 5
+++

This documentation often use [OPTIONS] placeholder in `docker run` commands (to create backups, import bare repositories...).
Considering the Gitlab instance has been configured with `docker-compose` method of [Quick Start](#quick-start) and that the Gitlab, Redis and Postgresql containers are called *gitlab_gitlab_1*, *gitlab_redis_1* and *gitlab_postgresql_1* respectively, here is the configuration to replace [OPTIONS] placeholder:

```bash
--link gitlab_redis_1:redisio \
--link gitlab_postgresql_1:postgresql \
-e "GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alpha-numeric-string" \
-v "/srv/docker/gitlab/gitlab:/home/git/data"
```

{{%panel header="Note"%}}Before executing any `docker run` command, stop the running Gitlab container. For instance, to import repositories:

```bash
docker stop gitlab_gitlab_1

docker run --name gitlab -it --rm \
  --link gitlab_redis_1:redisio --link gitlab_postgresql_1:postgresql \
  -e "GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alpha-numeric-string" \
  -v "/srv/docker/gitlab/gitlab:/home/git/data" \
  sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:import:repos
  
docker start gitlab_gitlab_1
```

{{%/panel%}}
