FLUTTER := $(shell command -v fvm 2>/dev/null && echo "fvm flutter" || echo "flutter")

.PHONY: test
test:
	$(FLUTTER) test --no-test-assets

.PHONY: coverage
coverage:
	@bash scripts/coverage.sh

.PHONY: open_coverage
open_coverage:
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		open coverage/html/index.html; \
	else \
		echo "Could not open coverage report."; \
		echo "May be you want to add support for opening the report for your current OS."; \
	fi

.PHONY: run_and_open_coverage
run_and_open_coverage: coverage open_coverage