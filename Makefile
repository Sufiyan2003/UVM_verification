TOP=tb
TEST ?= my_test
RUN_ARGS ?= $(shell python3 extract_all_tests.py)
DO_CMD ?= "run -all; quit"
WAVE ?= 0


ifeq ($(WAVE), 1)
	DO_CMD= "add wave -r /*; run -all; quit"
else
	DO_CMD="run -all; quit"
endif

VLOG=vlog -sv -linedebug
VSIM=vsim -voptargs=+acc=rt

DESIGN_DIR := ./design/async_fifo_2/*.sv
VERIF_DIR=./verif/async_fifo/*.sv
# VERIF_DIR=./verif/async_fifo_TB.sv

# all: compile run

compile:
	$(VLOG) $(DESIGN_DIR) $(VERIF_DIR)

# run:
# 	$(VSIM) -c -sv_seed random $(TOP) +UVM_TESTNAME=$(TEST) $(RUN_ARGS) -do "run -all; quit"

run.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	$(VSIM) -c -sv_seed random $(TOP) +UVM_TESTNAME=$(TEST) $(RUN_ARGS) -do $(DO_CMD)


gui.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	$(VSIM)  $(TOP) +UVM_TESTNAME=$(TEST) $(RUN_ARGS) -do "add wave -r /*; run -all"

debug.%:
	$(eval TEST_NAME=$*)
	$(eval RUN_ARGS=$(shell python3 extract_all_tests.py $(TEST_NAME)))
	$(VSIM) -debugDB $(TOP) +UVM_TESTNAME=$(TEST) $(RUN_ARGS) -do "add wave -r /*;"

baremetal:
	$(VSIM)  $(TOP)  $(RUN_ARGS) -do "add wave -r /*; run -all"
