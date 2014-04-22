# Changelog

**latest**
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
