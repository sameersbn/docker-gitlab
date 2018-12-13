+++
title = "Installation"
description = "Installation"
category = ["getting started"]
tags = ["getting started", "installation"]
weight = 3
+++

# Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/sameersbn/gitlab) and is the recommended method of installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/sameersbn/gitlab)

```bash
docker pull sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

You can also pull the `latest` tag which is built from the repository *HEAD*

```bash
docker pull sameersbn/gitlab:latest
```

Alternatively you can build the image locally.

```bash
docker build -t sameersbn/gitlab github.com/sameersbn/docker-gitlab
```
