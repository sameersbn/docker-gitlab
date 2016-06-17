#!/bin/sh

set -e
[[ ${DEBUG}x == "truex" ]] && set -x


case ${1} in
  app:start)
    test -e /var/run/gitlab/socket/gitlab-workhorse.socket && rm /var/run/gitlab/socket/gitlab-workhorse.socket
    test -d /var/run/gitlab/socket || mkdir -p /var/run/gitlab/socket
    chmod 0777 /var/run/gitlab/socket
    ;;
  *)
    exec "$@"
    ;;
esac

exit 0
