[![pipeline status](https://gitlab.timmertech.nl/docker/gitlab/badges/master/pipeline.svg)](https://gitlab.timmertech.nl/docker/gitlab/commits/master)
[![CircleCI](https://circleci.com/gh/GJRTimmer/docker-gitlab/tree/master.svg?style=svg)](https://circleci.com/gh/GJRTimmer/docker-gitlab/tree/master)

# Dockerized Gitlab

This repository provides a Dockerized Gitlab environment with Gitlab.

* Supported Editions
  * CE (Community Edition)
  * EE (Enterprise Edition)

Please note that the community edition is `default`.
To build the enterprise edition, either change the global configuration or build the image with: `GITLAB_EDITION=ee make all`.

This repository is forked from `sameersbn/docker-gitlab`.

[Documentation can be found here](https://docker.timmertech.nl/gitlab)
