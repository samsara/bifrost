FROM samsara/base-image-jdk8:u1410-j8u40

MAINTAINER Samsara's team (https://github.com/samsara/bifrost)

ADD ./docker/bifrost-supervisor.conf /etc/supervisor/conf.d/
ADD ./target/bifrost /opt/bifrost/bifrost
ADD ./docker/config.edn.tmpl /opt/bifrost/conf/config.edn.tmpl
ADD ./docker/configure-and-start.sh /

VOLUME ["/logs"]

CMD /configure-and-start.sh