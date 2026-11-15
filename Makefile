# Checks for the whole repository, run the same way locally and in CI.
#
#   make test                 Every package's tests with the coverage check:
#                             the workspace's, then app_template's.
#   make workspace-test       Only the workspace packages.
#   make app-template-test    Only app_template and its packages.
#   make release-check        Dry-run publishing every package whose version
#                             isn't on pub.dev yet.
#
# The test targets take an optional BASE=<git ref>: then only the packages
# changed since BASE are checked, as CI does for a pull request.
#
# Uses fvm when it's installed (the root's and app_template's .fvmrc pick the
# Flutter version), plain flutter/dart otherwise. The coverage check needs
# lcov.

FVM := $(shell command -v fvm >/dev/null 2>&1 && echo fvm)
FLUTTER := $(if $(FVM),fvm flutter,flutter)
DART := $(if $(FVM),fvm dart,dart)
ROOT := $(CURDIR)
BASE ?=

.PHONY: test workspace-test app-template-test release-check setup pub-get coverage-tool

test: workspace-test app-template-test

# Resolves the workspace, Melos included.
pub-get:
	$(FLUTTER) pub get

# The coverage package, which tool/coverage.dart needs for pure-Dart packages.
coverage-tool:
	@$(DART) pub global list | grep -q '^coverage ' || $(DART) pub global activate coverage

setup: pub-get coverage-tool

workspace-test: setup
ifeq ($(BASE),)
	$(DART) run melos run coverage --no-select
else
	$(DART) run melos exec --diff=$(BASE) --concurrency=1 -- \
		dart run '$$MELOS_ROOT_PATH/tool/coverage.dart'
endif

# app_template and its packages are outside the workspace, so each one is
# resolved and checked on its own. With BASE, a change inside one of its
# packages doesn't count as a change to app_template itself.
app-template-test: setup
	@for dir in app_template app_template/packages/*; do \
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
		(cd "$$dir" && $(FLUTTER) pub get >/dev/null && $(DART) run "$(ROOT)/tool/coverage.dart") || exit 1; \
	done

release-check: pub-get
	$(DART) run melos run release:check
