# Usage

Tested on 3 Dec 2023 on:
```
Debian GNU/Linux 12 (bookworm)
Steam Console Client (c) Valve Corporation - version 1701290101
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

6. Put the file `rds.service` in `/etc/systemd/system/`. This configures the
   _systemd_ managed service. Then reload the _systemctl_ daemon with the new
   config:

   ```
   systemctl daemon-reload
   ```

7. Enable and start the _systemd_ managed service.

   ```
   systemctl enable rds.service
   systemctl start rds.service
   ```

8. Follow the service's logs.

   ```
   journalctl -fu rds.service
   ```

   or alternatively watch e.g. process stdout:

   ```
   watch -n 1 "tail /proc/$(pgrep RustDedicated)/fd/1"
   ```

   To verify that the setup works, you may kill the game server and see how
   the _systemd_ setup detects it not being healthy and then restarts it:

   ```
   kill $(pgrep RustDedicated)
   ```
