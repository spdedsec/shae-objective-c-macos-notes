# Makefile — shae-objective-c-macos-notes
#
# SHAE Notes (Objective-C / Foundation). macOS desktop app.
#
# NOTE: clang with Objective-C support and the Foundation SDK are not
# available in this environment, so `make build` / `make test` / `make
# release` cannot be run locally. See README.md and scripts/install.sh.

.PHONY: build test release clean install help

SRC      := src/Notes.m
HEADER   := src/Notes.h
TARGET   := Notes
RELEASE  := shae-objective-c-macos-notes-v0.1.0.zip
CLANG    ?= clang
CFLAGS   ?= -fobjc-arc -framework Foundation

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

build: $(TARGET) ## Build the Notes binary (macOS/clang)

$(TARGET): $(SRC) $(HEADER)
	$(CLANG) $(CFLAGS) $(SRC) -o $(TARGET)
	@echo "Build OK: ./$(TARGET)"

test: build ## Compile (serves as the syntax/test check for Objective-C)
	@echo "Test OK: $(SRC) compiles with clang."

release: clean ## Create a release zip of src/
	@rm -f $(RELEASE)
	zip -r $(RELEASE) src scripts Makefile README.md DESIGN.md LICENSE docs
	@echo "Release artifact: $(RELEASE)"

clean: ## Remove build artifacts
	rm -f $(TARGET)
	rm -f $(RELEASE)

install: ## Notes on installing (see scripts/install.sh)
	@./scripts/install.sh
