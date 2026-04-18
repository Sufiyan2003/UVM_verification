# Makefile for QuestaSim UVM testbench - Windows Compatible

# Tool configurations
UVM_PATH = C:/altera/25.1std/questa_fse/verilog_src/uvm-1.2/src
VLOG = vlog -sv -linedebug
# VSIM = vsim -novopt
VSIM = vsim +acc

# Project structure
ROOT = $(CURDIR)
TOP = dm_cache_tb
TEST ?= cache_base_test
WAVE ?= 0

# DO command configuration
ifeq ($(WAVE), 1)
    DO_CMD = "add wave -r /*; run -all; quit"
else
    DO_CMD = "run -all; quit"
endif



.PHONY: all clean compile run gui wave help debug generate_order

all: clean compile run

# Create work library
work:
	vlib work
	vmap work work

# need to add all these into yamls
compile:
	@echo "Compiling UVM_PATH and cache_tx!!"
	$(VLOG) \
	+incdir+./verif/direct_mapped_cache/uvm/interfaces \
	+incdir+./verif/direct_mapped_cache/uvm/sequence_items \
	+incdir+./verif/direct_mapped_cache/uvm/sequence \
	+incdir+./verif/direct_mapped_cache/uvm/drivers \
	+incdir+./verif/direct_mapped_cache/uvm/monitor \
	+incdir+./verif/direct_mapped_cache/uvm/agents \
	+incdir+./verif/direct_mapped_cache/uvm/scoreboard \
	+incdir+./verif/direct_mapped_cache/uvm/env \
	+incdir+./verif/direct_mapped_cache/uvm/test \
	+incdir+./verif/direct_mapped_cache/uvm/config \
	+incdir+./verif/direct_mapped_cache/uvm/packages \
	+incdir+./verif/direct_mapped_cache/uvm/tb \
	./design/cache/interfaces.sv \
	./verif/direct_mapped_cache/uvm/packages/cache_struct_pkg.sv \
	./verif/direct_mapped_cache/uvm/packages/cache_pkg.sv \
	./design/cache/cache_top.sv \
	./verif/direct_mapped_cache/dm_cache_tb.sv

run.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	$(VSIM) -c -sv_seed random $(TOP) $(RUN_ARGS) -do $(DO_CMD)

gui.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	$(VSIM) -sv_seed random $(TOP)  $(RUN_ARGS) -do "add wave -r /*; run -all"

debug.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	$(VSIM) -sv_seed random $(TOP)  +UVM_TESTNAME=$(TEST) $(RUN_ARGS) -do "log -r /*; add wave -r /*;"

baremetal:
	$(VSIM)  $(TOP)  $(RUN_ARGS) -do "add wave -r /*; run -all"


runOpt.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	vopt +acc $(TOP) -o $(TOP)_opt $(RUN_ARGS)
	vsim -sv_seed random $(TOP)_opt $(RUN_ARGS) -do "log -r /*; add wave -r /*; run -all"