+++
title = "Data store"
description = "Data store"
category = ["configuration"]
tags = ["configuration", "datastore"]
+++

GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount a volume at,

* `/home/git/data`

Note that if you are using the `docker-compose` approach, this has already been done for you.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/docker/gitlab/gitlab
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/gitlab
```

Volumes can be mounted in docker by specifying the `-v` option in the docker run command.

```bash
docker run --name gitlab -d \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:11.5.0
```