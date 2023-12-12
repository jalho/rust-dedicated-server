#!/bin/bash

# TODO: wipe map weekly, BPs monthly
echo "Hello from wipe.sh!"

echo "Killing RDS"
set -xe
kill $(pgrep RustDedicated)
