# Usage

1. Provision a Debian VM with at least 16 GB RAM.
2. Install [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD#Manually)
   on the VM so that its entrypoint is at `home/rust/steamcmd/steamcmd.sh`.
3. Put compiled `rds-manager` to `/home/rust/rds-manager` in the VM.
   - `cargo build --release`
   - `scp target/release/rds-manager rust:/home/rust/`
4. Put the directory `server/` from this repository to `/home/rust/server` in
   the VM. Check the contained game server config files.
   - `scp -r server rust:/home/rust/`
5. Put the directory `scripts/` from this repository to `/home/rust/scripts` in
   the VM.
   - `scp -r scripts rust:/home/rust/`
6. Put `rust.service` from this repository to `/etc/systemd/system/rust.service`
   in the VM and reload systemd
   - `systemctl daemon-reload`
7. Start the systemd managed `rds-manager`
   - `systemctl enable rust`
   - `systemctl start rust`

## TODO

- [ ] This setup does not use the specified RDS instance ID ("instance0") for
      some reason, but the RDS default "my_server_identity" (with seed 1337)
      instead. Also the log file specified at `scripts/start-rds.sh` does not
      appear. Figure out why!
