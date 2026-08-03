# ModelSim / QuestaSim run script - RAM
# Usage:  vsim -do run.do
#
# Replaces the original memoryproject.mpf (absolute paths, not portable).
# Runs the true dual-port testbench; switch the vsim line for the original
# single-port design.

if {[file exists work]} { vdel -all }
vlib work

vlog -work work rtl/memorydesign.v
vlog -work work rtl/true_dual_port_ram.v
vlog -work work tb/memorytestbench.v
vlog -work work tb/true_dual_port_ram_tb.v

# original single-port design:
#   vsim -voptargs=+acc work.dualport_RAM_tb
vsim -voptargs=+acc work.true_dual_port_ram_tb

add wave -divider {port A}
add wave -radix binary   /true_dual_port_ram_tb/en_a
add wave -radix binary   /true_dual_port_ram_tb/we_a
add wave -radix unsigned /true_dual_port_ram_tb/addr_a
add wave -radix binary   /true_dual_port_ram_tb/din_a
add wave -radix binary   /true_dual_port_ram_tb/dout_a
add wave -divider {port B}
add wave -radix binary   /true_dual_port_ram_tb/en_b
add wave -radix binary   /true_dual_port_ram_tb/we_b
add wave -radix unsigned /true_dual_port_ram_tb/addr_b
add wave -radix binary   /true_dual_port_ram_tb/din_b
add wave -radix binary   /true_dual_port_ram_tb/dout_b

run -all
wave zoom full