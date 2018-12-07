+++
title = "Import Repositories"
description = "Import Repositories"
category = ["maintenance"]
tags = ["maintenance", "rake", "import", "repository", "repositories"]
+++

Copy all the **bare** git repositories to the `repositories/` directory of the [data store](#data-store) and execute the `gitlab:import:repos` rake task like so:

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}} app:rake gitlab:import:repos
```

Watch the logs and your repositories should be available into your new gitlab container.

See [Rake Tasks](#rake-tasks) for more information on executing rake tasks.
Usage when using `docker-compose` can also be found there.
