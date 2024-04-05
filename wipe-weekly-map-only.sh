#!/bin/bash

set -e

INSTANCE_DATA_DIR="/home/rust/server/instance0"
INSTANCE_CONFIG_FILE="$INSTANCE_DATA_DIR/cfg/server.cfg"

files_to_remove=(
    "$INSTANCE_DATA_DIR/Log.EAC.txt"
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

# Check if it's the first Friday that follows the first Thursday of the month.
# That implies that the preceding Thursday was a full wipe day and therefore
# we don't want to re-wipe the server on Friday.
#
#       $day_of_week -eq 5   -->  "it's Friday"
#       $day_of_month -le 7  -->  "it's the 1st Friday of the month"
#       $day_of_month -ge 2  -->  "Friday wasn't the first day of the month"
#
#if [ $day_of_week -eq 5 ] && [ $day_of_month -le 7 ] && [ $day_of_month -ge 2 ]; then
#    echo "Assuming it was full wipe yesteday -- Not wiping today!"
#    exit 0
#fi

systemctl stop rust

old_seed=$(grep "server.seed" $INSTANCE_CONFIG_FILE)
#new_seed=$RANDOM
new_seed=1359905311
echo "Changing seed from '$old_seed' to '$new_seed'"
sed -i "s/server.seed .*/server.seed $new_seed/" $INSTANCE_CONFIG_FILE

WORLD_SIZE=3500
echo "Setting world size to $WORLD_SIZE"
sed -i "s/server.worldsize .*/server.worldsize $WORLD_SIZE/" $INSTANCE_CONFIG_FILE

for index in "${!files_to_remove[@]}"; do
    echo "Removing ${files_to_remove[$index]}"
    rm ${files_to_remove[$index]} || true
done

systemctl start rust
