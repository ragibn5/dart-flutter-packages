FLUTTER ?= fvm flutter

.PHONY: test
test:
	$(FLUTTER) test --no-test-assets

.PHONY: coverage
coverage:
	@bash scripts/coverage.sh

.PHONY: opencvrg
opencvrg:
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		open coverage/html/index.html; \
	else \
		echo "Could not open coverage report."; \
		echo "May be you want to add support for opening the report for your current OS."; \
	fi
