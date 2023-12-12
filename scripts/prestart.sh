#!/bin/bash

source /home/rust/scripts/_constants.sh

# systemd compatible exit statuses
EXIT_STATUS_SHOULD_RESTART=0
EXIT_STATUS_SHOULD_NOT_RESTART=1

# TODO: Explicitly specify RDS installation directory somehow!
function update_rust() {
    $STEAMCMD_ABSOLUTE_PATH +login anonymous +app_update 258550 validate +quit
}

echo "checking requirements..."

# Netcat -- Needed for checking whether the server is up & healthy
#
# Considered OK if the game port is open for UDP (Idk if there is a better measure...)
command_netcat="nc"
if command -v "$command_netcat" &>/dev/null; then
    echo "$command_netcat is installed"
else
    echo "$command_netcat is not installed -- cannot proceed!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

# SteamCMD -- Needed for installing the Rust game server
#
# Installation instructions: https://developer.valvesoftware.com/wiki/SteamCMD
# (Accessed 2 Dec 2023)
if test -f $STEAMCMD_ABSOLUTE_PATH; then
    echo "$STEAMCMD_ABSOLUTE_PATH is installed"
else
    echo "$STEAMCMD_ABSOLUTE_PATH is not installed -- cannot proceed!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

# pgrep -- Needed for checking whether some action this script is supposed to
#          take is already in progress (because this script is intended to be
#          used such that it can be triggered on a regular interval)
command_pgrep="pgrep"
if command -v "$command_pgrep"; then
    echo "$command_pgrep is installed"
else
    echo "$command_pgrep is not installed -- cannot proceed!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

rds_host="localhost"
rds_port=28015 # default game port (UDP) used by RustDedicated
echo "checking $rds_host:$rds_port for UDP..."
if $command_netcat -zuv $rds_host $rds_port &>/dev/null; then
    echo "$rds_host:$rds_port is already up for UDP -- not proceeding!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi
echo "$rds_host:$rds_port is not up for UDP"

# TODO: Handle case where the process is up but server is still not accepting
#       players... Should somehow detect whether it's being started or whether
#       it's stuck in some error condition... IIRC I've seen such state once...
if $command_pgrep RustDedicated &>/dev/null; then
    echo "Rust game server is already being started -- not proceeding!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

if $command_pgrep steamcmd &>/dev/null; then
    echo "Rust is already being updated -- not proceeding!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

set -xe

echo "Updating Rust using SteamCMD..."
update_rust
update_status=$?
if test $update_status -ne 0; then
    echo "Rust update failed with code $update_status -- cannot proceed!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

if ! test -d $(dirname $RDS_ABSOLUTE_PATH); then
    echo "Expected RustDedicated installation dir in $(dirname $RDS_ABSOLUTE_PATH) -- cannot proceed!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi
if ! test -f $RDS_ABSOLUTE_PATH; then
    echo "Expected executable RustDedicated in installation dir in $(dirname $RDS_ABSOLUTE_PATH) -- cannot proceed!"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

RDS_INSTANCE_CFG_DIR_PATH=$(dirname $RDS_ABSOLUTE_PATH/server/$RDS_INSTANCE_ID/cfg)
if ! test -d $RDS_INSTANCE_CFG_DIR_PATH; then
    echo "Creating RDS instance config dir $RDS_INSTANCE_CFG_DIR_PATH"
    mkdir -p $RDS_INSTANCE_CFG_DIR_PATH
fi

if ! test -d $(dirname $RDS_ABSOLUTE_PATH/carbon); then
    PREWD=$(pwd)

    echo "Installing Carbon from $CARBON_RELEASE_URL"
    cd $(dirname $RDS_ABSOLUTE_PATH)
    wget $CARBON_RELEASE_URL
    tar -xzf Carbon.Linux.Release.tar.gz

    cd $PREWD
fi

exit $EXIT_STATUS_SHOULD_RESTART
