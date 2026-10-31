VERILATOR ?= verilator  

.PHONY: lint lint-strict lint-core lint-bus

lint: lint-core

lint-strict:
	python3 scripts/lint.py --strict --verilator $(VERILATOR)

lint-core:
	python3 scripts/lint.py core --verilator $(VERILATOR)

lint-bus:
	python3 scripts/lint.py bus --verilator $(VERILATOR)