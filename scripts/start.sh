RDS_INSTALLATION_DIR="/home/rust/.local/share/Steam/steamapps/common/rust_dedicated"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDS_INSTALLATION_DIR/RustDedicated_Data/Plugins"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDS_INSTALLATION_DIR/RustDedicated_Data/Plugins/x86_64"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# to enable Carbon (modding framework -- see https://docs.carbonmod.gg)
source $RDS_INSTALLATION_DIR/carbon/tools/environment.sh

cd $RDS_INSTALLATION_DIR
./RustDedicated -batchmode -logfile "rds.log" +server.identity "instance0" 2>&1
