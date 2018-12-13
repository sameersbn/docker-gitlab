+++
title = "Authentiq Configuration"
description = "Authentiq Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "authentiq"]
+++

To enable the Authentiq OmniAuth provider for passwordless authentication you must register an application with [Authentiq](https://www.authentiq.com/). Please refer to the GitLab [documentation](https://docs.gitlab.com/ce/administration/auth/authentiq.html) for the procedure to generate the client ID and secret key with Authentiq.

Once you have the API client id and client secret generated, configure them using the `OAUTH_AUTHENTIQ_CLIENT_ID` and `OAUTH_AUTHENTIQ_CLIENT_SECRET` environment variables respectively.

For example, if your API key is `xxx` and the API secret key is `yyy`, then adding `--env 'OAUTH_AUTHENTIQ_CLIENT_ID=xxx' --env 'OAUTH_AUTHENTIQ_CLIENT_SECRET=yyy'` to the docker run command enables support for Authentiq OAuth.

You may want to specify `OAUTH_AUTHENTIQ_REDIRECT_URI` as well. The OAuth scope can be altered as well with `OAUTH_AUTHENTIQ_SCOPE` (defaults to `'aq:name email~rs address aq:push'`).
