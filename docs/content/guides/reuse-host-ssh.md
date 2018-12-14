+++
title = "Reuse Docker Host SSH Daemon"
description = "Guide on howto use the docker host SSH Daemon"
+++

It is possible to use the SSH daemon that runs on the docker host instead of using a separate SSH port for GitLab.

# Setup

Create the system `git` user if necessary (make sure it has a working shell):

```bash
useradd --system git --home-dir /srv/docker/gitlab/data
```

The home directory must point to GitLab data directory, as it takes `.ssh/authorized_keys` from there.

Now create `gitlab-shell` home directory at the same location as in the container:

```bash
mkdir -p /home/git/gitlab-shell/bin
```

Create the shell proxy script at `/home/git/gitlab-shell/bin/gitlab-shell`:

```bash
#!/bin/bash
# Proxy SSH requests to docker container
sudo docker exec -i -u git gitlab sh -c "SSH_CONNECTION='$SSH_CONNECTION' SSH_ORIGINAL_COMMAND='$SSH_ORIGINAL_COMMAND' $0 $1"
```

Make it executable:

```bash
chmod +x /home/git/gitlab-shell/bin/gitlab-shell
```

Allow `git` user limited sudo access to execute a command inside GitLab docker container:

```bash
echo "git ALL=NOPASSWD: /usr/bin/docker exec -i -u git gitlab *" > /etc/sudoers.d/docker-gitlab
```

# Run GitLab

Start the container, mapping the `uid` and `gid` of host `git` user:

```bash
docker run --name gitlab -it --rm [options] \
    --env "USERMAP_UID=$(id -u git)" --env "USERMAP_GID=$(id -g git)" \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

# Access GitLab

Use Docker host SSH server to access repositories:

```bash
git clone git@docker.host:group/project.git
```

# Advanced: Use default UID/GID in the container

If you rely on the default `uid` and `gid`, for example if you link GitLab to [sameersbn/redmine](https://github.com/sameersbn/docker-redmine) container, you can run the container without UID/GID mapping and use [incron](http://inotify.aiken.cz/?section=incron&page=about&lang=en) to keep `.ssh/authorized_keys` accessible by host `git` user:

```bash
docker run --name gitlab -it --rm [options] \
    sameersbn/gitlab:{{< param "Gitlab.Version" >}}
```

Create the script at `/srv/docker/gitlab/fix_ssh_permissions.incron.sh`:

```bash
#!/bin/bash
[ $(stat -c %G "$1") != "git" ] && chgrp git "$1"
[ -f "$1" -a $(stat -c %a "$1") != 640 ] && chmod 640 "$1"
[ -d "$1" -a $(stat -c %a "$1") != 710 ] && chmod 710 "$1"
```

Make it executable:

```bash
chmod +x /srv/docker/gitlab/fix_ssh_permissions.incron.sh
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
/srv/docker/gitlab/data/.ssh IN_ATTRIB /srv/docker/gitlab/fix_ssh_permissions.incron.sh $@/$#
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