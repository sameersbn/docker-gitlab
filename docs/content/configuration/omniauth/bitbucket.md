+++
title = "Bitbucket Configuration"
description = "Bitbucket Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "bitbucket"]
+++

To enable the BitBucket OAuth2 OmniAuth provider you must register your application with BitBucket. BitBucket will generate a Client ID and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/bitbucket.html) for the procedure to generate the Client ID and secret with BitBucket.

Once you have the Client ID and secret generated, configure them using the `OAUTH_BITBUCKET_API_KEY` and `OAUTH_BITBUCKET_APP_SECRET` environment variables respectively.

For example, if your Client ID is `xxx` and the Client secret is `yyy`, then adding `--env 'OAUTH_BITBUCKET_API_KEY=xxx' --env 'OAUTH_BITBUCKET_APP_SECRET=yyy'` to the docker run command enables support for BitBucket OAuth.
