FROM busybox

MAINTAINER ivlis

RUN mkdir -p /var/run/redis/
RUN mkdir -p /var/run/postgresql/
RUN mkdir -p /var/run/mysqld/

VOLUME /var/run/redis/
VOLUME /var/run/postgresql/
VOLUME /var/run/mysqld/

CMD /bin/true
