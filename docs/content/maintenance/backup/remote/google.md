+++
title = "Google Cloud Storage (GCS)"
description = "Configure GCS for remote backup"
category = ["backup"]
tags = ["google", "gcs", "backup", "backups", "remote"]
weight = 322
+++

The image can be configured to automatically upload the backups to an Google Cloud Storage bucket. To enable automatic GCS backups first add `--env 'GCS_BACKUPS=true'` to the docker run command. In addition `GCS_BACKUP_BUCKET` must be properly configured to point to the desired GCS location.
Finally a couple of `Interoperable storage access keys` user must be created and their keys exposed through `GCS_BACKUP_ACCESS_KEY_ID` and `GCS_BACKUP_SECRET_ACCESS_KEY`.

More details about the Cloud storage interoperability  properties can found on [cloud.google.com/storage](https://cloud.google.com/storage/docs/interoperability)

GCS uploads are performed alongside normal backups, both through the appropriate `app:rake` command and when an automatic backup is performed.
