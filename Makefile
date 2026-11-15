# What Melos can't do: app_template (not a workspace member), CI's helpers,
# and one command for a full local run. Workspace work runs through Melos
# directly — see the README.
#
#   make check                   Everything: the workspace through Melos, then
#                                app_template, each analyzed and then tested
#                                with the coverage check.
#   make setup                   Resolve the workspace and activate the
#                                coverage package tool/coverage.dart needs.
#   make app-template-analyze    Analyze app_template and its packages.
#   make app-template-test       app_template's and its packages' tests with
#                                the coverage check.
#
# The app_template targets take an optional BASE=<git ref>: then only the
# packages changed since BASE are checked, as CI does for a pull request.
#
# CI also uses:
#   make workspace-changed BASE=<ref>      `true` when a workspace package
#   make app-template-changed BASE=<ref>   (or app_template) changed, else `false`.
#   make flutter-version                   The Flutter version the root's (or
#   make app-template-flutter-version      app_template's) .fvmrc pins.
#
# Uses fvm when it's installed (the root's and app_template's .fvmrc pick the
# Flutter version), plain flutter/dart otherwise. The coverage check needs
# lcov.

FVM := $(shell command -v fvm >/dev/null 2>&1 && echo fvm)
FLUTTER := $(if $(FVM),fvm flutter,flutter)
DART := $(if $(FVM),fvm dart,dart)
ROOT := $(CURDIR)
BASE ?=

# The Flutter version pinned in a .fvmrc.
fvmrc_flutter = $(shell sed -n 's/.*"flutter": *"\([^"]*\)".*/\1/p' $(1))

# Runs $(1) in app_template and in each of its packages, which are outside
# the workspace, so each one is resolved on its own first. With BASE, only
# the ones changed since it; a change inside one of app_template's packages
# doesn't count as a change to app_template itself.
define each_app_template_package
for dir in app_template app_template/packages/*; do \
		[ -f "$$dir/pubspec.yaml" ] || continue; \
		if [ -n "$(BASE)" ]; then \
			if [ "$$dir" = app_template ]; then \
				changed=$$(git diff --name-only "$(BASE)" HEAD -- app_template ':!app_template/packages'); \
			else \
				changed=$$(git diff --name-only "$(BASE)" HEAD -- "$$dir"); \
			fi; \
			[ -n "$$changed" ] || continue; \
		fi; \
		echo "== $$dir"; \
		(cd "$$dir" && $(FLUTTER) pub get >/dev/null && $(1)) || exit 1; \
	done
endef

# app_template's checks, shared by its own targets and check.
APP_TEMPLATE_ANALYZE = $(call each_app_template_package,$(DART) analyze)
APP_TEMPLATE_TEST = $(call each_app_template_package,$(DART) run "$(ROOT)/tool/coverage.dart")

.PHONY: check setup app-template-analyze app-template-test workspace-changed \
	app-template-changed flutter-version app-template-flutter-version require-base

check: setup
	$(DART) run melos run analyze --no-select
	$(DART) run melos run coverage --no-select
	@$(APP_TEMPLATE_ANALYZE)
	@$(APP_TEMPLATE_TEST)

# Resolves the workspace, Melos included, and activates the coverage package
# tool/coverage.dart needs for pure-Dart packages.
setup:
	$(FLUTTER) pub get
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage

app-template-analyze:
	@$(APP_TEMPLATE_ANALYZE)

# tool/coverage.dart's own dependencies come from the workspace, hence setup.
app-template-test: setup
	@$(APP_TEMPLATE_TEST)

# For CI's gates: print `true` when a workspace package, or app_template, changed since BASE, else `false`.
# The workspace gate asks a globally activated Melos, at the root pubspec.yaml's melos constraint, so it
# needs neither the Flutter SDK nor a resolved workspace.
workspace-changed: require-base
	@$(DART) pub global list | grep -q '^melos ' || \
		$(DART) pub global activate melos '$(shell sed -n 's/^  melos: *//p' pubspec.yaml)' >&2
	@packages=$$($(DART) pub global run melos list --diff="$(BASE)" --json) || exit 1; \
	[ "$$packages" = "[]" ] && echo false || echo true

app-template-changed: require-base
	@git diff --name-only "$(BASE)" HEAD -- app_template | grep -q . && echo true || echo false

# For CI's Flutter install: print the version the root's, or app_template's, .fvmrc pins.
flutter-version:
	@echo $(call fvmrc_flutter,.fvmrc)

app-template-flutter-version:
	@echo $(call fvmrc_flutter,app_template/.fvmrc)

require-base:
	@[ -n "$(BASE)" ] || { echo 'BASE=<git ref> is required' >&2; exit 1; }
