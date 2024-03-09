#!/bin/bash

set -xe

INSTANCE_DATA_DIR="/home/rust/server/instance0"

files_to_remove=(
    "$INSTANCE_DATA_DIR/Log.EAC.txt"
    "$INSTANCE_DATA_DIR/player.blueprints*"
    "$INSTANCE_DATA_DIR/player.deaths*"
    "$INSTANCE_DATA_DIR/player.identities*"
    "$INSTANCE_DATA_DIR/player.states*"
    "$INSTANCE_DATA_DIR/player.tokens*"
    "$INSTANCE_DATA_DIR/proceduralmap*.map*"
    "$INSTANCE_DATA_DIR/proceduralmap*.sav*"
    "$INSTANCE_DATA_DIR/serveremoji"
    "$INSTANCE_DATA_DIR/sv.files*"
)

day_of_week=$(date +%u) # 4 = Thursday, 5 = Friday
day_of_month=$(date +%d)

if [ $day_of_week -ne 4 ] || [ $day_of_month -gt 7 ]; then
    set +x
    echo "Not doing full wipe -- It's not Thursday or it's not the 1st Thursday of the month!"
    exit 0
fi

systemctl stop rust

old_seed=$(grep "server.seed" $INSTANCE_CONFIG_FILE)
new_seed=$RANDOM
sed -i "s/server.seed .*/server.seed $new_seed/" $INSTANCE_CONFIG_FILE
echo "server.seed has been updated from '$old_seed' to '$new_seed'"

for index in "${!files_to_remove[@]}"; do
    rm ${files_to_remove[$index]} || true
done

systemctl start rust
