## Usage

Tested on 3 Dec 2023 on:

```
Debian GNU/Linux 12 (bookworm)
Steam Console Client (c) Valve Corporation - version 1701290101
Carbon v1.2023.4314.0758
```

1. Create user `rust` with home `/home/rust/`. The _systemd_ managed service
   expects that.

   ```
   useradd -m rust
   ```

2. Install [_SteamCMD_](https://developer.valvesoftware.com/wiki/SteamCMD).
   It is used to install _RustDedicated_.

3. Using _SteamCMD_, install _RustDedicated_ for the user `rust` created earlier.
   In later steps we'll configure _systemd_ to run it.

   ```
   su rust
   cd
   /usr/games/steamcmd +login anonymous +app_update 258550 validate +quit
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

5. Put the dir `scripts/` in `/home/rust/`. The _systemd_ managed service
   expects that.

6. Install [Carbon](https://carbonmod.gg/) (modding framework). As of 3 Dec 2023
   it's distributed via GitHub releases so that you may extract it to the
   _RustDedicated_ installation directory:

   ```
   cd ~/.local/share/Steam/steamapps/common/rust_dedicated/
   wget https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Minimal.tar.gz
   tar -xzf Carbon.Linux.Minimal.tar.gz
   ```

   This will create a `carbon/` directory in the _RustDedicated_ installation
   directory.

   The Carbon installation is enabled in [start.sh](./scripts/start.sh) by
   sourcing the Carbon included `environment.sh`.

7. Put the file `rds.service` in `/etc/systemd/system/`. This configures the
   _systemd_ managed service. Then reload the _systemctl_ daemon with the new
   config:

   ```
   systemctl daemon-reload
   ```

8. Enable and start the _systemd_ managed service.

   ```
   systemctl enable rds.service
   systemctl start rds.service
   ```

## Tips

### Observing logs

See the _systemd_ managed service's logs:

   ```
   journalctl -fu rds.service
   ```

   or

   ```
   journalctl -xeu rds.service
   ```

Watch some process' stdout:

   ```
   watch -n 1 "tail /proc/$(pgrep RustDedicated)/fd/1"
   ```

The script that starts _RustDedicated_ ([start.sh](./scripts/start.sh)) may
define a log file for it (e.g. `rds.log`). Observe that file if it seems no
stdout is emitted from the process.

Carbon emits its logs to `carbon/logs`.

### Verifying the _systemd_ setup

To verify that the _systemd_ setup works, you may kill the game server and see
how it gets updated and restarted (or whatever else is defined in scripts
referred to in [rds.service](./rds.service)):

   ```
   kill $(pgrep RustDedicated)
   ```
