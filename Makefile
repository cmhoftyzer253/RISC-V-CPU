VERILATOR 	?= verilator
VIVADO 		?= vivado 
JOBS 		?= 
BUILD_ARGS 	?= 

.PHONY: lint lint-strict lint-top lint-strict-top lint-core lint-strict-core lint-bus lint-strict-bus \
		project synth impl bit clean-vivado

lint: lint-top

lint-strict: lint-strict-top

lint-top:
	python3 scripts/lint.py top --verilator $(VERILATOR)

lint-strict-top:
	python3 scripts/lint.py top --strict --verilator $(VERILATOR)
	
lint-core:
	python3 scripts/lint.py core --verilator $(VERILATOR)

lint-strict-core:
	python3 scripts/lint.py core --strict --verilator $(VERILATOR)

lint-bus:
	python3 scripts/lint.py bus --verilator $(VERILATOR)

lint-strict-bus:
	python3 scripts/lint.py bus --strict --verilator $(VERILATOR)

XPR 		:= build/vivado/riscv_cpu.xpr 
VIVADO_RUN 	= $(VIVADO) -mode batch -notrace -log build/logs/$@.log -journal build/logs/$@.jou
JOBS_ARG 	:= $(if $(JOBS), -jobs $(JOBS))

$(XPR): scripts/project.tcl rtl/rtl.f $(wildcard ip/*.tcl) $(wildcard ip/*.prj) $(wildcard fpga/*.xdc)
	@mkdir -p build/logs
	$(VIVADO) -mode batch -notrace -log build/logs/project.log -journal build/logs/project.jou -source scripts/project.tcl

project: $(XPR)

synth impl bit: $(XPR)
	@mkdir -p build/logs
	$(VIVADO_RUN) -source scripts/build.tcl -tclargs -to $@ $(JOBS_ARG) $(BUILD_ARGS)

clean-vivado:
	rm -rf build/vivado build/reports build/logs build/riscv_cpu.bit build/riscv_cpu.ltx .Xil