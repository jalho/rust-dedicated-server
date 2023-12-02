#!/bin/bash

# systemd compatible exit statuses
EXIT_STATUS_SHOULD_RESTART=0
EXIT_STATUS_SHOULD_NOT_RESTART=1

# other constants
RDS_DEFAULT_INSTALL_DIR="/home/rust/.local/share/Steam/steamapps/common/rust_dedicated"
STEAMCMD_ENTRYPOINT_PATH="/home/rust/.steam/steam/steamcmd/steamcmd.sh"

#
#   By default, as of 2 Dec 2023, this will install the game server in
#   `~/.local/share/Steam/steamapps/common/rust_dedicated/RustDedicated`
#   where `RustDedicated` is the executable (ELF).
#
#   In the same directory with the executable there will also be a start
#   script called `runds.sh` for running the server with appropriate parameters.
#
function update_rust() {
    cd $(dirname $STEAMCMD_ENTRYPOINT_PATH)
    ./$(basename $STEAMCMD_ENTRYPOINT_PATH) +login anonymous +app_update 258550 validate +quit
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
if test -f $STEAMCMD_ENTRYPOINT_PATH; then
    echo "$STEAMCMD_ENTRYPOINT_PATH is installed"
else
    echo "$STEAMCMD_ENTRYPOINT_PATH is not installed -- cannot proceed!"
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

if ! test -d $RDS_DEFAULT_INSTALL_DIR; then
    echo "Expected RustDedicated installation dir in $RDS_DEFAULT_INSTALL_DIR"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi
if ! test -f $RDS_DEFAULT_INSTALL_DIR/RustDedicated; then
    echo "Expected executable RustDedicated in installation dir in $RDS_DEFAULT_INSTALL_DIR"
    exit $EXIT_STATUS_SHOULD_NOT_RESTART
fi

exit $EXIT_STATUS_SHOULD_RESTART
