#!/bin/bash

# Files with unused imports
FILES=(
  "./kubernetes-deploy/main.go"
  "./oidc-demo/cmd/server/main.go"
  "./oidc-start/cmd/server/main.go"
  "./ssh-demo/cmd/client/main.go"
  "./ssh-demo/cmd/server/main.go"
  "./tls-demo/cmd/mtls-server/main.go"
  "./tls-demo/pkg/cert/x509.go"
  "./tls-demo/cmd/tls/main.go"
)

echo "Manual fix for specific files..."

for file in "${FILES[@]}"; do
  echo "Processing $file"
  
  # Create a completely new version of the file by stripping the io import
  grep -v '"io"' "$file" > "${file}.new"
  
  # Replace the original
  mv "${file}.new" "$file"
  
  echo "  ✅ Fixed $file"
done

echo "All files fixed!"