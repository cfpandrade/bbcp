#!/usr/bin/env bash
#
# Simple build script for bbcp
# Supports Linux, macOS, FreeBSD, and other UNIX-like systems
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    OS=$(uname -s)
    ARCH=$(uname -m)

    print_info "Detected OS: $OS ($ARCH)"

    case "$OS" in
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                print_info "Distribution: $NAME $VERSION"
            fi
            ;;
        Darwin)
            OSX_VERSION=$(sw_vers -productVersion)
            print_info "macOS version: $OSX_VERSION"
            ;;
        FreeBSD)
            FREEBSD_VERSION=$(freebsd-version)
            print_info "FreeBSD version: $FREEBSD_VERSION"
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    print_info "Checking dependencies..."

    local missing_deps=()

    # Check for C++ compiler
    if command -v g++ &> /dev/null; then
        GCC_VERSION=$(g++ --version | head -n1)
        print_success "C++ compiler found: $GCC_VERSION"
    elif command -v clang++ &> /dev/null; then
        CLANG_VERSION=$(clang++ --version | head -n1)
        print_success "C++ compiler found: $CLANG_VERSION"
    else
        print_error "No C++ compiler found (g++ or clang++)"
        missing_deps+=("g++/clang++")
    fi

    # Check for make
    if command -v make &> /dev/null; then
        print_success "Make found: $(make --version | head -n1)"
    else
        print_error "Make not found"
        missing_deps+=("make")
    fi

    # Check for OpenSSL headers
    if [ -f /usr/include/openssl/ssl.h ] || \
       [ -f /usr/local/include/openssl/ssl.h ] || \
       [ -f /opt/homebrew/include/openssl/ssl.h ]; then
        print_success "OpenSSL headers found"
    else
        print_warning "OpenSSL headers not found in standard locations"
        print_warning "  Ubuntu/Debian: sudo apt-get install libssl-dev"
        print_warning "  RHEL/Fedora:   sudo dnf install openssl-devel"
        print_warning "  macOS:         brew install openssl (usually pre-installed)"
    fi

    # Check for zlib headers
    if [ -f /usr/include/zlib.h ] || \
       [ -f /usr/local/include/zlib.h ] || \
       [ -f /opt/homebrew/include/zlib.h ]; then
        print_success "zlib headers found"
    else
        print_warning "zlib headers not found in standard locations"
        print_warning "  Ubuntu/Debian: sudo apt-get install zlib1g-dev"
        print_warning "  RHEL/Fedora:   sudo dnf install zlib-devel"
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Clean build
clean_build() {
    print_info "Cleaning previous build..."
    cd src
    make clean 2>/dev/null || true
    cd ..
    print_success "Clean complete"
}

# Build
build() {
    print_info "Building bbcp..."
    cd src

    if make; then
        cd ..
        print_success "Build complete!"
        return 0
    else
        cd ..
        print_error "Build failed"
        return 1
    fi
}

# Find binary
find_binary() {
    BINARY_PATH=$(find bin -name bbcp -type f 2>/dev/null | head -n1)

    if [ -n "$BINARY_PATH" ]; then
        print_success "Binary built: $BINARY_PATH"

        # Get version
        if [ -x "$BINARY_PATH" ]; then
            VERSION=$($BINARY_PATH --version 2>&1 | head -n1 || echo "unknown")
            print_info "Version: $VERSION"
        fi

        return 0
    else
        print_error "Binary not found after build"
        return 1
    fi
}

# Install binary
install_binary() {
    if [ -z "$BINARY_PATH" ]; then
        print_error "No binary to install"
        return 1
    fi

    local install_dir="${INSTALL_PREFIX:-/usr/local/bin}"

    print_info "Installing to $install_dir..."

    if [ ! -w "$install_dir" ]; then
        print_warning "No write permission to $install_dir, trying with sudo..."
        sudo cp "$BINARY_PATH" "$install_dir/bbcp"
    else
        cp "$BINARY_PATH" "$install_dir/bbcp"
    fi

    if [ -f "$install_dir/bbcp" ]; then
        chmod +x "$install_dir/bbcp"
        print_success "Installed to $install_dir/bbcp"

        # Verify installation
        if command -v bbcp &> /dev/null; then
            print_success "bbcp is now in your PATH"
            bbcp --version 2>&1 | head -n1
        fi
    else
        print_error "Installation failed"
        return 1
    fi
}

# Usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build script for bbcp

OPTIONS:
    -h, --help      Show this help message
    -c, --clean     Clean before building
    -i, --install   Install after building
    -p, --prefix    Installation prefix (default: /usr/local/bin)

EXAMPLES:
    $0                  # Build only
    $0 --clean          # Clean and build
    $0 --install        # Build and install
    $0 -c -i            # Clean, build, and install
    $0 -i -p ~/bin      # Build and install to ~/bin

EOF
}

# Main
main() {
    local do_clean=false
    local do_install=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--clean)
                do_clean=true
                shift
                ;;
            -i|--install)
                do_install=true
                shift
                ;;
            -p|--prefix)
                INSTALL_PREFIX="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    echo ""
    print_info "bbcp Build Script"
    print_info "================="
    echo ""

    detect_os
    check_dependencies

    if [ "$do_clean" = true ]; then
        clean_build
    fi

    if build && find_binary; then
        if [ "$do_install" = true ]; then
            install_binary
        else
            echo ""
            print_info "To install bbcp, run:"
            print_info "  sudo cp $BINARY_PATH /usr/local/bin/"
            print_info "Or run this script with --install flag"
        fi

        echo ""
        print_success "All done!"
        exit 0
    else
        exit 1
    fi
}

main "$@"
