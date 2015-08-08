#!/bin/bash
set -e

[[ -n $DEBUG_ENTRYPOINT ]] && set -x

SYSCONF_TEMPLATES_DIR="${SETUP_DIR}/config"
USERCONF_TEMPLATES_DIR="${GITLAB_DATA_DIR}/config"

GITLAB_BACKUP_DIR="${GITLAB_BACKUP_DIR:-$GITLAB_DATA_DIR/backups}"
GITLAB_REPOS_DIR="${GITLAB_REPOS_DIR:-$GITLAB_DATA_DIR/repositories}"
GITLAB_HOST=${GITLAB_HOST:-localhost}
GITLAB_PORT=${GITLAB_PORT:-}
GITLAB_SSH_HOST=${GITLAB_SSH_HOST:-$GITLAB_HOST}
GITLAB_SSH_PORT=${GITLAB_SSH_PORT:-$GITLAB_SHELL_SSH_PORT} # for backwards compatibility
GITLAB_SSH_PORT=${GITLAB_SSH_PORT:-22}
GITLAB_HTTPS=${GITLAB_HTTPS:-false}
GITLAB_EMAIL=${GITLAB_EMAIL:-example@example.com}
GITLAB_EMAIL_DISPLAY_NAME=${GITLAB_EMAIL_DISPLAY_NAME:-GitLab}
GITLAB_EMAIL_REPLY_TO=${GITLAB_EMAIL_REPLY_TO:-noreply@example.com}
GITLAB_TIMEZONE=${GITLAB_TIMEZONE:-UTC}
GITLAB_USERNAME_CHANGE=${GITLAB_USERNAME_CHANGE:-true}
GITLAB_CREATE_GROUP=${GITLAB_CREATE_GROUP:-true}
GITLAB_PROJECTS_ISSUES=${GITLAB_PROJECTS_ISSUES:-true}
GITLAB_PROJECTS_MERGE_REQUESTS=${GITLAB_PROJECTS_MERGE_REQUESTS:-true}
GITLAB_PROJECTS_WIKI=${GITLAB_PROJECTS_WIKI:-true}
GITLAB_PROJECTS_SNIPPETS=${GITLAB_PROJECTS_SNIPPETS:-false}
GITLAB_RELATIVE_URL_ROOT=${GITLAB_RELATIVE_URL_ROOT:-}
GITLAB_WEBHOOK_TIMEOUT=${GITLAB_WEBHOOK_TIMEOUT:-10}
GITLAB_SATELLITES_TIMEOUT=${GITLAB_SATELLITES_TIMEOUT:-30}
GITLAB_TIMEOUT=${GITLAB_TIMEOUT:-10}

SSL_SELF_SIGNED=${SSL_SELF_SIGNED:-false}
SSL_CERTIFICATE_PATH=${SSL_CERTIFICATE_PATH:-$GITLAB_DATA_DIR/certs/gitlab.crt}
SSL_KEY_PATH=${SSL_KEY_PATH:-$GITLAB_DATA_DIR/certs/gitlab.key}
SSL_DHPARAM_PATH=${SSL_DHPARAM_PATH:-$GITLAB_DATA_DIR/certs/dhparam.pem}
SSL_VERIFY_CLIENT=${SSL_VERIFY_CLIENT:-off}

CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$GITLAB_DATA_DIR/certs/ca.crt}

GITLAB_BACKUPS=${GITLAB_BACKUPS:-disable}
GITLAB_BACKUP_TIME=${GITLAB_BACKUP_TIME:-04:00}
GITLAB_BACKUP_EXPIRY=${GITLAB_BACKUP_EXPIRY:-}

AWS_BACKUPS=${AWS_BACKUPS:-false}
AWS_BACKUP_REGION=${AWS_BACKUP_REGION}
AWS_BACKUP_ACCESS_KEY_ID=${AWS_BACKUP_ACCESS_KEY_ID}
AWS_BACKUP_SECRET_ACCESS_KEY=${AWS_BACKUP_SECRET_ACCESS_KEY}
AWS_BACKUP_BUCKET=${AWS_BACKUP_BUCKET}

NGINX_WORKERS=${NGINX_WORKERS:-1}
NGINX_ACCEL_BUFFERING=${NGINX_ACCEL_BUFFERING:-no}
NGINX_PROXY_BUFFERING=${NGINX_PROXY_BUFFERING:-off}
NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-20m}
GITLAB_MAX_SIZE=$(echo $NGINX_MAX_UPLOAD_SIZE |sed -e "s/^ *\([0-9]*\)[mMkKgG] *$/\1/g" )
case "$NGINX_MAX_UPLOAD_SIZE" in
  *[kK] ) GITLAB_MAX_SIZE=$(($GITLAB_MAX_SIZE * 1024));;
  *[mM] ) GITLAB_MAX_SIZE=$(($GITLAB_MAX_SIZE * 1048576));;
  *[gG] ) GITLAB_MAX_SIZE=$(($GITLAB_MAX_SIZE * 1073741824));;
esac

REDIS_HOST=${REDIS_HOST:-}
REDIS_PORT=${REDIS_PORT:-}

UNICORN_WORKERS=${UNICORN_WORKERS:-3}
UNICORN_TIMEOUT=${UNICORN_TIMEOUT:-60}

SIDEKIQ_SHUTDOWN_TIMEOUT=${SIDEKIQ_SHUTDOWN_TIMEOUT:-4}
SIDEKIQ_CONCURRENCY=${SIDEKIQ_CONCURRENCY:-25}
SIDEKIQ_MEMORY_KILLER_MAX_RSS=${SIDEKIQ_MEMORY_KILLER_MAX_RSS:-1000000}

DB_TYPE=${DB_TYPE:-}
DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-}
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}
DB_POOL=${DB_POOL:-10}

SMTP_DOMAIN=${SMTP_DOMAIN:-www.gmail.com}
SMTP_HOST=${SMTP_HOST:-smtp.gmail.com}
SMTP_PORT=${SMTP_PORT:-587}
SMTP_USER=${SMTP_USER:-}
SMTP_PASS=${SMTP_PASS:-}
SMTP_OPENSSL_VERIFY_MODE=${SMTP_OPENSSL_VERIFY_MODE:-none}
SMTP_STARTTLS=${SMTP_STARTTLS:-true}
SMTP_TLS=${SMTP_TLS:-false}
SMTP_CA_ENABLED=${SMTP_CA_ENABLED:-false}
SMTP_CA_PATH=${SMTP_CA_PATH:-$GITLAB_DATA_DIR/certs}
SMTP_CA_FILE=${SMTP_CA_FILE:-$GITLAB_DATA_DIR/certs/ca.crt}
if [[ -n ${SMTP_USER} ]]; then
  SMTP_ENABLED=${SMTP_ENABLED:-true}
  SMTP_AUTHENTICATION=${SMTP_AUTHENTICATION:-login}
fi
SMTP_ENABLED=${SMTP_ENABLED:-false}
GITLAB_EMAIL_ENABLED=${GITLAB_EMAIL_ENABLED:-$SMTP_ENABLED}

LDAP_ENABLED=${LDAP_ENABLED:-false}
LDAP_HOST=${LDAP_HOST:-}
LDAP_PORT=${LDAP_PORT:-389}
LDAP_UID=${LDAP_UID:-sAMAccountName}
LDAP_METHOD=${LDAP_METHOD:-plain}
LDAP_BIND_DN=${LDAP_BIND_DN:-}
LDAP_PASS=${LDAP_PASS:-}
LDAP_ACTIVE_DIRECTORY=${LDAP_ACTIVE_DIRECTORY:-true}
LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN=${LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN:-}
LDAP_BLOCK_AUTO_CREATED_USERS=${LDAP_BLOCK_AUTO_CREATED_USERS:-false}
LDAP_BASE=${LDAP_BASE:-}
LDAP_USER_FILTER=${LDAP_USER_FILTER:-}
LDAP_LABEL=${LDAP_LABEL:-LDAP}

GITLAB_HTTPS_HSTS_ENABLED=${GITLAB_HTTPS_HSTS_ENABLED:-true}
GITLAB_HTTPS_HSTS_MAXAGE=${GITLAB_HTTPS_HSTS_MAXAGE:-31536000}

GITLAB_GRAVATAR_ENABLED=${GITLAB_GRAVATAR_ENABLED:-true}
GITLAB_GRAVATAR_HTTP_URL=${GITLAB_GRAVATAR_HTTP_URL:-}
GITLAB_GRAVATAR_HTTPS_URL=${GITLAB_GRAVATAR_HTTPS_URL:-}

OAUTH_ENABLED=${OAUTH_ENABLED:-}
OAUTH_AUTO_SIGN_IN_WITH_PROVIDER=${OAUTH_AUTO_SIGN_IN_WITH_PROVIDER:-}
OAUTH_ALLOW_SSO=${OAUTH_ALLOW_SSO:-false}
OAUTH_BLOCK_AUTO_CREATED_USERS=${OAUTH_BLOCK_AUTO_CREATED_USERS:-true}
OAUTH_AUTO_LINK_LDAP_USER=${OAUTH_AUTO_LINK_LDAP_USER:-false}

OAUTH_GOOGLE_API_KEY=${OAUTH_GOOGLE_API_KEY:-}
OAUTH_GOOGLE_APP_SECRET=${OAUTH_GOOGLE_APP_SECRET:-}

OAUTH_TWITTER_API_KEY=${OAUTH_TWITTER_API_KEY:-}
OAUTH_TWITTER_APP_SECRET=${OAUTH_TWITTER_APP_SECRET:-}

OAUTH_GITHUB_API_KEY=${OAUTH_GITHUB_API_KEY:-}
OAUTH_GITHUB_APP_SECRET=${OAUTH_GITHUB_APP_SECRET:-}

OAUTH_GITLAB_API_KEY=${OAUTH_GITLAB_API_KEY:-}
OAUTH_GITLAB_APP_SECRET=${OAUTH_GITLAB_APP_SECRET:-}

OAUTH_BITBUCKET_API_KEY=${OAUTH_BITBUCKET_API_KEY:-}
OAUTH_BITBUCKET_APP_SECRET=${OAUTH_BITBUCKET_APP_SECRET:-}

case $GITLAB_HTTPS in
  true)
    OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL=${OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL:-https://${GITLAB_HOST}/users/auth/saml/callback}
    OAUTH_SAML_ISSUER=${OAUTH_SAML_ISSUER:-https://${GITLAB_HOST}}
    ;;
  false)
    OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL=${OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL:-http://${GITLAB_HOST}/users/auth/saml/callback}
    OAUTH_SAML_ISSUER=${OAUTH_SAML_ISSUER:-http://${GITLAB_HOST}}
    ;;
esac
OAUTH_SAML_IDP_CERT_FINGERPRINT=${OAUTH_SAML_IDP_CERT_FINGERPRINT:-}
OAUTH_SAML_IDP_SSO_TARGET_URL=${OAUTH_SAML_IDP_SSO_TARGET_URL:-}
OAUTH_SAML_NAME_IDENTIFIER_FORMAT=${OAUTH_SAML_NAME_IDENTIFIER_FORMAT:-urn:oasis:names:tc:SAML:2.0:nameid-format:transient}

GOOGLE_ANALYTICS_ID=${GOOGLE_ANALYTICS_ID:-}

PIWIK_URL=${PIWIK_URL:-}
PIWIK_SITE_ID=${PIWIK_SITE_ID:-}

GITLAB_ROBOTS_OVERRIDE=${GITLAB_ROBOTS_OVERRIDE:-false}
GITLAB_ROBOTS_PATH=${GITLAB_ROBOTS_PATH:-$SYSCONF_TEMPLATES_DIR/gitlabhq/robots.txt}

# is a mysql or postgresql database linked?
# requires that the mysql or postgresql containers have exposed
# port 3306 and 5432 respectively.
if [[ -n ${MYSQL_PORT_3306_TCP_ADDR} ]]; then
  DB_TYPE=${DB_TYPE:-mysql}
  DB_HOST=${DB_HOST:-${MYSQL_PORT_3306_TCP_ADDR}}
  DB_PORT=${DB_PORT:-${MYSQL_PORT_3306_TCP_PORT}}

  # support for linked sameersbn/mysql image
  DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
  DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
  DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}

  # support for linked orchardup/mysql and enturylink/mysql image
  # also supports official mysql image
  DB_USER=${DB_USER:-${MYSQL_ENV_MYSQL_USER}}
  DB_PASS=${DB_PASS:-${MYSQL_ENV_MYSQL_PASSWORD}}
  DB_NAME=${DB_NAME:-${MYSQL_ENV_MYSQL_DATABASE}}
elif [[ -n ${POSTGRESQL_PORT_5432_TCP_ADDR} ]]; then
  DB_TYPE=${DB_TYPE:-postgres}
  DB_HOST=${DB_HOST:-${POSTGRESQL_PORT_5432_TCP_ADDR}}
  DB_PORT=${DB_PORT:-${POSTGRESQL_PORT_5432_TCP_PORT}}

  # support for linked official postgres image
  DB_USER=${DB_USER:-${POSTGRESQL_ENV_POSTGRES_USER}}
  DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_POSTGRES_PASSWORD}}
  DB_NAME=${DB_NAME:-${DB_USER}}

  # support for linked sameersbn/postgresql image
  DB_USER=${DB_USER:-${POSTGRESQL_ENV_DB_USER}}
  DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_DB_PASS}}
  DB_NAME=${DB_NAME:-${POSTGRESQL_ENV_DB_NAME}}

  # support for linked orchardup/postgresql image
  DB_USER=${DB_USER:-${POSTGRESQL_ENV_POSTGRESQL_USER}}
  DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_POSTGRESQL_PASS}}
  DB_NAME=${DB_NAME:-${POSTGRESQL_ENV_POSTGRESQL_DB}}

  # support for linked paintedfox/postgresql image
  DB_USER=${DB_USER:-${POSTGRESQL_ENV_USER}}
  DB_PASS=${DB_PASS:-${POSTGRESQL_ENV_PASS}}
  DB_NAME=${DB_NAME:-${POSTGRESQL_ENV_DB}}
fi

if [[ -z ${DB_HOST} ]]; then
  echo "ERROR: "
  echo "  Please configure the database connection."
  echo "  Refer http://git.io/wkYhyA for more information."
  echo "  Cannot continue without a database. Aborting..."
  exit 1
fi

# use default port number if it is still not set
case ${DB_TYPE} in
  mysql) DB_PORT=${DB_PORT:-3306} ;;
  postgres) DB_PORT=${DB_PORT:-5432} ;;
  *)
    echo "ERROR: "
    echo "  Please specify the database type in use via the DB_TYPE configuration option."
    echo "  Accepted values are \"postgres\" or \"mysql\". Aborting..."
    exit 1
    ;;
esac

# set default user and database
DB_USER=${DB_USER:-root}
DB_NAME=${DB_NAME:-gitlabhq_production}

# is a redis container linked?
if [[ -n ${REDISIO_PORT_6379_TCP_ADDR} ]]; then
  REDIS_HOST=${REDIS_HOST:-${REDISIO_PORT_6379_TCP_ADDR}}
  REDIS_PORT=${REDIS_PORT:-${REDISIO_PORT_6379_TCP_PORT}}
fi

# fallback to default redis port
REDIS_PORT=${REDIS_PORT:-6379}

if [[ -z ${REDIS_HOST} ]]; then
  echo "ERROR: "
  echo "  Please configure the redis connection."
  echo "  Refer http://git.io/PMnRSw for more information."
  echo "  Cannot continue without a redis connection. Aborting..."
  exit 1
fi

case ${GITLAB_HTTPS} in
  true)
    GITLAB_PORT=${GITLAB_PORT:-443}
    NGINX_X_FORWARDED_PROTO=${NGINX_X_FORWARDED_PROTO:-https}
    ;;
  *)
    GITLAB_PORT=${GITLAB_PORT:-80}
    NGINX_X_FORWARDED_PROTO=${NGINX_X_FORWARDED_PROTO:-\$scheme}
    ;;
esac

case ${GITLAB_BACKUPS} in
  daily|weekly|monthly) GITLAB_BACKUP_EXPIRY=${GITLAB_BACKUP_EXPIRY:-604800} ;;
  disable|*) GITLAB_BACKUP_EXPIRY=${GITLAB_BACKUP_EXPIRY:-0} ;;
esac

case ${LDAP_UID} in
  userPrincipalName) LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN=${LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN:-false} ;;
  *) LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN=${LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN:-true}
esac

## Adapt uid and gid for ${GITLAB_USER}:${GITLAB_USER}
USERMAP_ORIG_UID=$(id -u ${GITLAB_USER})
USERMAP_ORIG_GID=$(id -g ${GITLAB_USER})
USERMAP_GID=${USERMAP_GID:-${USERMAP_UID:-$USERMAP_ORIG_GID}}
USERMAP_UID=${USERMAP_UID:-$USERMAP_ORIG_UID}
if [[ ${USERMAP_UID} != ${USERMAP_ORIG_UID} ]] || [[ ${USERMAP_GID} != ${USERMAP_ORIG_GID} ]]; then
  echo "Adapting uid and gid for ${GITLAB_USER}:${GITLAB_USER} to $USERMAP_UID:$USERMAP_GID"
  groupmod -g ${USERMAP_GID} ${GITLAB_USER}
  sed -i -e "s/:${USERMAP_ORIG_UID}:${USERMAP_GID}:/:${USERMAP_UID}:${USERMAP_GID}:/" /etc/passwd
  find ${GITLAB_HOME} -path ${GITLAB_DATA_DIR}/\* -prune -o -print0 | xargs -0 chown -h ${GITLAB_USER}:${GITLAB_USER}
fi

if [[ ! -e ${GITLAB_DATA_DIR}/ssh/ssh_host_rsa_key ]]; then
  # create ssh host keys and move them to the data store.
  dpkg-reconfigure openssh-server
  mkdir -p ${GITLAB_DATA_DIR}/ssh/
  mv /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub ${GITLAB_DATA_DIR}/ssh/
fi

## fix permissions of ssh key files
chmod 0600 ${GITLAB_DATA_DIR}/ssh/*_key
chmod 0644 ${GITLAB_DATA_DIR}/ssh/*.pub
chown -R root:root ${GITLAB_DATA_DIR}/ssh

# configure sshd to pick up the host keys from ${GITLAB_DATA_DIR}/ssh/
sed -i 's,HostKey /etc/ssh/,HostKey '"${GITLAB_DATA_DIR}"'/ssh/,g' -i /etc/ssh/sshd_config

# populate ${GITLAB_LOG_DIR}
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/supervisor   && chown -R root:root ${GITLAB_LOG_DIR}/supervisor
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/nginx        && chown -R ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_LOG_DIR}/nginx
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/gitlab       && chown -R ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_LOG_DIR}/gitlab
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/gitlab-shell && chown -R ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_LOG_DIR}/gitlab-shell

cd ${GITLAB_INSTALL_DIR}

# copy configuration templates
case ${GITLAB_HTTPS} in
  true)
    if [[ -f ${SSL_CERTIFICATE_PATH} && -f ${SSL_KEY_PATH} && -f ${SSL_DHPARAM_PATH} ]]; then
      cp ${SYSCONF_TEMPLATES_DIR}/nginx/gitlab-ssl /etc/nginx/sites-enabled/gitlab
    else
      echo "SSL keys and certificates were not found."
      echo "Assuming that the container is running behind a HTTPS enabled load balancer."
      cp ${SYSCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab
    fi
    ;;
  *) cp ${SYSCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab ;;
esac

sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlab-shell/config.yml    ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/gitlab.yml        config/gitlab.yml
sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/resque.yml        config/resque.yml
sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/database.yml      config/database.yml
sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/unicorn.rb        config/unicorn.rb
sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/rack_attack.rb    config/initializers/rack_attack.rb
[[ ${SMTP_ENABLED} == true ]] && \
sudo -HEu ${GITLAB_USER} cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/smtp_settings.rb  config/initializers/smtp_settings.rb

# allow to override robots.txt to block bots
[[ ${GITLAB_ROBOTS_OVERRIDE} == true ]] && \
sudo -HEu ${GITLAB_USER} cp ${GITLAB_ROBOTS_PATH} public/robots.txt

# override default configuration templates with user templates
case ${GITLAB_HTTPS} in
  true)
    if [[ -f ${SSL_CERTIFICATE_PATH} && -f ${SSL_KEY_PATH} && -f ${SSL_DHPARAM_PATH} ]]; then
      [[ -f ${USERCONF_TEMPLATES_DIR}/nginx/gitlab-ssl ]] && cp ${USERCONF_TEMPLATES_DIR}/nginx/gitlab-ssl /etc/nginx/sites-enabled/gitlab
    else
      [[ -f ${USERCONF_TEMPLATES_DIR}/nginx/gitlab ]] && cp ${USERCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab
    fi
    ;;
  *) [[ -f ${USERCONF_TEMPLATES_DIR}/nginx/gitlab ]] && cp ${USERCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab ;;
esac

[[ -f ${USERCONF_TEMPLATES_DIR}/gitlab-shell/config.yml ]]   && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlab-shell/config.yml   ${GITLAB_SHELL_INSTALL_DIR}/config.yml
[[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/gitlab.yml ]]       && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/gitlab.yml       config/gitlab.yml
[[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/resque.yml ]]       && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/resque.yml       config/resque.yml
[[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/database.yml ]]     && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/database.yml     config/database.yml
[[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/unicorn.rb ]]       && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/unicorn.rb       config/unicorn.rb
[[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/rack_attack.rb ]]   && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/rack_attack.rb   config/initializers/rack_attack.rb
[[ ${SMTP_ENABLED} == true ]] && \
[[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/smtp_settings.rb ]] && sudo -HEu ${GITLAB_USER} cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/smtp_settings.rb config/initializers/smtp_settings.rb

if [[ -f ${SSL_CERTIFICATE_PATH} || -f ${CA_CERTIFICATES_PATH} ]]; then
  echo "Updating CA certificates..."
  [[ -f ${SSL_CERTIFICATE_PATH} ]] && cp "${SSL_CERTIFICATE_PATH}" /usr/local/share/ca-certificates/gitlab.crt
  [[ -f ${CA_CERTIFICATES_PATH} ]] && cp "${CA_CERTIFICATES_PATH}" /usr/local/share/ca-certificates/ca.crt
  update-ca-certificates --fresh >/dev/null
fi

# configure application paths
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_DATA_DIR}},'"${GITLAB_DATA_DIR}"',g' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_BACKUP_DIR}},'"${GITLAB_BACKUP_DIR}"',g' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_REPOS_DIR}},'"${GITLAB_REPOS_DIR}"',g' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_INSTALL_DIR}},'"${GITLAB_INSTALL_DIR}"',g' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_SHELL_INSTALL_DIR}},'"${GITLAB_SHELL_INSTALL_DIR}"',g' -i config/gitlab.yml

# configure gitlab
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_HOST}}/'"${GITLAB_HOST}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_PORT}}/'"${GITLAB_PORT}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_HTTPS}}/'"${GITLAB_HTTPS}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_EMAIL}}/'"${GITLAB_EMAIL}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_EMAIL_DISPLAY_NAME}}/'"${GITLAB_EMAIL_DISPLAY_NAME}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_EMAIL_REPLY_TO}}/'"${GITLAB_EMAIL_REPLY_TO}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_BACKUP_EXPIRY}}/'"${GITLAB_BACKUP_EXPIRY}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_MAX_SIZE}}/'"${GITLAB_MAX_SIZE}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_SSH_HOST}}/'"${GITLAB_SSH_HOST}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_SSH_PORT}}/'"${GITLAB_SSH_PORT}"'/' -i config/gitlab.yml

# configure default timezone
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_TIMEZONE}}/'"${GITLAB_TIMEZONE}"'/' -i config/gitlab.yml

# configure gitlab username_changing_enabled
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_USERNAME_CHANGE}}/'"${GITLAB_USERNAME_CHANGE}"'/' -i config/gitlab.yml

# configure gitlab default_can_create_group
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_CREATE_GROUP}}/'"${GITLAB_CREATE_GROUP}"'/' -i config/gitlab.yml

# configure gitlab default project feature: issues
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_PROJECTS_ISSUES}}/'"${GITLAB_PROJECTS_ISSUES}"'/' -i config/gitlab.yml

# configure gitlab default project feature: merge_requests
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_PROJECTS_MERGE_REQUESTS}}/'"${GITLAB_PROJECTS_MERGE_REQUESTS}"'/' -i config/gitlab.yml

# configure gitlab default project feature: wiki
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_PROJECTS_WIKI}}/'"${GITLAB_PROJECTS_WIKI}"'/' -i config/gitlab.yml

# configure gitlab default project feature: snippets
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_PROJECTS_SNIPPETS}}/'"${GITLAB_PROJECTS_SNIPPETS}"'/' -i config/gitlab.yml

# configure gitlab webhook timeout
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_WEBHOOK_TIMEOUT}}/'"${GITLAB_WEBHOOK_TIMEOUT}"'/' -i config/gitlab.yml

# configure gitlab satellite timeout
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_SATELLITES_TIMEOUT}}/'"${GITLAB_SATELLITES_TIMEOUT}"'/' -i config/gitlab.yml

# configure git timeout
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_TIMEOUT}}/'"${GITLAB_TIMEOUT}"'/' -i config/gitlab.yml

# configure database
if [[ ${DB_TYPE} == postgres ]]; then
  sudo -HEu ${GITLAB_USER} sed 's/{{DB_ADAPTER}}/postgresql/' -i config/database.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{DB_ENCODING}}/unicode/' -i config/database.yml
  sudo -HEu ${GITLAB_USER} sed '/reconnect: /d' -i config/database.yml
  sudo -HEu ${GITLAB_USER} sed '/collation: /d' -i config/database.yml
elif [[ ${DB_TYPE} == mysql ]]; then
  sudo -HEu ${GITLAB_USER} sed 's/{{DB_ADAPTER}}/mysql2/' -i config/database.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{DB_ENCODING}}/utf8/' -i config/database.yml
else
  echo "Invalid database type: '$DB_TYPE'. Supported choices: [mysql, postgres]."
fi

# configure database connection
sudo -HEu ${GITLAB_USER} sed 's/{{DB_HOST}}/'"${DB_HOST}"'/' -i config/database.yml
sudo -HEu ${GITLAB_USER} sed 's/{{DB_PORT}}/'"${DB_PORT}"'/' -i config/database.yml
sudo -HEu ${GITLAB_USER} sed 's/{{DB_NAME}}/'"${DB_NAME}"'/' -i config/database.yml
sudo -HEu ${GITLAB_USER} sed 's/{{DB_USER}}/'"${DB_USER}"'/' -i config/database.yml
sudo -HEu ${GITLAB_USER} sed 's/{{DB_PASS}}/'"${DB_PASS}"'/' -i config/database.yml
sudo -HEu ${GITLAB_USER} sed 's/{{DB_POOL}}/'"${DB_POOL}"'/' -i config/database.yml

# configure sidekiq concurrency
sed 's/{{SIDEKIQ_CONCURRENCY}}/'"${SIDEKIQ_CONCURRENCY}"'/' -i /etc/supervisor/conf.d/sidekiq.conf

# configure sidekiq shutdown timeout
sed 's/{{SIDEKIQ_SHUTDOWN_TIMEOUT}}/'"${SIDEKIQ_SHUTDOWN_TIMEOUT}"'/' -i /etc/supervisor/conf.d/sidekiq.conf

# enable SidekiqMemoryKiller
## The MemoryKiller is enabled by gitlab if the `SIDEKIQ_MEMORY_KILLER_MAX_RSS` is
## defined in the programs environment and has a non-zero value.
##
## Simply exporting the variable makes it available in the programs environment and
## therefore should enable the MemoryKiller.
##
## Every other MemoryKiller option specified in the docker env will automatically
## be exported, so why bother
export SIDEKIQ_MEMORY_KILLER_MAX_RSS

# configure redis
sudo -HEu ${GITLAB_USER} sed 's/{{REDIS_HOST}}/'"${REDIS_HOST}"'/g' -i config/resque.yml
sudo -HEu ${GITLAB_USER} sed 's/{{REDIS_PORT}}/'"${REDIS_PORT}"'/g' -i config/resque.yml

# configure gitlab-shell
sed 's,{{GITLAB_RELATIVE_URL_ROOT}},'"${GITLAB_RELATIVE_URL_ROOT}"',' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_HOME}},'"${GITLAB_HOME}"',g' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_LOG_DIR}},'"${GITLAB_LOG_DIR}"',g' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_DATA_DIR}},'"${GITLAB_DATA_DIR}"',g' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_BACKUP_DIR}},'"${GITLAB_BACKUP_DIR}"',g' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_REPOS_DIR}},'"${GITLAB_REPOS_DIR}"',g' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_SHELL_INSTALL_DIR}},'"${GITLAB_SHELL_INSTALL_DIR}"',g' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's/{{SSL_SELF_SIGNED}}/'"${SSL_SELF_SIGNED}"'/' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's/{{REDIS_HOST}}/'"${REDIS_HOST}"'/' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -HEu ${GITLAB_USER} sed 's/{{REDIS_PORT}}/'"${REDIS_PORT}"'/' -i ${GITLAB_SHELL_INSTALL_DIR}/config.yml

# configure unicorn workers
sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_INSTALL_DIR}},'"${GITLAB_INSTALL_DIR}"',g' -i config/unicorn.rb
sudo -HEu ${GITLAB_USER} sed 's/{{UNICORN_WORKERS}}/'"${UNICORN_WORKERS}"'/' -i config/unicorn.rb

# configure unicorn timeout
sudo -HEu ${GITLAB_USER} sed 's/{{UNICORN_TIMEOUT}}/'"${UNICORN_TIMEOUT}"'/' -i config/unicorn.rb

# configure mail delivery
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_EMAIL_ENABLED}}/'"${GITLAB_EMAIL_ENABLED}"'/' -i config/gitlab.yml
if [[ ${SMTP_ENABLED} == true ]]; then
  sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_HOST}}/'"${SMTP_HOST}"'/' -i config/initializers/smtp_settings.rb
  sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_PORT}}/'"${SMTP_PORT}"'/' -i config/initializers/smtp_settings.rb

  case ${SMTP_USER} in
    "") sudo -HEu ${GITLAB_USER} sed '/{{SMTP_USER}}/d' -i config/initializers/smtp_settings.rb ;;
    *) sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_USER}}/'"${SMTP_USER}"'/' -i config/initializers/smtp_settings.rb ;;
  esac

  case ${SMTP_PASS} in
    "") sudo -HEu ${GITLAB_USER} sed '/{{SMTP_PASS}}/d' -i config/initializers/smtp_settings.rb ;;
    *) sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_PASS}}/'"${SMTP_PASS}"'/' -i config/initializers/smtp_settings.rb ;;
  esac

  sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_DOMAIN}}/'"${SMTP_DOMAIN}"'/' -i config/initializers/smtp_settings.rb
  sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_STARTTLS}}/'"${SMTP_STARTTLS}"'/' -i config/initializers/smtp_settings.rb
  sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_TLS}}/'"${SMTP_TLS}"'/' -i config/initializers/smtp_settings.rb
  sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_OPENSSL_VERIFY_MODE}}/'"${SMTP_OPENSSL_VERIFY_MODE}"'/' -i config/initializers/smtp_settings.rb

  case ${SMTP_AUTHENTICATION} in
    "") sudo -HEu ${GITLAB_USER} sed '/{{SMTP_AUTHENTICATION}}/d' -i config/initializers/smtp_settings.rb ;;
    *) sudo -HEu ${GITLAB_USER} sed 's/{{SMTP_AUTHENTICATION}}/'"${SMTP_AUTHENTICATION}"'/' -i config/initializers/smtp_settings.rb ;;
  esac

  if [[ ${SMTP_CA_ENABLED} == true ]]; then
    if [[ -d ${SMTP_CA_PATH} ]]; then
      sudo -HEu ${GITLAB_USER} sed 's,{{SMTP_CA_PATH}},'"${SMTP_CA_PATH}"',' -i config/initializers/smtp_settings.rb
    fi

    if [[ -f ${SMTP_CA_FILE} ]]; then
      sudo -HEu ${GITLAB_USER} sed 's,{{SMTP_CA_FILE}},'"${SMTP_CA_FILE}"',' -i config/initializers/smtp_settings.rb
    fi
  else
    sudo -HEu ${GITLAB_USER} sed '/{{SMTP_CA_PATH}}/d' -i config/initializers/smtp_settings.rb
    sudo -HEu ${GITLAB_USER} sed '/{{SMTP_CA_FILE}}/d' -i config/initializers/smtp_settings.rb
  fi
fi

# apply LDAP configuration
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_ENABLED}}/'"${LDAP_ENABLED}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_HOST}}/'"${LDAP_HOST}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_PORT}}/'"${LDAP_PORT}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_UID}}/'"${LDAP_UID}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_METHOD}}/'"${LDAP_METHOD}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_BIND_DN}}/'"${LDAP_BIND_DN}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_PASS}}/'"${LDAP_PASS}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_ACTIVE_DIRECTORY}}/'"${LDAP_ACTIVE_DIRECTORY}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN}}/'"${LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_BLOCK_AUTO_CREATED_USERS}}/'"${LDAP_BLOCK_AUTO_CREATED_USERS}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_BASE}}/'"${LDAP_BASE}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_USER_FILTER}}/'"${LDAP_USER_FILTER}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{LDAP_LABEL}}/'"${LDAP_LABEL}"'/' -i config/gitlab.yml

# apply aws s3 backup configuration
case ${AWS_BACKUPS} in
  true)
    if [[ -z ${AWS_BACKUP_REGION} || -z ${AWS_BACKUP_ACCESS_KEY_ID} || -z ${AWS_BACKUP_SECRET_ACCESS_KEY} || -z ${AWS_BACKUP_BUCKET} ]]; then
      printf "\nMissing AWS options. Aborting...\n"
      exit 1
    fi
    sudo -HEu ${GITLAB_USER} sed 's/{{AWS_BACKUP_REGION}}/'"${AWS_BACKUP_REGION}"'/' -i config/gitlab.yml
    sudo -HEu ${GITLAB_USER} sed 's/{{AWS_BACKUP_ACCESS_KEY_ID}}/'"${AWS_BACKUP_ACCESS_KEY_ID}"'/' -i config/gitlab.yml
    sudo -HEu ${GITLAB_USER} sed 's,{{AWS_BACKUP_SECRET_ACCESS_KEY}},'"${AWS_BACKUP_SECRET_ACCESS_KEY}"',' -i config/gitlab.yml
    sudo -HEu ${GITLAB_USER} sed 's/{{AWS_BACKUP_BUCKET}}/'"${AWS_BACKUP_BUCKET}"'/' -i config/gitlab.yml
    ;;
  *)
    # remove backup configuration lines
    sudo -HEu ${GITLAB_USER} sed '/upload:/,/remote_directory:/d' -i config/gitlab.yml
    ;;
esac

# apply gravatar configuration
sudo -HEu ${GITLAB_USER} sed 's/{{GITLAB_GRAVATAR_ENABLED}}/'"${GITLAB_GRAVATAR_ENABLED}"'/' -i config/gitlab.yml
if [[ -n ${GITLAB_GRAVATAR_HTTP_URL} ]]; then
  GITLAB_GRAVATAR_HTTP_URL=$(echo "${GITLAB_GRAVATAR_HTTP_URL}" | sed 's/&/\\&/')  # escape ampersand for sed
  sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_GRAVATAR_HTTP_URL}},'"${GITLAB_GRAVATAR_HTTP_URL}"',g' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{GITLAB_GRAVATAR_HTTP_URL}}/d' -i config/gitlab.yml
fi
if [[ -n ${GITLAB_GRAVATAR_HTTPS_URL} ]]; then
  GITLAB_GRAVATAR_HTTPS_URL=$(echo "${GITLAB_GRAVATAR_HTTPS_URL}" | sed 's/&/\\&/')  # escape ampersand for sed
  sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_GRAVATAR_HTTPS_URL}},'"${GITLAB_GRAVATAR_HTTPS_URL}"',g' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{GITLAB_GRAVATAR_HTTPS_URL}}/d' -i config/gitlab.yml
fi

# apply oauth configuration

# google
if [[ -n ${OAUTH_GOOGLE_API_KEY} && -n ${OAUTH_GOOGLE_APP_SECRET} ]]; then
  OAUTH_ENABLED=true
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GOOGLE_API_KEY}}/'"${OAUTH_GOOGLE_API_KEY}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GOOGLE_APP_SECRET}}/'"${OAUTH_GOOGLE_APP_SECRET}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GOOGLE_RESTRICT_DOMAIN}}/'"${OAUTH_GOOGLE_RESTRICT_DOMAIN}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GOOGLE_APPROVAL_PROMPT}}//' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GOOGLE_API_KEY}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GOOGLE_APP_SECRET}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GOOGLE_RESTRICT_DOMAIN}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GOOGLE_APPROVAL_PROMPT}}/d' -i config/gitlab.yml
fi

# twitter
if [[ -n ${OAUTH_TWITTER_API_KEY} && -n ${OAUTH_TWITTER_APP_SECRET} ]]; then
  OAUTH_ENABLED=true
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_TWITTER_API_KEY}}/'"${OAUTH_TWITTER_API_KEY}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_TWITTER_APP_SECRET}}/'"${OAUTH_TWITTER_APP_SECRET}"'/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_TWITTER_API_KEY}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_TWITTER_APP_SECRET}}/d' -i config/gitlab.yml
fi

# github
if [[ -n ${OAUTH_GITHUB_API_KEY} && -n ${OAUTH_GITHUB_APP_SECRET} ]]; then
  OAUTH_ENABLED=true
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GITHUB_API_KEY}}/'"${OAUTH_GITHUB_API_KEY}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GITHUB_APP_SECRET}}/'"${OAUTH_GITHUB_APP_SECRET}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GITHUB_SCOPE}}/user:email/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GITHUB_API_KEY}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GITHUB_APP_SECRET}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GITHUB_SCOPE}}/d' -i config/gitlab.yml
fi

# gitlab
if [[ -n ${OAUTH_GITLAB_API_KEY} && -n ${OAUTH_GITLAB_APP_SECRET} ]]; then
  OAUTH_ENABLED=true
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GITLAB_API_KEY}}/'"${OAUTH_GITLAB_API_KEY}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GITLAB_APP_SECRET}}/'"${OAUTH_GITLAB_APP_SECRET}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_GITLAB_SCOPE}}/api/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GITLAB_API_KEY}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GITLAB_APP_SECRET}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_GITLAB_SCOPE}}/d' -i config/gitlab.yml
fi

# bitbucket
if [[ -n ${OAUTH_BITBUCKET_API_KEY} && -n ${OAUTH_BITBUCKET_APP_SECRET} ]]; then
  OAUTH_ENABLED=true
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_BITBUCKET_API_KEY}}/'"${OAUTH_BITBUCKET_API_KEY}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_BITBUCKET_APP_SECRET}}/'"${OAUTH_BITBUCKET_APP_SECRET}"'/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_BITBUCKET_API_KEY}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_BITBUCKET_APP_SECRET}}/d' -i config/gitlab.yml
fi

# saml
if [[ -n ${OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL} && \
      -n ${OAUTH_SAML_IDP_CERT_FINGERPRINT} && \
      -n ${OAUTH_SAML_IDP_SSO_TARGET_URL} && \
      -n ${OAUTH_SAML_ISSUER} && \
      -n ${OAUTH_SAML_NAME_IDENTIFIER_FORMAT} ]]; then
  OAUTH_ENABLED=true
  sudo -HEu ${GITLAB_USER} sed 's,{{OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL}},'"${OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL}"',' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_SAML_IDP_CERT_FINGERPRINT}}/'"${OAUTH_SAML_IDP_CERT_FINGERPRINT}"'/' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's,{{OAUTH_SAML_IDP_SSO_TARGET_URL}},'"${OAUTH_SAML_IDP_SSO_TARGET_URL}"',' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's,{{OAUTH_SAML_ISSUER}},'"${OAUTH_SAML_ISSUER}"',' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_SAML_NAME_IDENTIFIER_FORMAT}}/'"${OAUTH_SAML_NAME_IDENTIFIER_FORMAT}"'/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed "/name: 'saml'/,/name_identifier_format:/d" -i config/gitlab.yml
fi

# google analytics
if [[ -n ${GOOGLE_ANALYTICS_ID} ]]; then
  sudo -HEu ${GITLAB_USER} sed 's/{{GOOGLE_ANALYTICS_ID}}/'"${GOOGLE_ANALYTICS_ID}"'/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{GOOGLE_ANALYTICS_ID}}/d' -i config/gitlab.yml
fi

# piwik
if [[ -n ${PIWIK_URL} && -n ${PIWIK_SITE_ID} ]]; then
  sudo -HEu ${GITLAB_USER} sed 's,{{PIWIK_URL}},'"${PIWIK_URL}"',' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's/{{PIWIK_SITE_ID}}/'"${PIWIK_SITE_ID}"'/' -i config/gitlab.yml
else
  sudo -HEu ${GITLAB_USER} sed '/{{PIWIK_URL}}/d' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed '/{{PIWIK_SITE_ID}}/d' -i config/gitlab.yml
fi

OAUTH_ENABLED=${OAUTH_ENABLED:-false}
sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_ENABLED}}/'"${OAUTH_ENABLED}"'/' -i config/gitlab.yml

case $OAUTH_AUTO_SIGN_IN_WITH_PROVIDER in
  google_oauth2|twitter|github|gitlab|bitbucket|saml)
    sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_AUTO_SIGN_IN_WITH_PROVIDER}}/'"${OAUTH_AUTO_SIGN_IN_WITH_PROVIDER}"'/' -i config/gitlab.yml
    ;;
  *)
    sudo -HEu ${GITLAB_USER} sed '/{{OAUTH_AUTO_SIGN_IN_WITH_PROVIDER}}/d' -i config/gitlab.yml
    ;;
esac

sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_ALLOW_SSO}}/'"${OAUTH_ALLOW_SSO}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_BLOCK_AUTO_CREATED_USERS}}/'"${OAUTH_BLOCK_AUTO_CREATED_USERS}"'/' -i config/gitlab.yml
sudo -HEu ${GITLAB_USER} sed 's/{{OAUTH_AUTO_LINK_LDAP_USER}}/'"${OAUTH_AUTO_LINK_LDAP_USER}"'/' -i config/gitlab.yml

# configure nginx vhost
sed 's,{{GITLAB_INSTALL_DIR}},'"${GITLAB_INSTALL_DIR}"',g' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{GITLAB_LOG_DIR}},'"${GITLAB_LOG_DIR}"',g' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{YOUR_SERVER_FQDN}}/'"${GITLAB_HOST}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{GITLAB_PORT}}/'"${GITLAB_PORT}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{SSL_CERTIFICATE_PATH}},'"${SSL_CERTIFICATE_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{SSL_KEY_PATH}},'"${SSL_KEY_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{SSL_DHPARAM_PATH}},'"${SSL_DHPARAM_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{SSL_VERIFY_CLIENT}}/'"${SSL_VERIFY_CLIENT}"'/' -i /etc/nginx/sites-enabled/gitlab
if [[ -f ${CA_CERTIFICATES_PATH} ]]; then
  sed 's,{{CA_CERTIFICATES_PATH}},'"${CA_CERTIFICATES_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
else
  sed '/{{CA_CERTIFICATES_PATH}}/d' -i /etc/nginx/sites-enabled/gitlab
fi

sed 's/worker_processes .*/worker_processes '"${NGINX_WORKERS}"';/' -i /etc/nginx/nginx.conf
sed 's/{{NGINX_PROXY_BUFFERING}}/'"${NGINX_PROXY_BUFFERING}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{NGINX_ACCEL_BUFFERING}}/'"${NGINX_ACCEL_BUFFERING}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{NGINX_MAX_UPLOAD_SIZE}}/'"${NGINX_MAX_UPLOAD_SIZE}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{NGINX_X_FORWARDED_PROTO}}/'"${NGINX_X_FORWARDED_PROTO}"'/' -i /etc/nginx/sites-enabled/gitlab

if [[ ${GITLAB_HTTPS_HSTS_ENABLED} == true ]]; then
  sed 's/{{GITLAB_HTTPS_HSTS_MAXAGE}}/'"${GITLAB_HTTPS_HSTS_MAXAGE}"'/' -i /etc/nginx/sites-enabled/gitlab
else
  sed '/{{GITLAB_HTTPS_HSTS_MAXAGE}}/d' -i /etc/nginx/sites-enabled/gitlab
fi

# configure relative_url_root
if [[ -n ${GITLAB_RELATIVE_URL_ROOT} ]]; then
  sed 's,{{GITLAB_RELATIVE_URL_ROOT}},'"${GITLAB_RELATIVE_URL_ROOT}"',' -i /etc/nginx/sites-enabled/gitlab
  sed 's,{{GITLAB_RELATIVE_URL_ROOT__with_trailing_slash}},'"${GITLAB_RELATIVE_URL_ROOT}/"',' -i /etc/nginx/sites-enabled/gitlab
  sed 's,# alias '"${GITLAB_INSTALL_DIR}"'/public,alias '"${GITLAB_INSTALL_DIR}"'/public,' -i /etc/nginx/sites-enabled/gitlab

  sudo -HEu ${GITLAB_USER} sed 's,# config.relative_url_root = "/gitlab",config.relative_url_root = "'${GITLAB_RELATIVE_URL_ROOT}'",' -i config/application.rb
  sudo -HEu ${GITLAB_USER} sed 's,# relative_url_root: {{GITLAB_RELATIVE_URL_ROOT}},relative_url_root: '${GITLAB_RELATIVE_URL_ROOT}',' -i config/gitlab.yml
  sudo -HEu ${GITLAB_USER} sed 's,{{GITLAB_RELATIVE_URL_ROOT}},'"${GITLAB_RELATIVE_URL_ROOT}"',' -i config/unicorn.rb
else
  sed 's,{{GITLAB_RELATIVE_URL_ROOT}},/,' -i /etc/nginx/sites-enabled/gitlab
  sed 's,{{GITLAB_RELATIVE_URL_ROOT__with_trailing_slash}},/,' -i /etc/nginx/sites-enabled/gitlab
  sudo -HEu ${GITLAB_USER} sed '/{{GITLAB_RELATIVE_URL_ROOT}}/d' -i config/unicorn.rb
fi

# disable ipv6 support
if [[ ! -f /proc/net/if_inet6 ]]; then
  sed -e '/listen \[::\]:80/ s/^#*/#/' -i /etc/nginx/sites-enabled/gitlab
  sed -e '/listen \[::\]:443/ s/^#*/#/' -i /etc/nginx/sites-enabled/gitlab
fi

# fix permission and ownership of ${GITLAB_DATA_DIR}
chmod 755 ${GITLAB_DATA_DIR}
chown ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_DATA_DIR}

# set executable flags on ${GITLAB_DATA_DIR} (needed if mounted from a data-only
# container using --volumes-from)
chmod +x ${GITLAB_DATA_DIR}

# create the repositories directory and make sure it has the right permissions
mkdir -p ${GITLAB_REPOS_DIR}/
chown ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_REPOS_DIR}/
chmod ug+rwX,o-rwx ${GITLAB_REPOS_DIR}/
sudo -HEu ${GITLAB_USER} chmod g+s ${GITLAB_REPOS_DIR}/

# create the satellites directory and make sure it has the right permissions
mkdir -p ${GITLAB_DATA_DIR}/gitlab-satellites/
chmod u+rwx,g=rx,o-rwx ${GITLAB_DATA_DIR}/gitlab-satellites
chown ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_DATA_DIR}/gitlab-satellites

# remove old cache directory (remove this line after a few releases)
rm -rf ${GITLAB_DATA_DIR}/cache

# create the backups directory
mkdir -p ${GITLAB_BACKUP_DIR}
chown ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_BACKUP_DIR}

# create the uploads directory
mkdir -p ${GITLAB_DATA_DIR}/uploads/
chmod -R u+rwX ${GITLAB_DATA_DIR}/uploads/
chown ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_DATA_DIR}/uploads/

# create the .ssh directory
mkdir -p ${GITLAB_DATA_DIR}/.ssh/
touch ${GITLAB_DATA_DIR}/.ssh/authorized_keys
chmod 700 ${GITLAB_DATA_DIR}/.ssh
chmod 600 ${GITLAB_DATA_DIR}/.ssh/authorized_keys
chown -R ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_DATA_DIR}/.ssh

appInit () {
  # due to the nature of docker and its use cases, we allow some time
  # for the database server to come online.
  case ${DB_TYPE} in
    mysql)
      prog="mysqladmin -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} ${DB_PASS:+-p$DB_PASS} status"
      ;;
    postgres)
      prog=$(find /usr/lib/postgresql/ -name pg_isready)
      prog="${prog} -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -t 1"
      ;;
  esac
  timeout=60
  printf "Waiting for database server to accept connections"
  while ! ${prog} >/dev/null 2>&1
  do
    timeout=$(expr $timeout - 1)
    if [[ $timeout -eq 0 ]]; then
      printf "\nCould not connect to database server. Aborting...\n"
      exit 1
    fi
    printf "."
    sleep 1
  done
  echo

  # run the `gitlab:setup` rake task if required
  case ${DB_TYPE} in
    mysql)
      QUERY="SELECT count(*) FROM information_schema.tables WHERE table_schema = '${DB_NAME}';"
      COUNT=$(mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USER} ${DB_PASS:+-p$DB_PASS} -ss -e "${QUERY}")
      ;;
    postgres)
      QUERY="SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';"
      COUNT=$(PGPASSWORD="${DB_PASS}" psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -Atw -c "${QUERY}")
      ;;
  esac
  if [[ -z ${COUNT} || ${COUNT} -eq 0 ]]; then
    echo "Setting up GitLab for firstrun. Please be patient, this could take a while..."
    sudo -HEu ${GITLAB_USER} force=yes bundle exec rake gitlab:setup ${GITLAB_ROOT_PASSWORD:+GITLAB_ROOT_PASSWORD=$GITLAB_ROOT_PASSWORD} >/dev/null
  fi

  # migrate database and compile the assets if the gitlab version or relative_url has changed.
  CACHE_VERSION=
  [[ -f tmp/cache/VERSION ]] && CACHE_VERSION=$(cat tmp/cache/VERSION)
  [[ -f tmp/cache/GITLAB_RELATIVE_URL_ROOT ]] && CACHE_GITLAB_RELATIVE_URL_ROOT=$(cat tmp/cache/GITLAB_RELATIVE_URL_ROOT)
  if [[ ${GITLAB_VERSION} != ${CACHE_VERSION} || ${GITLAB_RELATIVE_URL_ROOT} != ${CACHE_GITLAB_RELATIVE_URL_ROOT} ]]; then
    echo "Migrating database..."
    sudo -HEu ${GITLAB_USER} bundle exec rake db:migrate >/dev/null

    # recreate the tmp directory
    rm -rf ${GITLAB_DATA_DIR}/tmp
    sudo -HEu ${GITLAB_USER} mkdir -p ${GITLAB_DATA_DIR}/tmp/
    chmod -R u+rwX ${GITLAB_DATA_DIR}/tmp/

    # create the tmp/cache and tmp/public/assets directory
    sudo -HEu ${GITLAB_USER} mkdir -p ${GITLAB_DATA_DIR}/tmp/cache/
    sudo -HEu ${GITLAB_USER} mkdir -p ${GITLAB_DATA_DIR}/tmp/public/assets/

    echo "Compiling assets. Please be patient, this could take a while..."
    sudo -HEu ${GITLAB_USER} bundle exec rake assets:clean >/dev/null 2>&1
    sudo -HEu ${GITLAB_USER} bundle exec rake assets:precompile >/dev/null 2>&1
    sudo -HEu ${GITLAB_USER} touch tmp/cache/VERSION
    sudo -HEu ${GITLAB_USER} echo "${GITLAB_VERSION}" > tmp/cache/VERSION
    sudo -HEu ${GITLAB_USER} echo "${GITLAB_RELATIVE_URL_ROOT}" > tmp/cache/GITLAB_RELATIVE_URL_ROOT
  fi

  # remove stale unicorn and sidekiq pid's if they exist.
  rm -rf tmp/pids/unicorn.pid
  rm -rf tmp/pids/sidekiq.pid

  # remove state unicorn socket if it exists
  rm -rf tmp/sockets/gitlab.socket

  # setup cron job for automatic backups
  case ${GITLAB_BACKUPS} in
    daily|weekly|monthly)
      read hour min <<< ${GITLAB_BACKUP_TIME//[:]/ }
      case ${GITLAB_BACKUPS} in
        daily)
          sudo -HEu ${GITLAB_USER} cat > /tmp/cron.${GITLAB_USER} <<EOF
# Automatic Backups: daily
$min $hour * * * /bin/bash -l -c 'cd ${GITLAB_INSTALL_DIR} && bundle exec rake gitlab:backup:create RAILS_ENV=${RAILS_ENV}'
EOF
          ;;
        weekly)
          sudo -HEu ${GITLAB_USER} cat > /tmp/cron.${GITLAB_USER} <<EOF
# Automatic Backups: weekly
$min $hour * * 0 /bin/bash -l -c 'cd ${GITLAB_INSTALL_DIR} && bundle exec rake gitlab:backup:create RAILS_ENV=${RAILS_ENV}'
EOF
          ;;
        monthly)
          sudo -HEu ${GITLAB_USER} cat > /tmp/cron.${GITLAB_USER} <<EOF
# Automatic Backups: monthly
$min $hour 01 * * /bin/bash -l -c 'cd ${GITLAB_INSTALL_DIR} && bundle exec rake gitlab:backup:create RAILS_ENV=${RAILS_ENV}'
EOF
          ;;
      esac
      crontab -u ${GITLAB_USER} /tmp/cron.${GITLAB_USER} && rm -rf /tmp/cron.${GITLAB_USER}
      ;;
  esac
}

appStart () {
  appInit
  # start supervisord
  echo "Starting supervisord..."
  exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

appSanitize () {
  echo "Checking repository directories permissions..."
  chmod -R ug+rwX,o-rwx ${GITLAB_REPOS_DIR}/
  chmod -R ug-s ${GITLAB_REPOS_DIR}/
  find ${GITLAB_REPOS_DIR}/ -type d -print0 | xargs -0 chmod g+s
  chown -R ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_REPOS_DIR}

  echo "Checking satellites directories permissions..."
  sudo -HEu ${GITLAB_USER} mkdir -p ${GITLAB_DATA_DIR}/gitlab-satellites/
  chmod u+rwx,g=rx,o-rwx ${GITLAB_DATA_DIR}/gitlab-satellites
  chown -R ${GITLAB_USER}:${GITLAB_USER} ${GITLAB_DATA_DIR}/gitlab-satellites

  echo "Checking uploads directory permissions..."
  chmod -R u+rwX ${GITLAB_DATA_DIR}/uploads/
  chown ${GITLAB_USER}:${GITLAB_USER} -R ${GITLAB_DATA_DIR}/uploads/

  echo "Checking tmp directory permissions..."
  chmod -R u+rwX ${GITLAB_DATA_DIR}/tmp/
  chown ${GITLAB_USER}:${GITLAB_USER} -R ${GITLAB_DATA_DIR}/tmp/
}

appRake () {
  if [[ -z ${1} ]]; then
    echo "Please specify the rake task to execute. See https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks"
    return 1
  fi

  if [[ ${1} == gitlab:backup:restore ]]; then
    interactive=true
    for arg in $@
    do
      if [[ $arg == BACKUP=* ]]; then
        interactive=false
        break
      fi
    done

    # user needs to select the backup to restore
    if [[ $interactive == true ]]; then
      nBackups=$(ls ${GITLAB_BACKUP_DIR}/*_gitlab_backup.tar | wc -l)
      if [[ $nBackups -eq 0 ]]; then
        echo "No backup present. Cannot continue restore process.".
        return 1
      fi

      for b in `ls ${GITLAB_BACKUP_DIR} | sort -r`
      do
        echo " ├ $b"
      done
      read -p "Select a backup to restore: " file

      if [[ ! -f ${GITLAB_BACKUP_DIR}/${file} ]]; then
        echo "Specified backup does not exist. Aborting..."
        return 1
      fi
      BACKUP=$(echo $file | cut -d'_' -f1)
    fi
  elif [[ ${1} == gitlab:import:repos ]]; then
    # sanitize the data volume to ensure there are no permission issues
    appSanitize
  fi

  echo "Running \"${1}\" rake task ..."
  sudo -HEu ${GITLAB_USER} bundle exec rake $@ ${BACKUP:+BACKUP=$BACKUP}
}

appHelp () {
  echo "Available options:"
  echo " app:start          - Starts the gitlab server (default)"
  echo " app:init           - Initialize the gitlab server (e.g. create databases, compile assets), but don't start it."
  echo " app:sanitize       - Fix repository/satellites directory permissions."
  echo " app:rake <task>    - Execute a rake task."
  echo " app:help           - Displays the help"
  echo " [command]          - Execute the specified linux command eg. bash."
}

case ${1} in
  app:start)
    appStart
    ;;
  app:init)
    appInit
    ;;
  app:sanitize)
    appSanitize
    ;;
  app:rake)
    shift 1
    appRake $@
    ;;
  app:help)
    appHelp
    ;;
  *)
    if [[ -x $1 ]]; then
      $1
    else
      prog=$(which $1)
      if [[ -n ${prog} ]] ; then
        shift 1
        $prog $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0
