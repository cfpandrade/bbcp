# Release v1.0.0 - Debian Package Support

## What's New

This is the first stable release of bbcp with Debian packaging support!

### Features

- **Debian Package Support**: Full `.deb` package for easy installation on Ubuntu/Debian systems
- **Ubuntu 24.04 LTS Support**: Tested and working with GCC 13 and OpenSSL 3.0
- **Automated Builds**: GitHub Actions workflow builds packages automatically
- **High-Performance Transfers**: Multiple parallel TCP streams for maximum throughput
- **Data Integrity**: MD5, CRC32, and Adler32 checksumming
- **Built-in Compression**: zlib compression support
- **Cross-Platform**: Linux, macOS, FreeBSD, AIX support

## Installation

### Option 1: From GitHub Release (Recommended)

The GitHub Actions workflow is now building the `.deb` package. Once the workflow completes:

1. Go to: https://github.com/cfpandrade/bbcp/releases/tag/v1.0.0
2. Download the `.deb` file
3. Install:
   ```bash
   sudo dpkg -i bbcp_1.0.0-1_amd64.deb
   sudo apt-get install -f  # Fix dependencies if needed
   ```

### Option 2: Build from Source

```bash
git clone https://github.com/cfpandrade/bbcp.git
cd bbcp
git checkout v1.0.0

# Build the .deb package
./build-deb.sh

# Install
sudo dpkg -i ../bbcp_1.0.0-1_amd64.deb
```

## Monitoring the Build

You can monitor the GitHub Actions workflow at:
https://github.com/cfpandrade/bbcp/actions

The workflow will:
1. Build the `.deb` package on Ubuntu 24.04
2. Test installation on Ubuntu 24.04, 22.04, and 20.04
3. Create a GitHub Release with the package attached
4. Include detailed installation instructions

## Verifying the Release

Once the workflow completes (usually 5-10 minutes), you can verify:

```bash
# Check the release exists
curl -s https://api.github.com/repos/cfpandrade/bbcp/releases/tags/v1.0.0 | grep "browser_download_url"

# Or visit in browser
open https://github.com/cfpandrade/bbcp/releases/tag/v1.0.0
```

## Package Contents

The `.deb` package includes:

- **Binary**: `/usr/bin/bbcp`
- **Documentation**:
  - `/usr/share/doc/bbcp/README.md`
  - `/usr/share/doc/bbcp/BUILDING.md`
  - `/usr/share/doc/bbcp/README.Debian`
  - `/usr/share/doc/bbcp/copyright`
  - `/usr/share/doc/bbcp/changelog.gz`

## Dependencies

The package automatically installs these dependencies:
- `libssl3` or `libssl1.1` (OpenSSL)
- `zlib1g` (compression)
- `libc6` (standard C library)

## Usage Examples

After installation:

```bash
# Verify installation
bbcp --version

# Simple file copy
bbcp myfile.dat user@remotehost:/destination/

# High-performance transfer with 8 parallel streams
bbcp -s 8 -P 5 largefile.iso user@remotehost:/backup/

# With compression
bbcp -c -s 8 logfile.tar user@remotehost:/backup/

# With checksum verification
bbcp -e dataset.tar.gz user@remotehost:/data/
```

## Tested Platforms

This release has been tested on:
- Ubuntu 24.04 LTS (Noble Numbat)
- Ubuntu 22.04 LTS (Jammy Jellyfish)
- Ubuntu 20.04 LTS (Focal Fossa)

## What's Next

Future improvements planned:
- RPM package support for RHEL/CentOS/Fedora
- Homebrew formula for macOS
- Pre-built static binaries
- Additional performance optimizations

## Support

- **Issues**: https://github.com/cfpandrade/bbcp/issues
- **Documentation**: https://github.com/cfpandrade/bbcp/blob/master/README.md
- **Original Project**: http://www.slac.stanford.edu/~abh/bbcp

## Credits

Original bbcp developed at SLAC National Accelerator Laboratory at Stanford University.

This fork maintained by Carlos (https://github.com/cfpandrade).

---

**Release Date**: December 8, 2024
**Git Tag**: v1.0.0
**Commit**: 24ed7ca
