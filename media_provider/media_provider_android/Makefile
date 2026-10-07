FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
DART := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm dart" || echo "dart")

.PHONY: test
test:
	$(FLUTTER) test --no-test-assets

.PHONY: build-runner
build-runner:
	$(DART) run build_runner build --delete-conflicting-outputs