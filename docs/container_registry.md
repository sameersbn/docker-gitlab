GitLab Container Registry
=========================
Since `8.8.0` GitLab introduces a container registry. GitLab is helping to authenticate the user against the registry and proxy it via Nginx. By [Registry](https://docs.docker.com/registry) we mean the registry from docker whereas *Container Registry* is the feature in GitLab.

- [Prerequisites](#prerequisites)
    - [Assumptions](#assumptions)
- [Installation](#installation)
    - [Create Auth Tokens](#create-auth-tokens)
- [Configuration](#configuration)
    - [Available Parameters](#available-parameters)
    - [ Storage driver](#storage-driver)
- [Maintenance](#maintenance)

# Prerequisites

  - [Docker Distribution](https://github.com/docker/distribution) >= 2.4
  - [Docker GitLab](https://github.com/sameersbn/docker-gitlab) >= 8.8.5-1

**Before you start this guide you should have a general understanding of**

 - [Docker Registry](https://docs.docker.com/registry/)
 - [Docker Registry configuration options](https://docs.docker.com/registry/configuration)
 - [Gitlabs Container registry integration](https://docs.gitlab.com/ce/administration/container_registry.html)

We will not duplicate all configuration/documentation but rather link directly to upstream gitlab/docker docs.

## Assumptions 

- We assume that you already have Nginx installed on your host system and that
you use a reverse proxy configuration to connect to your GitLab container.

- In this example we use a dedicated domain for the registry. The URLs for
the GitLab installation and the registry are:

* git.example.com
* registry.example.com

> Note: You could also run everything on the same domain and use different ports
> instead. The required configuration changes below should be straightforward.

# Installation

### Create auth tokens

GitLab needs a certificate ("auth token") to talk to the registry API. The
tokens must be provided in the `/certs` directory of your container. You could
use an existing domain ceritificate or create your own with a very long
lifetime (10 years) like this:

```bash
mkdir certs
cd certs
openssl req -new -newkey rsa:4096 > registry.csr
openssl rsa -in registry.csr -out registry.key
openssl x509 -in registry.csr -out registry.crt -req -signkey registry.key -days 3650 
```

It doesn't matter which details (domain name, etc.) you enter during key
creation. This information is not used at all.


### Update docker-compose.yml

First add the configuration for the registry container to your `docker-compose.yml`.

```yaml
    registry:
        image: registry
        restart: always
        expose:
            - "5000"
        ports:
            - "5000:5000"
        volumes:
            - ./gitlab/shared/registry:/registry
            - ./certs:/certs
        environment:
            # Change to info for production
            - REGISTRY_LOG_LEVEL=debug 
            - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry
            - REGISTRY_AUTH_TOKEN_REALM=https://git.example.com/jwt/auth
            - REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry.crt
            - REGISTRY_STORAGE_DELETE_ENABLED=true
            - REGISTRY_STORAGE_CACHE_BLOBDESCRIPTOR=inmemory
            # https://docs.docker.com/registry/configuration/#http 
            # If you are building a cluster of registries behind a load balancer, 
            # you MUST ensure the secret is the same for all registries.
            - REGISTRY_HTTP_SECRET=random-secure-value
            # NB do not change these values
            - REGISTRY_AUTH_TOKEN_SERVICE=container_registry
            - REGISTRY_AUTH_TOKEN_ISSUER=gitlab-issuer
```

> **Important:**
>
> 1. Don't change `REGISTRY_AUTH_TOKEN_SERVICE`. It must have
>    `container_registry` as value.
> 2. `REGISTRY_AUTH_TOKEN_REALM` must look like
>    `https://git.example.com/jwt/auth`. So the endpoint must be `/jwt/auth`.
>
> These configuration options are required by the GitLab Container Registry.

Then update the `volumes` and `environment` sections of your `gitlab` container:

```yaml
    gitlab:
        environment:
            # ...
            # Registry
            - GITLAB_REGISTRY_ENABLED=true
            # This is the public endpoint
            - GITLAB_REGISTRY_HOST=registry.example.com
            - GITLAB_REGISTRY_PORT=443
            # This is the internal endpoint
            - GITLAB_REGISTRY_API_URL=http://registry:5000
            - GITLAB_REGISTRY_KEY_PATH=/certs/registry.key

        volumes:
            - ./gitlab:/home/git/data
            - ./certs:/certs
```

# Configuration

## Available Parameters

Here is an example of all configuration parameters that can be used in the GitLab container. See the [Available Configuration Parameters](https://github.com/sameersbn/docker-gitlab#available-configuration-parameters).

## Storage driver

You can configure the Container Registry to use a different storage backend by
configuring a different storage driver. By default the GitLab Container Registry
is configured to use the *filesystem driver*, which makes use of `GITLAB_REGISTRY_PATH` 
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
[Docker Registry docs](https://docs.docker.com/registry/storage-drivers/).

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

Docker Configuration

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
    - REGISTRY_STORAGE_CACHE_BLOBDESCRIPTOR=inmemory
    - REGISTRY_STORAGE_DELETE_ENABLED=true
```

Generaly for more information about the configuration of the registry container you can find it under [registry configuration](https://docs.docker.com/registry/configuration).

# Maintenance
If you use another storage configuration than filesystem it will have no impact on your Maintenance workflow.

## Backups

See [Backup section in this repo](https://github.com/sameersbn/docker-gitlab#creating-backups) and [Offical Gitlab Docs](https://docs.gitlab.com/ce/raketasks/backup_restore.html)