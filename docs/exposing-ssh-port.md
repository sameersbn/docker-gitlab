# Exposing ssh port in dockerized gitlab-ce

This is how to expose this internal ssh port without affecting the existing ssh port on the host server:

* use this configuration script: [`../contrib/expose-gitlab-ssh-port.sh`](../contrib/expose-gitlab-ssh-port.sh)
* see implementation example in Vagrant: [harobed/docker-gitlab-vagrant-test
](https://github.com/harobed/docker-gitlab-vagrant-test)
* more information, see [« Exposing ssh port in dockerized gitlab-ce »](https://blog.xiaket.org/2017/exposing.ssh.port.in.dockerized.gitlab-ce.html) post
