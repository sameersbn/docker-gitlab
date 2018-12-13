+++
title = "HTTPS Configuration"
description = "HTTPS Configuration"
category = ["configuration", "tls", "ssl"]
tags = ["configuration", "tls", "ssl", "https"]
weight = 2
+++

HTTPS support can be enabled by setting the `GITLAB_HTTPS` option to `true`. Additionally, when using self-signed SSL certificates you need to the set `SSL_SELF_SIGNED` option to `true` as well. Assuming we are using self-signed certificates

```bash
docker run --name gitlab -d \
    --publish 10022:22 --publish 10080:80 --publish 10443:443 \
    --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_PORT=10443' \
    --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

In this configuration, any requests made over the plain http protocol will automatically be redirected to use the https protocol. However, this is not optimal when using a load balancer.
