VERILATOR ?= verilator  

.PHONY: lint lint-strict

lint:
	python3 scripts/lint.py --verilator $(VERILATOR)

lint-strict:
	python3 scripts/lint.py --strict --verilator $(VERILATOR)