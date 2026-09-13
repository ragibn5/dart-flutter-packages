FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
DART := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm dart" || echo "dart")
DEV_TOOLS := $(DART) run dev_tools
COVERAGE_EXCLUSIONS := \
	lib/di/config/** \
	lib/di/modules/** \
	lib/di/di.dart \
	lib/generated/** \
	lib/**/*.g.dart \
	lib/**/*.gen.dart \
	lib/**/firebase_options_*.dart \
	lib/main_*.dart \
	lib/**/models/** \
	lib/**/constants \
	lib/**/presentation/widgets/** \
	lib/**/bloc/*_event.dart \
	lib/**/bloc/*_state.dart \
	lib/features/app/infrastructure/config/**


.PHONY: test
test:
	$(FLUTTER) test --no-test-assets

.PHONY: build-runner
build-runner:
	$(DART) run build_runner build --delete-conflicting-outputs

.PHONY: generate-strings
generate-strings:
	$(DART) run intl_utils:generate

.PHONY: run-tests-with-coverage
run-tests-with-coverage:
	$(FLUTTER) test --no-test-assets --coverage --coverage-path coverage/lcov.info
	@echo "Coverage data generated at coverage/lcov.info."

.PHONY: process-coverage-data
process-coverage-data:
	@lcov --remove coverage/lcov.info --output-file coverage/lcov.info $(COVERAGE_EXCLUSIONS) --ignore-errors unused,empty >/dev/null 2>&1 || true
	@genhtml coverage/lcov.info -o coverage/html >/dev/null 2>&1 || true
	@echo "HTML report available at coverage/html/index.html."
	@echo "Coverage report generated at coverage/lcov.info."

.PHONY: view-coverage
view-coverage: run-tests-with-coverage process-coverage-data
	@if [[ "$$OSTYPE" == "darwin"* ]]; then \
		open coverage/html/index.html; \
	else \
		echo "Coverage report at coverage/html/index.html."; \
	fi
