# Usage

1. Create user `rust` with home `/home/rust/`. The _systemd_ managed service
   expects that.

   ```bash
   useradd -m rust
   ```

2. Install [_SteamCMD_](https://developer.valvesoftware.com/wiki/SteamCMD). It is
   used to install _RustDedicated_.

3. Using _SteamCMD_, install _RustDedicated_. In later steps we'll configure
   it to be run using _systemd_.

   ```bash
   steamcmd +login anonymous +app_update 258550 validate +quit
   ```

   As of 3 Dec 2023, the _RustDedicated_ installation goes to
   `~/.local/share/Steam/steamapps/common/rust_dedicated/` by default.

4. Configure the game server by placing `server.cfg` and `users.cfg` in path
   `./server/instance0/cfg/` (relative to the _RustDedicated_ installation
   directory). `instance0` refers to a Rust internal identity which should match
   the identity parameter given to the `RustDedicated` executable when it's run.

   ```
   $ whoami
   rust
   $ mkdir -p ~/.local/share/Steam/steamapps/common/rust_dedicated/server/instance0/cfg
   ```

   Examples for `server.cfg` and `users.cfg` are provided in this repository.

5. Edit the server start script named `runds.sh` that comes with the _RustDedicated_
   installation (in the installation directory). Append to parameters:
   `+server.identity "instance0"`. Once run, this should make the server load
   the instance specific configuration created earlier.

6. Put the dir `scripts/` in `/home/rust/`. The _systemd_ managed service
   expects that.

7. Put the file `rds.service` in `/etc/systemd/system/`. This configures the
   _systemd_ managed service. Then reload the _systemctl_ daemon with the new
   config:

   ```bash
   systemctl daemon-reload
   ```

8. Enable and start the _systemd_ managed service.

   ```bash
   systemctl enable rds.service
   systemctl start rds.service
   ```

9. Follow the service's logs.

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
