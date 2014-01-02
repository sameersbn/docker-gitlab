# Docker GitLab

Current Version: 6.4.3

Dockerfile to build a GitLab container image.

***Please refer to upgrading section if coming from previous version***

# Important notice for existing users
**/home/git/data** is now setup as the base data directory for the gitlab container. The .ssh, repositories, gitlab-satellites, uploads, backups and hooks directories are now all stored within this directory. This means that only one volume needs to be mounted at /home/git/data for all gitlab data.

To change to the new directory structure follow these steps:

```bash
sudo mkdir -p /opt/gitlab/data
sudo mv /opt/gitlab/.ssh /opt/gitlab/data/
sudo mv /opt/gitlab/repositories /opt/gitlab/data/
sudo mv /opt/gitlab/gitlab-satellites /opt/gitlab/data/
sudo mv /opt/gitlab/backups /opt/gitlab/data/
```

Replace the following parameters from the run command

```bash
-v /opt/gitlab/.ssh:/home/git/.ssh
-v /opt/gitlab/repositories:/home/git/repositories
-v /opt/gitlab/gitlab-satellites:/home/git/gitlab-satellites
-v /opt/gitlab/backups:/home/git/gitlab/tmp/backups
```

with

```bash
-v /opt/gitlab/data:/home/git/data
```

__NOTE__: A seperate volume still needs to be mounted for mysql data if the internal mysql server is used.

## Installation

Pull the docker image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the Trusted Build service.

```bash
docker pull sameersbn/gitlab
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/sameersbn/docker-gitlab.git
cd docker-gitlab
sudo docker build -t="$USER/gitlab" .
```

## Quick Start
Run the gitlab image

```bash
GITLAB=$(sudo docker run -d sameersbn/gitlab)
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

* /home/git/data

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
mkdir /opt/gitlab/data
docker run -d \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

### Configuring MySQL database connection
GitLab uses a database backend to store its data.

#### Using the internal mysql server
This docker image is configured to use a MySQL database backend. The database connection can be configured using environment variables. If not specified, the image will start a mysql server internally and use it. However in this case, the data stored in the mysql database will be lost if the container is stopped/deleted. To avoid this you should mount a volume at /var/lib/mysql.

```bash
mkdir /opt/gitlab/mysql
docker run -d \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql sameersbn/gitlab
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

To make sure the database is initialized start the container with **app:db:initialize** option.

**NOTE: This should be done only for the first run**.

*Assuming that the mysql server host is 192.168.1.100*

```bash
docker run -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:db:initialize
```

This will initialize the gitlab database. Now that the database is initialized, start the container without the initialize command.

```bash
docker run -d \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

### Configuring Mail
The mail configuration should be specified using environment variables while starting the GitLab image. The configuration defaults to using gmail to send emails and requires the specification of a valid username and password to login to the gmail servers.

The following environment variables need to be specified to get mail support to work.

* SMTP_HOST (defaults to smtp.gmail.com)
* SMTP_PORT (defaults to 587)
* SMTP_USER
* SMTP_PASS

```bash
docker run -d \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab
```

If you are not using google mail, then please configure the  SMTP host and port using the SMTP_HOST and SMTP_PORT configuration parameters.

__NOTE:__

I have only tested standard gmail and google apps login. I expect that the currently provided configuration parameters should be sufficient for most users. If this is not the case, then please let me know.

### Putting it all together

```bash
docker run -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -v /opt/gitlab/mysql:/var/lib/mysql \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  sameersbn/gitlab
```

If you are using an external mysql database

```bash
docker run -d -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  -e "DB_HOST=192.168.1.100" -e "DB_NAME=gitlabhq_production" -e "DB_USER=gitlab" -e "DB_PASS=password" \
  -e "GITLAB_HOST=git.local.host" -e "GITLAB_EMAIL=gitlab@local.host" -e "GITLAB_SUPPORT=support@local.host" \
  -e "SMTP_USER=USER@gmail.com" -e "SMTP_PASS=PASSWORD" \
  sameersbn/gitlab
```

## Taking backups

Gitlab defines a rake task to easily take a backup of your gitlab installation. The backup consists of all git repositories, uploaded files and as you might expect, the sql database.

Before taking a backup, please make sure that the gitlab image is not running for obvious reasons

```bash
docker stop <container-id>
```

To take a backup all you need to do is pass the "app:backup" command to the container image.

```bash
  docker run -i -t -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:backup
```

## Restoring Backups

Gitlab defines a rake task to easily restore a backup of your gitlab installation. Before performing the restore operation please make sure that the gitlab image is not running.

```bash
docker stop <container-id>
```

To restore a backup, run the image in interactive (-i -t) mode and pass the "app:restore" command to the container image.

```bash
  docker run -i -t -h git.local.host \
  -v /opt/gitlab/data:/home/git/data \
  sameersbn/gitlab app:restore
```

The restore operation will list all available backups in reverse chronological order. Select the backup you want to restore and gitlab will do its job.

## Upgrading

If you upgrading from previous version, please make sure you run the container with **app:db:migrate** command.

**Step 1: Stop the currently running image**

```bash
docker stop <container-id>
```

**Step 2: Backup the application data.**

```bash
docker run -i -t [OPTIONS] sameersbn/gitlab app:backup
```

**Step 3: Update the docker image.**

```bash
docker pull sameersbn/gitlab
```

**Step 4: Migrate the database.**

```bash
docker run -i -t [OPTIONS] sameersbn/gitlab app:db:migrate
```

**Step 5: Start the image**

```bash
docker run -i -d [OPTIONS] sameersbn/gitlab
```

### Other options
Below is the complete list of parameters that can be set using environment variables.

* GITLAB_HOST

        The hostname of the GitLab server. Defaults to localhost

* GITLAB_EMAIL

        The email address for the GitLab server. Defaults to gitlab@localhost.

* GITLAB_SUPPORT

        The support email address for the GitLab server. Defaults to support@localhost.

* GITLAB_SIGNUP

        Enable or disable gitlab user signup. Default is false. To enable user signup add '-e GITLAB_SIGNUP="true"' to the docker run command parameters.

* REDIS_HOST

        The hostname of the redis server. Defaults to localhost

* REDIS_PORT

        The connection port of the redis server. Defaults to 6379.

* UNICORN_WORKERS

        The number of unicorn workers to start. Defaults to 2.

* UNICORN_TIMEOUT

        Sets the timeout of unicorn worker processes. Defaults to 60 seconds.

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

* SMTP_HOST

        SMTP server host. Defaults to smtp.gmail.com.

* SMTP_PORT

        SMTP server port. Defaults to 587.

* SMTP_USER

        SMTP username.

* SMTP_PASS

        SMTP password.

## References
  * https://github.com/gitlabhq/gitlabhq
  * https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md
  * https://rtcamp.com/tutorials/linux/ubuntu-postfix-gmail-smtp
