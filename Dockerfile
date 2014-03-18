FROM ubuntu:12.04
MAINTAINER sameer@damagehead.com
ENV DEBIAN_FRONTEND noninteractive

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update # 20140310

# essentials
RUN apt-get install -y vim curl wget sudo net-tools pwgen \
    logrotate supervisor openssh-server unzip && \
    apt-get clean

# image specific
RUN apt-get install -y unzip build-essential checkinstall zlib1g-dev libyaml-dev libssl-dev \
		libgdbm-dev libreadline-dev libncurses5-dev libffi-dev && \
		apt-get clean

RUN apt-get install -y python-software-properties && \
    add-apt-repository -y ppa:brightbox/ruby-ng && \
    add-apt-repository -y ppa:git-core/ppa && apt-get update && \
    apt-get install -y libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev libmysqlclient-dev libpq-dev \
    nginx git-core mysql-server redis-server python2.7 python-docutils postfix && \
    apt-get clean

# install ruby from PPA
RUN apt-get install -y ruby2.0 ruby2.0-dev ruby-switch && ruby-switch --set ruby2.0 && gem install --no-ri --no-rdoc bundler

ADD assets/ /app/
RUN mv /app/.vimrc /app/.bash_aliases /root/
RUN chmod 755 /app/init /app/setup/install && /app/setup/install

ADD authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root -R /root/.ssh

EXPOSE 22
EXPOSE 80

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
