# Changelog

This file only reflects the changes that are made in this image. Please refer to the upstream GitLab [CHANGELOG](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/CHANGELOG) for the list of changes in GitLab.

**8.8.5-1**
- added GitLab Container Registry support
- added `SSL_CIPHERS` option to change chipers of the nginx

**8.8.5**
- gitlab: upgrade to CE v8.8.5

**8.8.4**
- gitlab: upgrade to CE v8.8.4
- added `GITLAB_PROJECTS_LIMIT` configuration option

**8.8.3**
- gitlab: upgrade to CE v8.8.3

**8.8.2**
- gitlab: upgrade to CE v8.8.2

**8.8.1**
- gitlab: upgrade to CE v8.8.1

**8.8.0**
- gitlab: upgrade to CE v8.8.0
- oauth: exposed `OAUTH_GITHUB_URL` and `OAUTH_GITHUB_VERIFY_SSL` options for users for GitHub Enterprise.

**8.7.6**
- gitlab: upgrade to CE v8.7.6

**8.7.5**
- gitlab: upgrade to CE v8.7.5

**8.7.3**
- gitlab: upgrade to CE v8.7.3

**8.7.2**
- gitlab: upgrade to CE v8.7.2

**8.7.1**
- gitlab: upgrade to CE v8.7.1

**8.7.0**
- gitlab-shell: upgrade to v.2.7.2
- gitlab: upgrade to CE v8.7.0
- SSO: `OAUTH_ALLOW_SSO` now specifies a comma separated list of providers.
- OAuth: Added `OAUTH_EXTERNAL_PROVIDERS` to specify external oauth providers.
- Exposed `GITLAB_TRUSTED_PROXIES` configuration parameter

**8.6.7**
- added `GITLAB_SIGNUP_ENABLED` option to enable/disable signups
- gitlab: upgrade to CE v8.6.7

**8.6.6**
- gitlab: upgrade to CE v8.6.6

**8.6.5**
- gitlab: upgrade to CE v8.6.5

**8.6.4**
- gitlab: upgrade to CE v8.6.4

**8.6.3**
- gitlab-shell: upgrade to v.2.6.12
- gitlab: upgrade to CE v8.6.3

**8.6.2**
- gitlab: upgrade to CE v8.6.2

**8.6.1**
- gitlab: upgrade to CE v8.6.1

**8.6.0**
- gitlab-shell: upgrade to v.2.6.11
- gitlab-workhorse: upgrade to v0.7.1
- gitlab: upgrade to CE v8.6.0
- exposed configuration parameters for auth0 OAUTH support
- fixed relative_url support

**8.5.8**
- gitlab: upgrade to CE v8.5.8

**8.5.7**
- gitlab: upgrade to CE v8.5.7

**8.5.5**
- gitlab: upgrade to CE v8.5.5

**8.5.4**
- gitlab: upgrade to CE v8.5.4

**8.5.3**
- gitlab: upgrade to CE v8.5.3

**8.5.1**
- gitlab: upgrade to CE v8.5.1

**8.5.0**
- gitlab-workhorse: upgrade to v0.6.4
- gitlab: upgrade to CE v8.5.0
- firstrun: expose `GITLAB_ROOT_EMAIL` configuration option
- expose `OAUTH_AUTO_LINK_SAML_USER` configuration parameter

**8.4.4**
- gitlab: upgrade to CE v8.4.4

**8.4.3**
- gitlab: upgrade to CE v8.4.3

**8.4.2**
- gitlab-workhorse: upgrade to v0.6.2
- gitlab: upgrade to CE v8.4.2

**8.4.1**
- gitlab: upgrade to CE v8.4.1

**8.4.0-1**
- `assets:precompile` moved back to build time

**8.4.0**
- gitlab-shell: upgrade to v.2.6.10
- gitlab-workhorse: upgrade to v0.6.1
- gitlab: upgrade to CE v8.4.0
- oauth: expose cas3 oauth configuration options
- oauth: expose azure oauth configuration options
- `assets:precompile` executed at runtime

**8.3.4**
- gitlab-workhorse: upgrade to v0.5.4
- gitlab: upgrade to CE v8.3.4
- expose `LDAP_TIMEOUT` configuration parameter

**8.3.2**
- gitlab: upgrade to CE v8.3.2

**8.3.1**
- gitlab: upgrade to CE v8.3.1

**8.3.0-1**
- fixed static asset routing when `GITLAB_RELATIVE_URL_ROOT` is used.

**8.3.0**
- `envsubst` is now used for updating the configurations
- renamed config `CA_CERTIFICATES_PATH` to `SSL_CA_CERTIFICATES_PATH`
- renamed config `GITLAB_HTTPS_HSTS_ENABLED` to `NGINX_HSTS_ENABLED`
- renamed config `GITLAB_HTTPS_HSTS_MAXAGE` to `NGINX_HSTS_MAXAGE`
- renamed config `GITLAB_BACKUPS` to `GITLAB_BACKUP_SCHEDULE`
- gitlab-workhorse: upgrade to v0.5.1
- gitlab: upgrade to CE v8.3.0
- expose `GITLAB_MAX_OBJECT_SIZE` configuration parameter
- removed `NGINX_MAX_UPLOAD_SIZE` configuration parameter
- gitlab-shell: upgrade to v.2.6.9

**8.2.3**
- fixed static asset routing when `GITLAB_RELATIVE_URL_ROOT` is used.
- added `GITLAB_BACKUP_PG_SCHEMA` configuration parameter
- gitlab: upgrade to CE v8.2.3

**8.2.2**
- added `GITLAB_DOWNLOADS_DIR` configuration parameter
- `DB_TYPE` parameter renamed to `DB_ADAPTER` with `mysql2` and `postgresql` as accepted values
- exposed `DB_ENCODING` parameter
- gitlab: upgrade to CE v8.2.2

**8.2.1-1**
- fixed typo while setting the value of `GITLAB_ARTIFACTS_DIR`

**8.2.1**
- expose rack_attack configuration options
- gitlab-shell: upgrade to v.2.6.8
- gitlab: upgrade to CE v8.2.1
- added `GITLAB_ARTIFACTS_ENABLED` configuration parameter
- added `GITLAB_ARTIFACTS_DIR` configuration parameter

**8.2.0**
- gitlab-shell: upgrade to v.2.6.7
- gitlab-workhorse: upgrade to v.0.4.2
- gitlab: upgrade to CE v8.2.0
- added `GITLAB_SHARED_DIR` configuration parameter
- added `GITLAB_LFS_OBJECTS_DIR` configuration parameter
- added `GITLAB_PROJECTS_BUILDS` configuration parameter
- added `GITLAB_LFS_ENABLED` configuration parameter

**8.1.4**
- gitlab: upgrade to CE v8.1.4

**8.1.3**
- proper long-term fix for http/https cloning when `GITLAB_RELATIVE_URL_ROOT` is used
- gitlab: upgrade to CE v8.1.3
- Expose Facebook OAUTH configuration parameters

**8.1.2**
- gitlab: upgrade to CE v8.1.2
- removed `GITLAB_SATELLITES_TIMEOUT` configuration parameter

**8.1.0-2**
- Recompile assets when `GITLAB_RELATIVE_URL_ROOT` is used Fixes #481

**8.1.0-1**
- temporary fix for http/https cloning when `GITLAB_RELATIVE_URL_ROOT` is used

**8.1.0**
- gitlab: upgrade to CE v8.1.0
- gitlab-git-http-server: upgrade to v0.3.0

**8.0.5-1**
- speed up container startup by compiling assets at image build time
- test connection to redis-server

**8.0.5**
- gitlab: upgrade to CE v.8.0.5

**8.0.4-2**
- fix http/https cloning when `GITLAB_RELATIVE_URL_ROOT` is used
- allow user to override `OAUTH_ENABLED` setting

**8.0.4-1**
- update baseimage to `sameersbn/ubuntu:14.04.20151011`

**8.0.4**
- gitlab: upgrade to CE v.8.0.4

**8.0.3**
- gitlab: upgrade to CE v.8.0.3

**8.0.2**
- gitlab: upgrade to CE v.8.0.2
- added `IMAP_STARTTLS` parameter, defaults to `false`
- expose oauth parameters for crowd server

**8.0.0**
- set default value of `DB_TYPE` to `postgres`
- added sample Kubernetes rc and service description files
- expose `GITLAB_BACKUP_ARCHIVE_PERMISSIONS` parameter
- gitlab: upgrade to CE v.8.0.0
- added `GITLAB_SECRETS_DB_KEY_BASE` parameter
- added `GITLAB_NOTIFY_ON_BROKEN_BUILDS` and `GITLAB_NOTIFY_PUSHER` parameters
- added options to email IMAP and reply by email feature
- set value of `GITLAB_EMAIL` to `SMTP_USER` if defined, else default to `example@example.com`
- removed `GITLAB_ROBOTS_OVERRIDE` parameter. Override default `robots.txt` if `GITLAB_ROBOTS_PATH` exists.
- added CI redirection using `GITLAB_CI_HOST` parameter

**7.14.3**
- gitlab: upgrade to CE v.7.14.3

**7.14.2**
- Apply grsecurity policies to nodejs binary #394
- Fix broken emojis post migration #196
- gitlab-shell: upgrade to v.2.6.5
- gitlab: upgrade to CE v.7.14.2

**7.14.1**
- gitlab: upgrade to CE v.7.14.1

**7.14.0**
- gitlab-shell: upgrade to v.2.6.4
- gitlab: upgrade to CE v.7.14.0

**7.13.5**
- gitlab: upgrade to CE v.7.13.5

**7.13.4**
- gitlab: upgrade to CE v.7.13.4

**7.13.3**
- gitlab: upgrade to CE v.7.13.3

**7.13.2**
- gitlab: upgrade to CE v.7.13.2

**7.13.1**
- gitlab: upgrade to CE v.7.13.1

**7.13.0**
- expose SAML OAuth provider configuration
- expose `OAUTH_AUTO_SIGN_IN_WITH_PROVIDER` configuration
- gitlab: upgrade to CE v.7.13.0

**7.12.2-2**
- enable persistence `.secret` file used in 2FA

**7.12.2-1**
- fixed gitlab:backup:restore raketask

**7.12.2**
- gitlab: upgrade to CE v.7.12.2

**7.12.1**
- gitlab: upgrade to CE v.7.12.1

**7.12.0**
- added `SMTP_TLS` configuration parameter
- gitlab: upgrade to CE v.7.12.0
- added `OAUTH_AUTO_LINK_LDAP_USER` configuration parameter

**7.11.4-1**
- base image update to fix SSL vulnerability

**7.11.4**
- gitlab: upgrade to CE v.7.11.4

**7.11.3**
- gitlab: upgrade to CE v.7.11.3

**7.11.2**
- gitlab: upgrade to CE v.7.11.2

**7.11.0**
- init: added `SIDEKIQ_MEMORY_KILLER_MAX_RSS` configuration option
- init: added `SIDEKIQ_SHUTDOWN_TIMEOUT` configuration option
- gitlab-shell: upgrade to v.2.6.3
- gitlab: upgrade to CE v.7.11.0
- init: removed `GITLAB_PROJECTS_VISIBILITY` ENV parameter

**7.10.4**
- gitlab: upgrade to CE v.7.10.4

**7.10.3**
- gitlab: upgrade to CE v.7.10.3

**7.10.2**
- init: added support for remote AWS backups
- gitlab: upgrade to CE v.7.10.2

**7.10.1**
- gitlab: upgrade to CE v.7.10.1

**7.10.0**
- gitlab-shell: upgrade to v.2.6.2
- gitlab: upgrade to CE v.7.10.0
- init: removed ENV variables to configure *External Issue Tracker* integration
- init: added `GITLAB_EMAIL_REPLY_TO` configuration option
- init: added `LDAP_BLOCK_AUTO_CREATED_USERS` configuration option

**7.9.4**
- gitlab: upgrade to CE v.7.9.4

**7.9.3**
- added `NGINX_PROXY_BUFFERING` option
- added `NGINX_ACCEL_BUFFERING` option
- added `GITLAB_GRAVATAR_ENABLED` option
- added `GITLAB_GRAVATAR_HTTP_URL` option
- added `GITLAB_GRAVATAR_HTTPS_URL` option
- fixes: "transfer closed with xxx bytes remaining to read" error
- gitlab: upgrade to CE v.7.9.3

**7.9.2**
- gitlab: upgrade to CE v.7.9.2

**7.9.1**
- init: set default value of `SMTP_OPENSSL_VERIFY_MODE` to `none`
- gitlab: upgrade to CE v.7.9.1

**7.9.0**
- gitlab-shell: upgrade to v.2.6.0
- gitlab: upgrade to CE v.7.9.0
- init: set default value of `UNICORN_WORKERS` to `3`
- init: set default value of `SMTP_OPENSSL_VERIFY_MODE` to `peer`
- init: removed `GITLAB_RESTRICTED_VISIBILITY` configuration option, can be set from the UI
- init: added BitBucket OAuth configuration support
- init: added `GITLAB_EMAIL_DISPLAY_NAME` configuration option

**7.8.4**
- gitlab: upgrade to CE v.7.8.4

**7.8.2**
- gitlab: upgrade to CE v.7.8.2

**7.8.1**
- gitlab-shell: upgrade to v.2.5.4
- gitlab: upgrade to CE v.7.8.1

**7.8.0**
- update postgresql client to the latest version, Closes #249
- removed `GITLAB_SIGNUP` configuration option, can be set from gitlab ui
- removed `GITLAB_SIGNIN` configuration option, can be set from gitlab ui
- removed `GITLAB_PROJECTS_LIMIT` configuration option, can be set from gitlab ui
- removed `GITLAB_GRAVATAR_ENABLED` configuration option, can be set from gitlab ui
- gitlab-shell: upgrade to v.2.5.3
- gitlab: upgrade to CE v.7.8.0
- init: set `LDAP_PORT` default value to `389`
- init: set `LDAP_METHOD` default value to `plain`
- init: added gitlab oauth configuration support

**7.7.2**
- gitlab-shell: upgrade to v.2.4.2
- gitlab: upgrade to CE v.7.7.2

**7.7.1**
- gitlab: upgrade to CE v.7.7.1

**7.7.0**
- init: added GOOGLE_ANALYTICS_ID configuration option
- added support for mantis issue tracker
- fixed log rotation configuration
- gitlab-shell: upgrade to v.2.4.1
- gitlab: upgrade to CE v.7.7.0

**7.6.2**
- gitlab: upgrade to CE v.7.6.2

**7.6.1**
- disable nginx ipv6 if host does not support it.
- init: added GITLAB_BACKUP_TIME configuration option
- gitlab: upgrade to CE v.7.6.1

**7.6.0**
- add support for configuring piwik
- gitlab-shell: upgrade to v.2.4.0
- gitlab: upgrade to CE v.7.6.0

**7.5.3**
- accept `BACKUP` parameter while running the restore rake task, closes #220
- init: do not run `gitlab:satellites:create` rake task at startup
- gitlab: upgrade to CE v.7.5.3

**7.5.2**
- gitlab: upgrade to CE v.7.5.2

**7.5.1**
- gitlab: upgrade to CE v.7.5.1
- gitlab-shell to v2.2.0
- added `GITLAB_TIMEZONE` configuration option
- added `GITLAB_EMAIL_ENABLED` configuration option

**7.4.4**
- gitlab: upgrade to CE v.7.4.4
- added `SSL_VERIFY_CLIENT` configuration option
- added `NGINX_WORKERS` configuration option
- added `USERMAP_UID` and `USERMAP_GID` configuration option

**7.4.3**
- gitlab: upgrade to CE v.7.4.3

**7.4.2**
- gitlab: upgrade to CE v.7.4.2

**7.4.0**
- gitlab: upgrade to CE v.7.4.0
- config: added `LDAP_ACTIVE_DIRECTORY` configuration option
- added SMTP_OPENSSL_VERIFY_MODE configuration option
- feature: gitlab logs volume
- automatically compile assets if relative_url is changed
- launch all daemons via supervisord

**7.3.2-1**
- fix mysql status check

**7.3.2**
- upgrade to gitlab-ce 7.3.2
- removed internal mysql server
- added support for fetching `DB_NAME`, `DB_USER` and `DB_PASS` from the postgresql linkage
- added support for fetching `DB_NAME`, `DB_USER` and `DB_PASS` from the mysql linkage
- gitlab-shell: upgrade to v.2.0.1
- added GITLAB_GRAVATAR_ENABLED configuration option
- added fig.yml

**7.3.1-3**
- fix mysql command again!

**7.3.1-2**
- fix mysql server status check

**7.3.1-1**
- plug bash vulnerability by switching to dash shell
- automatically run the `gitlab:setup` rake task for new installs

**7.3.1**
- upgrade to gitlab-ce 7.3.1

**7.3.0**
- upgrade to gitlab-ce 7.3.0
- added GITLAB_WEBHOOK_TIMEOUT configuration option
- upgrade to gitlab-shell 2.0.0
- removed internal redis server
- shutdown the container gracefully

**7.2.2**
- upgrade to gitlab-ce 7.2.2
- added GITLAB_HTTPS_HSTS_ENABLED configuration option (advanced config)
- added GITLAB_HTTPS_HSTS_MAXAGE configuration option (advanced config)
- upgrade to gitlab-shell 1.9.8
- purge development packages after install. shaves off ~300MB from the image.
- rebase image on sameersbn/debian:jessie.20140918 base image
- added GITLAB_SSH_HOST configuration option
- added GITLAB_USERNAME_CHANGE configuration option

**7.2.1-1**
- removed the GITLAB_HTTPS_ONLY configuration option
- added NGINX_X_FORWARDED_PROTO configuration option
- optimization: talk directly to the unicorn worker from gitlab-shell

**7.2.1**
- upgrade to gitlab-ce 7.2.1
- added new SMTP_ENABLED configuration option.

**7.2.0-1**
- fix nginx static route handling when GITLAB_RELATIVE_URL_ROOT is used.
- fix relative root access without the trailing '/' character
- added seperate server block for http config in gitlab.https.permissive. Fixes #127
- added OAUTH_GOOGLE_RESTRICT_DOMAIN config option.

**7.2.0**
- upgrade to gitlab-ce 7.2.0
- update to the sameersbn/ubuntu:14.04.20140818 baseimage
- remove /var/lib/apt/lists to optimize image size.
- disable UsePrivilegeSeparation in sshd configuration, fixes #122
- added OAUTH_BLOCK_AUTO_CREATED_USERS configuration option
- added OAUTH_ALLOW_SSO configuration option
- added github oauth configuration support
- added twitter oauth configuration support
- added google oauth configuration support
- added support for jira issue tracker
- added support for redmine issue tracker
- update to gitlab-shell 1.9.7
- update to the sameersbn/ubuntu:14.04.20140812 baseimage

**7.1.1**
- removed "add_header X-Frame-Options DENY" setting from the nginx config. fixes #110
- upgrade to gitlab-ce 7.1.1
- run /etc/init.d/gitlab as git user, plays nicely with selinux

**7.1.0**
- removed GITLAB_SUPPORT configuration option
- upgrade to gitlab-ce 7.1.0
- clone gitlab-ce and gitlab-shell sources from the git repo.
- disable pam authentication module in sshd
- update to the sameersbn/ubuntu:14.04.20140628 baseimage
- no more root access over ssh, use nsenter instead
- upgrade to nginx-1.6.x series from the nginx/stable ppa

**7.0.0**
- upgrade to gitlab-7.0.0
- fix repository and gitlab-satellites directory permissions.
- added GITLAB_RESTRICTED_VISIBILITY configuration option
- fix backup restore operation
- upgrade to gitlab-shell 1.9.6
- added app:sanitize command
- automatically migrate database when gitlab version is updated
- upgrade to gitlab-shell 1.9.5

**6.9.2**
- upgrade to gitlab-ce 6.9.2

**6.9.1**
- upgrade to gitlab-ce 6.9.1

**6.9.0**
- upgrade to gitlab-ce 6.9.0
- added GITLAB_RELATIVE_URL_ROOT configuration option
- added NGINX_MAX_UPLOAD_SIZE configuration to specify the maximum acceptable size of attachments.

**6.8.2**
- upgrade to gitlab-ce 6.8.2
- renamed configuration option GITLAB_SHELL_SSH_PORT to GITLAB_SSH_PORT
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
