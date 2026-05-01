#	SV-RV64IM Verification Makefile
#
#	Usage: 
#		make test_alu						run all testbenches
#		make test_alu TEST=alu_random_test	run specific testbench
#		make test_alu SEED=42				reproduce a specific failing testcase
#		make test_alu WAVES = 1				dump waveform in sim/alu_tb/alu_tb.vcd	
#		make cov_alu						open coverage report in IMC
#		make clean							clean simulation artifacts

XRUN ?= xrun 
XRUN_FLAGS = -uvm -access +rwc -coverage

RTL_DIR = rtl 
TB_DIR = tb 
SIM_DIR = sim 

#default uvm test if none selected
TEST ?= alu_random_test

ALU_TB_DIR = $(TB_DIR)/alu_golden
ALU_SIM_DIR = $(SIM_DIR)/alu 

.PHONY: test_alu
test_alu:
	mkdir -p $(ALU_SIM_DIR)
	cd $(ALU_TB_DIR) && $(XRUN) $(XRUN_FLAGS) 			\
		-l $(CURDIR)/$(ALU_SIM_DIR)/xrun.log 			\
		-xmlibdirpath $(CURDIR)/$(ALU_SIM_DIR)			\
		-covworkdir $(CURDIR)/$(ALU_SIM_DIR)/cov_work 	\
		-f dut.f -f tb.f 								\
		+UVM_TESTNAME=$(TEST) 							\
		$(if $(SEED), -svseed $(SEED),) 				\
		$(if $(filter, 1,$(WAVES)), UVM_VERBOSITY=UVM_HIGH,)

.PHONY: cov_alu
cov_alu:
	imc -load $(ALU_SIM_DIR)/cov_work &

ALL_TESTS	=	test_alu

.PHONY: test
test: $(ALL_TESTS)
	@echo ""
	@echo "=============================================="
	@echo "		ALL TESTS PASSED"
	@echo "=============================================="

.PHONY: clean
clean: 
	rm -rf $(SIM_DIR)/*
	rm -rf $(ALU_TB_DIR)/xcelium.d $(ALU_TB_DIR)/xrun.log
	rm -rf $(ALU_TB_DIR)/cov_work $(ALU_TB_DIR)/.simvision
	rm -rf $(ALU_TB_DIR)/INCA_libs $(ALU_TB_DIR)/waves.shm
	@echo "Removed simulation artificats"