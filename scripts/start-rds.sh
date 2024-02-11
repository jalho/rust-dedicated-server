#!/bin/bash

RCON_PORT=28016
RCON_PASSWORD="Your_Rcon_Password"
RDS_INSTANCE_ID="instance0"

set -xe

source /home/rust/carbon.sh

/home/rust/RustDedicated -batchmode +server.identity "$RDS_INSTANCE_ID" +rcon.port $RCON_PORT +rcon.web 1 +rcon.password "$RCON_PASSWORD"
