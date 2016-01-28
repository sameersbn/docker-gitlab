#!/bin/bash
set -e
source ${GITLAB_RUNTIME_DIR}/functions

[[ $DEBUG == true ]] && set -x

case ${1} in
  app:init|app:start|app:sanitize|app:rake)

    initialize_system
    configure_gitlab
    configure_gitlab_shell
    configure_nginx

    case ${1} in
      app:start)
        migrate_database
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
    echo "有效的选项:"
    echo " app:start        - 启动gitlab服务器(默认选项)"
    echo " app:init         - 初始化gitlab服务器(如创建数据库, 编译资源), 但是并不会启动。"
    echo " app:sanitize     - 确定repository/builds目录权限。"
    echo " app:rake <task>  - 执行一个rake任务。"
    echo " app:help         - 显示帮助信息"
    echo " [command]        - 执行指定命令，如bash。"
    ;;
  *)
    exec "$@"
    ;;
esac
