+++
title = "Google Configuration"
description = "Google Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "google"]
+++

To enable the Google OAuth2 OmniAuth provider you must register your application with Google. Google will generate a client ID and secret key for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/google.html) for the procedure to generate the client ID and secret key with google.

Once you have the client ID and secret keys generated, configure them using the `OAUTH_GOOGLE_API_KEY` and `OAUTH_GOOGLE_APP_SECRET` environment variables respectively.

For example, if your client ID is `xxx.apps.googleusercontent.com` and client secret key is `yyy`, then adding `--env 'OAUTH_GOOGLE_API_KEY=xxx.apps.googleusercontent.com' --env 'OAUTH_GOOGLE_APP_SECRET=yyy'` to the docker run command enables support for Google OAuth.

You can also restrict logins to a single domain by adding `--env "OAUTH_GOOGLE_RESTRICT_DOMAIN='example.com'"`.
