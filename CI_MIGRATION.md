# CI Migration Guide

Since version `8.0.0`, CI is now a part of GitLab. You no longer need to run a separate instance of the CI server. This guide walks you through the procedure of migrating your existing CI data into GitLab.

This guide assumes that you are currently using `sameersbn/gitlab` and `sameersbn/gitlab-ci` for setting up your GitLab and CI requirements.

> **Note:**
>
> If your CI server and your GitLab server use the same database adapter no special care is needed. If your CI server uses MySQL and your GitLab server uses PostgreSQL you need to pass a special option in **Step 4 - Upgrade CI > Create CI backup**. If your CI server uses PostgreSQL and your GitLab server uses MySQL you cannot migrate your CI data to GitLab `8.0`, Please refer to https://github.com/sameersbn/docker-gitlab/issues/429#issuecomment-152799995 for instructions to migrate from MySQL to PostgreSQL first.

## Step 1 - Get Ready

Stop your GitLab and CI servers

```bash
docker stop gitlab-ci gitlab
docker rm gitlab-ci gitlab
```

## Step 2 - Upgrade to the `7.14.3` releases

Migration to GitLab `8.0` can only be done from version `7.14.3`. As a result we need to first migrate to the most recent versions of these images.

### Upgrade to `sameersbn/gitlab:7.14.3`

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab:7.14.3 app:init
```

### Upgrade to `sameersbn/gitlab-ci:7.14.3-1`

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:7.14.3-1 app:init
```

## Step 3 - Generate Backups

Create backups to ensure that we can rollback in case you face issues during the migration

### Create GitLab backup

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab:7.14.3 app:rake gitlab:backup:create
```

Make a note of the backup archive `xxxxxxxxxx_gitlab_backup.tar` as it is the backup you will have to rollback to in case of errors.

### Create GitLab CI backup

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:7.14.3-1 app:rake backup:create
```

Make a note of the backup archive `xxxxxxxxxx_gitlab_ci_backup.tar.gz` as it is the backup you will have to rollback to in case of errors.

> **Note**: From this point only `8.0.x` version images are used.

## Step 4 - Upgrade CI

CI `8.x.x` is only meant for the purpose of migrating to GitLab `8.0`. Here we need to upgrade to version `8.x.x` and generate a backup that will be imported into GitLab.

### Upgrade to `sameersbn/gitlab-ci:8.0.5`

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:8.0.5 app:init
```

### Create CI backup

*If you are converting from MySQL to PostgreSQL, add `MYSQL_TO_POSTGRESQL=1` to the end of the below command.*

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:8.0.5 app:rake backup:create
```

Copy the generated backup archive `xxxxxxxxxx_gitlab_ci_backup.tar` into the `backups/` directory of the GitLab server.

```bash
cp <gitlab-ci-host-volume-path>/backups/xxxxxxxxxx_gitlab_ci_backup.tar <gitlab-ce-host-volume-path>/backups/
```

We are done with CI. If the rest of the migration goes was planned you will not need to start `sameersbn/gitlab-ci` ever again.

## Step 5 - Upgrade GitLab

Before we can upgrade to `sameersbn/gitlab:8.0.5-1`, we need to assign the value of `GITLAB_CI_SECRETS_DB_KEY_BASE` (from CI) to `GITLAB_SECRETS_DB_KEY_BASE` in GitLab's environment.

Next you also need to set the environment variable `GITLAB_CI_HOST` to the address of your CI server, eg. `ci.example.com`. This will make sure that your existing runners will be able to communicate to GitLab with the old url.

### Upgrade to `sameersbn/gitlab:8.0.5-1`

```bash
docker run -it --rm [OPTIONS] \
  --env GITLAB_CI_HOST=ci.example.com --env GITLAB_SECRETS_DB_KEY_BASE=xxxxxx \
  sameersbn/gitlab:8.0.5-1 app:init
```

### Migrate CI data

```bash
docker run -it --rm [OPTIONS] \
  --env GITLAB_CI_HOST=ci.example.com --env GITLAB_SECRETS_DB_KEY_BASE=xxxxxx \
  sameersbn/gitlab:8.0.5-1 app:rake ci:migrate
```

## Step 6 - Fix DNS and reverse proxy configurations

Since GitLab and CI are now one, update your DNS configuration to make sure `ci.example.com` points to your GitLab instance.

If you are using a reverse proxy, update the configuration such that `ci.example.com` interfaces with the GitLab server.

>**Note**: The above changes results in connections from your runners redirect multiple times before ending up at the right location. If you want to avoid this redirection you can update the url in your runners configuration file to point to `http://git.example.com/ci` when using plain http, or `https://git.example.com/ci` if you are using SSL.
>
> If you change the url on the runners you can also do away with the `ci.example.com` domain name altogether.

## Step 7 - Done!

You can now start the GitLab server normally. Make sure that `GITLAB_CI_HOST` and `GITLAB_SECRETS_DB_KEY_BASE` are defined in your containers environment.

