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

# create eula.txt with EULA env variable if it does not exist
if [ ! -f /data/eula.txt ]; then
    echo "eula=$EULA" > /data/eula.txt
fi

# update server.properties with rcon configuration
sed -i "s/^enable-rcon=.*$/enable-rcon=true/" /data/server.properties
sed -i "s/^rcon.port=.*$/rcon.port=${RCON_PORT:-25575}/" /data/server.properties
sed -i "s/^rcon.password=.*$/rcon.password=${RCON_PASSWORD:-foobar}/" /data/server.properties

java \
    -server \
    -Xmx${JAVA_XMX} \
    -Xms${JAVA_XMS} \
    ${JAVA_ADDITIONAL_ARGS} \
    -jar fabric-server-launch.jar nogui \
