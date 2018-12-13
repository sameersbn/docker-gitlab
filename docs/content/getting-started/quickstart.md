+++
title = "Quickstart"
description = "Quickstart"
category = ["getting started"]
tags = ["getting started", "installation", "prerequisites", "requirements"]
weight = 4
+++

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
    sameersbn/postgresql:10
```

Step 2. Launch a redis container

```bash
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:4.0.9-1
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
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

*Please refer to [Available Configuration Parameters](#available-configuration-parameters) to understand `GITLAB_PORT` and other configuration options*

__NOTE__: Please allow a couple of minutes for the GitLab application to start.

Point your browser to `http://localhost:10080` and set a password for the `root` user account.

You should now have the GitLab application up and ready for testing. If you want to use this image in production then please read on.

*The rest of the document will use the docker command line. You can quite simply adapt your configuration into a `docker-compose.yml` file if you wish to do so.*