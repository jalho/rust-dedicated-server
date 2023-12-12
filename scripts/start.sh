#!/bin/bash

source /home/rust/scripts/_constants.sh

RDS_INSTALLATION_DIR=$(dirname $RDS_ABSOLUTE_PATH)
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDS_INSTALLATION_DIR/RustDedicated_Data/Plugins"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDS_INSTALLATION_DIR/RustDedicated_Data/Plugins/x86_64"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

cd $RDS_INSTALLATION_DIR

# enable Carbon (modding framework -- see https://docs.carbonmod.gg)
echo "Loading 'carbon/tools/environment.sh' ..."
source ./carbon/tools/environment.sh
echo "Loading 'carbon/tools/environment.sh' exited with code $?"

# start the game server using the instance config identified as "instance0"
./RustDedicated -batchmode -logfile "rds.log" +server.identity "instance0" 2>&1
