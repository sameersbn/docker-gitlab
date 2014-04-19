FROM sameersbn/ubuntu:12.04.20140418
MAINTAINER sameer@damagehead.com

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

RUN apt-get install -y postgresql-client-9.1 && apt-get clean

ADD assets/ /app/
RUN chmod 755 /app/init /app/setup/install
RUN /app/setup/install

ADD authorized_keys /root/.ssh/

EXPOSE 22
EXPOSE 80

VOLUME ["/home/git/data"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
