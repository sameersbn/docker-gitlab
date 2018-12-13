+++
title = "Azure Configuration"
description = "Azure Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "azure"]
+++

To enable the Microsoft Azure OAuth2 OmniAuth provider you must register your application with Azure. Azure will generate a Client ID, Client secret and Tenant ID for you to use. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/azure.html) for the procedure.

Once you have the Client ID, Client secret and Tenant ID generated, configure them using the `OAUTH_AZURE_API_KEY`, `OAUTH_AZURE_API_SECRET` and `OAUTH_AZURE_TENANT_ID` environment variables respectively.

For example, if your Client ID is `xxx`, the Client secret is `yyy` and the Tenant ID is `zzz`, then adding `--env 'OAUTH_AZURE_API_KEY=xxx' --env 'OAUTH_AZURE_API_SECRET=yyy' --env 'OAUTH_AZURE_TENANT_ID=zzz'` to the docker run command enables support for Microsoft Azure OAuth.
