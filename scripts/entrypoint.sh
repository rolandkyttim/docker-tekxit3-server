#!/bin/sh

# create data dir if it does not exist
if [ ! -d /data ]; then
    echo "creating missing /data dir"
    mkdir /data
fi

# copy server data if the directory is empty
if [ `ls -1 /data | wc -l` -eq 0 ]; then
    echo "data dir is empty, installing server"
    cp -R /tekxit-server/* /data/
fi

java \
    -server \
    -Xmx${JAVA_XMX} \
    -Xms${JAVA_XMS} \
    -jar fabric-server-launch.jar nogui \
    ${JAVA_ADDITIONAL_ARGS}
