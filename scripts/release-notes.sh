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

You are kindly invited to provide contributions.

### Version-specific instructions for upgrades

Please consider the version specific upgrading instructions for [GitLab CE 15.0.x](https://docs.gitlab.com/ee/update/#1500) and [GitLab CE 15.1.x](https://docs.gitlab.com/ee/update/#1510)

* Elasticsearch 6.8 is no longer supported. Before you upgrade to GitLab 15.0, update Elasticsearch to any 7.x version.
* If you run external PostgreSQL, particularly AWS RDS, check you have a PostgreSQL bug fix to avoid the database crashing.
* The use of encrypted S3 buckets with storage-specific configuration is no longer supported after removing support for using background_upload.
* The certificate-based Kubernetes integration (DEPRECATED) is disabled by default, but you can be re-enable it through the certificate_based_clusters feature flag until GitLab 16.0.
* In GitLab 15.1.0, we are switching Rails ActiveSupport::Digest to use SHA256 instead of MD5. This affects ETag key generation for resources such as raw Snippet file downloads. In order to ensure consistent ETag key generation across multiple web nodes when upgrading, all servers must first be upgraded to 15.1.Z before upgrading to 15.2.0 or later.

## Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Be a part of the community and help resolve [issues](https://github.com/sameersbn/docker-gitlab/issues)
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Changelog

${CHANGELOG}
EOF
