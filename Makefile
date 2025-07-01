.PHONY: build test clean build-design-system test-design-system all

# Default target
all: clean build test

# Build the main project
build:
	xcodebuild -project humancron.xcodeproj -scheme humancron build

# Run tests
test:
	xcodebuild -project humancron.xcodeproj -scheme humancron test

# Clean build folder
clean:
	xcodebuild -project humancron.xcodeproj -scheme humancron clean

# Build DesignSystem package
build-design-system:
	cd DesignSystem && make build

# Test DesignSystem package
test-design-system:
	cd DesignSystem && make test

# Build everything
build-all: build-design-system build

# Test everything
test-all: test-design-system test

# Open project in Xcode
xcode:
	open humancron.xcodeproj

close:
	killall humancron

# Open the built app
open:
	open /Users/obsess/Library/Developer/Xcode/DerivedData/humancron-*/Build/Products/Debug/humancron.app


install:
	cp -r /Users/obsess/Library/Developer/Xcode/DerivedData/humancron-*/Build/Products/Debug/humancron.app /Applications/humancron.app

bo: build close open