+++
title = "CAS3 Configuration"
description = "CAS3 Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "cas3"]
+++

To enable the CAS OmniAuth provider you must register your application with your CAS instance. This requires the service URL GitLab will supply to CAS. It should be something like: https://git.example.com:443/users/auth/cas3/callback?url. By default handling for SLO is enabled, you only need to configure CAS for backchannel logout.

For example, if your cas server url is `https://sso.example.com`, then adding `--env 'OAUTH_CAS3_SERVER=https://sso.example.com'` to the docker run command enables support for CAS3 OAuth. Please refer to [Available Configuration Parameters](#available-configuration-parameters) for additional CAS3 configuration parameters.
