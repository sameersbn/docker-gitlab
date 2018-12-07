+++
title = "Gitlab S3 Backup"
description = "Guide to configure gitlab to backup to self hosted s3 compatiable storage"
+++

{{% panel theme="danger" header="TODO" %}}Rewrite

* Tags
* Category

{{%/panel%}}

{{%alert success%}}{{%attachments  /%}}{{%/alert%}}

GitLab Backup to s3 compatible storage
=================================================

Enables automatic backups to selfhosted s3 compatible storage like minio (https://minio.io/) and others.
This is an extend of AWS Remote Backups.

As explained in [doc.gitlab.com](https://docs.gitlab.com/ce/raketasks/backup_restore.html#upload-backups-to-remote-cloud-storage), it uses [Fog library](http://fog.io) and the module fog-aws. More details on [s3 supported parameters](https://github.com/fog/fog-aws/blob/master/lib/fog/aws/storage.rb)


- [Available Parameters](#available-parameters)
- [Installation](#installation)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)


# Available Parameters

Here is an example of all configuration parameters that can be used in the GitLab container.

```
...
gitlab:
    ...
    environment:
    - AWS_BACKUPS=true
    - AWS_BACKUP_ENDPOINT='http://minio:9000'
    - AWS_BACKUP_ACCESS_KEY_ID=minio
    - AWS_BACKUP_SECRET_ACCESS_KEY=minio123
    - AWS_BACKUP_BUCKET=docker
    - AWS_BACKUP_MULTIPART_CHUNK_SIZE=104857600

```

where:

| Parameter | Description |
| --------- | ----------- |
| `AWS_BACKUPS` | Enables automatic uploads to an Amazon S3 instance. Defaults to `false`. |
| `AWS_BACKUP_ENDPOINT` | AWS endpoint. No defaults. |
| `AWS_BACKUP_ACCESS_KEY_ID` | AWS access key id. No defaults. |
| `AWS_BACKUP_SECRET_ACCESS_KEY` | AWS secret access key. No defaults. |
| `AWS_BACKUP_BUCKET` | AWS bucket for backup uploads. No defaults. |
| `AWS_BACKUP_MULTIPART_CHUNK_SIZE` | Enables mulitpart uploads when file size reaches a defined size. See at [AWS S3 Docs](http://docs.aws.amazon.com/AmazonS3/latest/dev/uploadobjusingmpu.html) |

For more info look at [Available Configuration Parameters](https://github.com/sameersbn/docker-gitlab#available-configuration-parameters).

A minimum set of these parameters are required to use the s3 compatible storage:

```yml
...
gitlab:
    environment:
    - AWS_BACKUPS=true
    - AWS_BACKUP_ENDPOINT='http://minio:9000'
    - AWS_BACKUP_ACCESS_KEY_ID=minio
    - AWS_BACKUP_SECRET_ACCESS_KEY=minio123
    - AWS_BACKUP_BUCKET=docker
...
```
# Installation

Starting a fresh installation with GitLab would be like the `docker-compose` file.

## Docker Compose

See attached file.


## Creating Backups

Execute the rake task with a removeable container.
```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:backup:create
```
## Restoring Backups

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
