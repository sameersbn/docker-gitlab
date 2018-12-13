+++
title = "Facebook Configuration"
description = "Facebook Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "facebook"]
+++

To enable the Facebook OAuth2 OmniAuth provider you must register your application with Facebook. Facebook will generate a API key and secret for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/facebook.html) for the procedure to generate the API key and secret.

Once you have the API key and secret generated, configure them using the `OAUTH_FACEBOOK_API_KEY` and `OAUTH_FACEBOOK_APP_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `--env 'OAUTH_FACEBOOK_API_KEY=xxx' --env 'OAUTH_FACEBOOK_APP_SECRET=yyy'` to the docker run command enables support for Facebook OAuth.
