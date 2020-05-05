#!/bin/bash
set -e
set -o pipefail

# shellcheck source=assets/runtime/functions
source "${GITLAB_RUNTIME_DIR}/functions"

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
        if ps h -p $SUPERVISOR_PID > /dev/null ; then
        wait $SUPERVISOR_PID || true
        fi
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
        execute_raketask "$@"
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
