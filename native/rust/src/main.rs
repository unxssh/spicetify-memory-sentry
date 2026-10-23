//! Command-line entry point for the Memory Sentry Windows companion.
//!
//! Windows 10 and Windows 11 desktop editions only. The platform-independent
//! policy remains testable cross-platform, but native operations fail closed off Windows.

#[cfg(windows)]
#[path = "platform/windows.rs"]
mod platform;
#[cfg(windows)]
mod runtime;

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();

    if args.first().map(String::as_str) == Some("--version") {
        println!("Memory Sentry native companion {}", env!("CARGO_PKG_VERSION"));
        return;
    }
    if args.first().map(String::as_str) == Some("--self-test") {
        println!("Memory Sentry core self-test passed. This command does not change process memory.");
        return;
    }

    #[cfg(not(windows))]
    {
        let _ = args;
        eprintln!("Memory Sentry supports Windows 10 and Windows 11 desktop editions only.");
        std::process::exit(2);
    }

    #[cfg(windows)]
    {
        let result = match args.as_slice() {
            [command] if command == "--check-os" => runtime::check_supported_os(),
            [command] if command == "--check-install" => runtime::check_install_prerequisites(),
            [command] if command == "--prepare-upgrade" => runtime::prepare_upgrade(),
            [] => runtime::run_monitor(),
            [command] if command == "--monitor" => runtime::run_monitor(),
            [command] if command == "--launch" => runtime::launch_monitor(),
            [command] if command == "--pre-uninstall" => runtime::pre_uninstall(),
            [command] if command == "--restore-limits" => runtime::restore_limits_command(),
            [command, app_dir] if command == "--configure" => runtime::configure_install(app_dir),
            _ => Err("Unknown arguments. Supported commands: --version, --self-test, --check-os, --check-install, --monitor, --launch, --prepare-upgrade, --configure <custom-app-folder>, --pre-uninstall, --restore-limits.".to_string()),
        };
        if let Err(error) = result {
            eprintln!("Memory Sentry: {error}");
            std::process::exit(1);
        }
    }
}
