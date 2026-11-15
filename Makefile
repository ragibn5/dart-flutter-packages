# Checks for the whole repository, run the same way locally and in CI.
#
#   make check                   Everything: analyze, then the tests with the
#                                coverage check, for the workspace and then
#                                app_template.
#   make workspace-analyze       Analyze the workspace packages.
#   make workspace-test          The workspace packages' tests with the
#                                coverage check.
#   make app-template-analyze    Analyze app_template and its packages.
#   make app-template-test       app_template's and its packages' tests with
#                                the coverage check.
#   make release-check           Dry-run publishing every package whose
#                                version isn't on pub.dev yet.
#
# The analyze and test targets take an optional BASE=<git ref>: then only the
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

# The melos constraint the root pubspec.yaml's dev_dependencies give, for the
# globally activated Melos the workspace gate uses.
MELOS_CONSTRAINT := $(shell sed -n 's/^  melos: *//p' pubspec.yaml)

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

# Melos's options for every workspace package or, with BASE, the ones
# changed since it.
MELOS_SELECT := --no-select $(if $(BASE),--diff=$(BASE))

.PHONY: check workspace-analyze workspace-test app-template-analyze app-template-test \
	release-check setup pub-get coverage-tool melos-tool workspace-changed \
	app-template-changed flutter-version app-template-flutter-version require-base

check: workspace-analyze workspace-test app-template-analyze app-template-test

# Resolves the workspace, Melos included.
pub-get:
	$(FLUTTER) pub get

# The coverage package, which tool/coverage.dart needs for pure-Dart packages.
coverage-tool:
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage

setup: pub-get coverage-tool

# Melos activated globally, so the workspace gate can ask it which packages
# changed without resolving the workspace, which needs the Flutter SDK.
melos-tool:
	@$(DART) pub global list | grep -q '^melos ' || $(DART) pub global activate melos '$(MELOS_CONSTRAINT)' >&2

workspace-analyze: pub-get
	$(DART) run melos run analyze $(MELOS_SELECT)

workspace-test: setup
	$(DART) run melos run coverage $(MELOS_SELECT)

app-template-analyze: pub-get
	@$(call each_app_template_package,$(DART) analyze)

app-template-test: setup
	@$(call each_app_template_package,$(DART) run "$(ROOT)/tool/coverage.dart")

# melos publish dry-runs unless given --no-dry-run; --yes skips its prompt.
release-check: pub-get
	$(DART) run melos publish --yes

# For CI's gates: print `true` when a workspace package, or app_template, changed
# since BASE, else `false`.
workspace-changed: require-base melos-tool
	@packages=$$($(DART) pub global run melos list --diff="$(BASE)" --json) || exit 1; \
	[ "$$packages" = "[]" ] && echo false || echo true

app-template-changed: require-base
	@git diff --name-only "$(BASE)" HEAD -- app_template | grep -q . && echo true || echo false

# For CI's Flutter install: print the version the root's, or app_template's,
# .fvmrc pins.
flutter-version:
	@echo $(call fvmrc_flutter,.fvmrc)

app-template-flutter-version:
	@echo $(call fvmrc_flutter,app_template/.fvmrc)

require-base:
	@[ -n "$(BASE)" ] || { echo 'BASE=<git ref> is required' >&2; exit 1; }
