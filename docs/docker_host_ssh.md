Reuse docker host SSH daemon
============================

It is possible to use the SSH daemon that runs on the docker host instead of using a separate SSH port for GitLab.

## Setup

Create the system `git` user if necessary (make sure it is added to `docker` group and has a working shell):

```bash
useradd --system git --home-dir /srv/docker/gitlab/data --groups docker
```

Note that the home directory must point to GitLab data directory, as it takes `.ssh/authorized_keys` from there.

Now create `gitlab-shell` home directory at the same location as in the container:

```bash
mkdir -p /home/git/gitlab-shell/bin
```

Create the shell proxy script at `/home/git/gitlab-shell/bin/gitlab-shell`:

```bash
#!/bin/bash
# Proxy SSH requests to docker container
docker exec -i -u git gitlab sh -c "SSH_CONNECTION='$SSH_CONNECTION' SSH_ORIGINAL_COMMAND='$SSH_ORIGINAL_COMMAND' $0 $1"
```

Make it executable:

```bash
chmod +x /home/git/gitlab-shell/bin/gitlab-shell
```

## Run GitLab

Start the container, mapping the `uid` and `gid` of host `git` user:

```bash
docker run --name gitlab -it --rm [options] \
    --env "USERMAP_UID=$(id -u git)" --env "USERMAP_GID=$(id -g git)" \
    sameersbn/gitlab:8.11.3
```

### (Optional) Use default UID/GID in the container

if you rely on the default `uid` and `git`, for example if you link GitLab to [sameersbn/redmine](https://github.com/sameersbn/docker-redmine) container, you can run the container without UID/GID mapping and use [incron](http://inotify.aiken.cz/?section=incron&page=about&lang=en) to keep `.ssh/authorized_keys` accessible by host `git` user:

```bash
docker run --name gitlab -it --rm [options] \
    sameersbn/gitlab:8.11.3
```

Create the script at `/srv/docker/gitlab/data/fix_ssh_permissions.incron.sh`:

```bash
#!/bin/bash
[ $(stat -c %G "$1") != "git" ] && chgrp git "$1"
[ -f "$1" -a $(stat -c %a "$1") != 640 ] && chmod 640 "$1"
[ -d "$1" -a $(stat -c %a "$1") != 710 ] && chmod 710 "$1"
```

Make it executable:

```bash
chmod +x /srv/docker/gitlab/data/fix_ssh_permissions.incron.sh
```

Install incron:

```bash
apt-get install -y incron
echo root >> /etc/incron.allow
```

Open incrontab editor:

```bash
incrontab -e
```

and paste this:

```
/srv/docker/gitlab/data/.ssh IN_ATTRIB /srv/docker/gitlab/data/fix_ssh_permissions.incron.sh $@/$#
```

Start incrond and touch `authorized_keys` to have the permissions fixed:

```
/etc/init.d/incrond start
touch /srv/docker/gitlab/data/.ssh
touch /srv/docker/gitlab/data/.ssh/authorized_keys
```

Ensure that OpenSSH is running without `StrictModes`:

```
sed -i 's/StrictModes yes/StrictModes no/' /etc/ssh/sshd_config
/etc/init.d/ssh reload
```

## Access GitLab

Use Docker host to access repositories:

```bash
git clone git@docker.host:group/project.git
```
