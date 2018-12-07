+++
title = "Automated Backups"
description = "Configure automated backups"
weight = 314
+++

The image can be configured to automatically take backups `daily`, `weekly` or `monthly` using the `GITLAB_BACKUP_SCHEDULE` configuration option.

Daily backups are created at `GITLAB_BACKUP_TIME` which defaults to `04:00` everyday. Weekly backups are created every Sunday at the same time as the daily backups. Monthly backups are created on the 1st of every month at the same time as the daily backups.

By default, when automated backups are enabled, backups are held for a period of 7 days. While when automated backups are disabled, the backups are held for an infinite period of time. This behavior can be configured via the `GITLAB_BACKUP_EXPIRY` option.