#
# // Check Libero version and path length to verify project can be created
#

set libero_release [split [get_libero_version] .]

if {[string compare [lindex $libero_release 0] "2022"] == 0 && [string compare [lindex $libero_release 1] "3"] == 0} {
    puts "Libero v2022.3 detected."
} elseif {[string compare [lindex $libero_release 0] "2023"] == 0 && [string compare [lindex $libero_release 1] "2"] == 0} {
    puts "Libero v2023.2 detected."
} elseif {[string compare [lindex $libero_release 0] "2024"] == 0 && [string compare [lindex $libero_release 1] "1"] == 0} {
    puts "Libero v2024.1 detected."
} else {
    error "Incorrect Libero version detected. Please use Libero v2023.2, v2022.3 or v2024.1 to run these scripts."
}


if { [lindex $tcl_platform(os) 0]  == "Windows" } {
    if {[string length [pwd]] < 90} {
        puts "Project path length ok."
    } else {
        error "Path to project is too long, please reduce the path and try again."
    }
}

#
# // Process arguments
#

if { $::argc > 0 } {
    set i 1
    foreach arg $::argv {
        if {[string match "*:*" $arg]} {
            set temp [split $arg ":"]
            puts "Setting parameter [lindex $temp 0] to [lindex $temp 1]"
            set [lindex $temp 0] "[lindex $temp 1]"
        } else {
            set $arg 1
            puts "set $arg to 1"
        }
        incr i
    }
} else {
    puts "no command line argument passed"
}

#
# // Set required variables and add functions
#

set install_loc [defvar_get -name ACTEL_SW_DIR]
set mss_config_loc "$install_loc/bin64/pfsoc_mss"
set local_dir [pwd]
set constraint_path ./script_support/constraints
set project_name "BVF_GATEWARE_025T"
#set top_level_name BVF_GATEWARE

if {[info exists PROG_EXPORT_PATH]} {
    set prog_export_path $PROG_EXPORT_PATH/bitstream
} else {
    set prog_export_path $local_dir/bitstream
}

set fpe_export_path $prog_export_path/FlashProExpress
set directc_export_path $prog_export_path/DirectC
set spi_export_path $prog_export_path/LinuxProgramming

if {[info exists TOP_LEVEL_NAME]} {
    set top_level_name $TOP_LEVEL_NAME
} else {
    set top_level_name BVF_GATEWARE
}

if {[info exists CAPE_OPTION]} {
    set cape_option "$CAPE_OPTION"
} else {
    set cape_option "DEFAULT"
}
puts "Cape options selected: $cape_option"

if {[info exists M2_OPTION]} {
    set m2_option "$M2_OPTION"
} else {
    set m2_option "DEFAULT"
}
puts "M.2 option selected: $m2_option"


if {[info exists SYZYGY_OPTION]} {
    set syzygy_option "$SYZYGY_OPTION"
} else {
    if {[info exists HIGH_SPEED_CONN_OPTION]} {
        set syzygy_option "$HIGH_SPEED_CONN_OPTION"
    } else {
        set syzygy_option "DEFAULT"
    }
}

puts "SYZYGY high speed connector option option selected: $syzygy_option"

if {[info exists MIPI_CSI_OPTION]} {
    set mipi_csi_option "$MIPI_CSI_OPTION"
} else {
    set mipi_csi_option "DEFAULT"
}
puts "MIPI CSI option option selected: $mipi_csi_option"

if {[info exists PROJECT_LOCATION]} {
    set project_dir "$PROJECT_LOCATION"
} else {
    set project_dir "$local_dir/$project_name"
}
puts "project_dir: $project_dir"

if {[info exists DESIGN_VERSION]} {
    set gateware_design_version "$DESIGN_VERSION"
} else {
    set gateware_design_version "1"
}

if {[info exists SILICON_SIGNATURE]} {
    set gateware_silicon_signature "$SILICON_SIGNATURE"
} else {
    set gateware_silicon_signature "bea913b0"
}

source ./script_support/additional_configurations/functions.tcl

