use std::path::PathBuf;

fn main() {
    let discord_webhook_url = String::from("TODO"); // TODO: alert some Discord channel of server updating, starting, etc.
    let rcon_password = String::from("Your_Rcon_Password");
    let working_directory: PathBuf = "/home/rust/".into();
    let rds_instance_id = String::from("instance0");
    let carbon_download_url = String::from("https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz");

    println!("RDS-MANAGER START");
    check_working_dir(&working_directory, &rds_instance_id).unwrap();
    check_install_carbonmod(&working_directory, carbon_download_url);
    install_or_update_rds(&working_directory);
    run_server_blocking(&working_directory, rcon_password, rds_instance_id);
}

/// Check the working directory to exist and to contain required config and data
/// files.
fn check_working_dir(working_directory: &PathBuf, rds_instance_id: &String) -> Result<(), String> {
    if !working_directory.exists() {
        return Err(String::from(format!(
            "Expected working directory '{}' to exist",
            working_directory.to_string_lossy()
        )));
    }

    let rds_server_cfg_path =
        working_directory.join(format!("server/{}/cfg/server.cfg", rds_instance_id));
    if !rds_server_cfg_path.exists() {
        return Err(String::from(format!(
            "Expected RDS instance server config file '{}' to exist",
            rds_server_cfg_path.to_string_lossy()
        )));
    }

    let rds_users_cfg_path =
        working_directory.join(format!("server/{}/cfg/users.cfg", rds_instance_id));
    if !rds_users_cfg_path.exists() {
        return Err(String::from(format!(
            "Expected RDS instance users config file '{}' to exist",
            rds_users_cfg_path.to_string_lossy()
        )));
    }

    // TODO: add some sqlite db for collecting stats and check its data file to exist...

    return Ok(());
}

/// Check whether Carbon (modding framework) is installed, and install if not.
/// It's supposed to be self-updating, so no explicit update step is required
/// once installed.
fn check_install_carbonmod(working_directory: &PathBuf, carbon_download_url: String) {
    let carbon_installation_path = working_directory.join("carbon");
    if carbon_installation_path.exists() {
        println!("Found presumable Carbon installation at '{}', not reinstalling!", carbon_installation_path.to_string_lossy());
        return;
    }
    let download_filename = String::from("carbon.tgz");
    Command::new(
        working_directory,
        String::from("wget"),
        vec![
            String::from("-O"),
            download_filename.clone(), // TODO: make this thing accept borrowed instead
            carbon_download_url,
        ],
    )
    .execute();
    Command::new(
        working_directory,
        String::from("tar"),
        vec![String::from("-xzf"), download_filename],
    )
    .execute();
}

/// Install or update _RustDedicated_ using SteamCMD.
fn install_or_update_rds(working_directory: &PathBuf) {
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
fn run_server_blocking(
    working_directory: &PathBuf,
    rcon_password: String,
    rds_instance_id: String,
) {
    let rds_executable_name = "RustDedicated";
    let rds_executable_path = working_directory.join(rds_executable_name); // e.g. "/home/rust/RustDedicated"
    Command::new(
        working_directory,
        String::from("bash"),
        vec![
            String::from("-c"),
            String::from(format!(
                // load ("source") carbon.sh and then execute RustDedicated with it
                ". carbon.sh && '{}' -batchmode +server.identity {} +rcon.port 28016 +rcon.web 1 +rcon.password {}",
                rds_executable_path.to_string_lossy().to_string(),
                rds_instance_id,
                rcon_password
            )),
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
            Ok(exit_status) => {
                println!(
                    "'{}' finished with status '{}'",
                    &self.executable_path_name, exit_status
                );
            }
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
