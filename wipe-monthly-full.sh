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

systemctl stop rust

for index in "${!files_to_remove[@]}"; do
    rm ${files_to_remove[$index]} || true
done

systemctl start rust
