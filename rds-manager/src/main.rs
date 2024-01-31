use std::{
    path::PathBuf,
    process::{Command, Stdio},
};

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
            update(&working_directory);
        }

        run_server_blocking(&working_directory);

        panic!();
    }
}

/// TODO: How to check whether there are updates available for _RustDedicated_?
fn check_for_updates() -> bool {
    return true;
}

/// Update _RustDedicated_ using SteamCMD.
fn update(working_directory: &PathBuf) {
    let mut cmd = Command::new("echo");
    cmd.current_dir(working_directory);
    cmd.args(["Updating or installing RustDedicated using SteamCMD..."]);
    cmd.stderr(Stdio::null());

    // wait to finish
    match cmd.status() {
        Ok(_) => {}
        Err(err) => {
            eprintln!("{:?}", err);
            todo!();
        }
    }
}

/// Run _RustDedicated_ executable. Return when the executable finishes.
fn run_server_blocking(working_directory: &PathBuf) {
    let mut cmd = Command::new("echo");
    cmd.current_dir(working_directory);
    cmd.args(["Running RustDedicated..."]);
    cmd.stderr(Stdio::null());

    // wait to finish
    match cmd.status() {
        Ok(_) => {}
        Err(err) => {
            eprintln!("{:?}", err);
            todo!();
        }
    }
}
