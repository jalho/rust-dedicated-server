# ideally we would define this with SteamCMD's force_install_dir option or something, but idk how to use it...
RDS_ABSOLUTE_PATH="/home/rust/Steam/steamapps/common/rust_dedicated/RustDedicated"

# hopefully this is not too volatile...
STEAMCMD_ABSOLUTE_PATH="/usr/games/steamcmd"

# an arbitrary ID for a RustDedicated instance that we must choose
RDS_INSTANCE_ID="instance0"
RDS_INSTANCE_CFG_DIR_PATH=$(dirname $RDS_ABSOLUTE_PATH)/server/$RDS_INSTANCE_ID/cfg

# an URL we trust to distribute Carbon
CARBON_RELEASE_URL="https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz"

# RCON -- cannot be configured in RDS instance config, so we must define env vars for CLI args
RCON_PORT=28016
RCON_PASSWORD="SET_ME"
