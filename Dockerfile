FROM sameersbn/ubuntu:14.04.20140818
MAINTAINER sameer@damagehead.com

RUN add-apt-repository -y ppa:git-core/ppa \
 && add-apt-repository -y ppa:brightbox/ruby-ng \
 && add-apt-repository -y ppa:nginx/stable \
 && apt-get update \
 && apt-get install -y build-essential checkinstall cmake postgresql-client \
      nginx git-core openssh-server mysql-server redis-server python2.7 python-docutils \
      libmysqlclient-dev libpq-dev zlib1g-dev libyaml-dev libssl-dev \
      libgdbm-dev libreadline-dev libncurses5-dev libffi-dev \
      libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev \
      ruby2.1 ruby2.1-dev \
 && gem install --no-ri --no-rdoc bundler \
 && rm -rf /var/lib/apt/lists/* # 20140818

COPY assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

COPY assets/config/ /app/setup/config/
COPY assets/init /app/init
RUN chmod 755 /app/init

EXPOSE 22
EXPOSE 80
EXPOSE 443

VOLUME ["/home/git/data"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
