#!/bin/bash

DOWNLOAD_CARBONMOD="https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz"

set -xe

webhook_url="https://discord.com/api/webhooks/0000000000000000000/0aa0aaaaaaa0aaaaa0aaaaaaaaaaaaaa0aaaa0aaaaaaa_aa-aaaaa_0aaaaaaaaa0aa"

cd /home/rust/
json_payload='{"content":"Going to start the server... First checking for updates!"}'
curl -X POST -H "Content-Type: application/json" -d "$json_payload" "$webhook_url"

if test -f carbon/config.json; then
  cp carbon/config.json carbon-config-backup.json
fi

rm Carbon.Linux.Release.tar.gz || true
wget $DOWNLOAD_CARBONMOD
tar -xzf Carbon.Linux.Release.tar.gz

if test -f carbon-config-backup.json; then
  rm carbon/config.json
  mv carbon-config-backup.json carbon/config.json
fi

/home/rust/steamcmd/steamcmd.sh +force_install_dir /home/rust/ +login anonymous +app_update 258550 validate +quit

json_payload='{"content":"Update check successful!"}'
curl -X POST -H "Content-Type: application/json" -d "$json_payload" "$webhook_url"

source /home/rust/carbon/tools/environment.sh

json_payload='{"content":"Starting server... This usually takes around 15 minutes..."}'
curl -X POST -H "Content-Type: application/json" -d "$json_payload" "$webhook_url"
/home/rust/RustDedicated -batchmode +server.identity instance0 +rcon.port 28016 +rcon.web 1 +rcon.password Your_Rcon_Password

# There will be no alert to Discord from this script about the server being
# ready because the process is handed over to RustDedicated!
