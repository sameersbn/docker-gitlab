# Changelog

**latest**
- added GITLAB_PROJECTS_VISIBILITY configuration option to specify the default project visibility level.
- generate and store ssh host keys at the data store.
- default GITLAB_PROJECTS_LIMIT is now set to 100
- use sameersbn/ubuntu:14.04.20140508 base image, the trusted build of sameersbn/ubuntu:14.04.20140505 seems to be broken
- use sameersbn/ubuntu:14.04.20140505 base image
- added CA_CERTIFICATES_PATH configuration option to specify trusted root certificates.
- added SSL support
- added SSL_DHPARAM_PATH configuration option to specify path of dhparam.pem file.
- added SSL_KEY_PATH configuration option to specify path of ssl key.
- added SSL_CERTIFICATE_PATH configuration option to specify path of ssl certificate
- added GITLAB_HTTPS_ONLY configuration option to configure strict https only access
- added SSL_SELF_SIGNED configuration option to specify use of self signed ssl certificates.
- fix git over ssh when the default http/https ports are not used.
- compile the assets only if it does not exist or if the gitlab version has changed.
- upgrade gitlab-shell to version 1.9.4
- cache compiled assets to boost application startup.
- fix symlink to uploads directory

**6.8.1**
- upgrade to gitlab-ce 6.8.1

**6.8.0**
- upgrade to gitlab-shell 1.9.3
- added GITLAB_SIGNIN setting to enable or disable standard login form
- upgraded to gitlab-ce version 6.8.0
- added support for linking with redis container.
- use sameersbn/ubuntu as the base docker image
- install postgresql-client to fix restoring backups when used with a postgresql database backend.

**6.7.5**
- upgrade gitlab to 6.7.5
- support linking to mysql and postgresql containers
- added DEFAULT_PROJECTS_LIMIT configuration option

**6.7.4**
- upgrade gitlab to 6.7.4
- added SMTP_AUTHENTICATION configuration option, defaults to :login.
- added LDAP configuration options.

**6.7.3**
- upgrade gitlab to 6.7.3
- install ruby2.0 from ppa

**6.7.2**
- upgrade gitlab to 6.7.2
- upgrade gitlab-shell to 1.9.1
- reorganize repo
- do not perform system upgrades (http://crosbymichael.com/dockerfile-best-practices-take-2.html)

**6.6.5**
- upgraded to gitlab-6.6.5

**v6.6.4**
- upgraded to gitlab-6.6.4
- added changelog
- removed postfix mail delivery
- added SMTP_DOMAIN configuration option
- added SMTP_STARTTLS configuration option
- added SMTP_DOMAIN configuration option
- added DB_PORT configuration option
- changed backup time to 4am (UTC)

**v6.6.2**
- upgraded to gitlab-6.6.2
- added automated daily/monthly backups feature
- documented ssh login details for maintenance tasks.
- perform upgrade of git, nginx and other system packages
- added GITLAB_SHELL_SSH_PORT configuration option
- added app:rake command for executing gitlab rake tasks
- documented hardware requirements

**v6.6.1**
- upgraded to gitlabhq-6.6.1
- reformatted README
