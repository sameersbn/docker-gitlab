GitLab Container Registry
=========================
Since `8.8.0` GitLab introduces a container registry. GitLab is helping to authenticate the user against the registry and proxy it via Nginx. By [Registry](https://docs.docker.com/registry) we mean the registry from docker whereas *Container Registry* is the feature in GitLab.

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Maintenance](#maintenance)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)
- [Upgrading from an existing GitLab instance](#Upgrading-from-an-existing-GitLab-instance)

# Prerequisites

  - [Docker Distribution](https://github.com/docker/distribution) >= 2.4
  - [Docker GitLab](https://github.com/sameersbn/docker-gitlab) >= 8.8.5-1


# Installation

## Setup with Nginx as Reverse Proxy

We assume that you already have Nginx installed on your host system and that
you use a reverse proxy configuration to connect to your GitLab container.

In this example we use a dedicated domain for the registry. The URLs for
the GitLab installation and the registry are:

* git.example.com
* registry.example.com

> Note: You could also run everything on the same domain and use different ports
> instead. The required configuration changes below should be straightforward.

### Create auth tokens

GitLab needs a certificate ("auth token") to talk to the registry API. The
tokens must be provided in the `/certs` directory of your container. You could
use an existing domain ceritificate or create your own with a very long
lifetime like this:

```bash
mkdir certs
cd certs
# Generate a random password password_file used in the next commands
openssl rand -hex -out password_file 32
# Create a PKCS#10 certificate request
openssl req -new -passout file:password_file -newkey rsa:4096 -batch > registry.csr
# Convert RSA key
openssl rsa -passin file:password_file -in privkey.pem -out registry.key
# Generate certificate
openssl x509 -in registry.csr -out registry.crt -req -signkey registry.key -days 10000
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
            - REGISTRY_LOG_LEVEL=info
            - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry
            - REGISTRY_AUTH_TOKEN_REALM=https://git.example.com/jwt/auth
            - REGISTRY_AUTH_TOKEN_SERVICE=container_registry
            - REGISTRY_AUTH_TOKEN_ISSUER=gitlab-issuer
            - REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry.crt
            - REGISTRY_STORAGE_DELETE_ENABLED=true
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
            - GITLAB_REGISTRY_HOST=registry.example.com
            - GITLAB_REGISTRY_PORT=443
            - GITLAB_REGISTRY_API_URL=http://registry:5000
            - GITLAB_REGISTRY_KEY_PATH=/certs/registry.key

        volumes:
            - ./gitlab:/home/git/data
            - ./certs:/certs
```

### Nginx Site Configuration

```nginx
server {
    root /dev/null;
    server_name registry.example.com;
    charset UTF-8;
    access_log /var/log/nginx/registry.example.com.access.log;
    error_log /var/log/nginx/registry.example.com.error.log;

    # Set up SSL only connections:
    listen *:443 ssl http2;
    ssl_certificate             /etc/letsencrypt/live/registry.example.com/fullchain.pem;
    ssl_certificate_key         /etc/letsencrypt/live/registry.example.com/privkey.pem;

    ssl_ciphers 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4';
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_session_timeout  5m;

    client_max_body_size        0;
    chunked_transfer_encoding   on;

    location / {
        proxy_set_header  Host              $http_host;   # required for docker client's sake
        proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
        proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header  X-Forwarded-Proto $scheme;
        proxy_read_timeout                  900;
        proxy_pass        http://localhost:5000;
    }
}

server {
    listen *:80;
    server_name  registry.example.com;
    server_tokens off; ## Don't show the nginx version number, a security best practice
    return 301 https://$http_host:$request_uri;
}
```

# Configuration

## Available Parameters

Here is an example of all configuration parameters that can be used in the GitLab container.

```yml
...
gitlab:
    ...
    environment:
    - GITLAB_REGISTRY_ENABLED=true
    - GITLAB_REGISTRY_HOST=registry.gitlab.example.com
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
    sameersbn/gitlab:13.10.2 app:rake gitlab:backup:create
```
## Restoring Backups

GitLab also defines a rake task to restore a backup.

Before performing a restore make sure the container is stopped and removed to avoid container name conflicts.

```bash
docker stop registry gitlab && docker rm registry gitlab
```

Execute the rake task to restore a backup. Make sure you run the container in interactive mode `-it`.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:13.10.2 app:rake gitlab:backup:restore BACKUP=1417624827
```

# Upgrading from an existing GitLab installation


If you want enable this feature for an existing instance of GitLab you need to do the following steps.

- **Step 1**: Update the docker image.

```bash
docker pull sameersbn/gitlab:13.10.2
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
Create an authentication certificate with [Generating certificate for authentication with the registry](#generating-certificate-for-authentication-with-the-registry).

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
--env 'GITLAB_REGISTRY_CERT_PATH=/certs/registry-auth.crt' \
--env 'GITLAB_REGISTRY_KEY_PATH=/certs/registry-auth.key' \
--link registry:registry
sameersbn/gitlab:13.10.2
```


[wildcard certificate]: https://en.wikipedia.org/wiki/Wildcard_certificate
[ce-4040]: https://gitlab.com/gitlab-org/gitlab-foss/merge_requests/4040
[docker-insecure]: https://docs.docker.com/registry/insecure/
[registry-deploy]: https://docs.docker.com/registry/deploying/
[storage-config]: https://docs.docker.com/registry/configuration/#storage
[token-config]: https://docs.docker.com/registry/configuration/#token
[8-8-docs]: https://gitlab.com/gitlab-org/gitlab-foss/blob/8-8-stable/doc/administration/container_registry.md
