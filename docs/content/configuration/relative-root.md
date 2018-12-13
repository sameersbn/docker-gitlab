+++
title = "Relative Root Directory"
description = "Deploy to a subdirectory (relative url root)"
category = ["configuration"]
tags = ["configuration"]
+++

By default GitLab expects that your application is running at the root (eg. /). This section explains how to run your application inside a directory.

Let's assume we want to deploy our application to '/git'. GitLab needs to know this directory to generate the appropriate routes. This can be specified using the `GITLAB_RELATIVE_URL_ROOT` configuration option like so:

```bash
docker run --name gitlab -it --rm \
    --env 'GITLAB_RELATIVE_URL_ROOT=/git' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

GitLab will now be accessible at the `/git` path, e.g. `http://www.example.com/git`.

{{%panel header="Note"%}}The `GITLAB_RELATIVE_URL_ROOT` parameter should always begin with a slash and* **SHOULD NOT** *have any trailing slashes.{{%/panel%}}
