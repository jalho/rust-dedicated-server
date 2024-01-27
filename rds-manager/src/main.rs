use std::{process::{Command, Stdio}, path::PathBuf};

/// Parameters:
/// - **Absolute path to working directory** from which any rds-manager
///   operations shall be carried out. This will hopefully make it predictable
///   where SteamCMD installs its stuff and where RustDedicated emits its
///   artifacts and whatnot.
/// - **Discord webhook URL(s)** to notify of rds-manager events such as
///   server updating, server starting, server detected unhealthy etc.
fn main() {
    let discord_webhook_url = String::from("TODO");
    let working_directory: PathBuf = "/home/rust".into();

    loop {
        if check_for_updates() {
            update();
        }

        run_server_blocking();
    }
}

/// TODO: How to check whether there are updates available for _RustDedicated_?
fn check_for_updates() -> bool {
    return true;
}

/// Update _RustDedicated_ using SteamCMD.
fn update() {}

/// Run _RustDedicated_ executable. Return when the executable finishes.
fn run_server_blocking() {
    let mut cmd = Command::new("echo");
    cmd.args(["foo"]);
    cmd.stdout(Stdio::null());
    cmd.stderr(Stdio::null());

    // wait to finish
    match cmd.status() {
        _ => {}
    }
}
