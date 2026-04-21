set proj_dir [file normalize [file dirname [info script]]]
set proj_name "control_logic_project"

# Pick the first supported Nexys A7 part installed in this Vivado.
set target_part ""
foreach p {xc7a50tcsg324-1 xc7a100tcsg324-1} {
    if {[llength [get_parts -quiet $p]] > 0} {
        set target_part $p
        break
    }
}

if {$target_part eq ""} {
    error "No supported part found. Install Artix-7 device support for xc7a50tcsg324-1 or xc7a100tcsg324-1."
}

create_project $proj_name $proj_dir -part $target_part -force

# Keep explicit dependency order for VHDL analysis.
add_files "$proj_dir/src/clk_en.vhd"
add_files "$proj_dir/src/debounce.vhd"
add_files "$proj_dir/src/control_logic.vhd"
add_files -fileset sim_1 "$proj_dir/sim/control_logic_tb.vhd"

set_property top control_logic [current_fileset]
set_property top control_logic_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Created project '$proj_name' with part '$target_part'."
puts "Run behavioral simulation: Flow -> Run Simulation -> Run Behavioral Simulation"
