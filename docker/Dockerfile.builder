ARG DOCKER_BASE=${DOCKER_BASE:-${DOCKER_IMAGE}:base}

FROM ${DOCKER_BASE} AS BUILDER
ARG GOLANG_VERSION
ARG BUILD_DEPENDENCIES
ARG GITLAB_BUILD

ENV BUILD_DEPENDENCIES=${BUILD_DEPENDENCIES} \
    GOLANG_VERSION=${GOLANG_VERSION} \
    GITLAB_BUILD=${GITLAB_BUILD} \
    GOROOT=/tmp/go
ENV PATH=${GOROOT}/bin:${PATH}

RUN BUILD_DEPENDENCIES=$(echo ${BUILD_DEPENDENCIES} | sed 's|;| |g') && \
    apt-get update && \
    apt-get install --no-install-recommends -y ${BUILD_DEPENDENCIES} && \
    paxctl -Cm "$(command -v ruby${RUBY_VERSION})" && \
    paxctl -Cm "$(command -v nodejs)"

RUN echo "Downloading Go ${GOLANG_VERSION}..." && \
    wget -cnv https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz -P ${GITLAB_BUILD}/ && \
    tar -xf ${GITLAB_BUILD}/go${GOLANG_VERSION}.linux-amd64.tar.gz -C /tmp/

COPY rootfs/usr/local/bin/exec_as_git /usr/local/bin/exec_as_git

RUN exec_as_git git config --global core.autocrlf input && \
    exec_as_git git config --global gc.auto 0 && \
    exec_as_git git config --global repack.writeBitmaps true
