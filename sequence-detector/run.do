# ModelSim / QuestaSim run script - 1100111 sequence detector
# Usage:  vsim -do run.do
#
# Replaces the original FSM1100111.mpf (absolute paths, not portable).

if {[file exists work]} { vdel -all }
vlib work

vlog -work work rtl/mealy1100111.v
vlog -work work rtl/moorey1100111.v
vlog -work work tb/sequence_detector_selfcheck_tb.v

vsim -voptargs=+acc work.sequence_detector_selfcheck_tb

add wave -radix binary /sequence_detector_selfcheck_tb/clk
add wave -radix binary /sequence_detector_selfcheck_tb/rst
add wave -radix binary /sequence_detector_selfcheck_tb/in
add wave -radix binary /sequence_detector_selfcheck_tb/out
add wave -radix unsigned /sequence_detector_selfcheck_tb/detections
add wave -divider {DUT state}
add wave -radix unsigned /sequence_detector_selfcheck_tb/dut/cst
add wave -radix unsigned /sequence_detector_selfcheck_tb/dut/nst

run -all
wave zoom full