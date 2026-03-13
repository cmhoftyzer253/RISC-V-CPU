#	SV-RV64IM Verification Makefile
#
#	Usage: 
#		make test						run all testbenches
#		make test_alu					run specific testbench
#		make test_alu SEED = 42			reproduce a specific failing testcase
#		make test_alu WAVES = 1			dump waveform in sum/alu_tb/alu_tb.vcd	
#		make clean						clean simulation artifacts


VERILATOR	?=	verilator 

VER_FLAGS	=	--binary --timing --assert -sv -Wall -Wno-UNUSED -Wno-fatal

RTL_DIR		=	rtl
TB_DIR		=	tb
SIM_DIR		=	sim

ALU_TOP		=	alu_tb
ALU_SIM_DIR	=	$(SIM_DIR)/$(ALU_TOP)
ALU_SRCS    = 	$(RTL_DIR)/constants/cpu_consts.sv	\
				$(RTL_DIR)/execute/alu.sv 			\
              	$(TB_DIR)/alu_tb.sv

$(ALU_SIM_DIR)/$(ALU_TOP): $(ALU_SRCS)
	mkdir -p $(ALU_SIM_DIR)
	$(VERILATOR) $(VER_FLAGS)	\
		-I$(RTL_DIR)			\
		--Mdir $(ALU_SIM_DIR)	\
		--top-module $(ALU_TOP)	\
		-o $(ALU_TOP)			\
		$(ALU_SRCS)	

.PHONY: test_alu
test_alu: $(ALU_SIM_DIR)/$(ALU_TOP)
	@echo ""
	@echo "--- Running $(ALU_TOP) ---"
	$(ALU_SIM_DIR)/$(ALU_TOP)				\
		$(if $(SEED), +SEED=$(SEED),)		\
		$(if $(filter 1,$(WAVES)), +WAVES,)	\
	@echo "--- PASS: $(ALU_TOP) ---"

ALL_TESTS	=	test_alu

.PHONY: test
test: $(ALL_TESTS)
	@echo ""
	@echo "=============================================="
	@echo "		ALL TESTS PASSED"
	@echo "=============================================="

.PHONY: clean
clean: 
	rm -rf $(SIM_DIR)
	@echo "Removed $(SIM_DIR)"