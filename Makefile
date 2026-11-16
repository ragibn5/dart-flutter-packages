# Uses fvm when it's installed, otherwise flutter and dart from PATH.

FVM := $(shell command -v fvm >/dev/null 2>&1 && echo fvm)
FLUTTER := $(if $(FVM),fvm flutter,flutter)
DART := $(if $(FVM),fvm dart,dart)

.PHONY: check setup

# Analyzes every package and runs its tests with the coverage check, which
# needs lcov.
check: setup
	$(DART) run melos run analyze --no-select
	$(DART) run melos run coverage --no-select

# Resolves the workspace and installs the coverage tool.
setup:
	$(FLUTTER) pub get
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage
