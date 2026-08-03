# ModelSim / QuestaSim run script - FSM-controlled multiplier
# Usage:  vsim -do run.do
#
# Replaces the original DATAPATHCONTROLPATH2.mpf, which hardcoded absolute
# paths under C:/modeltech64_10.5/examples/ and was not portable.

if {[file exists work]} { vdel -all }
vlib work

vlog -work work rtl/ADD.v
vlog -work work rtl/CNTR.v
vlog -work work rtl/EQZ.v
vlog -work work rtl/PIPO1.v
vlog -work work rtl/PIPO2.v
vlog -work work rtl/datapath.v
vlog -work work rtl/controller.v
vlog -work work rtl/multiplier_top.v
vlog -work work tb/multiplier_tb.v

vsim -voptargs=+acc work.multiplier_tb

add wave -divider {control}
add wave -radix binary  /multiplier_tb/dut/u_ctrl/state
add wave -radix binary  /multiplier_tb/dut/start
add wave -radix binary  /multiplier_tb/dut/done
add wave -divider {datapath}
add wave -radix unsigned /multiplier_tb/dut/Bout
add wave -radix unsigned /multiplier_tb/dut/X
add wave -radix unsigned /multiplier_tb/dut/Y
add wave -radix unsigned /multiplier_tb/dut/Z

run -all
wave zoom full