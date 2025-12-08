#!/bin/bash
# Script to build bbcp Debian package
# Usage: ./build-deb.sh

set -e

echo "================================"
echo "Building bbcp Debian package"
echo "================================"
echo ""

# Check if required tools are installed
check_dependencies() {
    local missing_deps=()

    for cmd in dpkg-deb dpkg-buildpackage debhelper; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing required dependencies:"
        printf '  - %s\n' "${missing_deps[@]}"
        echo ""
        echo "Install them with:"
        echo "  sudo apt-get install dpkg-dev debhelper build-essential"
        exit 1
    fi
}

# Check build dependencies
check_build_deps() {
    local missing_deps=()

    if ! dpkg -s g++ &> /dev/null; then
        missing_deps+=("g++")
    fi
    if ! dpkg -s libssl-dev &> /dev/null; then
        missing_deps+=("libssl-dev")
    fi
    if ! dpkg -s zlib1g-dev &> /dev/null; then
        missing_deps+=("zlib1g-dev")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Warning: Missing build dependencies:"
        printf '  - %s\n' "${missing_deps[@]}"
        echo ""
        echo "Install them with:"
        echo "  sudo apt-get install g++ libssl-dev zlib1g-dev"
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf debian/bbcp debian/.debhelper debian/files debian/debhelper-build-stamp
rm -rf debian/*.substvars debian/*.log
rm -f ../*.deb ../*.build ../*.buildinfo ../*.changes

# Check dependencies
echo "Checking dependencies..."
check_dependencies
check_build_deps

# Build the package
echo ""
echo "Building package..."
dpkg-buildpackage -us -uc -b

echo ""
echo "================================"
echo "Build completed successfully!"
echo "================================"
echo ""
echo "Debian package created in parent directory:"
ls -lh ../*.deb 2>/dev/null || true
echo ""
echo "To install the package:"
echo "  sudo dpkg -i ../bbcp_*.deb"
echo "  sudo apt-get install -f  # Fix any missing dependencies"
echo ""
echo "To test the package:"
echo "  dpkg -c ../bbcp_*.deb  # List contents"
echo "  dpkg -I ../bbcp_*.deb  # Show package info"
