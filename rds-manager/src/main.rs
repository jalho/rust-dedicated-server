use std::path::PathBuf;

fn main() {
    let discord_webhook_url = String::from("TODO"); // TODO: alert some Discord channel of server updating, starting, etc.
    let working_directory: PathBuf = "/home/rust/".into();
    let rds_instance_id = String::from("instance0"); // TODO: bind symbol to def in scripts/start-rds.sh somehow
    let carbon_download_url = String::from("https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz");

    println!("RDS-MANAGER START");
    check_working_dir(&working_directory, &rds_instance_id).unwrap();
    check_install_carbonmod(&working_directory, carbon_download_url);
    println!("STEAMCMD START");
    install_or_update_rds(&working_directory);
    println!("RDS START");
    run_server_blocking(&working_directory);
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
        println!(
            "Found presumable Carbon installation at '{}', not reinstalling!",
            carbon_installation_path.to_string_lossy()
        );
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
    .fork();
    Command::new(
        working_directory,
        String::from("tar"),
        vec![String::from("-xzf"), download_filename],
    )
    .fork();
}

/// Install or update _RustDedicated_ using SteamCMD.
fn install_or_update_rds(working_directory: &PathBuf) {
    let steamcmd_executable_name = "steamcmd/steamcmd.sh";
    let steamcmd_executable_path = working_directory.join(steamcmd_executable_name); // e.g. "/home/rust/steamcmd/steamcmd.sh"
    Command::new(
        working_directory,
        steamcmd_executable_path.to_string_lossy().to_string(),
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
    .fork();
}

/// Run _RustDedicated_ executable. Return when the executable finishes.
fn run_server_blocking(working_directory: &PathBuf) {
    // TODO: load Carbon (modding framework) somehow...
    let rds_executable_name = String::from("RustDedicated");
    Command::new(
        working_directory,
        working_directory
            .join(rds_executable_name)
            .to_string_lossy()
            .to_string(),
        vec![
            String::from("-batchmode"),
            String::from("+server.identity"),
            String::from("instance0"), // TODO: parameterize
            String::from("+rcon.port"),
            String::from("28016"), // TODO: parameterize
            String::from("+rcon.web"),
            String::from("1"),
            String::from("+rcon.password"),
            String::from("Your_Rcon_Password"), // TODO: parameterize
        ],
    )
    .execute();
}

#[derive(Debug)]
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

    /// Execute as a new child process.
    fn fork(&self) {
        let mut cmd = std::process::Command::new(&self.executable_path_name);
        cmd.current_dir(&self.working_directory);
        cmd.args(&self.argv);
        println!("{:?}", self);
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

    /// Execute as current process.
    fn execute(&self) {
        let mut cmd = std::process::Command::new(&self.executable_path_name);
        cmd.current_dir(&self.working_directory);
        cmd.args(&self.argv);
        println!("{:?}", self);
        std::os::unix::process::CommandExt::exec(&mut cmd);
    }
}
