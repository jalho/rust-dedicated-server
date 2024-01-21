#!/bin/bash

EXPECTED_WORKDIR="/home/rust"
EXPECTED_USER="rust"
STEAMCMD_UTIL_SCRIPT_PATH="/home/rust/scripts/install-update-validate-rust.steamcmd"

set -xe

if ! test $(pwd) == $EXPECTED_WORKDIR; then
    echo "Expected to run from $EXPECTED_WORKDIR"
    exit 1
fi

if ! test $(whoami) == $EXPECTED_USER; then
    echo "Expected to run as $EXPECTED_USER"
    exit 1
fi

# Check whether SteamCMD is installed. It's used for installing and updating
# Rust. Docs: https://developer.valvesoftware.com/wiki/SteamCMD
if ! command -v steamcmd &>/dev/null; then
    echo "Missing dependency SteamCMD"
    exit 1
fi

if ! test -f $STEAMCMD_UTIL_SCRIPT_PATH; then
    echo "Missing required util script $STEAMCMD_UTIL_SCRIPT_PATH"
    exit 1
fi

steamcmd +runscript /home/rust/scripts/install-update-validate-rust.steamcmd
