# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build/Run
- Build and run: `go build ./... && go run <path_to_main.go>`
- Install binary: `go install ./...`

### Testing
- Run all tests: `go test ./...`
- Run specific test: `go test -v <package_path> -run <TestName>`
- Run tests with verbose output: `go test -v ./...`
- Run tests with coverage: `go test -cover ./...`

### Linting/Formatting
- Format code: `go fmt ./...`
- Lint code: `go vet ./...`
- Check imports: `goimports -w .`

## Coding Guidelines

- Imports: Standard library first, then third-party packages
- Error Handling: Use `if err != nil` pattern with context in error messages
- Formatting: Follow standard Go conventions (tabs for indentation)
- Naming: CamelCase for exported items, camelCase for unexported items
- Constants: UPPER_SNAKE_CASE
- Testing: Write table-driven tests with clear error messages
- Comment exported functions/types with proper godoc format
- Mock external dependencies for unit tests