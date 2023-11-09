FROM eclipse-temurin:17

ARG VERSION="0.32.0"

# The user that runs the minecraft server and own all the data
# you may want to change this to match your local user
ENV USER=minecraft
ENV UID=1000

# Memory limits for the java VM that can be overridden via env.
ENV JAVA_XMS=1G
ENV JAVA_XMX=4G
# Additional args that are appended to the end of the java command.
ENV JAVA_ADDITIONAL_ARGS=""

# the tekxit server files are published as .7z archive so we need something to unpack it.
RUN apt update
RUN apt install -y unzip curl

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        aarch64) ARCH="arm64" ;; \
        x86_64) ARCH="amd64" ;; \
    esac && \
    LATEST_VERSION=$(curl -sSL https://api.github.com/repos/itzg/rcon-cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    echo "LATEST_VERSION: ${LATEST_VERSION}" && \
    echo "ARCH: ${ARCH}" && \
    curl -sSL "https://github.com/itzg/rcon-cli/releases/download/${LATEST_VERSION}/rcon-cli_${LATEST_VERSION}_linux_${ARCH}.tar.gz" -o rcon-cli.tar.gz && \
    tar -xzf rcon-cli.tar.gz rcon-cli && \
    mv rcon-cli /usr/local/bin && \
    rm rcon-cli.tar.gz

# add entrypoint
ADD ./scripts/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

# create a new user to run our minecraft-server
RUN adduser \
    --disabled-password \
    --gecos "" \
    --uid "${UID}" \
    "${USER}"

# declare a directory for the data directory
# survives a container restart
RUN mkdir /tekxit-server && chown -R "${USER}" /tekxit-server

# switch to the minecraft user since we don't need root at this point
USER ${USER}
WORKDIR /tekxit-server

# download server files
RUN curl -sSL "https://www.tekxit.lol/downloads/tekxit4/${VERSION}Tekxit4Server.zip" -o tekxit-server.zip

# unpack server files
RUN \
    unzip tekxit-server.zip \
    && mv ${VERSION}Tekxit4Server/* . \
    && rmdir ${VERSION}Tekxit4Server

WORKDIR /data

EXPOSE 25565
EXPOSE 25575
ENTRYPOINT ["/bin/bash", "/entrypoint"]
