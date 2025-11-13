FROM ubuntu:noble-20251013

ARG VERSION=18.7.1

ENV GITLAB_VERSION=${VERSION} \
    RUBY_VERSION=3.2.9 \
    RUBY_SOURCE_SHA256SUM="abbad98db9aeb152773b0d35868e50003b8c467f3d06152577c4dfed9d88ed2a" \
    RUBYGEMS_VERSION=3.7.2 \
    GOLANG_VERSION=1.24.11 \
    GITLAB_SHELL_VERSION=14.45.5 \
    GITLAB_PAGES_VERSION=18.7.1 \
    GITALY_SERVER_VERSION=18.7.1 \
    GITLAB_USER="git" \
    GITLAB_HOME="/home/git" \
    GITLAB_LOG_DIR="/var/log/gitlab" \
    GITLAB_CACHE_DIR="/etc/docker-gitlab" \
    RAILS_ENV=production \
    NODE_ENV=production \
    NO_SOURCEMAPS=true

ENV GITLAB_INSTALL_DIR="${GITLAB_HOME}/gitlab" \
    GITLAB_SHELL_INSTALL_DIR="${GITLAB_HOME}/gitlab-shell" \
    GITLAB_GITALY_INSTALL_DIR="${GITLAB_HOME}/gitaly" \
    GITLAB_DATA_DIR="${GITLAB_HOME}/data" \
    GITLAB_BUILD_DIR="${GITLAB_CACHE_DIR}/build" \
    GITLAB_RUNTIME_DIR="${GITLAB_CACHE_DIR}/runtime"

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    wget ca-certificates apt-transport-https gnupg2 \
 && apt-get upgrade -y \
 && rm -rf /var/lib/apt/lists/*

RUN set -ex && \
    mkdir -p /etc/apt/keyrings \
 && wget --quiet -O - https://keyserver.ubuntu.com/pks/lookup?op=get\&search=0xe1dd270288b4e6030699e45fa1715d88e1df1f24 | gpg --dearmor -o /etc/apt/keyrings/git-core.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/git-core.gpg] http://ppa.launchpad.net/git-core/ppa/ubuntu noble main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/postgres.gpg \
 && echo 'deb [signed-by=/etc/apt/keyrings/postgres.gpg] http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main' > /etc/apt/sources.list.d/nodesource.list \
 && wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg \
 && echo 'deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list \
 && wget --quiet -O - https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/keyrings/nginx-archive-keyring.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu noble nginx" >> /etc/apt/sources.list.d/nginx.list \
 && printf "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" >> /etc/apt/preferences.d/99nginx \
 && set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      sudo supervisor logrotate locales curl \
      nginx openssh-server redis-tools \
      postgresql-client-13 postgresql-client-14 postgresql-client-15 \
      postgresql-client-16 postgresql-client-17 postgresql-client-18 \
      python3 python3-docutils nodejs yarn gettext-base graphicsmagick \
      libpq5 zlib1g libyaml-dev libssl-dev libgdbm-dev libre2-dev \
      libreadline-dev libncurses5-dev libffi-dev curl openssh-server libxml2-dev libxslt-dev \
      libcurl4-openssl-dev libicu-dev libkrb5-dev rsync python3-docutils pkg-config cmake \
      tzdata unzip libimage-exiftool-perl libmagic1 \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
 && rm -rf /var/lib/apt/lists/* /etc/nginx/conf.d/default.conf

COPY assets/build/ ${GITLAB_BUILD_DIR}/
RUN bash ${GITLAB_BUILD_DIR}/install.sh

COPY assets/runtime/ ${GITLAB_RUNTIME_DIR}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENV prometheus_multiproc_dir="/dev/shm"

ARG BUILD_DATE
ARG VCS_REF

LABEL \
    maintainer="sameer@damagehead.com" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name=gitlab \
    org.label-schema.vendor=damagehead \
    org.label-schema.url="https://github.com/sameersbn/docker-gitlab" \
    org.label-schema.vcs-url="https://github.com/sameersbn/docker-gitlab.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    com.damagehead.gitlab.license=MIT

EXPOSE 22/tcp 80/tcp 443/tcp

VOLUME ["${GITLAB_DATA_DIR}", "${GITLAB_LOG_DIR}"]
WORKDIR ${GITLAB_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
