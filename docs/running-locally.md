# Running Locally

In order to develop on this you need the following.

Create data folders (or edit the docker-compose file)

    sudo mkdir -p /srv/docker/gitlab/{gitlab,redis,postgresql}
    sudo chown -R $(whoami) /srv/docker

Docker compose setup

    docker pull sameersbn/gitlab
    # This will reuse the cache from the pre-built image
    docker-compose up 

The docker-compose setup will also mount `./assets/runtime/` to `/etc/docker-gitlab/runtime` so it makes it easier to develop/make changes.

Editing any of the `./assets/runtime/` configs can be tested by simply restarting the container instead of rebuilding

    docker-compose restart gitlab

NOTEs.

* docker-compose will not automatically reload `docker-compose.yaml` configuration changes on restart you will have to take down the stack and restart it
* 