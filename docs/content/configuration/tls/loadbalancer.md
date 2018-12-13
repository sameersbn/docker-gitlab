+++
title = "HTTPS Loadbalander Configuration"
description = "Using HTTPS with a load balancer"
category = ["configuration", "tls", "ssl"]
tags = ["configuration", "tls", "ssl", "https", "loadbalancer"]
weight = 4
+++

Load balancers like nginx/haproxy/hipache talk to backend applications over plain http and as such the installation of ssl keys and certificates are not required and should **NOT** be installed in the container. The SSL configuration has to instead be done at the load balancer.

However, when using a load balancer you **MUST** set `GITLAB_HTTPS` to `true`. Additionally you will need to set the `SSL_SELF_SIGNED` option to `true` if self signed SSL certificates are in use.

With this in place, you should configure the load balancer to support handling of https requests. But that is out of the scope of this document. Please refer to [Using SSL/HTTPS with HAProxy](http://seanmcgary.com/posts/using-sslhttps-with-haproxy) for information on the subject.

When using a load balancer, you probably want to make sure the load balancer performs the automatic http to https redirection. Information on this can also be found in the link above.

In summation, when using a load balancer, the docker command would look for the most part something like this:

```bash
docker run --name gitlab -d \
    --publish 10022:22 --publish 10080:80 \
    --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_PORT=443' \
    --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

Again, drop the `--env 'SSL_SELF_SIGNED=true'` option if you are using CA certified SSL certificates.

In case GitLab responds to any kind of POST request (login, OAUTH, changing settings etc.) with a 422 HTTP Error, consider adding this to your reverse proxy configuration:

`proxy_set_header X-Forwarded-Ssl on;` (nginx format)
