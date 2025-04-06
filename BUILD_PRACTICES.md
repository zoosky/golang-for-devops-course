# Go Build Best Practices

## Directory Structure

For multi-module repositories like this one, here are the recommended patterns for organizing binaries:

### Individual Module Organization
```
module-name/
├── cmd/                 # Command applications  
│   ├── app1/            # Each command in its own directory
│   │   └── main.go
│   └── app2/
│       └── main.go
├── pkg/                 # Library code usable by external applications
│   ├── component1/
│   └── component2/
├── internal/            # Code not intended for external use
├── bin/                 # Local build outputs (gitignored)
├── go.mod
└── go.sum
```

### Project-Wide Build Organization
```
project-root/
├── bin/                 # Cross-module binaries (production ready)
├── builds/              # Temporary build artifacts for testing
├── dist/                # Distribution packages
└── module1, module2...  # Individual modules
```

## Build Strategies

1. **Local Development**: 
   ```bash
   go build -o bin/appname ./cmd/appname
   ```

2. **Cross-Module Building** (use the `build-all.sh` script):
   ```bash
   ./build-all.sh
   ```

3. **Production Builds**:
   ```bash
   # For a specific platform
   GOOS=linux GOARCH=amd64 go build -o bin/appname-linux-amd64 ./cmd/appname
   
   # With version info
   go build -ldflags="-X 'main.Version=v1.0.0'" -o bin/appname ./cmd/appname
   ```

## Module Management Tips

1. **Consistent Import Paths**: Use consistent import paths in all modules

2. **Dependency Management**:
   ```bash
   # Update all dependencies
   go get -u ./...
   
   # Prune unused dependencies
   go mod tidy
   ```

3. **Workspace Commands**:
   ```bash
   # Sync all modules in workspace
   go work sync
   
   # Add a module to workspace
   go work use ./new-module
   ```

## Docker Builds

For containerized deployments:

```dockerfile
# Multi-stage build example
FROM golang:1.18-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o /app/myapp ./cmd/myapp

FROM alpine:latest
COPY --from=builder /app/myapp /usr/local/bin/
CMD ["myapp"]
```

## CI/CD Integration

For GitHub Actions or other CI systems:

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: actions/setup-go@v2
    with:
      go-version: '1.18'
  - run: go build ./...
  - run: go test ./...
```