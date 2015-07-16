#!/bin/bash


# REQUIRED:
#   ZOOKEEPER_PORT_2181_TCP
# OR
#   ZOOKEEPER_1_PORT_2181_TCP
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
#
# OPTIONAL
#   TOPIC_BLACKLIST
#   TOPIC_WHITELIST
#   S3_BUCKET_NAME

export KAFKA_ZOOKEEPER_CONNECT=$(env | grep 'ZOOKEEPER.*_PORT_2181_TCP=' | sed -e 's|.*tcp://||' | paste -sd ,)
if [[ -n "${KAFKA_ZOOKEEPER_CONNECT}" ]]; then
    export REPLACE_ZOOKEEPER_CONNECT="s/:zookeeper-connect\s.+$/:zookeeper-connect \"${KAFKA_ZOOKEEPER_CONNECT}\"/"
fi

# setting defaults
export HOSTNAME=${HOSTNAME:-bifrost}
export TOPIC_BLACKLIST=${TOPIC_BLACKLIST:-nil}
export TOPIC_WHITELIST=${TOPIC_WHITELIST:-nil}
export S3_BUCKET_NAME=${S3_BUCKET_NAME:-bifrost}

export CONFIG_FILE=/opt/bifrost/conf/config.edn
# replace variables in template with environment values
echo "TEMPLATE: generating configuation."
perl -pe 's/%%([A-Za-z0-9_]+)%%/defined $ENV{$1} ? $ENV{$1} : $&/eg' < ${CONFIG_FILE}.tmpl > $CONFIG_FILE

# check if all properties have been replaced
if grep -qoP '%%[^%]+%%' $CONFIG_FILE ; then
    echo "ERROR: Not all variable have been resolved,"
    echo "       please set the following variables in your environment:"
    grep -oP '%%[^%]+%%' $CONFIG_FILE | sed 's/%//g' | sort -u
    exit 1
fi


/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
