+++
title = "External Issue Trackers"
description = "Configure external issue tracker"
+++

Since version `7.10.0` support for external issue trackers can be enabled in the "Service Templates" section of the settings panel.

If you are using the [docker-redmine](https://github.com/sameersbn/docker-redmine) image, you can *one up* the gitlab integration with redmine by adding `--volumes-from=gitlab` flag to the docker run command while starting the redmine container.

By using the above option the `/home/git/data/repositories` directory will be accessible by the redmine container and now you can add your git repository path to your redmine project. If, for example, in your gitlab server you have a project named `opensource/gitlab`, the bare repository will be accessible at `/home/git/data/repositories/opensource/gitlab.git` in the redmine container.
