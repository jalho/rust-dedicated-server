use std::path::PathBuf;

/// Parameters:
/// - **Absolute path to working directory** from which any rds-manager
///   operations shall be carried out. This will hopefully make it predictable
///   where SteamCMD installs its stuff and where RustDedicated emits its
///   artifacts and whatnot.
/// - **Discord webhook URL(s)** to notify of rds-manager events such as
///   server updating, server starting, server detected unhealthy etc.
fn main() {
    let discord_webhook_url = String::from("TODO");
    let rcon_password = String::from("Your_Rcon_Password");
    let working_directory: PathBuf = "/home/rust/".into();

    loop {
        install_or_update(&working_directory);
        run_server_blocking(&working_directory, rcon_password);
        panic!();
    }
}

/// Install or update _RustDedicated_ using SteamCMD.
fn install_or_update(working_directory: &PathBuf) {
    Command::new(
        working_directory,
        String::from("steamcmd"),
        vec![
            String::from("+force_install_dir"),
            working_directory.to_string_lossy().to_string(),
            String::from("+login"),
            String::from("anonymous"),
            String::from("+app_update"),
            String::from("258550"),
            String::from("validate"),
            String::from("+quit"),
        ],
    )
    .execute();
}

/// Run _RustDedicated_ executable. Return when the executable finishes.
fn run_server_blocking(working_directory: &PathBuf, rcon_password: String) {
    let rds_executable_name = "RustDedicated";
    let rds_executable_path = working_directory.join(rds_executable_name); // e.g. "/home/rust/RustDedicated"
    let rds_instance_id = String::from("instance0");
    Command::new(
        working_directory,
        rds_executable_path.to_string_lossy().to_string(),
        vec![
            String::from("-batchmode"),
            String::from("+server.identity"),
            rds_instance_id,
            String::from("+rcon.port"),
            String::from("28016"),
            String::from("+rcon.web"),
            String::from("1"),
            String::from("+rcon.password"),
            rcon_password,
        ],
    )
    .execute();
}

struct Command<'execution_context> {
    executable_path_name: String,
    working_directory: &'execution_context PathBuf,
    argv: Vec<String>,
}

impl<'execution_context> Command<'execution_context> {
    fn new(
        working_directory: &'execution_context PathBuf,
        executable_path_name: String,
        args: Vec<String>,
    ) -> Self {
        return Command {
            executable_path_name,
            working_directory,
            argv: args,
        };
    }

    fn execute(&self) {
        let mut cmd = std::process::Command::new(&self.executable_path_name);
        cmd.current_dir(&self.working_directory);
        cmd.args(&self.argv);
        match cmd.status() {
            Ok(_) => {}
            Err(_) => {
                eprintln!(
                    "Failed to execute '{}' in '{}'! Is the executable installed? Does the working directory exist?",
                    self.executable_path_name,
                    self.working_directory.to_string_lossy(),
                );
                todo!();
            }
        }
    }
}
