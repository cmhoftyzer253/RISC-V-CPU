# Vivado Verification Makefile

# Usage:
# make test MODULE=alu					run test for alu 
# make test_alu 						same
# make test_alu TEST=alu_random_test	run specific UVM test class
# make test_alu SEED=42					reproduce a run with a seed
# make waves_alu 						open alu wdb file in xsim
# make clean

XVLOG 	?= xvlog 
XELAB 	?= xelab 
XSIM 	?= xsim 
XSC 	?= xsc  

MODULE 	?= alu

RTL_DIR 	:= rtl 
TB_DIR 		:= tb/$(MODULE)
SIM_DIR 	:= sim/$(MODULE)
TCL_DIR 	:= scripts

TOP_MOD		:= $(MODULE)_tb_top
SNAPSHOT	:= $(MODULE)_tb_top_snap
TEST		?= $(MODULE)_random_test

DPI_SRC 	:= $(TB_DIR)/$(MODULE)_golden.c 
DPI_LIB		:= $(TB_DIR)/xsim.dir/xsc/dpi.so 
ifneq ($(wildcard $(DPI_SRC)),)
	DPI_OPT := -sv_lib dpi
	DPI_DEP := $(DPI_LIB)
endif

# Tool flags
XELAB_OPTS := 	-L uvm $(DPI_OPT) -debug typical

XSIM_OPTS 	:= 	-testplusarg "{ UVM_TESTNAME=$(TEST) }" \
                -tclbatch $(CURDIR)/$(TCL_DIR)/xsim_run.tcl \
                -wdb $(CURDIR)/$(SIM_DIR)/waves.wdb

ifdef SEED
	XSIM_OPTS += -sv_seed $(SEED)
endif

.PHONY: test waves clean

test: $(DPI_DEP)
	@mkdir -p $(SIM_DIR)
	cd $(TB_DIR) && $(XVLOG) -sv -L uvm -f dut.f -f tb.f \
		-i $(CURDIR)/$(TB_DIR) \
		-log $(CURDIR)/$(SIM_DIR)/xvlog.log
	cd $(TB_DIR) && $(XELAB) $(XELAB_OPTS) $(TOP_MOD) -s $(SNAPSHOT) \
		-log $(CURDIR)/$(SIM_DIR)/xelab.log
	cd $(TB_DIR) && $(XSIM) $(XSIM_OPTS) \
		-log $(CURDIR)/$(SIM_DIR)/xsim.log \
		$(SNAPSHOT)

$(DPI_LIB): $(DPI_SRC)
	cd $(TB_DIR) && $(XSC) $(notdir $(DPI_SRC))

waves:
	$(XSIM) -gui $(SIM_DIR)/waves.wdb &

clean: 
	rm -rf sim/
	rm -rf tb/*/xsim.dir
	rm -rf tb/*/*.jou tb/*/*.log tb/*/*.pb
	@echo "Removed simulation artifacts"

test_%:
	@$(MAKE) test MODULE=$*

waves_%:
	@$(MAKE) waves MODULE=$*