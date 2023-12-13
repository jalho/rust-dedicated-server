RDS_USER_HOME="/home/rust"

# hopefully this is not too volatile...
STEAMCMD_ABSOLUTE_PATH="/usr/games/steamcmd"

# an arbitrary ID for a RustDedicated instance that we must choose
RDS_INSTANCE_ID="instance0"

# an URL we trust to distribute Carbon
CARBON_RELEASE_URL="https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz"

# RCON -- cannot be configured in RDS instance config, so we must define env vars for CLI args
RCON_PORT=28016
RCON_PASSWORD="SET_ME"

function get_rds_absolute_path() {
    echo "$(find $RDS_USER_HOME -type f -name RustDedicated)"
}
