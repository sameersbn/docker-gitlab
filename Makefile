PROJECT_DIR		= $(CURDIR)
SCRIPT_DIR		= $(CURDIR)/scripts
DOCKER_DIR		= $(CURDIR)/docker

.PHONY: all
all: base builder docker

.PHONY: base
base:
	@${SCRIPT_DIR}/build ${PROJECT_DIR} ${DOCKER_DIR}/Dockerfile.base

.PHONY: builder
builder:
	@${SCRIPT_DIR}/build ${PROJECT_DIR} ${DOCKER_DIR}/Dockerfile.builder

.PHONY: docker
docker:
	@${SCRIPT_DIR}/build ${PROJECT_DIR} ${DOCKER_DIR}/Dockerfile

.PHONY: gitlab
gitlab: docker

.PHONY: test
test:
	@${SCRIPT_DIR}/test ${PROJECT_DIR} start

.PHONY: stop
stop:
	@${SCRIPT_DIR}/test ${PROJECT_DIR} stop

.PHONY: purge
purge:
	@${SCRIPT_DIR}/test ${PROJECT_DIR} purge

.PHONY: logs
	@docker logs -f gitlab-test

.PHONY: docs
docs-test:
	${SCRIPT_DIR}/docs ${PROJECT_DIR} build

.PHONY: docs-server
docs-server:
	${SCRIPT_DIR}/docs ${PROJECT_DIR} server

.PHONY: docs-deploy
docs-deploy:
	${SCRIPT_DIR}/docs ${PROJECT_DIR} deploy