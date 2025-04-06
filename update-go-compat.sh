#!/bin/bash

COMPAT_GO_VERSION="1.18"
echo "Temporarily updating Go version to $COMPAT_GO_VERSION in all go.mod files..."
echo "This is needed for compatibility with your current Go installation."
echo "After installing Go 1.24.2, you can run update-go-version.sh to update to 1.24"

# Find all go.mod files
GO_MOD_FILES=$(find . -name "go.mod" -type f)

# Variables for tracking
updated_count=0
skipped_count=0
failed_count=0
problems=()

# Update go.mod files
for mod_file in $GO_MOD_FILES; do
  echo "Updating $mod_file..."
  
  # Get current version
  current_version=$(grep -E "^go [0-9]+\.[0-9]+" "$mod_file" | awk '{print $2}')
  
  if [ -z "$current_version" ]; then
    echo "  ⚠️ Could not find Go version in $mod_file - skipping"
    skipped_count=$((skipped_count + 1))
    continue
  fi
  
  # Update go directive
  if sed -i.bak "s/go $current_version/go $COMPAT_GO_VERSION/" "$mod_file"; then
    rm -f "${mod_file}.bak"
    echo "  ✅ Successfully updated $mod_file from Go $current_version to $COMPAT_GO_VERSION"
    updated_count=$((updated_count + 1))
  else
    echo "  ❌ Failed to update $mod_file"
    failed_count=$((failed_count + 1))
    problems+=("$mod_file")
  fi
done

echo ""
echo "Go Version Update Summary:"
echo "✅ Successfully updated: $updated_count modules"
if [ $skipped_count -gt 0 ]; then
  echo "⚠️ Skipped: $skipped_count modules"
fi

if [ $failed_count -gt 0 ]; then
  echo "❌ Failed: $failed_count modules"
  echo "Modules with issues:"
  for problem in "${problems[@]}"; do
    echo "  - $problem"
  done
  exit 1
else
  echo "All modules updated successfully!"
  echo ""
  echo "NOTE: This is a temporary compatibility fix for your current Go 1.18 installation."
  echo "After installing Go 1.24.2, run ./update-go-version.sh to update to Go 1.24"
  exit 0
fi