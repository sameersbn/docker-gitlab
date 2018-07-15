#!/bin/bash
set -e

file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
    echo >&2 "info: setting $var from environment to ${val}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
    echo >&2 "info: setting ${var} from ${fileVar} to ***REDACTED***"
  else
    echo >&2 "warn: ${var} and ${fileVar} not found in environment"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

file_env 'GITLAB_AWS_ACCESS_KEY_ID'
file_env 'GITLAB_AWS_SECRET_KEY'
file_env 'DB_PASS'
file_env 'GITLAB_SECRETS_DB_KEY_BASE'
file_env 'GITLAB_SECRETS_SECRET_KEY_BASE'
file_env 'GITLAB_SECRETS_OTP_KEY_BASE'
file_env 'GITLAB_ROOT_PASSWORD'
file_env 'IMAP_PASS'
file_env 'SMTP_PASS'
file_env 'LDAP_PASS'
file_env 'OAUTH_GOOGLE_API_KEY'
file_env 'OAUTH_GOOGLE_APP_SECRET'
file_env 'OAUTH_FACEBOOK_API_KEY'
file_env 'OAUTH_FACEBOOK_APP_SECRET'
file_env 'OAUTH_TWITTER_API_KEY'
file_env 'OAUTH_TWITTER_APP_SECRET'
file_env 'OAUTH_AUTHENTIQ_CLIENT_ID'
file_env 'OAUTH_AUTHENTIQ_CLIENT_SECRET'
file_env 'OAUTH_GITHUB_API_KEY'
file_env 'OAUTH_GITHUB_APP_SECRET'
file_env 'OAUTH_GITLAB_API_KEY'
file_env 'OAUTH_GITLAB_APP_SECRET'
file_env 'OAUTH_CROWD_APP_PASSWORD'
file_env 'OAUTH_BITBUCKET_API_KEY'
file_env 'OAUTH_BITBUCKET_APP_SECRET'
file_env 'OAUTH_AUTH0_CLIENT_ID'
file_env 'OAUTH_AUTH0_CLIENT_SECRET'
file_env 'OAUTH_AZURE_API_KEY'
file_env 'OAUTH_AZURE_API_SECRET'
file_env 'AWS_BACKUP_ACCESS_KEY_ID'
file_env 'AWS_BACKUP_SECRET_ACCESS_KEY'
file_env 'GCS_BACKUP_ACCESS_KEY_ID'
file_env 'GCS_BACKUP_SECRET_ACCESS_KEY'
file_env 'GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_ACCESS_KEY_ID'
file_env 'GITLAB_ARTIFACTS_OBJECT_STORE_CONNECTION_AWS_SECRET_ACCESS_KEY'
file_env 'GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_ACCESS_KEY_ID'
file_env 'GITLAB_LFS_OBJECT_STORE_CONNECTION_AWS_SECRET_ACCESS_KEY'
file_env 'GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_ACCESS_KEY_ID'
file_env 'GITLAB_UPLOADS_OBJECT_STORE_CONNECTION_AWS_SECRET_ACCESS_KEY'

source ${GITLAB_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:init|app:start|app:sanitize|app:rake)

    initialize_system
    configure_gitlab
    configure_gitlab_shell
    configure_gitlab_pages
    configure_nginx

    case ${1} in
      app:start)
        /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf &
        SUPERVISOR_PID=$!
        migrate_database
        kill -15 $SUPERVISOR_PID
        ps h -p $SUPERVISOR_PID > /dev/null && wait $SUPERVISOR_PID
        rm -rf /var/run/supervisor.sock
        exec /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf
        ;;
      app:init)
        migrate_database
        ;;
      app:sanitize)
        sanitize_datadir
        ;;
      app:rake)
        shift 1
        execute_raketask $@
        ;;
    esac
    ;;
  app:help)
    echo "Available options:"
    echo " app:start        - Starts the gitlab server (default)"
    echo " app:init         - Initialize the gitlab server (e.g. create databases, compile assets), but don't start it."
    echo " app:sanitize     - Fix repository/builds directory permissions."
    echo " app:rake <task>  - Execute a rake task."
    echo " app:help         - Displays the help"
    echo " [command]        - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac
