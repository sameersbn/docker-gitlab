+++
title = "Docker Secrets Configuration"
description = "Docker Secrets Configuration"
category = ["configuration"]
tags = ["configuration", "secrets", "docker"]
+++

All the above environment variables can be put into a [secrets](https://docs.docker.com/compose/compose-file/#secrets) or [config](https://docs.docker.com/compose/compose-file/#configs) file
and then both docker-compose and Docker Swarm can import them into your gitlab container.

On startup, the gitlab container will source env vars from a config file labeled `gitlab-config`, and then a secrets file labeled `gitlab-secrets` (both mounted in the default locations).

See the exmample `config/docker-swarm/docker-compose.yml` file, and the example `gitlab.config` and `gitlab.secrets` file.

If you're not using one of these files, then don't include its entry in the docker-compose file.
