#!/bin/bash
set -e
source ${GITLAB_RUNTIME_DIR}/functions

[[ -n $DEBUG ]] && set -x

case ${1} in
  app:init|app:start|app:sanitize|app:rake)

    system_initialize
    system_configure_gitlab
    system_configure_gitlab_shell
    system_configure_gitlab_git_http_server
    system_configure_nginx

    case ${1} in
      app:start)
        system_gitlab_migrate_database
        exec /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf
        ;;
      app:init)
        system_gitlab_migrate_database
        ;;
      app:sanitize)
        system_sanitize_datadir
        ;;
      app:rake)
        shift 1
        system_gitlab_execute_raketask $@
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

exit 0
