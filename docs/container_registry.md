GitLab Container Registry
=========================
Since `8.8.0` GitLab introduces container registry. GitLab is helping to authenticate the user against the registry and proxy it via NGINX. If we are talking about [Registry](https://docs.docker.com/registry) we are meaning the registry from docker and Container Registry is the feature of GitLab.

- [Prerequisites](#prerequisites)
- [Available Parameters](#available-parameters)
- [Installation](#installation)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
- [Upgrading from an existing GitLab instance](#Upgrading-from-an-existing-GitLab-instance)

# Prerequisites

  - [Docker Distribution](https://github.com/docker/distribution) >= 2.4
  - [Docker GitLab](https://github.com/sameersbn/docker-gitlab) >= 8.8.5-1


# Available Parameters

Here is an example of all configuration parameters that can be used in the GitLab container.

```
...
gitlab:
    ...
    environment:
    - GITLAB_REGISTRY_ENABLED=true
    - GITLAB_REGISTRY_HOST=registry.gitlab.example.com
    - GITLAB_REGISTRY_PORT=5500
    - GITLAB_REGISTRY_API_URL=http://registry:5000
    - GITLAB_REGISTRY_KEY_PATH=/certs/registry-auth.key
    - GITLAB_REGISTRY_ISSUER=gitlab-issuer
    - SSL_REGISTRY_KEY_PATH=/certs/registry.key
    - SSL_REGISTRY_CERT_PATH=/certs/registry.crt
```

where:

| Parameter | Description |
| --------- | ----------- |
| `GITLAB_REGISTRY_ENABLED ` | `true` or `false`. Enables the Registry in GitLab. By default this is `false`. |
| `GITLAB_REGISTRY_HOST `    | The host URL under which the Registry will run and the users will be able to use. |
| `GITLAB_REGISTRY_PORT `    | The port under which the external Registry domain will listen on. |
| `GITLAB_REGISTRY_API_URL ` | The internal API URL under which the Registry is exposed to. |
| `GITLAB_REGISTRY_KEY_PATH `| The private key location that is a pair of Registry's `rootcertbundle`. Read the [token auth configuration documentation][token-config]. |
| `GITLAB_REGISTRY_PATH `    | This should be the same directory like specified in Registry's `rootdirectory`. Read the [storage configuration documentation][storage-config]. This path needs to be readable by the GitLab user, the web-server user and the Registry user *if you use filesystem as storage configuration*. Read more in [#container-registry-storage-path](#container-registry-storage-path). |
| `GITLAB_REGISTRY_ISSUER`  | This should be the same value as configured in Registry's `issuer`. Otherwise the authentication will not work. For more info read the [token auth configuration documentation][token-config]. |
| `SSL_REGISTRY_KEY_PATH `    | The private key of the `SSL_REGISTRY_CERT_PATH`. This will be later used in nginx to proxy your registry via https. |
| `SSL_REGISTRY_CERT_PATH `    | The certificate for the private key of `SSL_REGISTRY_KEY_PATH`. This will be later used in nginx to proxy your registry via https. |

For more info look at [Available Configuration Parameters](https://github.com/sameersbn/docker-gitlab#available-configuration-parameters).

A minimum set of these parameters are required to use the GitLab Container Registry feature.

```yml
...
gitlab:
    environment:
    - GITLAB_REGISTRY_ENABLED=true
    - GITLAB_REGISTRY_HOST=registry.gitlab.example.com
    - GITLAB_REGISTRY_API_URL=http://registry:5000
    - GITLAB_REGISTRY_KEY_PATH=/certs/registry-auth.key
    - GITLAB_REGISTRY_ISSUER=gitlab-issuer
...
```
# Installation

Starting a fresh installation with GitLab Container registry would be like the `docker-compose` file.

## Docker Compose

This is an example with a registry and filesystem as storage driver.

```yml
version: '2'

services:
  redis:
    restart: always
    image: sameersbn/redis:latest
    command:
    - --loglevel warning
    volumes:
    - ./redis:/var/lib/redis:Z
  postgresql:
    restart: always
    image: sameersbn/postgresql:9.5-4
    volumes:
    - ./postgresql:/var/lib/postgresql:Z
    environment:
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production
    - DB_EXTENSION=pg_trgm

  gitlab:
    restart: always
    image: sameersbn/gitlab:8.15.1
    depends_on:
    - redis
    - postgresql
    ports:
    - "10080:80"
    - "5500:5500"
    - "10022:22"
    volumes:
    - ./gitlab:/home/git/data:Z
    - ./logs:/var/log/gitlab
    - ./certs:/certs
    environment:
    - DEBUG=false

    - DB_ADAPTER=postgresql
    - DB_HOST=postgresql
    - DB_PORT=5432
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production

    - REDIS_HOST=redis
    - REDIS_PORT=6379
    - GITLAB_SSH_PORT=10022
    - GITLAB_PORT=10080
    - GITLAB_HOST=gitlab.example.com

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
    - ./gitlab/shared/registry:/registry
    - ./certs:/certs
    environment:
    - REGISTRY_LOG_LEVEL=info
    - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry
    - REGISTRY_AUTH_TOKEN_REALM=http://gitlab.example.com:10080/jwt/auth
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


## Generating certificate for authentication with the registry

So GitLab handles for us the authentication with Registry we need an certificate to do that secure.
With have here two options:

1. Use a signed certificate from an Trusted Certificate Authority.
2. Self-Signed Certificate for the authentication process.

### Signed Certificate
If you have a signed certificate from a Trusted Certificate Authority you need only to copy the files in then `certs` folder and mount the folder in both containers (gitlab,registry) like in the docker-compose example.
After that you need to set an environment variable in each container.
In the **GitLab Container** you need to set `GITLAB_REGISTRY_KEY_PATH` this is the private key of the signed certificate.
In the **Registry Container** you need to set `REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE` to the certificate file of the signed certificate.
For more info read [token auth configuration documentation][token-config].

### Self Signed Certificate

Generate a self signed certificate with openssl.

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

After this mount the `certs` dir in both containers and set the same environment variables like way of the signed certificate.



## Container Registry storage driver

You can configure the Container Registry to use a different storage backend by
configuring a different storage driver. By default the GitLab Container Registry
is configured to use the filesystem driver, which makes use of [storage path](#container-registry-storage-path)
configuration. These configurations will all be done in the registry container.

The different supported drivers are:

| Driver     | Description                         |
|------------|-------------------------------------|
| filesystem | Uses a path on the local filesystem |
| azure      | Microsoft Azure Blob Storage        |
| gcs        | Google Cloud Storage                |
| s3         | Amazon Simple Storage Service       |
| swift      | OpenStack Swift Object Storage      |
| oss        | Aliyun OSS                          |

Read more about the individual driver's config options in the
[Docker Registry docs][storage-config].

> **Warning** GitLab will not backup Docker images that are not stored on the filesystem. Remember to enable backups with your object storage provider if desired.
>
> If you use **filesystem** as storage driver you need to mount the path from `GITLAB_REGISTRY_DIR` of the GitLab container in the registry container. So both container can access the registry data.
> If you don't change `GITLAB_REGISTRY_DIR` you will find your registry data in the mounted volume from the GitLab Container under `./gitlab/shared/registry`. This don't need to be seprated mounted because `./gitlab` is already mounted in the GitLab Container. If it will be mounted seperated the whole restoring proccess of GitLab backup won't work because gitlab try to create an folder under `./gitlab/shared/registry` /`GITLAB_REGISTRY_DIR` and GitLab can't delete/remove the mount point inside the container so the restoring process of the backup will fail.
> An example how it works is in the `docker-compose`.

### Example for Amazon Simple Storage Service (s3)

If you want to configure your registry via `/etc/docker/registry/config.yml` your storage part should like this snippet below.

```yaml
storage:
  s3:
    accesskey: 'AKIAKIAKI'
    secretkey: 'secret123'
    bucket: 'gitlab-registry-bucket-AKIAKIAKI'
  cache:
    blobdescriptor: inmemory
  delete:
    enabled: true
```



```yaml
 ...
 registry:
    restart: always
    image: registry:2.4.1
    volumes:
     - ./certs:/certs
    environment:
    - REGISTRY_LOG_LEVEL=info
    - REGISTRY_AUTH_TOKEN_REALM=https://gitlab.example.com:10080/jwt/auth
    - REGISTRY_AUTH_TOKEN_SERVICE=container_registry
    - REGISTRY_AUTH_TOKEN_ISSUER=gitlab-issuer
    - REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry-auth.crt
    - REGISTRY_STORAGE_S3_ACCESSKEY=AKIAKIAKI
    - REGISTRY_STORAGE_S3_SECRETKEY=secret123
    - REGISTRY_STORAGE_S3_BUCKET=gitlab-registry-bucket-AKIAKIAKI
    - REGISTRY_CACHE_BLOBDESCRIPTOR=inmemory
    - REGISTRY_STORAGE_DELETE_ENABLED=true
```

Generaly for more information about the configuration of the registry container you can find it under [registry configuration](https://docs.docker.com/registry/configuration).


## Storage limitations

Currently, there is no storage limitation, which means a user can upload an
infinite amount of Docker images with arbitrary sizes. This setting will be
configurable in future releases.


# Maintenance
If you use another storage configuration than filesystem it will have no impact on your Maintenance workflow.

## Creating Backups

Creating Backups is the same like without a container registry. I would recommend to stop your registry container.

```bash
docker stop registry gitlab && docker rm registry gitlab
```

Execute the rake task with a removeable container.
```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.15.1 app:rake gitlab:backup:create
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
    sameersbn/gitlab:8.15.1 app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.15.1 app:rake gitlab:backup:restore BACKUP=1417624827
```

# Upgrading from an existing GitLab installation


If you want enable this feature for an existing instance of GitLab you need to do the following steps.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/gitlab:8.15.1
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
sameersbn/gitlab:8.15.1
```


[wildcard certificate]: https://en.wikipedia.org/wiki/Wildcard_certificate
[ce-4040]: https://gitlab.com/gitlab-org/gitlab-ce/merge_requests/4040
[docker-insecure]: https://docs.docker.com/registry/insecure/
[registry-deploy]: https://docs.docker.com/registry/deploying/
[storage-config]: https://docs.docker.com/registry/configuration/#storage
[token-config]: https://docs.docker.com/registry/configuration/#token
[8-8-docs]: https://gitlab.com/gitlab-org/gitlab-ce/blob/8-8-stable/doc/administration/container_registry.md
