+++
title = "SAML Configuration"
description = "SAML Configuration"
category = ["configuration", "omniauth", "oauth"]
tags = ["configuration", "omniauth", "oauth", "saml"]
+++

GitLab can be configured to act as a SAML 2.0 Service Provider (SP). This allows GitLab to consume assertions from a SAML 2.0 Identity Provider (IdP) such as Microsoft ADFS to authenticate users. Please refer to the GitLab [documentation](http://doc.gitlab.com/ce/integration/saml.html).

The following parameters have to be configured to enable SAML OAuth support in this image: `OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL`, `OAUTH_SAML_IDP_CERT_FINGERPRINT`, `OAUTH_SAML_IDP_SSO_TARGET_URL`, `OAUTH_SAML_ISSUER` and `OAUTH_SAML_NAME_IDENTIFIER_FORMAT`.

You can also override the default "Sign in with" button label with `OAUTH_SAML_LABEL`.

Please refer to [Available Configuration Parameters](#available-configuration-parameters) for the default configurations of these parameters.
