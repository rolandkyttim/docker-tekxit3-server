#!/bin/bash

# Default values
RCON_PASSWORD=${RCON_PASSWORD:-"foobar"}
RCON_PORT=${RCON_PORT:-25575}

# Function to display help message
show_help() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Options:"
    echo "  --password, -p   Specify the RCON password (default: $RCON_PASSWORD)"
    echo "  --port, -P       Specify the RCON port (default: $RCON_PORT)"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "If no COMMAND is specified, the script will run in interactive mode."
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --password|-p)
            RCON_PASSWORD="$2"
            shift
            ;;
        --port|-P)
            RCON_PORT="$2"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            COMMAND="$1"
            ;;
    esac
    shift
done

# Run the rcon-cli command
docker compose exec tekxit rcon-cli --host localhost --port ${RCON_PORT} --password ${RCON_PASSWORD} ${COMMAND}
