#!/usr/bin/env sh

RELEASE=${GIT_TAG:-$1}

if [ -z "${RELEASE}" ]; then
  echo "Usage:"
  echo "./scripts/release-notes.sh v0.1.0"
  exit 1
fi

if ! git rev-list ${RELEASE} >/dev/null 2>&1; then
  echo "${RELEASE} does not exist"
  exit
fi

PREV_RELEASE=${PREV_RELEASE:-$(git describe --tags --abbrev=0 ${RELEASE}^)}
PREV_RELEASE=${PREV_RELEASE:-$(git rev-list --max-parents=0 ${RELEASE}^)}
NOTABLE_CHANGES=$(git cat-file -p ${RELEASE} | sed '/-----BEGIN PGP SIGNATURE-----/,//d' | tail -n +6)
CHANGELOG=$(git log --no-merges --pretty=format:'- [%h] %s (%aN)' ${PREV_RELEASE}..${RELEASE})
if [ $? -ne 0 ]; then
  echo "Error creating changelog"
  exit 1
fi

cat <<EOF
${NOTABLE_CHANGES}

## Docker Images for sameersbn/gitlab:${RELEASE}

- [docker.io](https://hub.docker.com/r/sameersbn/gitlab/tags)
- [quay.io](https://quay.io/repository/sameersbn/gitlab?tag=${RELEASE}&tab=tags)

## Installation

For installation and usage instructions please refer to the [README](https://github.com/sameersbn/docker-gitlab/blob/${RELEASE}/README.md)

## Important notes

Please note that this version does not yet include any rework as a consequence of the major release and possibly some functions in our implementation might not be usable yet or only to a limited extent.

Don't forget to consider the version specific upgrading instructions for [GitLab CE](https://docs.gitlab.com/ee/update/) **before** upgrading your GitLab CE instance!

Please note:
- GitLab 16.6.x requires at least PostgreSQL 13.
- As of GitLab 16.7, PostgreSQL 14 is the default version. However, PostgreSQL 14 isn't supported on Geo deployments and is planned for future releases (see <https://docs.gitlab.com/ee/update/versions/gitlab_16_changes.html#1670>).

## Contributing

You are kindly invited to provide contributions. If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Be a part of the community and help resolve [issues](https://github.com/sameersbn/docker-gitlab/issues)
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Changelog

${CHANGELOG}
EOF
