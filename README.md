# docker-tekxit4-server

Dockerfiles to run a Minecraft [tekxit4](https://www.technicpack.net/modpack/tekxit-4-official.1921233) server.

## Usage

### Setting up the server

```sh
git clone https://github.com/Ithilias/docker-tekxit4-server.git
cd docker-tekxit4-server

# server data will be written to ./data by default. You might want to change the volume before you continue.
# memory limits can be set by changing the environment variables in the compose file.

# Set the EULA environment variable to true to automatically accept the Minecraft EULA.
# Set the RCON_PORT and RCON_PASSWORD environment variables to configure the RCON port and password.

docker compose up
```

Alternatively, you can use the Docker image available as a package on GitHub.
Here's an example `docker-compose.yml` file for using the Docker image:

```yaml
services:
  tekxit:
    container_name: tekxit
    image: ghcr.io/ithilias/docker-tekxit4-server:latest
    environment:
      JAVA_XMS: "4G"
      JAVA_XMX: "12G"
      EULA: "true"
      RCON_PORT: "25575"
      RCON_PASSWORD: "foobar"
    volumes:
      - ./data:/data
    ports:
      - "25565:25565"
```

The server will now be installed to the data volume.

### Accessing the console

This image comes with [rcon-cli](https://github.com/itzg/rcon-cli) preinstalled. The RCON port and password can be configured using the `RCON_PORT` and `RCON_PASSWORD` environment variables in the docker-compose file.

To access the console, you can use the `mc-command.sh` script:

```sh
./mc-command.sh -h
```

### Updating the Server

To update your Tekxit4 server, follow these steps:

1. **Backup Important Files:** Before updating, it's crucial to backup your world, configurations, and any other important data. This can usually be found in the `./data` directory.

2. **Prepare for Update:** Ensure the `./data` directory is empty. The updated server files will be copied here.

3. **Pull the Latest Image:** Run `docker compose pull` to download the latest version of the Docker image.

4. **Restart the Server:** Use `docker compose up -d` to restart your server. This will ensure the server runs with the latest image and updates necessary files.

5. **Restore Backups:** If necessary, restore any backed-up files to their respective locations in the `./data` directory.

6. **Verify Server Operation:** Once the server is running, connect to it and verify that everything is functioning correctly. Pay special attention to world integrity and mod functionality.

**Note:** Be sure to read the update notes for the specific version of Tekxit4 you're updating to. Some updates might require additional steps or considerations, especially if there are major changes in mods.