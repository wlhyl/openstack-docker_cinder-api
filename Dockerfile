# image name lzh/cinder-api:kilo
FROM 10.64.0.50:5000/lzh/openstackbase:kilo

MAINTAINER Zuhui Liu penguin_tux@live.com

ENV BASE_VERSION 2015-08-07
ENV OPENSTACK_VERSION kilo


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install cinder-api -y
RUN apt-get clean

RUN env --unset=DEBIAN_FRONTEND

RUN cp -rp /etc/cinder/ /cinder
RUN rm -rf /var/log/cinder/*
RUN rm -rf /var/lib/cinder/cinder.sqlite

VOLUME ["/etc/cinder"]
VOLUME ["/var/log/cinder"]

ADD entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ADD cinder-api.conf /etc/supervisor/conf.d/cinder-api.conf

EXPOSE 8776

ENTRYPOINT ["/usr/bin/entrypoint.sh"]