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

3. Put the dir `scripts/` from this repository in `/home/rust/`.

   Check values defined in [\_constants.sh](./scripts/_constants.sh), like `$RCON_PASSWORD`.

4. Install [_RustDedicated_](https://developer.valvesoftware.com/wiki/Rust_Dedicated_Server#Installation)
   and [_Carbon_](https://carbonmod.gg/) (modding framework).

   ```
   su rust
   cd /home/rust
   bash /home/rust/scripts/prestart.sh
   ```

   The script `prestart.sh` is the same that _systemd_ will use to regularly check whether to update _RustDedicated_.

   Once the script has completed running, _RustDedicated_ should be installed in `$RDS_ABSOLUTE_PATH` defined in [\_constants.sh](./scripts/_constants.sh).

5. Configure the game server by placing `server.cfg` and `users.cfg` in path
   `./server/$ID/cfg/` (relative to the _RustDedicated_ installation
   directory).

   Examples for `server.cfg` and `users.cfg` are provided in this repository:

   ```
   cd $(dirname $RDS_ABSOLUTE_PATH)/server/$RDS_INSTANCE_ID/cfg
   wget https://raw.githubusercontent.com/jalho/rust-dedicated-server/master/server.cfg
   wget https://raw.githubusercontent.com/jalho/rust-dedicated-server/master/users.cfg
   ```

6. Put the files `*.service` and `*.timer` files from this repository to
   `/etc/systemd/system/`. This configures _systemd_ managed services and
   their associated timers. Reload the daemon with the new config:

   ```
   systemctl daemon-reload
   ```

7. Enable and start the _systemd_ managed services and their associated timers:

   ```
   systemctl enable rds.service && systemctl start rds.service
   systemctl enable rds-wipe.service && systemctl start rds-wipe.service
   systemctl enable rds-wipe.timer && systemctl start rds-wipe.timer
   ```

   Likewise to disable:

   ```
   systemctl stop rds-wipe.timer && systemctl disable rds-wipe.timer
   systemctl stop rds-wipe.service && systemctl disable rds-wipe.service
   systemctl stop rds.service && systemctl disable rds.service
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
stdout is emitted from the process. For example:

```
watch -n 1 "tail $(dirname $RDS_ABSOLUTE_PATH)/rds.log"
```

Carbon emits its logs to `$(dirname RDS_ABSOLUTE_PATH)/carbon/logs/`.

### Sending RCON commands

Use e.g. [rcon-cli](https://github.com/jalho/rcon-cli):

```
$ rcon-cli --password "SET_ME" --command "playerlist"
```

### Verifying the _systemd_ setup

To verify that the _systemd_ setup works, you may kill the game server and see
how it gets updated and restarted (or whatever else is defined in scripts
referred to in [rds.service](./rds.service)):

```
kill $(pgrep RustDedicated)
```
