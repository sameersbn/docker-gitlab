# GitLab Backup to s3 compatible storage

Enables automatic backups to self-hosted s3 compatible storage like minio (<https://minio.io/>) and others.
This is an extend of AWS Remote Backups.

As explained in [doc.gitlab.com](https://docs.gitlab.com/ce/raketasks/backup_restore.html#upload-backups-to-remote-cloud-storage), it uses [Fog library](http://fog.io) and the module fog-aws. More details on [s3 supported parameters](https://github.com/fog/fog-aws/blob/master/lib/fog/aws/storage.rb)

- [GitLab Backup to s3 compatible storage](#gitlab-backup-to-s3-compatible-storage)
  - [Available Parameters](#available-parameters)
  - [Installation](#installation)
    - [Docker Compose](#docker-compose)
    - [Creating Backups](#creating-backups)
    - [Restoring Backups](#restoring-backups)

## Available Parameters

Here is an example of all configuration parameters that can be used in the GitLab container.

```yaml
...
gitlab:
    ...
    environment:
    - AWS_BACKUPS=true
    - AWS_BACKUP_ENDPOINT='http://minio:9000'
    - AWS_BACKUP_ACCESS_KEY_ID=minio
    - AWS_BACKUP_SECRET_ACCESS_KEY=minio123
    - AWS_BACKUP_BUCKET=docker
    - AWS_BACKUP_MULTIPART_CHUNK_SIZE=104857600
```

where:

| Parameter | Description |
| --------- | ----------- |
| `AWS_BACKUPS` | Enables automatic uploads to an Amazon S3 instance. Defaults to `false`. |
| `AWS_BACKUP_ENDPOINT` | AWS endpoint. No defaults. |
| `AWS_BACKUP_ACCESS_KEY_ID` | AWS access key id. No defaults. |
| `AWS_BACKUP_SECRET_ACCESS_KEY` | AWS secret access key. No defaults. |
| `AWS_BACKUP_BUCKET` | AWS bucket for backup uploads. No defaults. |
| `AWS_BACKUP_MULTIPART_CHUNK_SIZE` | Enables multipart uploads when file size reaches a defined size. See at [AWS S3 Docs](http://docs.aws.amazon.com/AmazonS3/latest/dev/uploadobjusingmpu.html) |

For more info look at [Available Configuration Parameters](https://github.com/sameersbn/docker-gitlab#available-configuration-parameters).

A minimum set of these parameters are required to use the s3 compatible storage:

```yaml
...
gitlab:
    environment:
    - AWS_BACKUPS=true
    - AWS_BACKUP_ENDPOINT='http://minio:9000'
    - AWS_BACKUP_ACCESS_KEY_ID=minio
    - AWS_BACKUP_SECRET_ACCESS_KEY=minio123
    - AWS_BACKUP_BUCKET=docker
...
```

## Installation

Starting a fresh installation with GitLab would be like the `docker-compose` file.

### Docker Compose

This is an example with minio.

```yml
services:
  redis:
    restart: always
    image: sameersbn/redis:7
    command:
    - --loglevel warning
    volumes:
    - /tmp/docker/gitlab/redis:/data:Z

  postgresql:
    restart: always
    image: sameersbn/postgresql:10-2
    volumes:
    - /tmp/docker/gitlab/postgresql:/var/lib/postgresql:Z
    environment:
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production
    - DB_EXTENSION=pg_trgm

  gitlab:
    restart: always
    #image: sameersbn/gitlab:8.16.4
    build: .
    depends_on:
    - redis
    - postgresql
    ports:
    - "10080:80"
    - "10022:22"
    volumes:
    - /tmp/docker/gitlab/gitlab:/home/git/data:Z
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
    - TZ=Asia/Kolkata
    - GITLAB_TIMEZONE=Kolkata
    - GITLAB_HTTPS=false
    - SSL_SELF_SIGNED=false
    - GITLAB_HOST=localhost
    - GITLAB_PORT=10080
    - GITLAB_SSH_PORT=10022
    - GITLAB_RELATIVE_URL_ROOT=
    - GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_ENCRYPTED_SETTINGS_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_ROOT_PASSWORD=
    - GITLAB_ROOT_EMAIL=
    - GITLAB_NOTIFY_ON_BROKEN_BUILDS=true
    - GITLAB_NOTIFY_PUSHER=false
    - GITLAB_EMAIL=notifications@example.com
    - GITLAB_EMAIL_REPLY_TO=noreply@example.com
    - GITLAB_INCOMING_EMAIL_ADDRESS=reply@example.com
    - GITLAB_BACKUP_SCHEDULE=daily
    - GITLAB_BACKUP_TIME=01:00
    - SMTP_ENABLED=false
    - SMTP_DOMAIN=www.example.com
    - SMTP_HOST=smtp.gmail.com
    - SMTP_PORT=587
    - SMTP_USER=mailer@example.com
    - SMTP_PASS=password
    - SMTP_STARTTLS=true
    - SMTP_AUTHENTICATION=login
    - IMAP_ENABLED=false
    - IMAP_HOST=imap.gmail.com
    - IMAP_PORT=993
    - IMAP_USER=mailer@example.com
    - IMAP_PASS=password
    - IMAP_SSL=true
    - IMAP_STARTTLS=false
    - OAUTH_ENABLED=false
    - OAUTH_AUTO_SIGN_IN_WITH_PROVIDER=
    - OAUTH_ALLOW_SSO=
    - OAUTH_BLOCK_AUTO_CREATED_USERS=true
    - OAUTH_AUTO_LINK_LDAP_USER=false
    - OAUTH_AUTO_LINK_SAML_USER=false
    - OAUTH_EXTERNAL_PROVIDERS=
    - OAUTH_CAS3_LABEL=cas3
    - OAUTH_CAS3_SERVER=
    - OAUTH_CAS3_DISABLE_SSL_VERIFICATION=false
    - OAUTH_CAS3_LOGIN_URL=/cas/login
    - OAUTH_CAS3_VALIDATE_URL=/cas/p3/serviceValidate
    - OAUTH_CAS3_LOGOUT_URL=/cas/logout
    - OAUTH_GOOGLE_API_KEY=
    - OAUTH_GOOGLE_APP_SECRET=
    - OAUTH_GOOGLE_RESTRICT_DOMAIN=
    - OAUTH_FACEBOOK_API_KEY=
    - OAUTH_FACEBOOK_APP_SECRET=
    - OAUTH_TWITTER_API_KEY=
    - OAUTH_TWITTER_APP_SECRET=
    - OAUTH_GITHUB_API_KEY=
    - OAUTH_GITHUB_APP_SECRET=
    - OAUTH_GITHUB_URL=
    - OAUTH_GITHUB_VERIFY_SSL=
    - OAUTH_GITLAB_API_KEY=
    - OAUTH_GITLAB_APP_SECRET=
    - OAUTH_BITBUCKET_API_KEY=
    - OAUTH_BITBUCKET_APP_SECRET=
    - OAUTH_BITBUCKET_URL=
    - OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL=
    - OAUTH_SAML_IDP_CERT_FINGERPRINT=
    - OAUTH_SAML_IDP_SSO_TARGET_URL=
    - OAUTH_SAML_ISSUER=
    - OAUTH_SAML_LABEL="Our SAML Provider"
    - OAUTH_SAML_NAME_IDENTIFIER_FORMAT=urn:oasis:names:tc:SAML:2.0:nameid-format:transient
    - OAUTH_SAML_GROUPS_ATTRIBUTE=
    - OAUTH_SAML_EXTERNAL_GROUPS=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_EMAIL=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_NAME=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_USERNAME=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_FIRST_NAME=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_LAST_NAME=
    - OAUTH_CROWD_SERVER_URL=
    - OAUTH_CROWD_APP_NAME=
    - OAUTH_CROWD_APP_PASSWORD=
    - OAUTH_AUTH0_CLIENT_ID=
    - OAUTH_AUTH0_CLIENT_SECRET=
    - OAUTH_AUTH0_DOMAIN=
    - OAUTH_AUTH0_SCOPE=
    - OAUTH_AZURE_API_KEY=
    - OAUTH_AZURE_API_SECRET=
    - OAUTH_AZURE_TENANT_ID=
    - AWS_BACKUPS=true
    - AWS_BACKUP_ENDPOINT='http://minio:9000'
    - AWS_BACKUP_ACCESS_KEY_ID=minio
    - AWS_BACKUP_SECRET_ACCESS_KEY=minio123
    - AWS_BACKUP_BUCKET=docker

  minio:
    image: minio/minio
    ports:
      - "9000:9000"
    environment:
      MINIO_ACCESS_KEY: minio
      MINIO_SECRET_KEY: minio123
    command: server /export
```

### Creating Backups

Execute the rake task with a removeable container.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.16.4 app:rake gitlab:backup:create
```

### Restoring Backups

Execute the rake task to restore a backup. Make sure you run the container in interactive mode `-it`.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.16.4 app:rake gitlab:backup:restore
```

The list of all available backups will be displayed in reverse chronological order. Select the backup you want to restore and continue.

To avoid user interaction in the restore operation, specify the timestamp of the backup using the `BACKUP` argument to the rake task.

```bash
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:8.16.4 app:rake gitlab:backup:restore BACKUP=1417624827
```
