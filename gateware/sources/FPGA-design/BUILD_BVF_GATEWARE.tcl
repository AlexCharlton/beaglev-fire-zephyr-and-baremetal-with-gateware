#
# This is based on the Icicle Kit Refernece Design TCL script
#

source ./ENV.tcl

#
# // Create Libero project
#

new_project \
    -location $project_dir \
    -name $project_name \
    -project_description {} \
    -block_mode 0 \
    -standalone_peripheral_initialization 0 \
    -instantiate_in_smartdesign 1 \
    -ondemand_build_dh 1 \
    -use_relative_path 0 \
    -linked_files_root_dir_env {} \
    -hdl {VERILOG} \
    -family {PolarFireSoC} \
    -die {MPFS025T} \
    -package {FCVG484} \
    -speed {STD} \
    -die_voltage {1.0} \
    -part_range {EXT} \
    -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
    -adv_options {RESTRICTPROBEPINS:0} \
    -adv_options {RESTRICTSPIPINS:0} \
    -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
    -adv_options {TARGETDEVICESFORMIGRATION:MPFS095T;MPFS160T;MPFS095TL;MPFS160TL;} \
    -adv_options {TEMPR:EXT} \
    -adv_options {VCCI_1.2_VOLTR:EXT} \
    -adv_options {VCCI_1.5_VOLTR:EXT} \
    -adv_options {VCCI_1.8_VOLTR:EXT} \
    -adv_options {VCCI_2.5_VOLTR:EXT} \
    -adv_options {VCCI_3.3_VOLTR:EXT} \
    -adv_options {VOLTR:EXT}

#
# // Download required cores
#

download_core -vlnv {Actel:SgCore:PF_OSC:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_CCC:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:DirectCore:CORERESET_PF:*} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Microsemi:SgCore:PFSOC_INIT_MONITOR:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:DirectCore:COREAXI4INTERCONNECT:2.8.103} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:SgCore:PF_CLK_DIV:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_DRI:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_NGMUX:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_PCIE:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_TX_PLL:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_XCVR_REF_CLK:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:DirectCore:CoreAPB3:4.2.100} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:DirectCore:CoreGPIO:3.2.102} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:1.2.108} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:Simulation:CLK_GEN:1.0.1} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:Simulation:RESET_GEN:1.0.1} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:DirectCore:corepwm:4.5.100} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:DirectCore:COREI2C:7.2.101} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} -location {www.microchip-ip.com/repositories/DirectCore}
download_core -vlnv {Actel:SystemBuilder:PF_IOD_GENERIC_RX:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SgCore:PF_IO:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Actel:SystemBuilder:PF_XCVR_ERM:*} -location {www.microchip-ip.com/repositories/SgCore}
download_core -vlnv {Microchip:SolutionCore:mipicsi2rxdecoderPF:4.7.0} -location {www.microchip-ip.com/repositories/DirectCore}

#
# // Generate base design
#

source ./script_support/B_V_F_recursive.tcl

#
# // Import I/O constraints
#

set import_pdc_files "-io_pdc \"./constraints/base_design.pdc\""
set place_route_pdc_files "-file \"${project_dir}/constraint/io/base_design.pdc\""

import_files \
    -convert_EDN_to_HDL 0 \
    -io_pdc "${constraint_path}/base_design.pdc" \
    -fp_pdc "${constraint_path}/NW_PLL.pdc" \
    -fp_pdc "./script_support/components/SYZYGY/$syzygy_option/constraints/fp/SYZYGY.pdc" \
    -sdc "${constraint_path}/fic_clocks.sdc" \
    -io_pdc "./script_support/components/CAPE/$cape_option/constraints/cape.pdc" \
    -io_pdc "./script_support/components/M2/$m2_option/constraints/M2.pdc" \
    -io_pdc "./script_support/components/SYZYGY/$syzygy_option/constraints/SYZYGY.pdc" \
    -io_pdc "./script_support/components/MIPI_CSI/$mipi_csi_option/constraints/MIPI_CSI_INTERFACE.pdc"

#
# // Associate imported constraints with the design flow
#

organize_tool_files \
    -tool {SYNTHESIZE} \
    -file "${project_dir}/constraint/fic_clocks.sdc" \
    -module ${top_level_name}::work \
    -input_type {constraint}

organize_tool_files \
    -tool {PLACEROUTE} \
    -file "${project_dir}/constraint/io/base_design.pdc" \
    -file "${project_dir}/constraint/fp/NW_PLL.pdc" \
    -file "${project_dir}/constraint/fp/SYZYGY.pdc" \
    -file "${project_dir}/constraint/fic_clocks.sdc" \
    -file "${project_dir}/constraint/io/cape.pdc" \
    -file "${project_dir}/constraint/io/M2.pdc" \
    -file "${project_dir}/constraint/io/SYZYGY.pdc" \
    -file "${project_dir}/constraint/io/MIPI_CSI_INTERFACE.pdc" \
    -module ${top_level_name}::work \
    -input_type {constraint}

organize_tool_files \
    -tool {VERIFYTIMING} \
    -file "${project_dir}/constraint/fic_clocks.sdc" \
    -module ${top_level_name}::work \
    -input_type {constraint}

configure_tool \
    -name {CONFIGURE_PROG_OPTIONS} \
    -params {back_level_version:0} \
    -params design_version:$gateware_design_version \
    -params silicon_signature:$gateware_silicon_signature

#
# // Derive timing constraints
#

build_design_hierarchy
derive_constraints_sdc

#
# // Run the design flow and add eNVM clients if required
#
file mkdir $prog_export_path
file mkdir $fpe_export_path
file mkdir $spi_export_path
file mkdir $directc_export_path

if !{[info exists ONLY_CREATE_DESIGN]} {
    run_tool -name {SYNTHESIZE}
    run_tool -name {PLACEROUTE}
    run_tool -name {VERIFYTIMING}
    if {[info exists HSS_IMAGE_PATH]} {
        create_eNVM_config "$local_dir/script_support/components/MSS/ENVM.cfg" "$HSS_IMAGE_PATH"
        run_tool -name {GENERATEPROGRAMMINGDATA}
        configure_envm -cfg_file {script_support/components/MSS/ENVM.cfg}
        source ./script_support/export_spi_prog_file.tcl
        configure_spiflash -cfg_file {./script_support/spiflash.cfg}
        run_tool -name {GENERATEPROGRAMMINGFILE}
        #       run_tool -name {GENERATE_SPI_FLASH_IMAGE}
        source ./script_support/export_flashproexpress.tcl
        source ./script_support/export_directc.tcl
    } else {
        run_tool -name {GENERATEPROGRAMMINGDATA}
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "!!!              No Hart Software Services (HSS) image provided.             !!!"
        puts "!!! Make sure this is what you were planning. If so, you know what you are   !!!"
        puts "!!! doing: Open the Libero project to generate the design's programming      !!!"
        puts "!!! bitstream flavor you need.                                               !!!"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    }
}

save_project
