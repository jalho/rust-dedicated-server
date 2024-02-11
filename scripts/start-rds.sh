#!/bin/bash

RCON_PORT=28016
RCON_PASSWORD="Your_Rcon_Password"
RDS_INSTANCE_ID="instance0"
RDS_LOGFILE="/home/rust/rds_$(date +%s).log"

set -xe

source /home/rust/carbon.sh

/home/rust/RustDedicated -batchmode -logfile "$RDS_LOGFILE" +server.identity "$RDS_INSTANCE_ID" +rcon.port 28016 +rcon.web 1 +rcon.password "$RCON_PASSWORD"
