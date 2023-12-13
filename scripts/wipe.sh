#!/bin/bash

source /home/rust/scripts/_constants.sh

function set_seed() {
    local RDS_INSTANCE_CFG_FILEPATH=$1
    if ! test -f $RDS_INSTANCE_CFG_FILEPATH; then
        echo "Cannot set seed -- file '$RDS_INSTANCE_CFG_FILEPATH' doesn't exist"
        exit 1
    fi
    local PATTERN="server.seed"
    local OLD_SEED=$(grep "$PATTERN" "$RDS_INSTANCE_CFG_FILEPATH" | awk '{print $2}')
    local NEW_SEED=$RANDOM
    sed -i "s/$PATTERN $OLD_SEED/$PATTERN $NEW_SEED/" "$RDS_INSTANCE_CFG_FILEPATH"
    if test $? -eq 0; then
        echo "Changed seed from '$OLD_SEED' to '$NEW_SEED' in $RDS_INSTANCE_CFG_FILEPATH"
    else
        echo "Failed to change seed"
        exit 1
    fi
}

echo "Wipe procedure initiated"

set_seed $RDS_INSTANCE_CFG_DIR_PATH/server.cfg

# TODO: Wipe blueprints once a month

kill $(pgrep RustDedicated)
if test $? -eq 0; then
    echo "Killed RDS"
else
    echo "Failed to kill RDS"
fi
