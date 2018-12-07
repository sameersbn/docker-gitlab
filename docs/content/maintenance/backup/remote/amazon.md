+++
title = "Amazon Web Services (AWS)"
description = "Configure AWS for remote backup"
category = ["backup"]
tags = ["amazon", "aws", "backup", "backups", "remote"]
weight =321
+++

The image can be configured to automatically upload the backups to an AWS S3 bucket. To enable automatic AWS backups first add `--env 'AWS_BACKUPS=true'` to the docker run command. In addition `AWS_BACKUP_REGION` and `AWS_BACKUP_BUCKET` must be properly configured to point to the desired AWS location. Finally an IAM user must be configured with appropriate access permission and their AWS keys exposed through `AWS_BACKUP_ACCESS_KEY_ID` and `AWS_BACKUP_SECRET_ACCESS_KEY`.

More details about the appropriate IAM user properties can found on [doc.gitlab.com](http://doc.gitlab.com/ce/raketasks/backup_restore.html#upload-backups-to-remote-cloud-storage)

For remote backup to selfhosted s3 compatible storage, use `AWS_BACKUP_ENDPOINT`.

AWS uploads are performed alongside normal backups, both through the appropriate `app:rake` command and when an automatic backup is performed.
