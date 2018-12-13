+++
title = "TLS (SSL) Configuration"
description = "TLS (SSL) Configuration"
category = ["configuration", "tls", "ssl"]
tags = ["configuration", "tls", "ssl"]
weight = 1
+++

Access to the gitlab application can be secured using SSL so as to prevent unauthorized access to the data in your repositories. While a CA certified SSL certificate allows for verification of trust via the CA, a self signed certificate can also provide an equal level of trust verification as long as each client takes some additional steps to verify the identity of your website. I will provide instructions on achieving this towards the end of this section.

Jump to the [Using HTTPS with a load balancer](#using-https-with-a-load-balancer) section if you are using a load balancer such as hipache, haproxy or nginx.

To secure your application via SSL you basically need two things:

- **Private key (.key)**
- **SSL certificate (.crt)**

When using CA certified certificates, these files are provided to you by the CA. When using self-signed certificates you need to generate these files yourself. Skip to [Strengthening the server security](#strengthening-the-server-security) section if you are armed with CA certified SSL certificates.

# Generation of a Self Signed Certificate

Generation of a self-signed SSL certificate involves a simple 3-step procedure:

**STEP 1**: Create the server private key

```bash
openssl genrsa -out gitlab.key 2048
```

**STEP 2**: Create the certificate signing request (CSR)

```bash
openssl req -new -key gitlab.key -out gitlab.csr
```

**STEP 3**: Sign the certificate using the private key and CSR

```bash
openssl x509 -req -days 3650 -in gitlab.csr -signkey gitlab.key -out gitlab.crt
```

Congratulations! You now have a self-signed SSL certificate valid for 10 years.

# Strengthening the server security

This section provides you with instructions to [strengthen your server security](https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html). To achieve this we need to generate stronger DHE parameters.

```bash
openssl dhparam -out dhparam.pem 2048
```

# Installation of the SSL Certificates

Out of the four files generated above, we need to install the `gitlab.key`, `gitlab.crt` and `dhparam.pem` files at the gitlab server. The CSR file is not needed, but do make sure you safely backup the file (in case you ever need it again).

The default path that the gitlab application is configured to look for the SSL certificates is at `/home/git/data/certs`, this can however be changed using the `SSL_KEY_PATH`, `SSL_CERTIFICATE_PATH` and `SSL_DHPARAM_PATH` configuration options.

If you remember from above, the `/home/git/data` path is the path of the [data store](#data-store), which means that we have to create a folder named `certs/` inside `/srv/docker/gitlab/gitlab/` and copy the files into it and as a measure of security we'll update the permission on the `gitlab.key` file to only be readable by the owner.

```bash
mkdir -p /srv/docker/gitlab/gitlab/certs
cp gitlab.key /srv/docker/gitlab/gitlab/certs/
cp gitlab.crt /srv/docker/gitlab/gitlab/certs/
cp dhparam.pem /srv/docker/gitlab/gitlab/certs/
chmod 400 /srv/docker/gitlab/gitlab/certs/gitlab.key
```

Great! we are now just one step away from having our application secured.
