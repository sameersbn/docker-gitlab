# Docker GitLab

Dockerfile to build a GitLab container image.

## Installation

```bash
git clone https://github.com/sameersbn/docker-gitlab.git
cd docker-gitlab
sudo docker build -t="gitlabhq/gitlab" .
```

## Quick Start
Run the gitlab image

```bash
GITLAB=$(sudo docker run -d gitlabhq/gitlab)
GITLAB_IP=$(sudo docker inspect $GITLAB | grep IPAddres | awk -F'"' '{print $4}')
```

Access the GitLab application

```bash
xdg-open "http://${GITLAB_IP}"
```

__NOTE__: Please allow a minute or two for the GitLab application to start.

Login using the default username and password:

* username: admin@local.host
* password: 5iveL!fe

You should now have GitLab ready for testing. If you want to use GitLab for more than just testing then please read the **Advanced Options** section.

## Advanced Options

### Mounting volumes
GitLab is a code hosting software and as such you don't want to lose your code when the docker container is stopped/deleted. To avoid losing any data, you should mount volumes at.

* /home/git/repositories
* /home/git/gitlab-satellites
* /home/git/.ssh

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
mkdir /opt/gitlab/repositories
mkdir /opt/gitlab/gitlab-satellites
mkdir /opt/gitlab/.ssh
docker run -d \
  -v /opt/gitlab/repositories:/home/git/repositories \
  -v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites \
  -v /opt/gitlab/.ssh:/home/git/.ssh gitlabhq/gitlab
```

### Configuring MySQL database connection
GitLab uses a database backend to store its data.

#### Using the internal mysql server
This docker image is configured to use a MySQL database backend. The database connection can be configured using environment variables. If not specified, the image will start a mysql server internally and use it. However in this case, the data stored in the mysql database will be lost if the container is stopped/deleted. To avoid this you should mount a volume at /var/lib/mysql.

```bash
mkdir /opt/gitlab/mysql
docker run -d \
  -v /opt/gitlab/repositories:/home/git/repositories \
  -v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites \
  -v /opt/gitlab/.ssh:/home/git/.ssh \
  -v /opt/gitlab/mysql:/var/lib/mysql gitlabhq/gitlab
```

This will make sure that the data stored in the database is not lost when the image is stopped and started again.

#### Using an external mysql server
The image can be configured to use an external MySQL database instead of starting a MySQL server internally. The database configuration should be specified using environment variables while starting the GitLab image.

Before you start the GitLab image create user and database for gitlab.

```bash
mysql -uroot -p
CREATE USER 'gitlab'@'%.%.%.%' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'%.%.%.%';
```

To make sure the database is initialized start the container with DB_INIT=yes environment variable set.

**NOTE: This should be done only for the first run**.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" -e "DB_INIT=yes" \
  -v /opt/gitlab/repositories:/home/git/repositories \
  -v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites \
  -v /opt/gitlab/.ssh:/home/git/.ssh gitlabhq/gitlab
```

This will initialize the gitlab database. Now that the database is initialized, omit the **-e "DB_INIT=yes"** option from the docker command.

```bash
docker run -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/repositories:/home/git/repositories \
  -v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites \
  -v /opt/gitlab/.ssh:/home/git/.ssh gitlabhq/gitlab
```

### Other options
Below is the complete list of parameters that can be set using environment variables.

* GITLAB_HOST

        The hostname of the GitLab server. Defaults to localhost

* GITLAB_EMAIL

        The email address for the GitLab server. Defaults to gitlab@localhost.

* GITLAB_SUPPORT

        The support email address for the GitLab server. Defaults to support@localhost.

* REDIS_HOST

        The hostname of the redis server. Defaults to localhost

* REDIS_PORT

        The connection port of the redis server. Defaults to 6379.

* UNICORN_WORKERS

        The number of unicorn workers to start. Defaults to 2.

* SIDEKIQ_CONCURRENCY

        The number of concurrent sidekiq jobs to run. Defaults to 5

* DB_HOST

        The mysql server hostname. Defaults to localhost.

* DB_NAME

        The mysql database name. Defaults to gitlabhq_production

* DB_USER

        The mysql database user. Defaults to root

* DB_PASS

        The mysql database password. Defaults to no password

* DB_POOL

        The mysql database connection pool count. Defaults to 5.

* DB_INIT

        Whether to initial the mysql database. Defaults to no

### Putting it all together

```bash
docker run -d -h git.local.host \
  -v /opt/gitlab/repositories:/home/git/repositories \
  -v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites \
  -v /opt/gitlab/.ssh:/home/git/.ssh \
  -v /opt/gitlab/mysql:/var/lib/mysql \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  gitlabhq/gitlab
```

If you are using an external mysql database

```bash
docker run -d -h git.local.host \
  -v /opt/gitlab/repositories:/home/git/repositories \
  -v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites \
  -v /opt/gitlab/.ssh:/home/git/.ssh \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  gitlabhq/gitlab
```

## References
  https://github.com/gitlabhq/gitlabhq

  https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
