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
#
#  TESTED ON 2024-09-21 ON:
#
#   Debian GNU/Linux 12 (bookworm)
#   kernel release 6.1.0-23-amd64
#   Docker version 27.2.0, build 3ab4256
#

MANAGED_DATA_VOL="steamcmd-data"

# initially tested with sha256:4f82cc9dc0a7beadbbc7dc289811ead83a93e22c249c07509418bb7151ec361f
INSTALLER_IMAGE="steamcmd/steamcmd:debian-12"
INSTALLER_CONTAINER="installer"

# initially tested with sha256:b8084b1a576c5504a031936e1132574f4ce1d6cc7130bbcc25a28f074539ae6b
GAMESERVER_IMAGE="debian:12.7"
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

echo -n "INFO: Installing or updating game server in managed volume '$MANAGED_DATA_VOL' using container '$INSTALLER_CONTAINER'... "
set -e
docker run --rm -d \
  --name $INSTALLER_CONTAINER \
  -v $MANAGED_DATA_VOL:/docker-managed-steamcmd-vol \
  $INSTALLER_IMAGE \
 +force_install_dir /docker-managed-steamcmd-vol +login anonymous +app_update 258550 validate +quit \
 1>/dev/null
docker wait $INSTALLER_CONTAINER 1>/dev/null
set +e
echo "Installed!"

echo -n "INFO: Starting game server in detached container '$GAMESERVER_CONTAINER'... "
set -e
docker run --rm -d \
  --name $GAMESERVER_CONTAINER \
  -v $MANAGED_DATA_VOL:/steamcmd-installations \
  -e LD_LIBRARY_PATH="/steamcmd-installations/RustDedicated_Data/Plugins/x86_64" \
  $GAMESERVER_IMAGE \
  /bin/sh -c "cd /steamcmd-installations && ./RustDedicated -batchmode +server.identity instance0 +rcon.port 28016 +rcon.web 1 +rcon.password instance0 +server.worldsize 1000" \
  1>/dev/null
set +e
echo "Started!"

echo "INFO: Following game server logs!"
docker container logs -f $GAMESERVER_CONTAINER
