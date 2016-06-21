GitLab Container Registry
=========================
Since `8.8.0` GitLab introduces container registry. Container Registry is a feature that handles your authentication for a docker registry.


- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
- [Upgrading from an existing GitLab instance](#Upgrading-from-an-existing-GitLab-instance)

# Prerequisites
  - [Docker Distribution](https://github.com/docker/distribution) >= 2.4
  - [Docker GitLab](https://github.com/sameersbn/docker-gitlab) >= 8.8.5-1

# Installation
Starting a fresh installation with GitLab Container registry would be like this `docker-compose` file.

## Generating certificate for authentication with the registry

You can skip the following steps if you have a **trusted certificate**.

- **Step 1**: Create a certs dir
 ```bash
 mkdir certs && cd certs
 ```

- **Step 2**: Generate a private key and sign request for the private key
```bash
openssl req -nodes -newkey rsa:4096 -keyout registry-auth.key -out registry-auth.csr -subj "/CN=gitlab-issuer"
```

- **Step 3**: Sign your created privated key
```bash
openssl x509 -in registry-auth.csr -out registry-auth.crt -req -signkey registry-auth.key -days 3650
```

## Docker Compose
```yml
version: '2'

services:
  redis:
    restart: always
    image: sameersbn/redis:latest
    command:
    - --loglevel warning
    volumes:
    - /srv/gitlab/redis:/var/lib/redis:Z
  postgresql:
    restart: always
    image: sameersbn/postgresql:9.4-22
    volumes:
    - /srv/gitlab/postgresql:/var/lib/postgresql:Z
    enviroment:
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production
    - DB_EXTENSION=pg_trgm

  gitlab:
    restart: always
    image: sameersbn/gitlab:8.8.5-1
    depends_on:
    - redis
    - postgresql
    ports:
    - "10080:80"
    - "5500:5000"
    - "10022:22"
    volumes:
    - /srv/gitlab/gitlab:/home/git/data:Z
    - /srv/gitlab/logs:/var/log/gitlab
    - ./certs:/certs
    enviroment:
    - DEBUG=false

    - DB_ADAPTER=postgresql
    - DB_HOST=postgresql
    - DB_PORT=5432
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production

    - REDIS_HOST=redis
    - REDIS_PORT=6379
    - GITLAB_SSH_PORT=1022
    - GITLAB_PORT=10080
    - GITLAB_HOST=localhost

    - GITLAB_SECRETS_DB_KEY_BASE=superrandomsecret
    - GITLAB_REGISTRY_ENABLED=true
    - GITLAB_REGISTRY_HOST=registry.gitlab.example.com
    - GITLAB_REGISTRY_PORT=5500
    - GITLAB_REGISTRY_API_URL=http://registry:5000
    - GITLAB_REGISTRY_KEY_PATH=/certs/registry-auth.key
    - SSL_REGISTRY_KEY_PATH=/certs/registry.key
    - SSL_REGISTRY_CERT_PATH=/certs/registry.crt

  registry:
    restart: always
    image: registry:2.4.1
    volumes:
     - /srv/gitlab/shared/registry:/registry
     - ./certs:/certs
    enviroment:
    - REGISTRY_LOG_LEVEL=info
    - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry
    - REGISTRY_AUTH_TOKEN_REALM=https://gitlab.example.com/jwt/auth
    - REGISTRY_AUTH_TOKEN_SERVICE=container_registry
    - REGISTRY_AUTH_TOKEN_ISSUER=gitlab-issuer
    - REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry-auth.crt
    - REGISTRY_STORAGE_DELETE_ENABLED=true
```
> **Important Notice**
>
> 1. Don't change `REGISTRY_AUTH_TOKEN_SERVICE`. It must have `container_registry` as value.
> 2. `REGISTRY_AUTH_TOKEN_REALM` need to be look like `http/s://gitlab.example.com/jwt/auth`. Endpoint must be `/jwt/auth`
> These configuration options are required by the GitLab Container Registry.

The trick is here that you are mounting the registry data as volume from `$GITLAB_REGISTRY_DIR`. So this adds the ability to do backups and restore them.


# Maintenance

## Creating Backups

Creating Backups is the same like without a container registry. I would recommend to stop your registry container.

```bash
docker stop registry gitlab && docker rm registry gitlab
```

Execute the rake task with a removeable container.
```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.8.5-1 app:rake gitlab:backup:create
```
## Restoring Backups

Gitlab also defines a rake task to restore a backup.

Before performing a restore make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop registry gitlab && docker rm registry gitlab
```

Execute the rake task to restore a backup. Make sure you run the container in interactive mode `-it`.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.8.5-1 app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.8.5-1 app:rake gitlab:backup:restore BACKUP=1417624827
```

# Upgrading from an existing GitLab installation


If you want enable this feature for an existing instance of GitLab you need to do the following steps.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/gitlab:8.8.5-1
```

- **Step 2**: Stop and remove the currently running image

```bash
docker stop gitlab && docker rm gitlab
```

- **Step 3**: Create a backup

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:x.x.x app:rake gitlab:backup:create
```

- **Step 4**: Create a certs folder
Create an authentication certificate with [Generating certificate for authentication with the registry](#Generating-certificate-for-authentication-with-the-registry).

- **Step 5**: Create an registry instance

> **Important Notice**
>
> Storage of the registry must be mounted from gitlab from GitLab.
> GitLab must have the container of the registry storage folder to be able to create and restore backups

```bash
docker run --name registry -d \
--restart=always \
-v /srv/gitlab/shared/registry:/registry \
-v ./certs:/certs \
--env 'REGISTRY_LOG_LEVEL=info' \
--env 'REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry' \
--env 'REGISTRY_AUTH_TOKEN_REALM=http://gitlab.example.com/jwt/auth' \
--env 'REGISTRY_AUTH_TOKEN_SERVICE=container_registry' \
--env 'REGISTRY_AUTH_TOKEN_ISSUER=gitlab-issuer' \
--env 'REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry-auth.crt' \
--env 'REGISTRY_STORAGE_DELETE_ENABLED=true' \
registry:2.4.1
```
- **Step 6**: Start the image

```bash
docker run --name gitlab -d [PREVIOUS_OPTIONS] \
-v /srv/gitlab/certs:/certs \
--env 'SSL_REGISTRY_CERT_PATH=/certs/registry.crt' \
--env 'SSL_REGISTRY_KEY_PATH=/certs/registry.key' \
--env 'GITLAB_REGISTRY_ENABLED=true' \
--env 'GITLAB_REGISTRY_HOST=registry.gitlab.example.com' \
--env 'GITLAB_REGISTRY_API_URL=http://registry:5000/' \
--env 'GITLAB_REGISTRY_KEY_PATH=/certs/registry-auth.key' \
--link registry:registry
sameersbn/gitlab:8.8.5-1
```
