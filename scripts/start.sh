RDS_INSTALLATION_DIR="/home/rust/.local/share/Steam/steamapps/common/rust_dedicated"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDS_INSTALLATION_DIR/RustDedicated_Data/Plugins"
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$RDS_INSTALLATION_DIR/RustDedicated_Data/Plugins/x86_64"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

cd $RDS_INSTALLATION_DIR
./RustDedicated -batchmode -logfile "rds.log" +server.identity "instance0" 2>&1
