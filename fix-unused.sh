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

echo "Fixing unused imports..."

for file in "${FILES[@]}"; do
  echo "Processing $file"
  
  # Make a backup
  cp "$file" "${file}.bak"
  
  # Remove unused io imports
  sed -i.bak2 '/^[ \t]*"io"[ \t]*$/d' "$file"
  
  echo "  ✅ Fixed unused imports in $file"
  rm -f "${file}.bak" "${file}.bak2"
done

echo "Fixed unused imports in all files"