# Repository checks, run the same way locally and in CI.
#
#   make check                   Analyze every package and run its tests with
#                                the coverage check.
#   make setup                   Resolve the workspace and install the
#                                coverage tool.
#   make app-template-analyze    Analyze the standalone project and its
#                                packages.
#   make app-template-test       Run the standalone project's and its
#                                packages' tests with the coverage check.
#
# The app-template-* targets take an optional BASE=<git ref> to check only
# what changed since it.
#
# Used by CI:
#   make workspace-changed BASE=<ref>      Print `true` if a workspace package
#   make app-template-changed BASE=<ref>   (or the standalone project) changed
#                                          since BASE, else `false`.
#   make flutter-version                   Print the Flutter version pinned for
#   make app-template-flutter-version      the workspace (or the standalone
#                                          project).
#
# Uses fvm when it's installed, otherwise flutter and dart from PATH. The
# coverage check needs lcov.

FVM := $(shell command -v fvm >/dev/null 2>&1 && echo fvm)
FLUTTER := $(if $(FVM),fvm flutter,flutter)
DART := $(if $(FVM),fvm dart,dart)
BASE ?=

# The standalone project, which resolves on its own, outside the workspace.
TEMPLATE_DIR := app_template

# The Flutter version a .fvmrc pins.
fvmrc_flutter = $(shell sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' $(1))

# Runs $(1) in the standalone project and in each of its packages, resolving
# each one first. With BASE, only in those changed since it; a change inside
# one of its packages doesn't count as a change to the project itself.
define each_template_package
for dir in $(TEMPLATE_DIR) $(TEMPLATE_DIR)/packages/*; do \
		[ -f "$$dir/pubspec.yaml" ] || continue; \
		if [ -n "$(BASE)" ]; then \
			if [ "$$dir" = $(TEMPLATE_DIR) ]; then \
				changed=$$(git diff --name-only "$(BASE)" HEAD -- $(TEMPLATE_DIR) ':!$(TEMPLATE_DIR)/packages'); \
			else \
				changed=$$(git diff --name-only "$(BASE)" HEAD -- "$$dir"); \
			fi; \
			[ -n "$$changed" ] || continue; \
		fi; \
		echo "== $$dir"; \
		(cd "$$dir" && $(FLUTTER) pub get >/dev/null && $(1)) || exit 1; \
	done
endef

TEMPLATE_ANALYZE = $(call each_template_package,$(DART) analyze)
TEMPLATE_TEST = $(call each_template_package,$(DART) run "$(CURDIR)/tool/coverage.dart")

.PHONY: check setup app-template-analyze app-template-test workspace-changed \
	app-template-changed flutter-version app-template-flutter-version require-base

check: setup
	$(DART) run melos run analyze --no-select
	$(DART) run melos run coverage --no-select
	@$(TEMPLATE_ANALYZE)
	@$(TEMPLATE_TEST)

setup:
	$(FLUTTER) pub get
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage

app-template-analyze:
	@$(TEMPLATE_ANALYZE)

# The coverage check's own dependencies resolve with the workspace.
app-template-test: setup
	@$(TEMPLATE_TEST)

# Asks a globally installed workspace tool, at the version the root
# pubspec.yaml allows, so it needs neither Flutter nor a resolved workspace.
workspace-changed: require-base
	@$(DART) pub global list | grep -q '^melos ' || \
		$(DART) pub global activate melos '$(shell sed -n 's/^  melos: *//p' pubspec.yaml)' >&2
	@packages=$$($(DART) pub global run melos list --diff="$(BASE)" --json) || exit 1; \
	[ "$$packages" = "[]" ] && echo false || echo true

app-template-changed: require-base
	@git diff --name-only "$(BASE)" HEAD -- $(TEMPLATE_DIR) | grep -q . && echo true || echo false

flutter-version:
	@echo $(call fvmrc_flutter,.fvmrc)

app-template-flutter-version:
	@echo $(call fvmrc_flutter,$(TEMPLATE_DIR)/.fvmrc)

require-base:
	@[ -n "$(BASE)" ] || { echo 'BASE=<git ref> is required' >&2; exit 1; }
