VERILATOR ?= verilator

.PHONY: lint lint-strict lint-core lint-bus

lint: lint-top

lint-strict:
	lint-strict-top

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