FROM sameersbn/ubuntu:12.04.20140418
MAINTAINER sameer@damagehead.com

RUN apt-get install -y python-software-properties && \
		add-apt-repository -y ppa:git-core/ppa && \
		add-apt-repository -y ppa:brightbox/ruby-ng && \
		apt-get update && \
		apt-get install -y build-essential checkinstall postgresql-client-9.1 \
			nginx git-core mysql-server redis-server python2.7 python-docutils \
			libmysqlclient-dev libpq-dev zlib1g-dev libyaml-dev libssl-dev \
			libgdbm-dev libreadline-dev libncurses5-dev libffi-dev \
			libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev \
			ruby2.0 ruby-switch ruby2.0-dev && \
		ruby-switch --set ruby2.0 && gem install --no-ri --no-rdoc bundler && \
		apt-get clean # 20140418

ADD assets/ /app/
RUN chmod 755 /app/init /app/setup/install
RUN /app/setup/install

ADD config/ /app/setup/config/

ADD authorized_keys /root/.ssh/

EXPOSE 22
EXPOSE 80

VOLUME ["/home/git/data"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
