+++
title = "Host UID / GID Mapping"
description = "Host UID / GID Mapping"
category = ["configuration"]
tags = ["configuration", "uid", "gid", "mapping"]
+++

Per default the container is configured to run gitlab as user and group `git` with `uid` and `gid` `1000`. The host possibly uses this ids for different purposes leading to unfavorable effects. From the host it appears as if the mounted data volumes are owned by the host's user/group `1000`.

Also the container processes seem to be executed as the host's user/group `1000`. The container can be configured to map the `uid` and `gid` of `git` to different ids on host by passing the environment variables `USERMAP_UID` and `USERMAP_GID`. The following command maps the ids to user and group `git` on the host.

```bash
docker run --name gitlab -it --rm [options] \
    --env "USERMAP_UID=$(id -u git)" --env "USERMAP_GID=$(id -g git)" \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

When changing this mapping, all files and directories in the mounted data volume `/home/git/data` have to be re-owned by the new ids. This can be achieved automatically using the following command:

```bash
docker run --name gitlab -d [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:sanitize
```
