#!/bin/bash

# Files that need fixing based on the build errors
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
  "./tls-demo/pkg/cmd/cert.go"
  "./tls-demo/pkg/cmd/root.go"
)

echo "Fixing io/ioutil imports..."

for file in "${FILES[@]}"; do
  echo "Processing $file"
  
  # Check if file exists
  if [ ! -f "$file" ]; then
    echo "  ⚠️ File does not exist, skipping"
    continue
  fi
  
  # Create a backup first
  cp "$file" "${file}.bak"
  
  # Check for imports block style
  if grep -q "import (" "$file"; then
    # Multi-line import block - remove io/ioutil and add io, os if not already present
    awk '
    BEGIN { in_import = 0; io_found = 0; os_found = 0; has_ioutil = 0; }
    /^import \(/ { in_import = 1; print; next; }
    in_import && /^\)/ {
      if (has_ioutil) {
        if (!io_found) print "\t\"io\"";
        if (!os_found) print "\t\"os\"";
      }
      in_import = 0;
      print;
      next;
    }
    in_import && /io\/ioutil/ {
      has_ioutil = 1;
      next;
    }
    in_import && /^[ \t]*"io"/ { io_found = 1; print; next; }
    in_import && /^[ \t]*"os"/ { os_found = 1; print; next; }
    { print; }
    ' "${file}.bak" > "$file"
    
  else
    # Single-line imports - replace io/ioutil with io and os
    sed -i.bak2 's/import "io\/ioutil"/import (\n\t"io"\n\t"os"\n)/' "$file"
  fi
  
  # Replace function calls
  sed -i.bak3 's/ioutil\.ReadFile/os.ReadFile/g' "$file"
  sed -i.bak3 's/ioutil\.WriteFile/os.WriteFile/g' "$file"
  sed -i.bak3 's/ioutil\.ReadAll/io.ReadAll/g' "$file"
  sed -i.bak3 's/ioutil\.NopCloser/io.NopCloser/g' "$file"
  sed -i.bak3 's/ioutil\.TempDir/os.MkdirTemp/g' "$file"
  sed -i.bak3 's/ioutil\.TempFile/os.CreateTemp/g' "$file"
  
  echo "  ✅ Fixed io/ioutil imports in $file"
  
  # Clean up backup files
  rm -f "${file}.bak" "${file}.bak2" "${file}.bak3"
done

echo "Fixed io/ioutil imports in all files"