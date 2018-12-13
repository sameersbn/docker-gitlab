ARG DOCKER_BUILDER=${DOCKER_BUILDER:-${DOCKER_IMAGE}:builder}
ARG DOCKER_BASE=${DOCKER_BASE:-${DOCKER_IMAGE}:base}

#-------------------------------------------------------------------------------
# Image: Ruby Dependencies
#
FROM ${DOCKER_BUILDER} AS RUBY
ARG RUBY_HOME
ARG RAILS_ENV
ARG NODE_ENV

ENV RUBY_HOME=${RUBY_HOME} \
    GEM_HOME=${RUBY_HOME} \
    GEM_PATH=${RUBY_HOME} \
    RAILS_ENV=${RAILS_ENV} \
    NODE_ENV=${NODE_ENV} \
    PATH=${RUBY_HOME}/bin:${PATH}

RUN gem install --no-document bundler

#-------------------------------------------------------------------------------
# Image: Shell
#
FROM ${DOCKER_BUILDER} AS GITLAB_SHELL
ARG GITLAB_BUILD
ARG GITLAB_SHELL_VERSION
ARG GITLAB_SHELL_URL
ARG GITLAB_SHELL_INSTALL

ENV GITLAB_BUILD=${GITLAB_BUILD} \
    GITLAB_SHELL_VERSION=${GITLAB_SHELL_VERSION} \
    GITLAB_SHELL_URL=${GITLAB_SHELL_URL} \
    GITLAB_SHELL_INSTALL=${GITLAB_SHELL_INSTALL}

COPY /build/gitlab-shell /
RUN /gitlab-shell

#-------------------------------------------------------------------------------
# Image: Workhorse
#
FROM ${DOCKER_BUILDER} AS GITLAB_WORKHORSE
ARG GITLAB_WORKHORSE_VERSION
ARG GITLAB_WORKHORSE_URL
ARG GITLAB_WORKHORSE_BUILD

ENV GITLAB_WORKHORSE_VERSION=${GITLAB_WORKHORSE_VERSION} \
    GITLAB_WORKHORSE_URL=${GITLAB_WORKHORSE_URL} \
    GITLAB_WORKHORSE_BUILD=${GITLAB_WORKHORSE_BUILD}

COPY /build/gitlab-workhorse /
RUN /gitlab-workhorse

#-------------------------------------------------------------------------------
# Image: Pages
#
FROM ${DOCKER_BUILDER} AS GITLAB_PAGES
ARG GITLAB_PAGES_VERSION
ARG GITLAB_PAGES_URL
ARG GITLAB_PAGES_BUILD

ENV GITLAB_PAGES_VERSION=${GITLAB_PAGES_VERSION} \
    GITLAB_PAGES_URL=${GITLAB_PAGES_URL} \
    GITLAB_PAGES_BUILD=${GITLAB_PAGES_BUILD}

COPY /build/gitlab-pages /
RUN /gitlab-pages

#-------------------------------------------------------------------------------
# Image: Gitaly
#
# ruby -> Lowercase, some older docker versions have an issue
# with uppercase stage name
FROM ruby AS GITLAB_GITALY
ARG GITLAB_GITALY_VERSION
ARG GITLAB_GITALY_URL
ARG GITLAB_GITALY_BUILD
ARG GITLAB_GITALY_INSTALL

ENV GITLAB_GITALY_VERSION=${GITLAB_GITALY_VERSION} \
    GITLAB_GITALY_URL=${GITLAB_GITALY_URL} \
    GITLAB_GITALY_BUILD=${GITLAB_GITALY_BUILD} \
    GITLAB_GITALY_INSTALL=${GITLAB_GITALY_INSTALL}

COPY /build/gitlab-gitaly /
RUN /gitlab-gitaly

#-------------------------------------------------------------------------------
# Image: Gitlab
#
# ruby -> Lowercase, some older docker versions have an issue
# with uppercase stage name
FROM ruby AS GITLAB
ARG GITLAB_VERSION
ARG GITLAB_INSTALL_DIR
ARG GITLAB_INSTALL_URL
ARG GITLAB_CACHE

ENV GITLAB_VERSION=${GITLAB_VERSION} \
    GITLAB_INSTALL_DIR=${GITLAB_INSTALL_DIR} \
    GITLAB_INSTALL_URL=${GITLAB_INSTALL_URL} \
    GITLAB_CACHE=${GITLAB_CACHE}

COPY /build/gitlab /
RUN /gitlab

#-------------------------------------------------------------------------------
# Image: Supervisor
#
FROM ${DOCKER_BUILDER} AS SUPERVISOR
ARG RAILS_ENV
ARG GITLAB_LOGS
ARG GITLAB_HOME
ARG GITLAB_INSTALL_DIR
ARG GITLAB_GITALY_INSTALL

ENV GITLAB_LOG_DIR=${GITLAB_LOGS} \
    GITLAB_INSTALL_DIR=${GITLAB_INSTALL_DIR} \
    GITLAB_HOME=${GITLAB_HOME} \
    RAILS_ENV=${RAILS_ENV} \
    GITLAB_GITALY_INSTALL_DIR=${GITLAB_GITALY_INSTALL}

COPY build/supervisor /supervisor
RUN /supervisor

#-------------------------------------------------------------------------------
# Image: Runtime
#
FROM ${DOCKER_BASE} AS RUNTIME
ARG BUILD_DATE
ARG GIT_COMMIT
ARG GIT_BRANCH
ARG CONTAINER_MAINTAINER
ARG CONTAINER_NAME
ARG CONTAINER_VENDOR
ARG CONTAINER_URL
ARG CONTAINER_VCS
ARG RUBY_HOME
ARG GITLAB_VERSION
ARG GITLAB_HOME
ARG GITLAB_USER
ARG GITLAB_DATA
ARG GITLAB_LOGS
ARG GITLAB_RUNTIME
ARG GITLAB_SHELL_INSTALL
ARG GITLAB_INSTALL_DIR
ARG GITLAB_GITALY_INSTALL
ARG RAILS_ENV
ARG NODE_ENV

ENV RAILS_ENV=${RAILS_ENV} \
    NODE_ENV=${NODE_ENV} \
    GEM_HOME=${RUBY_HOME} \
    GEM_PATH=${RUBY_HOME} \
    PATH=${RUBY_HOME}/bin:${PATH} \
    GITLAB_VERSION=${GITLAB_VERSION} \
    GITLAB_HOME=${GITLAB_HOME} \
    GITLAB_USER=${GITLAB_USER} \
    GITLAB_DATA_DIR=${GITLAB_DATA} \
    GITLAB_LOG_DIR=${GITLAB_LOGS} \
    GITLAB_RUNTIME_DIR=${GITLAB_RUNTIME} \
    GITLAB_INSTALL_DIR=${GITLAB_INSTALL_DIR} \
    GITLAB_GITALY_INSTALL_DIR=${GITLAB_GITALY_INSTALL} \
    GITLAB_SHELL_INSTALL_DIR=${GITLAB_SHELL_INSTALL}
    
COPY --from=GITLAB_SHELL ${GITLAB_SHELL_INSTALL_DIR} ${GITLAB_SHELL_INSTALL_DIR}/
COPY --from=GITLAB_WORKHORSE /usr/local/bin/gitlab* /usr/local/bin/
COPY --from=GITLAB_PAGES /usr/local/bin/gitlab-pages /usr/local/bin/
COPY --from=GITLAB_GITALY ${GITLAB_GITALY_INSTALL_DIR} ${GITLAB_GITALY_INSTALL}
COPY --from=GITLAB_GITALY /usr/local/bin/gitaly* /usr/local/bin/
COPY --from=RUBY ${RUBY_HOME} ${RUBY_HOME}/
COPY --from=GITLAB_GITALY ${RUBY_HOME} ${RUBY_HOME} /
COPY --from=GITLAB ${RUBY_HOME} ${RUBY_HOME}/
COPY --from=GITLAB ${GITLAB_INSTALL_DIR} ${GITLAB_INSTALL_DIR}
COPY --from=SUPERVISOR /etc/supervisor/ /etc/supervisor/

COPY rootfs/ /
RUN /sbin/entrypoint configure

LABEL \
    maintainer="\"${CONTAINER_MAINTAINER}\"" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name=${CONTAINER_NAME} \
    org.label-schema.vendor=${CONTAINER_VENDOR} \
    org.label-schema.url="${CONTAINER_URL}" \
    org.label-schema.vcs-url="${CONTAINER_VCS}" \
    org.label-schema.vcs-ref=${GIT_COMMIT} \
    org.label-schema.vcs-branch=${GIT_BRANCH} \
    org.label-schema.vcs-type="git" \
    org.label-schema.license=MIT

EXPOSE 22/tcp 80/tcp 443/tcp

VOLUME ["${GITLAB_DATA}", "${GITLAB_LOGS}"]
WORKDIR ${GITLAB_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint"]
CMD ["app:start"]
