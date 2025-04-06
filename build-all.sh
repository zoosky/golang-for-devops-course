#!/bin/bash

# Create a directory for build artifacts
BUILD_DIR="$(pwd)/builds"
mkdir -p "$BUILD_DIR"

# Add a warning about gitignore
echo "NOTE: The builds/ directory is gitignored. These binaries are for testing only."
echo "Building all modules in the golang-for-devops-course..."
echo "Build artifacts will be stored in: $BUILD_DIR"

# Get all modules from go.work
MODULES=$(grep -v "^#" go.work | grep -o "\./[a-zA-Z0-9_-]*" | sort)

# Keep track of success/failure
success_count=0
failure_count=0
failed_modules=()
built_artifacts=()

# Process each module
for module in $MODULES; do
  echo ""
  echo "Building module: $module"
  
  # Get module name without leading ./
  module_name=$(echo "$module" | sed 's/\.\///')
  
  # Check if module has a main.go file directly or in cmd subfolder
  MAIN_FILES=$(find "$module" -name "main.go" -type f | sort)
  
  if [ -z "$MAIN_FILES" ]; then
    echo "  No main.go found in $module - skipping"
    continue
  fi
  
  # Try to build each main.go file found
  for main_file in $MAIN_FILES; do
    # Get directory containing main.go
    dir=$(dirname "$main_file")
    main_dir=$(echo "$dir" | sed "s|$module/||" | sed 's|/|-|g')
    
    # If main.go is in the root, use module name as binary name
    if [ "$main_dir" == "" ]; then
      binary_name="$module_name"
    else
      binary_name="$module_name-$main_dir"
    fi
    
    echo "  Building $main_file → $binary_name"
    
    # Attempt to build with output to build directory
    if (cd "$dir" && go build -o "$BUILD_DIR/$binary_name"); then
      echo "  ✅ Successfully built $main_file → $BUILD_DIR/$binary_name"
      built_artifacts+=("$binary_name")
      ((success_count++))
    else
      echo "  ❌ Failed to build $main_file"
      ((failure_count++))
      failed_modules+=("$main_file")
    fi
  done
done

echo ""
echo "Build Summary:"
echo "✅ Successfully built: $success_count module(s)"
echo "📦 Build artifacts in: $BUILD_DIR"
echo ""
echo "Built binaries:"
for artifact in "${built_artifacts[@]}"; do
  echo "  - $artifact"
done

if [ $failure_count -gt 0 ]; then
  echo ""
  echo "❌ Failed to build: $failure_count module(s)"
  echo "Failed modules:"
  for failed in "${failed_modules[@]}"; do
    echo "  - $failed"
  done
  exit 1
else
  echo ""
  echo "All modules built successfully!"
  exit 0
fi