# Local checks for the whole repository.
#
#   make test   Run every package's tests with the coverage check CI uses:
#               the workspace packages, then app_template and its packages.
#
# Uses fvm when it's installed (the root's and app_template's .fvmrc pick the
# Flutter version), plain flutter/dart otherwise. Needs lcov.

FVM := $(shell command -v fvm >/dev/null 2>&1 && echo fvm)
FLUTTER := $(if $(FVM),fvm flutter,flutter)
DART := $(if $(FVM),fvm dart,dart)
ROOT := $(CURDIR)

.PHONY: test workspace-test app-template-test setup

test: workspace-test app-template-test

# Resolves the workspace and activates the coverage package that
# tool/coverage.dart needs for pure-Dart packages.
setup:
	$(FLUTTER) pub get
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage

workspace-test: setup
	$(DART) run melos run coverage --no-select

app-template-test: setup
	@for dir in app_template app_template/packages/*; do \
		[ -f "$$dir/pubspec.yaml" ] || continue; \
		echo "== $$dir"; \
		(cd "$$dir" && $(FLUTTER) pub get >/dev/null && $(DART) run "$(ROOT)/tool/coverage.dart") || exit 1; \
	done
