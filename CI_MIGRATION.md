# GitLab CI Migration Guide

Since version `8.0.0`, GitLab CI is now a part of GitLab CE. You no longer need to run a separate instance of the GitLab CI server. This guide walks you through the procedure of migrating your existing GitLab CI data into GitLab CE.

This guide assumes that you are currently using `sameersbn/gitlab` and `sameersbn/gitlab-ci` for setting up your GitLab CE and GitLab CI requirements.

## Step 1 - Get Ready

Stop your Gitlab CE and CI servers

```bash
docker stop gitlab-ci gitlab
docker rm gitlab-ci gitlab
```

## Step 2 - Upgrade to most recent `7.14.x` releases

Migration to GitLab `8.0.0` can only be done from version `7.14.3`. As a result we need to first migrate to the most recent versions of these images.

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

### Create Gitlab CI backup

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:7.14.3-1 app:rake backup:create
```

Make a note of the backup archive `xxxxxxxxxx_gitlab_ci_backup.tar.gz` as it is the backup you will have to rollback to in case of errors.

> **Note**: From this point only `8.0.0` version images are used.

## Step 4 - Upgrade GitLab CI

GitLab CI `8.0.0` is only meant for the purpose of migrating to GitLab `8.0.0`. Here we need to upgrade to versio `8.0.0` and generate a backup that will be imported into GitLab.

### Upgrade to `sameersbn/gitlab-ci:8.0.0`

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:8.0.0 app:init
```

### Create GitLab CI backup

```bash
docker run -it --rm [OPTIONS] \
  sameersbn/gitlab-ci:8.0.0 app:rake backup:create
```

Copy the generated backup archive `xxxxxxxxxx_gitlab_ci_backup.tar` into the `backups/` directory of the GitLab CE server.

```bash
cp <gitlab-ci-host-volume-path>/backups/xxxxxxxxxx_gitlab_ci_backup.tar <gitlab-ce-host-volume-path>/backups/
```

We are done with GitLab CI. If the rest of the migration goes was planned you will not need to start `sameersbn/gitlab-ci` ever again.

## Step 5 - Upgrade GitLab

Before we can upgrade to `sameersbn/gitlab:8.0.0`, we need to assign the value of `GITLAB_CI_SECRETS_DB_KEY_BASE` (from GitLab CI) to `GITLAB_SECRETS_DB_KEY_BASE` in GitLab's environment.

Next you also need to set the environment variable `GITLAB_CI_HOST` to the address of your CI server, eg. `ci.example.com`. This will make sure that your existing runners will be able to communicate to GitLab with the old url.

### Upgrade to `sameersbn/gitlab-ci:8.0.0`

```bash
docker run -it --rm [OPTIONS] \
  --env GITLAB_CI_HOST=ci.example.com --env GITLAB_SECRETS_DB_KEY_BASE=xxxxxx \
  sameersbn/gitlab:8.0.0 app:init
```

### Migrate CI data

```bash
docker run -it --rm [OPTIONS] \
  --env GITLAB_CI_HOST=ci.example.com --env GITLAB_SECRETS_DB_KEY_BASE=xxxxxx \
  sameersbn/gitlab:8.0.0 app:rake ci:migrate
```

## Step 6 - Fix DNS and reverse proxy configurations

Since GitLab and GitLab CI are now one, update your DNS configuration to make sure `ci.example.com` points to your GitLab instance.

If you are using a reverse proxy, update the configuration such that `ci.example.com` interfaces with the GitLab server.

## Step 7 - Done!

You can now start the GitLab server normally. Make sure that `GITLAB_CI_HOST` and `GITLAB_SECRETS_DB_KEY_BASE` are defined in your containers environment.

