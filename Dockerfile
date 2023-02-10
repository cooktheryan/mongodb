FROM registry.access.redhat.com/ubi8/ubi

ADD mongo.repo /etc/yum.repos.d/

ENV JSYAML_VERSION 3.13.1

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN set -eux; \
	groupadd --gid 996 --system mongod; \
	useradd --uid 996 --system --gid  mongod --home-dir /data/db mongod; \
	mkdir -p /data/db /data/configdb; \
	chown -R mongod:mongod /data/db /data/configdb

RUN dnf -y install npm jq mongodb-org && dnf localinstall -y http://rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/numactl-2.0.12-13.el8.x86_64.rpm https://rpmfind.net/linux/centos/8-stream/BaseOS/x86_64/os/Packages/numactl-libs-2.0.12-13.el8.x86_64.rpm && dnf clean all && npm install mongodb && rm -rf /var/lib/mongo && mv /etc/mongod.conf /etc/mongod.conf.orig

RUN mkdir /docker-entrypoint-initdb.d

ADD create_pacman_db.js /usr/local/bin/

# install GOSU
RUN curl -L -o /usr/bin/gosu https://github.com/tianon/gosu/releases/download/1.16/gosu-amd64 && chmod +x /usr/bin/gosu && curl -L -o /js-yaml.js "https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/dist/js-yaml.js"

VOLUME /data/db /data/configdb

# ensure that if running as custom user that "mongosh" has a valid "HOME"
# https://github.com/docker-library/mongo/issues/524
ENV HOME /data/db

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 27017
CMD ["mongod"]
