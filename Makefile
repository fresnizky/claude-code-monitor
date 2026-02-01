APP_NAME = Claude Code Dashboard
BUNDLE_ID = ar.resnizky.claude-code-dashboard
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
EXECUTABLE = $(shell swift build -c release --show-bin-path 2>/dev/null)/ClaudeCodeDashboard

.PHONY: build clean install run

build:
	@echo "Building ClaudeCodeDashboard..."
	swift build -c release
	@echo "Creating app bundle..."
	@mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	@mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	@cp "$(EXECUTABLE)" "$(APP_BUNDLE)/Contents/MacOS/ClaudeCodeDashboard"
	@cp ClaudeCodeDashboard/Info.plist "$(APP_BUNDLE)/Contents/"
	@codesign -s - --force "$(APP_BUNDLE)"
	@echo "Built: $(APP_BUNDLE)"

clean:
	swift package clean
	rm -rf $(BUILD_DIR)

install: build
	./install.sh

run: build
	@open "$(APP_BUNDLE)"
