#!/bin/bash

set -xe

EXPECTED_WORKDIR="/home/rust"
EXPECTED_USER="rust"
RDS_EXECUTABLE="/home/rust/RustDedicated"
CARBON_INIT="/home/rust/carbon/tools/environment.sh"
RDS_INSTANCE_ID="instance0"
RDS_INSTANCE_CFG_DIR="/home/rust/server/$RDS_INSTANCE_ID"
RDS_INSTANCE_CFG_FILENAME="/home/rust/server/$RDS_INSTANCE_ID/cfg/server.cfg"
RDS_LOGFILE="/home/rust/rds.log"

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

if ! test -n "$RCON_PASSWORD"; then
    echo "Env var RCON_PASSWORD is not set"
    exit 1
fi

source $CARBON_INIT

$RDS_EXECUTABLE -batchmode -logfile "$RDS_LOGFILE" +server.identity "$RDS_INSTANCE_ID" +rcon.port 28016 +rcon.web 1 +rcon.password "$RCON_PASSWORD" > /dev/null 2>&1 &
