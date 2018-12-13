+++
title = "Mail Configuration"
description = "Mail Configuration"
category = ["configuration"]
tags = ["configuration", "mail", "smtp"]
+++

The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

If you are using Gmail then all you need to do is:

```bash
docker run --name gitlab -d \
    --env 'SMTP_USER=USER@gmail.com' --env 'SMTP_PASS=PASSWORD' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of SMTP parameters that can be specified.

# Reply by email

Since version `8.0.0` GitLab adds support for commenting on issues by replying to emails.

To enable this feature you need to provide IMAP configuration parameters that will allow GitLab to connect to your mail server and read mails. Additionally, you may need to specify `GITLAB_INCOMING_EMAIL_ADDRESS` if your incoming email address is not the same as the `IMAP_USER`.

If your email provider supports email [sub-addressing](https://en.wikipedia.org/wiki/Email_address#Sub-addressing) then you should add the `+%{key}` placeholder after the user part of the email address, eg. `GITLAB_INCOMING_EMAIL_ADDRESS=reply+%{key}@example.com`. Please read the [documentation on reply by email](http://doc.gitlab.com/ce/incoming_email/README.html) to understand the requirements for this feature.

If you are using Gmail then all you need to do is:

```bash
docker run --name gitlab -d \
    --env 'IMAP_USER=USER@gmail.com' --env 'IMAP_PASS=PASSWORD' \
    --env 'GITLAB_INCOMING_EMAIL_ADDRESS=USER+%{key}@gmail.com' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

Please refer the [Available Configuration Parameters](#available-configuration-parameters) section for the list of IMAP parameters that can be specified.
