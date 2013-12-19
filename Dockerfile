FROM ubuntu:12.04
MAINTAINER sameer@damagehead.com

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y && apt-get clean # 20130925

RUN apt-get install -y wget curl unzip build-essential checkinstall zlib1g-dev libyaml-dev libssl-dev \
		libgdbm-dev libreadline-dev libncurses5-dev libffi-dev && \
		apt-get clean

RUN apt-get install -y python-software-properties && \
		add-apt-repository -y ppa:git-core/ppa && \
		apt-get update && apt-get install -y libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev libmysqlclient-dev \
		sudo nginx git-core mysql-server openssh-server redis-server python2.7 python-docutils postfix logrotate supervisor vim && \
		apt-get clean

RUN wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz -O - | tar -zxf - -C /tmp/ && \
		cd /tmp/ruby-2.0.0-p353/ && \
		./configure --disable-install-rdoc --enable-pthread --prefix=/usr && \
		make && make install && \
		cd /tmp && rm -rf /tmp/ruby-2.0.0-p353 && \
		gem install --no-ri --no-rdoc bundler

ADD resources/ /gitlab/
RUN chmod 755 /gitlab/gitlab /gitlab/setup/install && /gitlab/setup/install

ADD resources/authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown root:root -R /root/.ssh

EXPOSE 22
EXPOSE 80

ENTRYPOINT ["/gitlab/gitlab"]
CMD ["app:start"]
