+++
title = "Upgrading"
description = "Upgrading Gitlab"
category = ["maintenance"]
tags = ["maintenance", "upgrade", "gitlab"]
+++

{{% panel theme="danger" header="Important Notice" %}}Since GitLab release `8.6.0` PostgreSQL users should enable `pg_trgm` extension on the GitLab database. Refer to GitLab's [Postgresql Requirements](http://doc.gitlab.com/ce/install/requirements.html#postgresql-requirements) for more information

If you're using `sameersbn/postgresql` then please upgrade to `sameersbn/postgresql:9.4-18` or later and add `DB_EXTENSION=pg_trgm` to the environment of the PostgreSQL container (see: https://github.com/sameersbn/docker-gitlab/blob/master/docker-compose.yml#L8).{{% /panel %}}

GitLabHQ releases new versions on the 22nd of every month, bugfix releases immediately follow. I update this project almost immediately when a release is made (at least it has been the case so far). If you are using the image in production environments I recommend that you delay updates by a couple of days after the gitlab release, allowing some time for the dust to settle down.

To upgrade to newer gitlab releases, simply follow this 4 step upgrade procedure.

{{% panel header="Note" %}}Upgrading to `sameersbn/gitlab:{{< param "Gitlab.Version" >}}` from `sameersbn/gitlab:7.x.x` can cause issues. It is therefore required that you first upgrade to `sameersbn/gitlab:8.0.5-1` before upgrading to `sameersbn/gitlab:8.1.0` or higher.{{%/panel%}}

{{% panel theme="default" header="Step 1: Update the docker image" %}}

```bash
docker pull sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

{{%/panel%}}

{{% panel theme="default" header="Step 2: Stop and remove the currently running image" %}}

```bash
docker stop gitlab
docker rm gitlab
```

{{%/panel%}}

{{% panel theme="default" header="Step 3: Create a backup" %}}

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:x.x.x app:rake gitlab:backup:create
```

Replace `x.x.x` with the version you are upgrading from. For example, if you are upgrading from version `6.0.0`, set `x.x.x` to `6.0.0`
{{%/panel%}}

{{% panel theme="default" header="Step 4: Start the image" %}}
> **Note**: Since GitLab `8.0.0` you need to provide the `GITLAB_SECRETS_DB_KEY_BASE` parameter while starting the image.

> **Note**: Since GitLab `8.11.0` you need to provide the `GITLAB_SECRETS_SECRET_KEY_BASE` and `GITLAB_SECRETS_OTP_KEY_BASE` parameters while starting the image. These should initially both have the same value as the contents of the `/home/git/data/.secret` file. See [Available Configuration Parameters](#available-configuration-parameters) for more information on these parameters.

```bash
docker run --name gitlab -d [OPTIONS] sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

{{%/panel%}}
