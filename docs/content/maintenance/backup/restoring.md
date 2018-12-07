+++
title = "Restoring Backups"
description = "Restoring backups"
weight = 312
+++

GitLab also defines a rake task to restore a backup.

Before performing a restore make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop gitlab && docker rm gitlab
```

If this is a fresh database that you're doing the restore on, first
you need to prepare the database:

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake db:setup
```

Execute the rake task to restore a backup. Make sure you run the container in interactive mode `-it`.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:backup:restore BACKUP=1417624827
```

When using `docker-compose` you may use the following command to execute the restore.

```bash
docker-compose run --rm gitlab app:rake gitlab:backup:restore # List available backups
docker-compose run --rm gitlab app:rake gitlab:backup:restore BACKUP=1417624827 # Choose to restore from 1417624827
```