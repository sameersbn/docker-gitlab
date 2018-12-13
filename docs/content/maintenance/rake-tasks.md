+++
title = "Rake Tasks"
description = "Rake tasks"
category = ["maintenance"]
tags = ["maintenance", "rake"]
+++

The `app:rake` command allows you to run gitlab rake tasks. To run a rake task simply specify the task to be executed to the `app:rake` command. For example, if you want to gather information about GitLab and the system it runs on.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:env:info
```

You can also use `docker exec` to run raketasks on running gitlab instance. For example,

```bash
docker exec --user git -it gitlab bundle exec rake gitlab:env:info RAILS_ENV=production
```

Similarly, to import bare repositories into GitLab project instance

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:import:repos
```

Or

```bash
docker exec -it gitlab sudo -HEu git bundle exec rake gitlab:import:repos RAILS_ENV=production
```

OR, if attached to the container
 ```bash
. /sbin/entrypoint.sh app:help
```

For a complete list of available rake tasks please refer https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks or the help section of your gitlab installation.

*P.S. Please avoid running the rake tasks for backup and restore operations on a running gitlab instance.*

To use the `app:rake` command with `docker-compose` use the following command.

```bash
# For stopped instances
docker-compose run --rm gitlab app:rake gitlab:env:info
docker-compose run --rm gitlab app:rake gitlab:import:repos

# For running instances
docker-compose exec --user git gitlab bundle exec rake gitlab:env:info RAILS_ENV=production
docker-compose exec gitlab sudo -HEu git bundle exec rake gitlab:import:repos RAILS_ENV=production
```
