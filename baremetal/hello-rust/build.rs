use std::path::PathBuf;
use walkdir::WalkDir;

fn main() {
    // Find all C source files, excluding specific directories
    let c_sources: Vec<PathBuf> = WalkDir::new("mpfs-platform")
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| {
            let path = e.path();
            let is_c_file = path.extension().map_or(false, |ext| ext == "c");
            let path_str = path.to_string_lossy().replace('\\', "/");
            let in_mss = path_str.contains("mpfs-platform/platform/drivers/mss");
            let in_allowed_mss = path_str.contains("mss_uart") || path_str.contains("mss_gpio");

            is_c_file && (!in_mss || in_allowed_mss)
        })
        .map(|e| e.path().to_owned())
        .collect();

    // Define assembly sources
    let asm_sources = [
        "mpfs-platform/platform/mpfs_hal/startup_gcc/mss_entry.S",
        "mpfs-platform/platform/mpfs_hal/startup_gcc/mss_utils.S",
        "mpfs-platform/platform/hal/hw_reg_access.S",
    ];

    // Common compiler flags from the makefile
    let mut build = cc::Build::new();
    build
        .flag("-march=rv64gc")
        .flag("-mabi=lp64d")
        .flag("-mcmodel=medany")
        .flag("-msmall-data-limit=8")
        .flag("-mstrict-align")
        .flag("-mno-save-restore")
        .flag("-Os")
        .flag("-ffunction-sections")
        .flag("-fdata-sections")
        .flag("-fsigned-char")
        .flag("-g")
        .define("NDEBUG", None)
        .includes(&[
            "mpfs-platform/application",
            "mpfs-platform/boards/beaglev-fire/platform_config",
            "mpfs-platform/platform",
            "mpfs-platform/boards/beaglev-fire",
        ]);

    // Compile C sources
    let mut c_build = build.clone();
    c_build
        .compiler("riscv64-unknown-elf-gcc")
        .std("gnu11")
        .flag("-Wstrict-prototypes")
        .flag("-Wbad-function-cast")
        .files(c_sources);

    // Compile assembly sources
    let mut asm_build = build.clone();
    asm_build
        .compiler("riscv64-unknown-elf-gcc")
        .files(asm_sources)
        .flag("-x")
        .flag("assembler-with-cpp");

    // Perform the compilation
    c_build.compile("platform_c");
    asm_build.compile("platform_asm");

    // Linker
    let out_dir = PathBuf::from(std::env::var("OUT_DIR").unwrap());
    let linker_script =
        "mpfs-platform/platform/platform_config_reference/linker/mpfs-ddr-loaded-by-boot-loader.ld";
    let linker_script_dst = out_dir.join("linker.ld");
    std::fs::copy(linker_script, &linker_script_dst).unwrap();

    println!("cargo:rustc-link-search={}", out_dir.display());
    println!("cargo:rustc-link-arg=-Tlinker.ld");
    println!("cargo:rustc-link-arg=--gc-sections");
    // These are the flags that the makefile uses, but that the rust linker doesn't recognize
    // println!("cargo:rustc-link-arg=-march=rv64gc");
    // println!("cargo:rustc-link-arg=-mabi=lp64d");
    // println!("cargo:rustc-link-arg=-mcmodel=medany");
    // println!("cargo:rustc-link-arg=-msmall-data-limit=8");
    // println!("cargo:rustc-link-arg=-mstrict-align");
    // println!("cargo:rustc-link-arg=-mno-save-restore");
    // println!("cargo:rustc-link-arg=-Os");
    // println!("cargo:rustc-link-arg=-g");
    // println!("cargo:rustc-link-arg=-fmessage-length=0");
    // println!("cargo:rustc-link-arg=-ffunction-sections");
    // println!("cargo:rustc-link-arg=-fdata-sections");
    // println!("cargo:rustc-link-arg=-fsigned-char");
    // println!("cargo:rustc-link-arg=-Xlinker");
    // println!("cargo:rustc-link-arg=--specs=nano.specs");
    // println!("cargo:rustc-link-arg=--specs=nosys.specs");
    // println!("cargo:rustc-link-arg=-nostartfiles");

    // Tell cargo to rerun if any files in mpfs-platform change
    println!("cargo:rerun-if-changed=mpfs-platform");
    println!("cargo:rerun-if-changed=build.rs");
}
