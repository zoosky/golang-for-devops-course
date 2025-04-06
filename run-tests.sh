#!/bin/bash

# Find all modules with test files
echo "Testing all modules with test files..."

# Keep track of which modules fail
failed_modules=()
expected_failures=("dns-start" "oidc-start") # Modules that are expected to fail

# Test modules with tests
modules=(
  "aws-s3-testing"
  "dns-demo"
  "dns-start"
  "http-login-tests"
  "kubernetes-deploy-github"
  "oidc-demo"
  "oidc-start"
)

for module in "${modules[@]}"; do
  echo ""
  echo "Testing module: $module"
  cd "$module"
  
  # Run tests and capture result
  go test ./... -v
  result=$?
  
  # Check if failure was expected
  if [ $result -ne 0 ]; then
    if [[ " ${expected_failures[@]} " =~ " ${module} " ]]; then
      echo "NOTE: $module failed as expected (likely contains template code)"
    else
      failed_modules+=("$module")
    fi
  fi
  
  cd ..
done

echo ""
if [ ${#failed_modules[@]} -eq 0 ]; then
  echo "All tests completed successfully (excluding expected failures)!"
  exit 0
else
  echo "The following modules had test failures:"
  printf "  - %s\n" "${failed_modules[@]}"
  exit 1
fi