FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive
ENV PG_MAJOR 9.6
ENV PG_VERSION PostgresPro 9.6.5.1
ENV LANG ru_RU.utf8
ENV LC_ALL ru_RU.UTF-8

RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates 


RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y vim lsb apt-utils language-pack-ru && \
	sh -c 'echo "deb http://repo.postgrespro.ru/pgpro-9.6/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro.list' && \
	wget --quiet -O - http://repo.postgrespro.ru/pgpro-9.6/keys/GPG-KEY-POSTGRESPRO | apt-key add - && \
	apt-get update && \
	apt-get install -y postgrespro-9.6 libpq5 postgrespro-client

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/postgresql/data

#copy dict
COPY ru-dict/* /usr/share/postgresql/9.6/tsearch_data/
COPY en-dict/* /usr/share/postgresql/9.6/tsearch_data/

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]