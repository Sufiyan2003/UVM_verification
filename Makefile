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
OUT_DIR = output
PROJ_NAME ?= default
PROJ_DIR  = $(OUT_DIR)/$(PROJ_NAME)

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

gen:
	@echo "Compiling all tests in test_db.yaml"
	@python3 extract_all_tests.py


# need to add all these into yamls
compile.%:
	@echo "Compiling UVM_PATH and cache_tx!!"
	$(eval INCL := $(shell python3 compile_project.py $*))
	$(VLOG) $(INCL)


run.%:
	$(eval TEST_NAME := $*)
	$(eval RUN_ARGS := $(shell python3 get_test_args.py $(TEST_NAME)))
	$(eval RUN_DIR := $(shell python3 get_run_dir.py "$(PROJ_DIR)" "$(TEST_NAME)"))

	@if not exist "$(RUN_DIR)" mkdir "$(RUN_DIR)"

	@echo ============ Running $(TEST_NAME) ============
	@echo Saving logs in $(RUN_DIR)

	$(VSIM) -c -sv_seed random $(TOP) \
	$(RUN_ARGS) \
	-do $(DO_CMD) \
	-l $(RUN_DIR)/sim.log

gui.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 get_test_args.py $(TEST_NAME)))
	$(VSIM) -sv_seed random $(TOP)  $(RUN_ARGS) -do "add wave -r /*; run -all"

debug.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 get_test_args.py $(TEST_NAME)))
	$(VSIM) -sv_seed random $(TOP)  +UVM_TESTNAME=$(TEST) $(RUN_ARGS) -do "log -r /*; add wave -r /*;"

baremetal:
	$(VSIM)  $(TOP)  $(RUN_ARGS) -do "add wave -r /*; run -all"


runOpt.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 get_test_args.py $(TEST_NAME)))
	vopt +acc $(TOP) -o $(TOP)_opt $(RUN_ARGS)
	vsim -sv_seed random $(TOP)_opt $(RUN_ARGS) -do "log -r /*; add wave -r /*; run -all"

clean:
	@echo "Cleaning output directory..."
	@if exist output rmdir /s /q output