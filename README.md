# Usage

1. Install [_SteamCMD_](https://developer.valvesoftware.com/wiki/SteamCMD). It is
   used to install _RustDedicated_.

2. Using _SteamCMD_, install _RustDedicated_. In later steps we'll configure
   it to be run using _systemd_.

   ```bash
   steamcmd +login anonymous +app_update 258550 validate +quit
   ```

3. Create user `rust` with home `/home/rust/`. The _systemd_ managed service
   expects that.

   ```bash
   useradd -m rust
   ```

4. Put the dir `scripts/` in `/home/rust/`. The _systemd_ managed service
   expects that.

5. Put the file `rds.service` in `/etc/systemd/system/`. This configures the
   _systemd_ managed service. Then reload the _systemctl_ daemon with the new
   config:

   ```bash
   systemctl daemon-reload
   ```

6. Enable and start the _systemd_ managed service.

   ```bash
   systemctl enable rds.service
   systemctl start rds.service
   ```

7. Follow the service's logs.

   ```bash
   journalctl -fu rds.service
   ```

   In the logs you should see the service checking the server's health on a
   regular interval. The interval was configured in `rds.service`.

   To verify that the setup works, you may kill the game server and see how
   the _systemd_ setup detects it not being healthy and then restarts it:

   ```bash
   kill $(pgrep RustDedicated)
   ```
