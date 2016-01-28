all: build

help:
	@echo ""
	@echo "-- 帮助菜单"
	@echo ""
	@echo "   1. make build        - 构建gitlab镜像"
	@echo "   2. make quickstart   - 启动gitlab"
	@echo "   3. make stop         - 停止gitlab"
	@echo "   4. make logs         - 显示日志"
	@echo "   5. make purge        - 停止并且移除容器"

build:
	@docker build --tag=leebing/gitlab .

release: build
	@docker build --tag=leebing/gitlab:$(shell cat VERSION) .

quickstart:
	@echo "正在启动postgresql容器..."
	@docker run --name=gitlab-postgresql -d \
		--env='DB_NAME=gitlabhq_production' \
		--env='DB_USER=gitlab' --env='DB_PASS=password' \
		sameersbn/postgresql:latest
	@echo "正在启动redis容器..."
	@docker run --name=gitlab-redis -d \
		sameersbn/redis:latest
	@echo "正在启动gitlab容器..."
	@docker run --name='gitlab-demo' -d \
		--link=gitlab-postgresql:postgresql --link=gitlab-redis:redisio \
		--publish=10022:22 --publish=10080:80 \
		--env='GITLAB_PORT=10080' --env='GITLAB_SSH_PORT=10022' \
		sameersbn/gitlab:latest
	@echo "请耐心等待. 处理将会花一会儿时间..."
	@echo "请通过http://localhost:10080访问gitlab"
	@echo "需要获取日志请输入'make logs'"

stop:
	@echo "正在停止gitlab..."
	@docker stop gitlab-demo >/dev/null
	@echo "正在停止redis..."
	@docker stop gitlab-redis >/dev/null
	@echo "正在停止postgresql..."
	@docker stop gitlab-postgresql >/dev/null

purge: stop
	@echo "正在移除已停止的容器..."
	@docker rm -v gitlab-demo >/dev/null
	@docker rm -v gitlab-redis >/dev/null
	@docker rm -v gitlab-postgresql >/dev/null

logs:
	@docker logs -f gitlab-demo
