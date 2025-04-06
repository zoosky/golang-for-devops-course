# golang-for-devops-course

Course material for [Golang For DevOps And Cloud Engineers](https://www.udemy.com/course/golang-for-devops-and-cloud-engineers/?referralCode=5A05F011338E0C54EAE7)

 To run all tests:

    ./run-tests.sh

  You can also test individual modules by:

    cd <module-directory>
    go test ./... -v

For testing specific test cases:

    cd <module-directory>
    go test -v ./... -run TestName

To build all modules:

The build-all script will display:

- Which modules it's building
- Build status for each main.go file
- A summary of successful and failed builds
- Exit with code 1 if any builds fail, 0 if all succeed

    ./build-all.sh

Binaries

The binary naming follows the pattern:

- For root-level main.go: `<module-name>-.-<module-name>`
- For cmd/* packages: `<module-name>-cmd-<subpackage>`

  To run a specific binary, you can use:
  ./builds/[binary-name]

  For example:
  ./builds/http-get-.-http-get
  ./builds/hello-world-.-hello-world

 The upgrade to Go 1.24.2 has been completed successfully. Steps:

  1. Used the update-go-version.sh script to update all go.mod files to Go 1.24
  2. Updated the go.work file to use Go 1.24 and the Go 1.24.2 toolchain
  3. Fixed deprecated `io/ioutil` imports using `fix-ioutil.sh`
  4. Fixed unused imports with `fix-unused.sh` and `final-fix.sh`
  5. Verified the upgrade by successfully building all modules with build-all.sh
  6. Ran tests to confirm everything works correctly (with expected failures in template code)

  All modules are now using Go 1.24 with the 1.24.2 toolchain.
