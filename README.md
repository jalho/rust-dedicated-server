# Weekend Rust Server

My setup for hosting _RustDedicated_ server (RDS), i.e. a game server for the
survival video game called _Rust_. The server is distributed via _SteamCMD_ as
an executable called `RustDedicated`.

The setup's idea is to have a Rust server reliably up part time, mainly on
weekends. The reliability part is solved by managing the server with _systemd_
so that it restarts and updates automatically when necessary, and the part time
weekend focus is solved by deploying the stack on Google Cloud and utilizing VM
instance schedules there. The point of the part time scheduling is to only incur
server hosting costs when necessary, i.e. on weekends, and maybe a couple hours
on weekday evenings.

## Components

- _Rust Server Starter_: Wipe, update and start a Rust server.

  This program is executed each time at the VM instance's startup. It performs
  the following task sequence:

  1.  **Conditional Wipe:** Check whether it is Friday and whether or not the
      Rust server has wiped today already. If there's already been a wipe today,
      then proceed to step #2 ("Rust Server Startup"). If there hasn't been a
      wipe today yet, then do the wipe:

      1. Make sure the Rust server is not running. Disable and stop any
         corresponding systemd managed services. Kill the corresponding
         processes started by the services.
      2. Delete saved map files and any other weekly wipe specific data.
      3. Generate and configure a new random map seed.
      4. If it's the first Friday of the month, delete players' saved blueprints.

  2.  **Rust Server Update:** Update the Rust server if there are updates
      available, using SteamCMD.

  3.  **Rust Server Start:** Start the game server.

- _RDS Sync_: A program that sits between web browser clients and RDS, sending
  game state updates to the clients and passing admin commands from the clients
  to the game server.

  See [jalho/rds-sync](https://github.com/jalho/rds-sync).

## Setting things up

1. Provision a virtual machine (VM) for running `RustDedicated`.
   Debian 11, 2-4 vCPUs and 16 GB of RAM is good.

2. Configure _Rust Server Starter_ described above to be managed by systemd on
   the VM. It should run at VM startup, and rerun automatically if the started
   `RustDedicated` process terminates for any reason.

3. Set up VM instance schedules (a Google Cloud feature). For example:
   - Start the VM:
     - Monday to Friday: at 14 UTC
     - Saturday and Sunday: no start -- should be up already
   - Stop the VM:
     - Sunday to Thursday: at midnight UTC
     - Friday and Saturday: no stop -- let it run
