# Usage

1. Provision a Debian VM with at least 16 GB RAM.

2. Install [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD#Manually)
   on the VM so that its entrypoint is at `/home/rust/steamcmd/steamcmd.sh`. The
   entry point needs to be different of where RustDedicated will be installed
   (that being `/home/rust/`)!

   ```
   mkdir -p /home/rust/steamcmd
   cd /home/rust/steamcmd
   curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
   ```

3. Install [Carbon](https://carbonmod.gg/) where RustDedicated will be installed, i.e. `/home/rust/`.

   ```
   cd /home/rust/
   wget https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz
   tar -xzf Carbon.Linux.Release.tar.gz
   ```

4. Put the directory [`server/`](./server/) from this repository to
   `/home/rust/server` in the VM. Check the contained game server config files.

   ```
   scp -r server rust:/home/rust/
   ```

5. Put the RDS running script [`run-with-carbon.sh`](./run-with-carbon.sh) from
   this repository to `/home/rust/` in the VM. It will be run by systemd.

6. Put the systemd unit files (`*.service`, `*.timer`) from this repository to
   `/etc/systemd/system/` in the VM. Reload systemd.

   ```
   systemctl daemon-reload
   ```

7. Start the systemd managed Rust game server service.

   ```
   systemctl enable rust
   systemctl start rust
   ```

8. Start scheduled wipe services.

   ```
   systemctl enable wipe-weekly-map-only.timer
   systemctl start wipe-weekly-map-only.timer
   systemctl enable wipe-weekly-map-only.service
   systemctl start wipe-weekly-map-only.service
   ```

   ```
   systemctl enable wipe-monthly-full.timer
   systemctl start wipe-monthly-full.timer
   systemctl enable wipe-monthly-full.service
   systemctl start wipe-monthly-full.service
   ```

9. Now you should have systemd running RustDedicated.
