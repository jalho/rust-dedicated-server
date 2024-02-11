# Usage

1. Provision a Debian VM with at least 16 GB RAM
2. Install [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD#Manually)
   on the VM so that its entrypoint is at `home/rust/steamcmd/steamcmd.sh`
3. Put compiled `rds-manager` to `/home/rust/` in the VM
   - Compiling: `cargo build --release`
   - Moving: `scp target/release/rds-manager rust:/home/rust/`
4. Put the directory `server/` from this repository to `/home/rust/` in the VM
   - Check the contained Rust game server config files
5. Put `rust.service` from this repository to `/etc/systemd/system/` in the VM
   and reload systemd
   - `systemctl daemon-reload`
6. Start the systemd managed `rds-manager`
   - `systemctl enable rust`
   - `systemctl start rust`

## Tips

- Observe the logs of the systemd managed `rds-manager`: `journalctl -fu rust`
- Kill RustDedicated process `kill $(pgrep RustDedicated)`
