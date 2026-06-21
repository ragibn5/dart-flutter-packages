FLUTTER := $(shell command -v fvm 2>/dev/null && echo "fvm flutter" || echo "flutter")

.PHONY: test
test:
	$(FLUTTER) test --no-test-assets

.PHONY: run-tests-with-coverage
run-tests-with-coverage:
	@bash scripts/coverage/run_test_with_coverage.sh

.PHONY: process-coverage-data
process-coverage-data:
	@bash scripts/coverage/process_coverage_data.sh

.PHONY: enforce-coverage-threshold
enforce-coverage-threshold:
	@bash ../scripts/check_coverage.sh coverage/lcov.info 100

.PHONY: view-coverage
view-coverage: run-tests-with-coverage process-coverage-data
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		open coverage/html/index.html; \
	else \
		echo "Coverage report at coverage/html/index.html"; \
	fi