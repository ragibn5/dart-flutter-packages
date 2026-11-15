# Repository checks, run the same way locally and in CI.
#
#   make check    Analyze every package and run its tests with the coverage
#                 check.
#   make setup    Resolve the workspace and install the coverage tool.
#
# Used by CI:
#   make workspace-changed BASE=<ref>    Print `true` if a workspace package
#                                        changed since BASE, else `false`.
#   make flutter-version                 Print the Flutter version the
#                                        workspace pins.
#
# Uses fvm when it's installed, otherwise flutter and dart from PATH. The
# coverage check needs lcov.

FVM := $(shell command -v fvm >/dev/null 2>&1 && echo fvm)
FLUTTER := $(if $(FVM),fvm flutter,flutter)
DART := $(if $(FVM),fvm dart,dart)
BASE ?=

.PHONY: check setup workspace-changed flutter-version

check: setup
	$(DART) run melos run analyze --no-select
	$(DART) run melos run coverage --no-select

setup:
	$(FLUTTER) pub get
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage

# Asks a globally installed workspace tool, at the version the root
# pubspec.yaml allows, so it needs neither Flutter nor a resolved workspace.
workspace-changed:
	@[ -n "$(BASE)" ] || { echo 'BASE=<git ref> is required' >&2; exit 1; }
	@$(DART) pub global list | grep -q '^melos ' || \
		$(DART) pub global activate melos '$(shell sed -n 's/^  melos: *//p' pubspec.yaml)' >&2
	@packages=$$($(DART) pub global run melos list --diff="$(BASE)" --json) || exit 1; \
	[ "$$packages" = "[]" ] && echo false || echo true

flutter-version:
	@sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' .fvmrc
