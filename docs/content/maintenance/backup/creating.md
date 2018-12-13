+++
title = "Creating Backups"
description = "Creating backups"
weight = 311
category = ["maintenance", "backup"]
tags = ["maintenance", "backup", "create"]
+++

GitLab defines a rake task to take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop gitlab && docker rm gitlab
```

Execute the rake task to create a backup.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:backup:create
```

A backup will be created in the backups folder of the [Data Store](#data-store). You can change the location of the backups using the `GITLAB_BACKUP_DIR` configuration parameter.

*P.S. Backups can also be generated on a running instance using `docker exec` as described in the [Rake Tasks](#rake-tasks) section. However, to avoid undesired side-effects, I advice against running backup and restore operations on a running instance.*

When using `docker-compose` you may use the following command to execute the backup.

```bash
docker-compose run --rm gitlab app:rake gitlab:backup:create
```
