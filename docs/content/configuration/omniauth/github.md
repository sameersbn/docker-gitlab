+++
title = "Github Configuration"
description = "Github Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "github"]
+++

To enable the GitHub OAuth2 OmniAuth provider you must register your application with GitHub. GitHub will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/github.html) for the procedure to generate the Client ID and secret with github.

Once you have the Client ID and secret generated, configure them using the `OAUTH_GITHUB_API_KEY` and `OAUTH_GITHUB_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_GITHUB_API_KEY=xxx' --env 'OAUTH_GITHUB_APP_SECRET=yyy'` to the docker run command enables support for GitHub OAuth.

Users of GitHub Enterprise may want to specify `OAUTH_GITHUB_URL` and `OAUTH_GITHUB_VERIFY_SSL` as well.
