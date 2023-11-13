#!/bin/bash

# Constants for default RCON values
DEFAULT_RCON_PORT=25575
DEFAULT_RCON_PASSWORD='foobar'

# Function to handle TERM signal
shutdown_handler() {
    echo "TERM signal received, attempting to shut down the server..."

    # Try to gracefully shut down the server using rcon-cli
    if ! rcon-cli --host localhost --port ${RCON_PORT:-$DEFAULT_RCON_PORT} --password ${RCON_PASSWORD:-$DEFAULT_RCON_PASSWORD} stop; then
        echo "Failed to send the stop command via rcon-cli, forcing the server to stop..."
        # Forcefully terminate the server process if rcon-cli fails
        kill -TERM $SERVER_PID

        # Wait a little to see if the process terminates
        sleep 5

        # If the server still didn't stop, kill it harshly
        if kill -0 $SERVER_PID > /dev/null 2>&1; then
            echo "Server did not shut down, sending KILL signal..."
            kill -KILL $SERVER_PID
        fi
    else
        echo "Server is shutting down gracefully..."
    fi

    # Wait for the server to stop
    wait $SERVER_PID
}

# Set the trap for the TERM signal
trap 'shutdown_handler' TERM

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

# Check if server.properties exists
if [ ! -f /data/server.properties ]; then
    echo "server.properties not found, copying default configuration..."
    cp /tekxit-server/server.properties.dist server.properties
fi

# set owner of data dir to minecraft user
chown -R minecraft:minecraft /data

# update server.properties with rcon configuration
sed -i "s/^enable-rcon=.*$/enable-rcon=true/" /data/server.properties
sed -i "s/^rcon.port=.*$/rcon.port=${RCON_PORT:-$DEFAULT_RCON_PORT}/" /data/server.properties
sed -i "s/^rcon.password=.*$/rcon.password=${RCON_PASSWORD:-$DEFAULT_RCON_PASSWORD}/" /data/server.properties

exec gosu minecraft \
  java \
    -server \
    -Xmx${JAVA_XMX} \
    -Xms${JAVA_XMS} \
    ${JAVA_ADDITIONAL_ARGS} \
    -jar fabric-server-launch.jar nogui \
    & SERVER_PID=$!

# Wait for the server to stop
wait $SERVER_PID
