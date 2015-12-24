FROM busybox

MAINTAINER ivlis

RUN mkdir -p /var/run/gitlab
VOLUME /var/run/gitlab/

RUN mkdir -p /etc/nginx/conf.d
VOLUME /etc/nginx/conf.d/

RUN mkdir /sbin
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]

