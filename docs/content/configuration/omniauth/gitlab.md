+++
title = "Gitlab Configuration"
description = "Gitlab Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "gitlab"]
+++

To enable the GitLab OAuth2 OmniAuth provider you must register your application with GitLab. GitLab will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/gitlab.html) for the procedure to generate the Client ID and secret with GitLab.

Once you have the Client ID and secret generated, configure them using the `OAUTH_GITLAB_API_KEY` and `OAUTH_GITLAB_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_GITLAB_API_KEY=xxx' --env 'OAUTH_GITLAB_APP_SECRET=yyy'` to the docker run command enables support for GitLab OAuth.
