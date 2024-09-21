#!/bin/bash

#
#  WHAT DO?
# 
#   0. Using SteamCMD (as packaged by https://github.com/steamcmd/docker)...
#
#   1. Install or verify installation of RustDedicated (game server)
#
#   2. Install or update Carbon (modding framework)
#

MANAGED_DATA_VOL="steamcmd-data"

INSTALLER_IMAGE="steamcmd/steamcmd:debian-12@sha256:4f82cc9dc0a7beadbbc7dc289811ead83a93e22c249c07509418bb7151ec361f"
INSTALLER_CONTAINER="installer"

GAMESERVER_IMAGE="debian:12.7@sha256:b8084b1a576c5504a031936e1132574f4ce1d6cc7130bbcc25a28f074539ae6b"
GAMESERVER_CONTAINER="gameserver"

echo -n "INFO: Checking if Docker managed volume '$MANAGED_DATA_VOL' exists... "
docker volume inspect $MANAGED_DATA_VOL 2>/dev/null 1>/dev/null
exit_check_vol=$?
if test $exit_check_vol -ne 0; then
  echo "Does not exist!"
  echo -n "INFO: Creating Docker managed volume '$MANAGED_DATA_VOL'... "
  set -e
  docker volume create $MANAGED_DATA_VOL 1>/dev/null
  set +e
  echo "Created!"
else
  echo "Exists!"
fi

echo -n "INFO: Installing or updating RustDedicated game server in the managed volume '$MANAGED_DATA_VOL'... "
set -e
docker run --rm \
  --name $INSTALLER_CONTAINER \
  -v $MANAGED_DATA_VOL:/docker-managed-steamcmd-vol \
  $INSTALLER_IMAGE \
 +force_install_dir /docker-managed-steamcmd-vol +login anonymous +app_update 258550 validate +quit
set +e
echo "Done!"

docker run --rm \
  --name $GAMESERVER_CONTAINER \
  -v $MANAGED_DATA_VOL:/steamcmd-installations \
  -e LD_LIBRARY_PATH="/steamcmd-installations/RustDedicated_Data/Plugins/x86_64" \
  $GAMESERVER_IMAGE \
  /bin/sh -c "cd /steamcmd-installations && ./RustDedicated -batchmode +server.identity instance0 +rcon.port 28016 +rcon.web 1 +rcon.password instance0 +server.worldsize 1000"
