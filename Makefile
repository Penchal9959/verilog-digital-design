# Icarus Verilog build/run for all designs.
#   make            - build and run everything
#   make multiplier - FSM-controlled multiplier
#   make seqdet     - 1100111 sequence detector
#   make ram        - single-port and true dual-port RAM
#   make clean      - remove build artifacts

IVERILOG := iverilog
VVP      := vvp
IVFLAGS  := -g2005 -Wall
BUILD    := build

MUL_DIR := multiplier-datapath-controller
SEQ_DIR := sequence-detector
RAM_DIR := ram

.PHONY: all multiplier seqdet ram clean

all: multiplier seqdet ram

$(BUILD):
	@mkdir -p $(BUILD)

multiplier: | $(BUILD)
	@echo "=== multiplier ==="
	@$(IVERILOG) $(IVFLAGS) -o $(BUILD)/multiplier.vvp $(MUL_DIR)/rtl/*.v $(MUL_DIR)/tb/multiplier_tb.v
	@cd $(BUILD) && $(VVP) multiplier.vvp

seqdet: | $(BUILD)
	@echo "=== sequence-detector ==="
	@$(IVERILOG) $(IVFLAGS) -o $(BUILD)/seqdet.vvp $(SEQ_DIR)/rtl/mealy1100111.v $(SEQ_DIR)/tb/sequence_detector_selfcheck_tb.v
	@cd $(BUILD) && $(VVP) seqdet.vvp

ram: | $(BUILD)
	@echo "=== ram (single-port, original) ==="
	@$(IVERILOG) $(IVFLAGS) -o $(BUILD)/ram.vvp $(RAM_DIR)/rtl/memorydesign.v $(RAM_DIR)/tb/memorytestbench.v
	@cd $(BUILD) && $(VVP) ram.vvp
	@echo "=== ram (true dual-port) ==="
	@$(IVERILOG) $(IVFLAGS) -o $(BUILD)/tdpram.vvp $(RAM_DIR)/rtl/true_dual_port_ram.v $(RAM_DIR)/tb/true_dual_port_ram_tb.v
	@cd $(BUILD) && $(VVP) tdpram.vvp

clean:
	@rm -rf $(BUILD)
