+++
title = "Host Key Backups"
description = "Host Key backups"
weight = 313
+++

SSH keys are not backed up in the normal gitlab backup process. You
will need to backup the `ssh/` directory in the data volume by hand
and you will want to restore it prior to doing a gitlab restore.
