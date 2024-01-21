#!/bin/bash

set -x

EXPECTED_WORKDIR="/home/rust"
EXPECTED_USER="rust"
RDS_EXECUTABLE="/home/rust/RustDedicated"
CARBON_INIT="/home/rust/carbon/tools/environment.sh"
RDS_INSTANCE_ID="instance0"
RDS_INSTANCE_CFG_DIR="/home/rust/server/$RDS_INSTANCE_ID"
RDS_INSTANCE_CFG_FILENAME="/home/rust/server/$RDS_INSTANCE_ID/cfg/server.cfg"
RDS_LOGFILE="/home/rust/rds.log"
RDS_START_TIMEOUT_SECONDS=3600
RDS_EXPECTED_GAME_PORT=28015 # UDP, default

wait_for_udp() {
    local RDS_HOST="$1"
    local RDS_PORT="$2"
    local TIMEOUT="$3"

    local START_TIME=$(date +%s)

    echo -n "Waiting for port $RDS_PORT to open for UDP..."

    while true; do
        nc -zuv "$RDS_HOST" "$RDS_PORT" >/dev/null 2>&1
        if test $? -eq 0; then
            echo " Open!"
            return 0
        fi

        local CURRENT_TIME=$(date +%s)
        local ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        if test "$ELAPSED_TIME" -ge "$TIMEOUT"; then
            echo " Timed out!"
            return 1
        fi

        sleep 60
    done
}

alert_discord() {
    local WEBHOOK_URL="$1"
    local BODY="{\"content\":\"$2\"}"
    curl $WEBHOOK_URL -H 'Content-Type: application/json' -H "Content-Length: ${#BODY}" -d "$BODY"
}

if ! test -n "$RCON_PASSWORD"; then
    echo "Env var RCON_PASSWORD is not set"
    exit 1
fi

if ! test -n "$DISCORD_WEBHOOK_URL"; then
    echo "Env var DISCORD_WEBHOOK_URL is not set"
    exit 1
fi

if test $(pgrep RustDedicated); then
    echo "RustDedicated is already running"
    exit 1
fi

# Check whether netcat is installed. It's used for checking whether the Rust
# server managed to get up.
if ! command -v nc &>/dev/null; then
    echo "Missing dependency netcat"
    exit 1
fi

if ! test $(pwd) == $EXPECTED_WORKDIR; then
    echo "Expected to run from $EXPECTED_WORKDIR"
    exit 1
fi

if ! test $(whoami) == $EXPECTED_USER; then
    echo "Expected to run as $EXPECTED_USER"
    exit 1
fi

if ! test -f $RDS_EXECUTABLE; then
    echo "Missing executable '$RDS_EXECUTABLE'"
    exit 1
fi

if ! test -f $CARBON_INIT; then
    echo "Missing Carbon init file '$CARBON_INIT'"
    exit 1
fi

if ! test -d $RDS_INSTANCE_CFG_DIR; then
    echo "Missing RDS instance config dif '$RDS_INSTANCE_CFG_DIR'"
    exit 1
fi

if ! test -f $RDS_INSTANCE_CFG_FILENAME; then
    echo "Missing RDS instance config file '$RDS_INSTANCE_CFG_FILENAME'"
    exit 1
fi

source $CARBON_INIT

$RDS_EXECUTABLE -batchmode -logfile "$RDS_LOGFILE" +server.identity "$RDS_INSTANCE_ID" +rcon.port 28016 +rcon.web 1 +rcon.password "$RCON_PASSWORD" >/dev/null 2>&1 &

set +x
wait_for_udp "localhost" $RDS_EXPECTED_GAME_PORT $RDS_START_TIMEOUT_SECONDS
if test $? -eq 0; then
    echo "Server is up"
    alert_discord $DISCORD_WEBHOOK_URL "Server is up"
else
    echo "Timeout: Game server did not open port $RDS_EXPECTED_GAME_PORT for UDP within $RDS_START_TIMEOUT_SECONDS sec. This likely implies an error in its startup. Killing the process."
    set -x
    kill $(pgrep RustDedicated)
    exit 1
fi
