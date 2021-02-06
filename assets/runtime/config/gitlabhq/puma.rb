ENV['RAILS_RELATIVE_URL_ROOT'] = "{{GITLAB_RELATIVE_URL_ROOT}}"

# frozen_string_literal: true

# Load "path" as a rackup file.
#
# The default is "config.ru".
#
rackup 'config.ru'
pidfile '{{GITLAB_INSTALL_DIR}}/tmp/pids/puma.pid'
state_path '{{GITLAB_INSTALL_DIR}}/tmp/pids/puma.state'

stdout_redirect '{{GITLAB_INSTALL_DIR}}/log/puma.stdout.log',
  '{{GITLAB_INSTALL_DIR}}/log/puma.stderr.log',
  true

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
#
# The default is "0, 16".
#
threads {{PUMA_THREADS_MIN}}, {{PUMA_THREADS_MAX}}

# By default, workers accept all requests and queue them to pass to handlers.
# When false, workers accept the number of simultaneous requests configured.
#
# Queueing requests generally improves performance, but can cause deadlocks if
# the app is waiting on a request to itself. See https://github.com/puma/puma/issues/612
#
# When set to false this may require a reverse proxy to handle slow clients and
# queue requests before they reach puma. This is due to disabling HTTP keepalive
queue_requests false

# Bind the server to "url". "tcp://", "unix://" and "ssl://" are the only
# accepted protocols.
bind 'unix:///home/git/gitlab/tmp/sockets/gitlab.socket'
bind 'tcp://127.0.0.1:8080'

workers {{PUMA_WORKERS}}

require_relative "{{GITLAB_INSTALL_DIR}}/lib/gitlab/cluster/lifecycle_events"
require_relative "{{GITLAB_INSTALL_DIR}}/lib/gitlab/cluster/puma_worker_killer_initializer"

on_restart do
  # Signal application hooks that we're about to restart
  Gitlab::Cluster::LifecycleEvents.do_before_master_restart
end

before_fork do
  # Signal to the puma killer
  Gitlab::Cluster::PumaWorkerKillerInitializer.start(@config.options, puma_per_worker_max_memory_mb: {{PUMA_PER_WORKER_MAX_MEMORY_MB}}, puma_master_max_memory_mb: {{PUMA_MASTER_MAX_MEMORY_MB}}) unless ENV['DISABLE_PUMA_WORKER_KILLER']

  # Signal application hooks that we're about to fork
  Gitlab::Cluster::LifecycleEvents.do_before_fork
end

Gitlab::Cluster::LifecycleEvents.set_puma_options @config.options
on_worker_boot do
  # Signal application hooks of worker start
  Gitlab::Cluster::LifecycleEvents.do_worker_start
end

# Preload the application before starting the workers; this conflicts with
# phased restart feature. (off by default)
preload_app!

tag 'gitlab-puma-worker'

# Verifies that all workers have checked in to the master process within
# the given timeout. If not the worker process will be restarted. Default
# value is 60 seconds.
#
worker_timeout {{PUMA_TIMEOUT}}

# Use json formatter
require_relative "{{GITLAB_INSTALL_DIR}}/lib/gitlab/puma_logging/json_formatter"

json_formatter = Gitlab::PumaLogging::JSONFormatter.new
log_formatter do |str|
  json_formatter.call(str)
end
