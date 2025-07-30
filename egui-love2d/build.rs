use std::env;
use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=src/");
    
    // Get the target OS
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    
    // Platform-specific build configurations
    match target_os.as_str() {
        "windows" => {
            // On Windows, we might need to link against specific libraries
            println!("cargo:rustc-link-lib=dylib=user32");
            println!("cargo:rustc-link-lib=dylib=gdi32");
        },
        "macos" => {
            // On macOS, link against Cocoa framework if needed
            println!("cargo:rustc-link-lib=framework=Cocoa");
        },
        "linux" => {
            // On Linux, ensure we have the necessary X11 libraries
            if let Ok(output) = Command::new("pkg-config")
                .args(&["--libs", "x11"])
                .output() 
            {
                if output.status.success() {
                    let libs = String::from_utf8_lossy(&output.stdout);
                    for lib in libs.split_whitespace() {
                        if lib.starts_with("-l") {
                            println!("cargo:rustc-link-lib=dylib={}", &lib[2..]);
                        }
                    }
                }
            }
        },
        _ => {}
    }
    
    // Check for Lua development libraries
    if let Ok(output) = Command::new("pkg-config")
        .args(&["--cflags", "--libs", "lua5.4"])
        .output()
    {
        if output.status.success() {
            let flags = String::from_utf8_lossy(&output.stdout);
            for flag in flags.split_whitespace() {
                if flag.starts_with("-l") {
                    println!("cargo:rustc-link-lib=dylib={}", &flag[2..]);
                } else if flag.starts_with("-L") {
                    println!("cargo:rustc-link-search=native={}", &flag[2..]);
                }
            }
        }
    }
}