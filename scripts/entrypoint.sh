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

# Check for update indicator
if [ -f /tekxit-server/update_indicator ]; then
    echo "Update indicator found, updating server..."
    # Remove the update indicator
    rm -f /tekxit-server/update_indicator

    # List of files to exclude from /tekxit-server to /data
    files_to_exclude=("server.properties" "eula.txt")

    # Iterate over the files in /tekxit-server
    for item in /tekxit-server/*; do
        # If it's a file
        if [ -f "$item" ]; then
            # Extract the file name
            file_name=$(basename "$item")

            # If the file is not in the exclusion list
            if [[ ! " ${files_to_exclude[@]} " =~ " ${file_name} " ]]; then
                # If the file exists in /data, remove it
                if [ -f "/data/$file_name" ]; then
                    echo "Removing existing $file_name in /data..."
                    rm -f "/data/$file_name"
                fi

                # Copy the file from /tekxit-server to /data
                echo "Copying $file_name to /data..."
                cp "$item" "/data/"
            fi
        fi

        # If it's a directory
        if [ -d "$item" ]; then
            # Extract the directory name
            dir_name=$(basename "$item")

            # If the directory exists in /data, remove it
            if [ -d "/data/$dir_name" ]; then
                echo "Removing existing $dir_name directory in /data..."
                rm -rf "/data/$dir_name"
            fi

            # Copy the directory from /tekxit-server to /data
            echo "Copying $dir_name directory to /data..."
            cp -R "$item" "/data/"
        fi
    done
fi

# create eula.txt with EULA env variable if it does not exist
if [ ! -f /data/eula.txt ]; then
    echo "eula=$EULA" > /data/eula.txt
fi

# Check if server.properties exists
if [ ! -f /data/server.properties ]; then
    echo "server.properties not found, copying default configuration..."
    cp /tekxit-server/server.properties /data/server.properties
fi

# set owner of data dir to minecraft user
chown -R minecraft:minecraft /data

# update server.properties with rcon configuration
sed -i "s/^enable-rcon=.*$/enable-rcon=true/" /data/server.properties
sed -i "s/^rcon.port=.*$/rcon.port=${RCON_PORT:-$DEFAULT_RCON_PORT}/" /data/server.properties
sed -i "s/^rcon.password=.*$/rcon.password=${RCON_PASSWORD:-$DEFAULT_RCON_PASSWORD}/" /data/server.properties

# Extract the line that contains the .jar item
jar_line=$(grep -oP '[\w-]+\.jar' ServerLinux.sh)

echo $jar_line

exec gosu minecraft \
  java \
    -server \
    -Xmx${JAVA_XMX} \
    -Xms${JAVA_XMS} \
    ${JAVA_ADDITIONAL_ARGS} \
    -jar ${jar_line} nogui \
    & SERVER_PID=$!

# Wait for the server to stop
wait $SERVER_PID
