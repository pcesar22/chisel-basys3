package provide basys3lib 1.0

namespace eval ::basys3lib {
    # Export commands
    # namespace export basys3_connect basys3_disconnect basys3_program
    namespace export global_print set_proj_root set_output_dir
}

proc ::basys3lib::set_bitstream_dir { dir } {
    global bitStreamDir
    set bitStreamDir $dir
}

proc ::basys3lib::set_output_dir { dir } {
    global outputDir
    set outputDir $dir
}

proc ::basys3lib::set_proj_name { dir } {
    global projName
    set projName $dir
}

proc ::basys3lib::set_proj_root { dir } {
    global projRoot
    set projRoot $dir
}

proc ::basys3lib::global_print {} {
    global projName
    global projRoot
    global outputDir
    global bitStreamDir
    puts "project name: $projName"
    puts "project root: $projRoot"
    puts "project output dir: $outputDir"
    puts "bitstream dir: $bitStreamDir"
}

proc ::basys3lib::connect {} {
    set servers [get_hw_servers]
    if { [llength $servers] > 0 } {
        puts "Hardware server already running: $servers"
    } else {
        connect_hw_server -url localhost:3121
    }
}

proc ::basys3lib::disconnect {} {
    disconnect_hw_server
}

proc ::basys3lib::program { } {
    current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
    open_hw_target
    current_hw_device [lindex [get_hw_devices] 0]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
    set_property PROGRAM.FILE $bitStreamDir [lindex [get_hw_devices] 0]
    program_hw_devices [lindex [get_hw_devices] 0]
    refresh_hw_device [lindex [get_hw_devices] 0]
}

#########################
## VIVADO COMPILATION   #
#########################

proc ::basys3lib::compile {} {

    global projName
    global projRoot
    global outputDir
    global bitStreamDir

    set summaryDir $outputDir/summary
    set sourceDir $projRoot

    puts "Assuming all source code is in $sourceDir"
    puts "Assuming there is an xdc file at '$sourceDir/$projName.xdc'"
    puts "All project output will go to $outputDir"

    puts "---------------------------------------"
    puts "Creating output dir '$outputDir'"
    puts "---------------------------------------"
    file mkdir $outputDir
    puts "---------------------------------------"
    puts "Creating summary dir '$summaryDir'"
    puts "---------------------------------------"
    file mkdir $summaryDir

    puts "---------------------------------------"
    puts " 1) Reading verilog"
    puts "---------------------------------------"
    read_verilog [ glob $sourceDir/*.v ]
    read_xdc $sourceDir/$projName.xdc

    puts "---------------------------------------"
    puts " 2) Synthesis"
    puts "---------------------------------------"
    synth_design -top top -part xc7a35tcpg236-1
    write_checkpoint -force $outputDir/post_synth

    puts "---------------------------------------"
    puts " 3) Placement"
    puts "---------------------------------------"
    opt_design
    place_design
    phys_opt_design
    write_checkpoint -force $outputDir/post_place

    puts "---------------------------------------"
    puts " 3) Route"
    puts "---------------------------------------"
    route_design
    write_checkpoint -force $outputDir/post_route
    report_utilization -file $summaryDir/post_route_util.rpt
    report_drc -file $summaryDir/post_imp_drc.rpt
    write_verilog -force $outputDir/blink_netlist.v
    write_xdc -no_fixed_only -force $outputDir/$projName_impl.xdc

    puts "---------------------------------------"
    puts " 4) Bitstream"
    puts "---------------------------------------"

    write_bitstream -force $bitStreamDir/$projName.bit
    puts "Bitstream generated at '$bitStreamDir/$projName.bit'"
    puts "Compilation finished."
}

proc ::basys3lib::full { bitstream } {
    compile
    open_hw_manager
    basys3_connect
    basys3_program
}
