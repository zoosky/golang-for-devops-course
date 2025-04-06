#!/bin/bash

NEW_GO_VERSION="1.24"
echo "Updating Go version to $NEW_GO_VERSION in all go.mod files..."

# Find all go.mod files
GO_MOD_FILES=$(find . -name "go.mod" -type f)

# Variables for tracking
updated_count=0
skipped_count=0
failed_count=0
problems=()

# Migrate deprecated io/ioutil to io and os
echo "Looking for deprecated io/ioutil imports to update..."
IOUTIL_FILES=$(grep -r "io/ioutil" --include="*.go" . | cut -d ":" -f 1 | sort -u)

if [ -n "$IOUTIL_FILES" ]; then
  echo "Updating io/ioutil imports in these files:"
  for file in $IOUTIL_FILES; do
    echo "  - $file"
    # Replace imports
    sed -i.bak 's|"io/ioutil"|"io"\n\t"os"|g' "$file"
    # Replace function calls
    sed -i.bak 's|ioutil\.ReadFile|os.ReadFile|g' "$file"
    sed -i.bak 's|ioutil\.WriteFile|os.WriteFile|g' "$file"
    sed -i.bak 's|ioutil\.ReadAll|io.ReadAll|g' "$file"
    sed -i.bak 's|ioutil\.NopCloser|io.NopCloser|g' "$file"
    sed -i.bak 's|ioutil\.TempDir|os.MkdirTemp|g' "$file"
    sed -i.bak 's|ioutil\.TempFile|os.CreateTemp|g' "$file"
    rm -f "${file}.bak"
  done
  echo "Updated io/ioutil imports in $(echo "$IOUTIL_FILES" | wc -l | tr -d ' ') files"
else
  echo "No io/ioutil imports found"
fi

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
  if sed -i.bak "s/go $current_version/go $NEW_GO_VERSION/" "$mod_file"; then
    rm -f "${mod_file}.bak"
    echo "  ✅ Successfully updated $mod_file from Go $current_version to $NEW_GO_VERSION"
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
  echo "NOTE: You may need to run 'go work sync' after switching to Go 1.24.2"
  echo "to synchronize the workspace dependencies."
  exit 0
fi