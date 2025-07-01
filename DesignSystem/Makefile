.PHONY: build test clean format lint all

# Default target
all: clean build test

# Build the package
build:
	swift build

# Run tests
test:
	swift test

# Clean build artifacts
clean:
	swift package clean

# Format code (requires swift-format)
format:
	@echo "Note: swift-format not configured yet"

# Lint code (requires SwiftLint)
lint:
	@echo "Note: SwiftLint not configured yet"

# Build for release
release:
	swift build -c release

# Generate documentation
docs:
	swift package generate-documentation

# Open package in Xcode
xcode:
	open Package.swift