# Docker Swarm mode deployment

Here's a guide to deploy **GitLab** with:

* [Docker Swarm mode](https://docs.docker.com/engine/swarm/) for cluster management and orchestration.
* [Docker Registry](https://docs.docker.com/registry/) with HTTPS, TLS (SSL) handled automatically, using GitLab credentials and integration with GitLab CI.
* [Traefik](https://traefik.io/) proxy to handle domain based redirection, HTTPS communication and automatic certificate generation with [Let's encrypt](https://letsencrypt.org/). You don't need to build a custom Nginx proxy or anything similar, it's all handled by Traefik.
* Automatic generation and configuration of GitLab / Registry internal communication certificates.

## Set up Docker Swarm

Set up a Docker Swarm mode cluster with a main global Traefik load balancer following the guide at [DockerSwarm.rocks](https://dockerswarm.rocks).

It will take you less than 20 minutes to follow it to deploy a cluster (of one or more machines) and have it ready for the next steps.

## Configure DNS records

Configure your DNS domain records to point one subdomain for your GitLab instance and one subdomain for the Docker Registry to the new server.

For example, a DNS `A` record for `gitlab.example.com` and a DNS `A` record for `registry.example.com`.

If you have a cluster with several nodes, make sure those DNS records point to the IP of the node that will host the `gitlab` and `registry` services.

This is because `gitlab` has to listen on port `22` for Git to work, but we will configure it to make it listen on port `22` only on the server that has GitLab.

That way, if you have other servers in your cluster, you won't have to change the default SSH port of all of them.

## Modify the server SSH port

As by default Git uses the same SSH port `22`, and you want your GitLab container to use that port, modify your server SSH configuration to use a different port. This guide will assume you will use port `2222` for your server SSH and port `22` for your GitLab.

Connect to your remote server as normally, e.g.:

```bash
ssh root@gitlab.example.com
```

Create a backup of your SSH config file:

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

Modify your SSH config.

**Warning**: if something is broken after modifying the SSH configuration, you could lock yourself out of the server.

You need to have a line `Port 2222` and make sure there's no line `Port 22`.

You can use this command to do it automatically, it will check for a line with `Port 22` or `#Port 22` and replace it with `Port 2222`.

```bash
sed -i 's|^#\?Port 22$|Port 2222|' /etc/ssh/sshd_config
```

Or you can modify it with `nano` by hand, with:

```bash
nano /etc/ssh/sshd_config
```

Confirm that there's a single line with `Port 2222` with:

```bash
grep "^Port" /etc/ssh/sshd_config
```

Then restart the SSH server:

```bash
systemctl restart sshd.service
```

**Warning**: at this point, if you lose your connection and something was wrong in the configuration, you could lock yourself out of the server. Run the following steps in a new terminal session, without closing the existing one, so that, if something was wrong, you can use the current session to edit the configurations, revert them, and restart the SSH service, before being locked out.

In a different terminal session, without closing the existing one, try connecting with SSH to your server using the new port, e.g.:

```bash
ssh -p 2222 root@gitlab.example.com
```

If you get connected to the remote server normally, everything is working correctly.

## Download the Docker Compose stack file

* Download the Docker Compose stack file:

```bash
curl -L https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.swarm.yml -o docker-compose.swarm.yml
```

## Set environment variables

Set and export the environment variables `GITLAB_HOST` and `REGISTRY_HOST` to the subdomains you configured.

For example:

```bash
export GITLAB_HOST=gitlab.example.com
export REGISTRY_HOST=registry.example.com
```

You will use the domain for `GITLAB_HOST` to access GitLab in your browser and to commit and push with Git.

And you will use the domain for `REGISTRY_HOST` to store, push, and pull Docker images, e.g.:

```bash
docker pull registry.example.com/mygroup/myproject/imagename:sometag
```

These environment variables will be used by the file `docker-compose.swarm.yml`.

They are used inside of the stacks and are also used to configure the domains for the Traefik load balancer. Because of that, you need to export them for them to be available when deploying the stack.

## Other environment variables

There are many additional environment variables with different configurations.

Read the [main README](https://github.com/sameersbn/docker-gitlab) for all the options.

For Registry specific options and details, check the main [GitLab Registry documentation in this repo](https://github.com/sameersbn/docker-gitlab/blob/master/docs/container_registry.md).

You can configure them by editing de file `docker-compose.swarm.yml`.

You can do it in the command line with a program like `nano`, e.g.:

```bash
nano docker-compose.swarm.yml
```

## Set other environment variables

If you want anyone to sign up instead of only people with invitation, change `GITLAB_SIGNUP_ENABLED` to `true`:

```bash
export GITLAB_SIGNUP_ENABLED=true
```

There are several environment variables that require random strings for keys and passwords.

For the sections that require generating random strings for keys and passwords, each time, run the following command and copy the output:

```bash
openssl rand -hex 32
# Outputs something like: 99d3b1f01aa639e4a76f4fc281fc834747a543720ba4c8a8648ba755aef9be7f
```

You can copy it and set it in the file like:

```yaml
- GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alphanumeric-string
- GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alphanumeric-string
- GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alphanumeric-string
```

There are several other settings that you might want to configure, like email accounts for notifications, SMTP credentials to send emails, etc.

## Copy the file

If you modified the file locally, make sure you copy it to your remote server, e.g.:

```bash
scp -P 2222 docker-compose.swarm.yml root@gitlab.example.com:/root/
```

and connect via SSH to your remote server, e.g.:

```bash
ssh -p 2222 root@gitlab.example.com
```

If you modified the file locally and then connected to your server later, make sure you export the environment variables `GITLAB_HOST` and `REGISTRY_HOST` that are needed even if you modified the Docker Compose file (as those are used in the Traefik labels).

## About volumes, labels, and constraints

Because the Docker Swarm cluster may have more than one single node (machine) in the cluster, we need to make sure that the services that need to save and read files from volumes are always deployed to the same node.

For example, the service for `redis` uses a volume, you can check it on the `docker-compose.swarm.yml` file:

```yaml
    volumes:
    - redis-data:/var/lib/redis:Z
```

To make sure `redis` is always deployed to the same node that contains the same volume `redis-data`, we have a constraint:

```yaml
    deploy:
      placement:
        constraints:
          - node.labels.gitlab.redis-data == true
```

This tells Docker that the service `redis` should be deployed to a Docker node (a machine in the cluster) with the label `node.labels.gitlab.redis-data=true`.

Then we can make one node (only one) have this label, and Docker Swarm will always deploy the `redis` service to the same node. That way, the service will keep reading the same volume every time. Even if you re-deploy or upgrade the stack.

## Add constraint labels

Now we are going to add the needed labels to satisfy those constraints, to make sure the volumes work correctly.

* Connect to a manager node in your Docker Swarm cluster. It could be the same server that will run GitLab, or it could be a different one.

* If you are deploying the stack in the same current manager node, get its node ID and store it in an environment variable:

```bash
export NODE_ID=$(docker info -f '{{.Swarm.NodeID}}')
```

* Otherwise, you can check the current available nodes with:

```console
$ docker node ls

ID                            HOSTNAME             STATUS   AVAILABILITY   MANAGER STATUS   ENGINE VERSION
m48gz5e8ucmk59af4m6enmnaz *   dog.example.com      Ready    Active         Leader           19.03.9
4w456u9lnanau629v3y456k9d     cat.example.com      Ready    Active                          19.03.9
mue36qqwqnzrqt4iqi0yyd6ie     gitlab.example.com   Ready    Active                          19.03.9
```

And select the node where you want to deploy the main `gitlab` service. In this example, in the node that has a `HOSTNAME` with value `gitlab.example.com`, with node ID `mue36qqwqnzrqt4iqi0yyd6ie`.

So, you could export that environment variable using the node ID with something like:

```bash
export NODE_ID=mue36qqwqnzrqt4iqi0yyd6ie
```

* Create a label in that node, so that the service `gitlab` and `registry` are always deployed to the same node and use the same volumes:

```bash
docker node update --label-add gitlab.certs-data=true $NODE_ID
```

We need to make sure `gitlab` and `registry` are deployed on the same node because they share the same volume with the TLS certificates generated by `gitlab`.

Now create the label for `redis`. You could use another node in your cluster if you have more than one, for simplicity we are going to use the same node, e.g.:

```bash
docker node update --label-add gitlab.redis-data=true $NODE_ID
```

And add the label for `postgres`:

```bash
docker node update --label-add gitlab.postgresql-data=true $NODE_ID
```

**Note**: you only have to set those labels once. Not every time you want to re-deploy your stack.

## Deploy the stack

Now, having the labels set in the Docker nodes, and the environment variables exported, you can deploy your stack:

```bash
docker stack deploy --compose-file docker-compose.swarm.yml gitlab
```

**Note**: the environment variables `GITLAB_HOST` and `REGISTRY_HOST` have to be available every time to deploy the stack. But the node labels can be set only once, the first time you deploy.

You can check the status of the deployment with:

```bash
docker stack ps gitlab
```

Or check the logs, for example for the service `gitlab_gitlab`:

```bash
docker service logs gitlab_gitlab
```

## Internal certificates

GitLab and the Docker Registry have public facing HTTPS certificates generated with Let's Encrypt for each one. But to communicate between themselves they use an additional self-signed certificate.

To tell GitLab to generate those self-signed certificates for the internal communication with GitLab, the `gitlab` service has an environment variable:

```yaml
- GITLAB_REGISTRY_GENERATE_INTERNAL_CERTIFICATES=true
```

GitLab will generate the certificates and store them in the location given by:

```yaml
- GITLAB_REGISTRY_KEY_PATH=/certs/registry.key
```

And that location, `/certs`, is mounted as a named volume:

```yaml
    volumes:
    - gitlab-data:/home/git/data:Z
    - certs-data:/certs
```

So, the self-signed certificates will be generated inside the named volume `gitlab-certs`.

And the Registry also has that named volume mounted:

```yaml
    volumes:
      - registry-data:/registry
      - certs-data:/certs
```

And the Registry is configured to look for the certificate in that same location that GitLab used to generate the certificate:

```yaml
- REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry.crt
```

## GitLab Runner in Docker

If you use GitLab and want to integrate Continuous Integration / Continuous Deployment, you can follow this section to install the GitLab runner.

You should create the runner using Docker standalone instead of in Docker Swarm mode, as you need the configurations to persist, and in Docker Swarm mode, the container could be deployed to a different server and you would lose those configurations.

### Testing and Deployment

For testing, the GitLab runner can run in any node.

But if you want to deploy another runner for deployment (or use the same one), it has to run on a manager node in the Docker Swarm cluster.

### Create the GitLab Runner in Docker standalone mode

To install a GitLab runner in a standalone Docker run:

```bash
docker run -d \
    --name gitlab-runner \
    --restart always \
    -v gitlab-runner:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest
```

Then, enter into that container:

```bash
docker exec -it gitlab-runner bash
```

### Install the GitLab Runner

* Go to the GitLab "Admin Area -> Runners" section.
* Get the URL and create a variable with it in the bash session inside of your Runner's Docker container, e.g.:

```bash
export GITLAB_URL=https://gitlab.example.com/
```

* Get the registration token and create a variable in the bash session inside of your Runner's Docker container, e.g.:

```bash
export GITLAB_TOKEN=WYasdfJp4sdfasdf1234
```

* Run the next command editing the name and tags as you need, you can also edit them later in the web user interface.

```bash
gitlab-runner \
    register -n \
    --name "Docker Runner" \
    --executor docker \
    --docker-image docker:latest \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
    --url $GITLAB_URL \
    --registration-token $GITLAB_TOKEN \
    --tag-list dog-cat-cluster,stag,prod
```

* You can edit the runner more from the GitLab admin section.
