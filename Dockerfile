FROM ubuntu:12.04
MAINTAINER sameer@damagehead.com
ENV DEBIAN_FRONTEND noninteractive

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update # 20140409

# Fix some issues with APT packages.
# See https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl && \
		ln -sf /bin/true /sbin/initctl

# essentials
RUN apt-get install -y vim curl wget sudo net-tools pwgen unzip \
			logrotate supervisor openssh-server && apt-get clean

# build tools
RUN apt-get install -y gcc make && apt-get clean

# image specific
RUN apt-get install -y python-software-properties && \
		add-apt-repository -y ppa:git-core/ppa && apt-get update

RUN apt-get install -y build-essential checkinstall \
			nginx git-core mysql-server redis-server python2.7 python-docutils \
			libmysqlclient-dev libpq-dev zlib1g-dev libyaml-dev libssl-dev \
			libgdbm-dev libreadline-dev libncurses5-dev libffi-dev \
			libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev && \
		apt-get clean

RUN add-apt-repository -y ppa:brightbox/ruby-ng && apt-get update && \
		apt-get install -y ruby2.0 ruby-switch ruby2.0-dev && apt-get clean && \
		ruby-switch --set ruby2.0 && gem install --no-ri --no-rdoc bundler

ADD assets/ /app/
RUN mv /app/.vimrc /app/.bash_aliases /root/
RUN chmod 755 /app/init /app/setup/install && /app/setup/install

ADD authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root -R /root/.ssh

EXPOSE 22
EXPOSE 80

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
