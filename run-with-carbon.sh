#!/bin/bash

cd /home/rust/
/home/rust/steamcmd/steamcmd.sh +force_install_dir /home/rust/ +login anonymous +app_update 258550 validate +quit
source /home/rust/carbon.sh
/home/rust/RustDedicated -batchmode +server.identity instance0 +rcon.port 28016 +rcon.web 1 +rcon.password Your_Rcon_Password
