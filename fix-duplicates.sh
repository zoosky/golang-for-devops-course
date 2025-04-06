#!/bin/bash

# Files with duplicate imports
FILES=(
  "./aws-s3-testing/main.go"
  "./kubernetes-deploy/main.go"
  "./oidc-demo/cmd/server/main.go"
  "./oidc-start/cmd/server/main.go"
  "./ssh-demo/cmd/client/main.go"
  "./ssh-demo/cmd/server/main.go"
  "./tls-demo/cmd/mtls-client/main.go"
  "./tls-demo/cmd/mtls-server/main.go"
  "./tls-demo/pkg/cert/x509.go"
)

echo "Fixing duplicate imports..."

for file in "${FILES[@]}"; do
  echo "Processing $file"
  
  # Make a backup
  cp "$file" "${file}.bak"
  
  # Fix duplicate imports of io and os
  awk '
  BEGIN { skip = 0; seen_io = 0; seen_os = 0; }
  /^import \(/ { print; in_import = 1; next; }
  in_import && /^\)/ { print; in_import = 0; next; }
  in_import && /^[ \t]*"io"/ { 
    if (seen_io == 0) { 
      seen_io = 1; 
      print; 
    }
    next; 
  }
  in_import && /^[ \t]*"os"/ { 
    if (seen_os == 0) { 
      seen_os = 1; 
      print; 
    }
    next; 
  }
  { print; }
  ' "${file}.bak" > "$file"
  
  echo "  ✅ Fixed duplicate imports in $file"
  rm -f "${file}.bak"
done

echo "Fixed duplicate imports in all files"