FROM sameersbn/ubuntu:14.04.20161211
MAINTAINER sameer@damagehead.com

ENV GITLAB_VERSION=8.14.4 \
    RUBY_VERSION=2.3 \
    GOLANG_VERSION=1.6.3 \
    GITLAB_SHELL_VERSION=4.0.3 \
    GITLAB_WORKHORSE_VERSION=1.1.1 \
    GITLAB_USER="git" \
    GITLAB_HOME="/home/git" \
    GITLAB_LOG_DIR="/var/log/gitlab" \
    GITLAB_CACHE_DIR="/etc/docker-gitlab" \
    RAILS_ENV=production

ENV GITLAB_INSTALL_DIR="${GITLAB_HOME}/gitlab" \
    GITLAB_SHELL_INSTALL_DIR="${GITLAB_HOME}/gitlab-shell" \
    GITLAB_WORKHORSE_INSTALL_DIR="${GITLAB_HOME}/gitlab-workhorse" \
    GITLAB_DATA_DIR="${GITLAB_HOME}/data" \
    GITLAB_BUILD_DIR="${GITLAB_CACHE_DIR}/build" \
    GITLAB_RUNTIME_DIR="${GITLAB_CACHE_DIR}/runtime"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor logrotate locales curl \
      nginx openssh-server mysql-client postgresql-client redis-tools \
      ruby${RUBY_VERSION} python2.7 python-docutils nodejs gettext-base \
      libmysqlclient18 libpq5 zlib1g libyaml-0-2 libssl1.0.0 \
      libgdbm3 libreadline6 libncurses5 libffi6 \
      libxml2 libxslt1.1 libcurl3 libicu52 \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
 && gem install --no-document bundler \
 && rm -rf /var/lib/apt/lists/*

# KLUDGE: This secion is to install git 2.10.2 due to this issue:
# https://gitlab.com/gitlab-org/gitlab-ce/issues/25301 .
# Once that's resolved delete this RUN command and prefix
# the line above that starts like this:
#   ruby${RUBY_VERSION} python2.7 python-docutils [...]
# with "git " so it looks like:
#   git ruby${RUBY_VERSION} python2.7 python-docutils [...]
# Note that "git-core" is deprecated.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev \
      build-essential autoconf \
    && wget https://github.com/git/git/archive/v2.10.2.tar.gz \
    && curl -SL https://github.com/git/git/archive/v2.10.2.tar.gz \
     | tar -xzC /tmp \
    && cd /tmp/git-2.10.2 \
    && make configure \
    && ./configure --prefix=/usr \
    && make all \
    && make install \
    && rm -rf /var/lib/apt/lists/*
      
COPY assets/build/ ${GITLAB_BUILD_DIR}/
RUN bash ${GITLAB_BUILD_DIR}/install.sh

COPY assets/runtime/ ${GITLAB_RUNTIME_DIR}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 22/tcp 80/tcp 443/tcp

VOLUME ["${GITLAB_DATA_DIR}", "${GITLAB_LOG_DIR}"]
WORKDIR ${GITLAB_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
