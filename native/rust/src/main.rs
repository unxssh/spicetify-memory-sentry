//! Experimental launcher for the Rust migration.
//!
//! Safety gate: this binary deliberately does not change process memory yet.
//! Do not replace the existing Node.js helper with this executable until the
//! native process-discovery and recovery milestones in docs/RUST-MIGRATION.md
//! have passed Windows integration tests.

#[cfg(windows)]
#[path = "platform/windows.rs"]
mod platform;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.iter().any(|arg| arg == "--version") {
        println!("Memory Sentry native scaffold {}", env!("CARGO_PKG_VERSION"));
        return;
    }

    if args.iter().any(|arg| arg == "--self-test") {
        println!("Rust policy scaffold is built. No working-set limits are changed by this command.");
        return;
    }

    #[cfg(not(windows))]
    {
        eprintln!("Memory Sentry supports Windows 10 and Windows 11 desktop editions only.");
        std::process::exit(2);
    }

    #[cfg(windows)]
    {
        match platform::detect_supported_client_os() {
            Ok((name, build)) => {
                eprintln!("{name} build {build} detected.");
                eprintln!("This Rust migration scaffold does not apply working-set limits yet; the existing helper remains the supported implementation.");
                std::process::exit(3);
            }
            Err(reason) => {
                eprintln!("Memory Sentry supports Windows 10 and Windows 11 desktop editions only: {reason}");
                std::process::exit(2);
            }
        }
    }
}
