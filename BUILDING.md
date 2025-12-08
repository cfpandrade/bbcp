# Building bbcp

This document provides detailed instructions for building bbcp from source on various platforms.

## Table of Contents

- [Quick Start](#quick-start)
- [Build Methods](#build-methods)
  - [Using the Build Script (Recommended)](#using-the-build-script-recommended)
  - [Using Make (Traditional)](#using-make-traditional)
  - [Using CMake (Modern)](#using-cmake-modern)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Build Options](#build-options)
- [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Clone and build
git clone https://github.com/cfpandrade/bbcp.git
cd bbcp

# Option 1: Use the build script (easiest)
./build.sh --install

# Option 2: Use make directly
cd src && make && cd ..
sudo cp bin/*/bbcp /usr/local/bin/

# Option 3: Use CMake
mkdir build && cd build
cmake .. && make
sudo make install
```

## Build Methods

### Using the Build Script (Recommended)

The build script provides automatic dependency checking and platform detection:

```bash
# Build only
./build.sh

# Clean and build
./build.sh --clean

# Build and install
./build.sh --install

# Install to custom location
./build.sh --install --prefix $HOME/bin

# Get help
./build.sh --help
```

Features:
- ✓ Automatic OS and architecture detection
- ✓ Dependency checking with helpful error messages
- ✓ Colored output for easy reading
- ✓ Version detection
- ✓ Flexible installation options

### Using Make (Traditional)

The traditional build method using the original Makefile:

```bash
cd src
make

# The binary will be in ../bin/<platform>/bbcp
# For example: ../bin/amd64_linux5/bbcp on modern Linux
#              ../bin/ARM64_darwin_230/bbcp on Apple Silicon Mac

# To clean
make clean
```

### Using CMake (Modern)

CMake provides better cross-platform support and dependency management:

```bash
# Create build directory
mkdir build
cd build

# Configure
cmake ..

# Build
make

# Or build with verbose output
make VERBOSE=1

# Run tests (if enabled)
ctest

# Install (requires sudo on most systems)
sudo make install

# Install to custom prefix
cmake -DCMAKE_INSTALL_PREFIX=$HOME/local ..
make install
```

#### CMake Options

```bash
# Debug build
cmake -DCMAKE_BUILD_TYPE=Debug ..

# Release build with optimizations
cmake -DCMAKE_BUILD_TYPE=Release ..

# Specify compiler
cmake -DCMAKE_CXX_COMPILER=clang++ ..

# Custom OpenSSL location
cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl ..
```

## Platform-Specific Instructions

### Ubuntu / Debian

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev zlib1g-dev g++ cmake

# Build
./build.sh --install
```

Supported versions:
- Ubuntu 24.04 LTS (Noble)
- Ubuntu 22.04 LTS (Jammy)
- Ubuntu 20.04 LTS (Focal)
- Ubuntu 18.04 LTS (Bionic)
- Debian 12 (Bookworm)
- Debian 11 (Bullseye)

### RHEL / CentOS / Rocky / AlmaLinux / Fedora

```bash
# RHEL 8+, Rocky 8+, AlmaLinux 8+, Fedora
sudo dnf install -y gcc-c++ openssl-devel zlib-devel make cmake

# RHEL 7, CentOS 7
sudo yum install -y gcc-c++ openssl-devel zlib-devel make cmake

# Build
./build.sh --install
```

### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Optional: Install CMake via Homebrew
brew install cmake

# Build
./build.sh --install
```

Supported versions:
- macOS 15 (Sequoia)
- macOS 14 (Sonoma)
- macOS 13 (Ventura)
- macOS 12 (Monterey)
- macOS 11 (Big Sur)

Architectures:
- Intel (x86_64)
- Apple Silicon (ARM64 - M1, M2, M3, M4)

### FreeBSD

```bash
# Dependencies are usually pre-installed
# If needed:
sudo pkg install gmake gcc openssl

# Build using GNU make
cd src
gmake
cd ..

# Install
sudo cp bin/*/bbcp /usr/local/bin/
```

### Alpine Linux

```bash
# Install dependencies
apk add --no-cache build-base openssl-dev zlib-dev cmake

# Build
./build.sh --install
```

### Arch Linux

```bash
# Install dependencies
sudo pacman -S base-devel openssl zlib cmake

# Build
./build.sh --install
```

## Build Options

### Compiler Selection

You can specify a different compiler:

```bash
# Using Make
cd src
make CC=clang CXX=clang++

# Using CMake
cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ ..
```

### Optimization Levels

```bash
# Using Make with custom flags
cd src
make CFLAGS="-O3 -march=native"

# Using CMake
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-O3 -march=native" ..
```

### Static Linking (for portable binaries)

```bash
# Using CMake
cmake -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++" ..
make
```

## Troubleshooting

### OpenSSL Not Found

**Symptom**: Build fails with "openssl/ssl.h: No such file or directory"

**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install libssl-dev

# RHEL/Fedora
sudo dnf install openssl-devel

# macOS (if using Homebrew OpenSSL)
cmake -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl ..
# or for Apple Silicon
cmake -DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl ..
```

### zlib Not Found

**Symptom**: Build fails with "zlib.h: No such file or directory"

**Solution**:
```bash
# Ubuntu/Debian
sudo apt-get install zlib1g-dev

# RHEL/Fedora
sudo dnf install zlib-devel

# macOS
# zlib is usually pre-installed
```

### Compiler Too Old

**Symptom**: Errors about C++11 features not supported

**Solution**:
```bash
# Ubuntu 18.04 - use newer GCC
sudo apt-get install g++-8
export CXX=g++-8

# RHEL 7 - use devtoolset
sudo yum install centos-release-scl
sudo yum install devtoolset-8
scl enable devtoolset-8 bash
```

### Permission Denied During Install

**Symptom**: "Permission denied" when running `make install`

**Solution**:
```bash
# Use sudo
sudo make install

# Or install to home directory
cmake -DCMAKE_INSTALL_PREFIX=$HOME/local ..
make install
```

### Binary Not Found After Build

**Symptom**: Cannot find bbcp binary after successful build

**Solution**:
```bash
# Find the binary
find . -name bbcp -type f

# It will be in bin/<platform>/bbcp
# Example locations:
# Linux: bin/amd64_linux5/bbcp
# macOS Intel: bin/X86_darwin_230/bbcp
# macOS ARM: bin/ARM64_darwin_230/bbcp
```

## Cross-Compilation

### Building for Different Architectures

```bash
# Build 32-bit on 64-bit Linux
cmake -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" ..

# Build ARM on x86 (requires cross-compiler)
cmake -DCMAKE_TOOLCHAIN_FILE=arm-toolchain.cmake ..
```

## Verifying the Build

After building, verify the binary works:

```bash
# Find the binary
BBCP=$(find bin -name bbcp -type f | head -n1)

# Check version
$BBCP --version

# Check help
$BBCP --help

# Run a simple test
echo "test" > /tmp/test.txt
$BBCP /tmp/test.txt /tmp/test2.txt
diff /tmp/test.txt /tmp/test2.txt
```

## Additional Resources

- [Main README](README.md) - Usage examples and quick start
- [Original Documentation](http://www.slac.stanford.edu/~abh/bbcp) - Stanford SLAC official docs
- [GitHub Issues](https://github.com/cfpandrade/bbcp/issues) - Report build problems

## Contributing Build Improvements

If you've successfully built bbcp on a platform not listed here, or have improvements to the build system, please contribute:

1. Fork the repository
2. Add your improvements
3. Test on your platform
4. Submit a pull request with details about your platform and changes
