# Docker Swarm mode deployment

How to deploy **GitLab** from scratch in a clean server with the following features:

* [Docker Swarm mode](https://docs.docker.com/engine/swarm/) for cluster management and orchestration.
* [Docker Registry](https://docs.docker.com/registry/) with HTTPS, TLS (SSL) handled automatically, using GitLab credentials and integration with GitLab CI.
* [Traefik](https://traefik.io/) proxy to handle domain based redirection, HTTPS communication and automatic certificate generation with [Let's encrypt](https://letsencrypt.org/). You don't need to build a custom Nginx proxy or anything similar, it's all handled by Traefik.
* Automatic generation and configuration of GitLab / Registry internal communication certificates.

## Install a new Linux server with Docker

* Create a new remote server (VPS).
* If you can create a `swap` disk partition, do it based on the [Ubuntu FAQ for swap partitions](https://help.ubuntu.com/community/SwapFaq#How_much_swap_do_I_need.3F).
* Deploy your Linux distribution. As a suggestion, the latest Ubuntu LTS version image.
* Connect to it via SSH, e.g.:

```bash
ssh root@172.173.174.175
```

* Update packages:

```bash
# Install the latest updates
apt-get update
apt-get upgrade -y
```

* Install Docker following the official guide: https://docs.docker.com/install/
* Or alternatively, run the official convenience script, but have in mind that it would install the `edge` version:

```bash
# Download Docker
curl -fsSL get.docker.com -o get-docker.sh
# Install Docker
sh get-docker.sh
# Remove Docker install script
rm get-docker.sh
```

## Modify the server SSH port

As by default Git uses the same SSH port `22`, and you want your GitLab container to use that port, modify your server SSH configuration to use a different port. This guide will assume you will use port `2222` for your server SSH and port `22` for your GitLab.

Connect to your remote server as normally, e.g.:

```bash
ssh root@172.173.174.175
```

Create a backup of your SSH config file:

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
```

Modify your SSH config. 

**Warning**: if something is broken after modifying the SSH configuration, you could lock yourself out of the server.


You need to change the line `Port 22` to `Port 2222`. You can do it with this command:

```bash
sed -i 's|Port 22$|Port 2222|' /etc/ssh/sshd_config
```

Or you can modify it with `nano` by hand, with:

```bash
nano /etc/ssh/sshd_config
```

Then restart the SSH server:

```bash
systemctl restart sshd.service
```

**Warning**: at this point, if you lose your connection and something was wrong in the configuration, you could lock yourself out of the server. Run the following steps in a new terminal session, without closing the existing one, so that, if something was wrong, you can use the current session to edit the configurations, revert them, and restart the SSH service, before being locked out.

In a different terminal session, without closing the existing one, try connecting with SSH to your server using the new port, e.g.:

```bash
ssh -p 2222 root@172.173.174.175
```

If you get connected to the remote server normally, everything is fine.


## Set up swarm mode

In Docker Swarm Mode you have one or more "manager" nodes and one or more "worker" nodes (that can be the same manager nodes).

The first step, is to configure one (or more) manager nodes.

* On the main manager node, run:

```bash
docker swarm init
```

* On the main manager node, for each additional manager node you want to set up, run:

```bash
docker swarm join-token manager
```

* Copy the result and paste it in the additional manager node's terminal, it will be something like:

```bash
 docker swarm join --token SWMTKN-1-5tl7yaasdfd9qt9j0easdfnml4lqbosbasf14p13-f3hem9ckmkhasdf3idrzk5gz 172.173.174.175:2377
```

* On the main manager node, for each additional worker node you want to set up, run:

```bash
docker swarm join-token worker
```

* Copy the result and paste it in the additional worker node's terminal, it will be something like:

```bash
docker swarm join --token SWMTKN-1-5tl7ya98erd9qtasdfml4lqbosbhfqv3asdf4p13-dzw6ugasdfk0arn0 172.173.174.175:2377
```

## Traefik

Set up a main load balancer with Traefik that handles the public connections and Let's encrypt HTTPS certificates.

* Create a network that will be shared with Traefik and the containers that should be accessible from the outside, with:

```bash
docker network create --driver=overlay traefik-public
```

* Create an environment variable with your email, to be used for the generation of Let's Encrypt certificates:

```bash
export EMAIL=admin@example.com
```

* Create a Traefik service:

```bash
docker service create \
    --name traefik \
    --constraint=node.role==manager \
    --publish 80:80 \
    --publish 8080:8080 \
    --publish 443:443 \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --mount type=volume,source=traefik-public-certificates,target=/certificates \
    --network traefik-public \
    traefik:v1.5 \
    --docker \
    --docker.swarmmode \
    --docker.watch \
    --docker.exposedbydefault=false \
    --constraints=tag==traefik-public \
    --entrypoints='Name:http Address::80' \
    --entrypoints='Name:https Address::443 TLS' \
    --acme \
    --acme.email=$EMAIL \
    --acme.storage=/certificates/acme.json \
    --acme.entryPoint=https \
    --acme.httpChallenge.entryPoint=http\
    --acme.onhostrule=true \
    --acme.acmelogging=true \
    --logLevel=DEBUG \
    --accessLog \
    --web
```

The previous command explained:

* `docker service create`: create a Docker Swarm mode service
* `--name traefik`: name the service "traefik"
* `--constraint=node.role==manager` make it run on a Swarm Manager node
* `--publish 80:80`: listen on ports 80 - HTTP
* `--publish 8080:8080`: listen on port 8080 - HTTP for Traefik web UI
* `--publish 443:443`: listen on port 443 - HTTPS
* `--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock`: communicate with Docker, to read labels, etc.
* `--mount type=volume,source=traefik-public-certificates,target=/certificates`: create a volume to store TLS certificates
* `--network traefik-public`: listen to the specific network traefik-public
* `traefik`: use the image traefik:latest
* `--docker`: enable Docker
* `--docker.swarmmode`: enable Docker Swarm Mode
* `--docker.watch`: enable "watch", so it reloads its config based on new stacks and labels
* `--docker.exposedbydefault=false`: don't expose all the services, only services with traefik.enable=true
* `--constraints=tag==traefik-public`: only show services with traefik.tag=traefik-public, to isolate from possible intra-stack traefik instances
* `--entrypoints='Name:http Address::80'`: create an entrypoint http, on port 80
* `--entrypoints='Name:https Address::443 TLS'`: create an entrypoint https, on port 443 with TLS enabled
* `--acme`: enable Let's encrypt
* `--acme.email=$EMAIL`: let's encrypt email, using the environment variable
* `--acme.storage=/certificates/acme.json`: where to store the Let's encrypt TLS certificates - in the mapped volume
* `--acme.entryPoint=https`: the entrypoint for Let's encrypt - created above
* `--acme.onhostrule=true`: get new certificates automatically with host rules: "traefik.frontend.rule=Host:web.example.com"
* `--acme.acmelogging=true`: log Let's encrypt activity - to debug when and if it gets certificates
* `--logLevel=DEBUG`: log everything, to debug configurations and config reloads
* `--web`: enable the web UI, at port 8080

To check if it worked, check the logs:

```bash
docker service logs traefik
# To make it scrollable with `less`, run:
# docker service logs traefik | less
```

## Deploy GitLab

### Update variables

Open the file `docker-compose.swarm-stack.yml` and modify the variables that you need to configure.

Read the [main README](https://github.com/sameersbn/docker-gitlab) for all the options.

For Registry specific options and details, check the previous [GitLab Registry documentation](https://github.com/sameersbn/docker-gitlab/blob/master/docs/container_registry.md).

Make sure you modify the following sections:

* Modify `git.example.com` to point to the domain for your GitLab:

```yaml
REGISTRY_AUTH_TOKEN_REALM=https://git.example.com/jwt/auth
```

* Modify the Traefik label rule, change the `registry.example.com` to the domain for your Registry:

```yaml
- "traefik.frontend.rule=Host:registry.example.com"
```

* Modify the Traefik label rule, change the `- "git.example.com"` to the domain for your GitLab:

```yaml
- "traefik.frontend.rule=Host:git.example.com"
```

* Set `GITLAB_REGISTRY_HOST` to the domain of your Registry:

```yaml
- GITLAB_REGISTRY_HOST=registry.example.com
```

* If you want anyone to sign up instead of only people with invitation, change `GITLAB_SIGNUP_ENABLED` to `true`:

```yaml
- GITLAB_SIGNUP_ENABLED=false
```

* Set `GITLAB_HOST` to the domain for your GitLab:

```yaml
- GITLAB_HOST=git.example.com
```

* For the sections that require generating random strings for keys and passwords, each time, run the following command and copy the output:

```bash
openssl rand -hex 32
# Outputs something like: 99d3b1f01aa639e4a76f4fc281fc834747a543720ba4c8a8648ba755aef9be7f
```

* Set the following variables to different random keys:

```yaml
- GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alphanumeric-string
- GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alphanumeric-string
- GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alphanumeric-string
```

* Set `GITLAB_ROOT_PASSWORD` to the key of the main first administrator user:

```yaml
- GITLAB_ROOT_PASSWORD=change-this-admin-password
```

* Set `GITLAB_ROOT_EMAIL` to the email of the main first administrator user:

```yaml
- GITLAB_ROOT_EMAIL=admin@example.com
```

* Set the appropriate email accounts for the following variables:

```yaml
- GITLAB_EMAIL=notifications@git.example.com
- GITLAB_EMAIL_REPLY_TO=noreply@git.example.com
- GITLAB_INCOMING_EMAIL_ADDRESS=reply@git.example.com
```

### Deploy the stack

After finishing editing the Docker Compose file, copy it to your remote server, e.g.:

```bash
scp -P 2222 docker-compose.swarm-stack.yml root@172.173.174.175:/root/
```

Then connect with SSH to your remote server, e.g.:

```bash
ssh -p 2222 root@172.173.174.175
```

Deploy your stack with something like:

```bash
docker stack deploy -c docker-compose.swarm-stack.yml my-gitlab-stack
```

### Technical details

#### Volumes

The sections with volumes like:

```yaml
    volumes:
    - gitlab-redis:/var/lib/redis:Z
```

refer to a named volume. In this case, to `gitlab-redis`. Named volumes put the files in a directory in the normal file system under `/var/lib/docker/volumes/` but that is handled by Docker, so you avoid conflicts or exposing files in other places while still preserving important changing files in your file system (in a way easy to recover).

All those named volumes are defined in the section:

```yaml
volumes:
  gitlab-redis:
  gitlab-postgres:
  gitlab-gitlab:
  gitlab-registry:
  gitlab-certs:
```

#### Traefik

If you followed the Traefik section above, you would have a main Traefik proxy listening on the HTTP and HTTPS ports (`80` and `443`) that also handles HTTPS TLS (SSL) certificate generation via Let's Encrypt.

For it to work, your stack needs to have access to the previous external network you created.

This section tells Docker that this stack should have access to that `traefik-public` network:

```yaml
networks: 
  traefik-public:
    external: true
```

that way, the main Traefik proxy / load balancer can reach the containers in this stack that have Traefik enabled.

That main Traefik will read the labels in the Docker services and will use that to generate and refresh its own configuration on the fly.

Here's one of those sections with comments explaining what each label does:

```yaml
    deploy:
      labels:
        # When registry.example.com is requested, the request should be handled by this service / container
        # Also, given the way the main Traefik is configured, this will ask it to generate an HTTPS certificate for registry.example.com
        - "traefik.frontend.rule=Host:registry.example.com"
        # Enable Traefik for this service / container, all the other containers won't be accessible, so, for example, your database won't be exposed
        # but this service should be exposed to the world, so Traefik must be enabled
        - "traefik.enable=true"
        # This is the port this service listens on. Is recommended to tell Traefik which port it should try to use
        - "traefik.port=5000"
        # To allow having stacks with internal Traefik proxies without interfering with the main Traefik,
        # this enables the main Traefik to see these configurations (labels). If it didn't have this tag, 
        # the main Traefik wouldn't read these configurations, but there could be a Traefik in this stack that could read them
        # For example to distribute traffic based on the path
        - "traefik.tags=traefik-public"
        # Let Traefik know which network it should use to communicate with this service
        # Although the tag and the network have the same name for simplicity, they refer to different things
        - "traefik.docker.network=traefik-public"
        # Listen on HTTP to redirect to HTTPS
        - "traefik.redirectorservice.frontend.entryPoints=http"
        # Redirect to HTTPS
        - "traefik.redirectorservice.frontend.redirect.entryPoint=https"
        # Listen on HTTPS and serve the requests
        - "traefik.webservice.frontend.entryPoints=https"
```

as this will go in a Docker Swarm mode cluster, the `labels` need to be *inside* `deploy`, not at the same level.

Appart from the service labels, the services that should be able to communicate with, and reachable by, the main Traefik (`registry` and `gitlab`), are connected to the `traefik-public` network in a section in the service like:

```yaml
    networks:
      - traefik-public
      - default
```

There is a special network `default`. By default, all the stacks come with a network named with a prefix based on the stack and the name `default`, as in `git-example-com_default`.

And by default, all the services in a stack are connected to that network, but they see it as if it was named `default`.

As in the fragment above we are overriding the `networks` section to add `traefik-public`, we have to add the `default` network too, to let the service communicate with other parts of the stack, like the database.

#### Internal certificates

GitLab and the Docker Registry have public facing HTTPS certificates generated with Let's encrypt for each one. But to communicate between themselves they use an additional self-signed certificate.

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
    - gitlab-gitlab:/home/git/data:Z
    - gitlab-certs:/certs
```

So, the self-signed certificates will be generated inside the named volume `gitlab-certs`.

And the Registry also has that named volume mounted:

```yaml
    volumes:
      - gitlab-registry:/registry
      - gitlab-certs:/certs
```

And the Registry is configured to look for the certificate in that same location, that GitLab used to generate the certificate:

```yaml
- REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE=/certs/registry.crt
```

## GitLab Runner in Docker

If you use GitLab and want to integrate Continuous Integration / Continuous Deployment, you can follow this section to install the GitLab runner.

There is a sub-section with how to install it in Docker Swarm mode and one in Docker standalone mode. You can set up the GitLab Runner in a different server or even a different Docker Swarm cluster.


### Create the GitLab Runner in Docker Swarm mode

To install a GitLab runner in Docker Swarm mode run:

```bash
docker service create \
    --name gitlab-runner \
    --constraint 'node.role==manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mount src=gitlab-runner-config,dst=/etc/gitlab-runner \
    gitlab/gitlab-runner:latest
```

After that, check in which node the service is running with:

```bash
docker service ps gitlab-runner
```

You will get an output like:

```
root@dog:~/code# docker service ps gitlab-runner
ID                  NAME                IMAGE                         NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
eybbh93ll0iw        gitlab-runner.1     gitlab/gitlab-runner:latest   cat.example.com     Running             Running 33 seconds ago
```

Then SSH to the node running it (in the example above it would be `cat.example.com`), e.g.:

```bash
ssh root@cat.example.com
```

In that node, run a `docker exec` command to register it, use auto-completion ( with `tab` ) for it to fill the name of the container, e.g.:

```bash
docker exec -it gitlab-ru
```

...and then hit `tab`.

Complete the command with the [GitLab Runner registration setup](https://docs.gitlab.com/runner/register/index.html#docker), e.g.:

```bash
docker exec -it gitlab-runner.1.eybbh93lasdfvvnasdfh7 bash
```

Continue below in the seciton **Install the GitLab Runner**.

### Create the GitLab Runner in Docker standalone mode

You might want to run a GitLab runner in Docker standalone, for example, run the tests in a standalone server and deploy in a Docker Swarm mode cluster. 

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

Continue below in the seciton **Install the GitLab Runner**.

### Install the GitLab Runner

* Go to the GitLab "Admin Area -> Runners" section.
* Get the URL and create a variable in your Docker Manager's Terminal, e.g.:

```bash
export GITLAB_URL=https://git.example.com/
```

* Get the registration token and create a variable in your Docker Manager's Terminal, e.g.:

```bash
export GITLAB_TOKEN=WYasdfJp4sdfasdf1234
```

* Run the next command editing the name and tags as you need.

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

## Notes

This guide was heavily inspired by and based on [this other guide, on creating full stack projects and deploying them in a cluster equivalent to the one created here, with GitLab CI](https://github.com/senseta-os/senseta-base-project/blob/master/docker-swarm-cluster-deploy.md).
