# GitLab-CI Configuration

When using your own gitlab instance, the provided .gitlab-ci.yml will be automatically be using the settings provided by the GitLab Instance. If needed several options can be overriden.

Overrides for these values can be set within the project, under `Settings` -> `CI/CD` -> `Variables`.

| Variable               | Default Value      | Description                                                                                                                                                                                                              |
| ---------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `CI_REGISTRY`          | `hub.docker.com`   | If available this will be automatically overriden by registry address which is configured within the GitLab instance                                                                                                     |
| `CI_REGISTRY_USER`     | `gitlab-ci-token`  | Username for the registry                                                                                                                                                                                                |
| `CI_REGISTRY_PASSWORD` | `${CI_JOB_TOKEN}`  | Password for the registry                                                                                                                                                                                                |
| `DOCKER_IMAGE`         | `sameersbn/gitlab` | Docker image name, will be automatically be overriden by the running GitLab instance with the `${CI_PROJECT_PATH}` variable. This will case the image to be uploaded to the local registry of the project within GitLab. |
