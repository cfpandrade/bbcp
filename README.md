# bbcp - Block Based Copy Protocol

Securely and quickly copy data from source to target using multiple parallel streams.

## About This Fork

This is a public fork of bbcp. The original bbcp was developed at SLAC National Accelerator Laboratory at Stanford University.

**Original project**: http://www.slac.stanford.edu/~abh/bbcp

## Features

- **High-speed parallel transfers** - Uses multiple TCP streams for maximum throughput
- **Data integrity** - MD5, CRC32, and Adler32 checksumming
- **Compression** - Built-in zlib compression to reduce bandwidth
- **Progress monitoring** - Real-time transfer statistics
- **Secure** - Works seamlessly with SSH
- **Cross-platform** - Linux, macOS, FreeBSD, AIX support

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/cfpandrade/bbcp.git
cd bbcp/src

# Build
make

# Install to system PATH
sudo cp ../bin/*/bbcp /usr/local/bin/
bbcp --version
```

### Platform-Specific

#### Ubuntu/Debian

**Tested on**: 24.04 LTS, 22.04 LTS, 20.04 LTS, 18.04 LTS

```bash
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev zlib1g-dev g++
cd src && make
sudo cp ../bin/*/bbcp /usr/local/bin/
```

**Note**: Ubuntu 24.04 uses GCC 13 and OpenSSL 3.0 - fully supported!

#### RHEL/Rocky/AlmaLinux/Fedora

```bash
sudo dnf install -y gcc-c++ openssl-devel zlib-devel make
cd src && make
sudo cp ../bin/*/bbcp /usr/local/bin/
```

#### macOS

```bash
# Install Xcode Command Line Tools (if needed)
xcode-select --install

cd src && make
sudo cp ../bin/*/bbcp /usr/local/bin/
```

## Usage Examples

### Basic Copy

```bash
# Simple file copy
bbcp sourcefile user@remotehost:/path/to/destination

# Copy directory recursively
bbcp -r /local/directory user@remotehost:/remote/directory
```

### High-Performance Transfer

```bash
# Use 8 parallel streams with 4MB window size, show progress every 5 seconds
bbcp -s 8 -w 4M -P 5 largefile.dat user@remotehost:/data/

# With compression (useful for text/log files)
bbcp -c -s 8 -w 4M logfile.tar user@remotehost:/backup/

# Preserve permissions and timestamps
bbcp -p -r /source/path user@remotehost:/destination/
```

### Checksum Validation

```bash
# Enable MD5 checksumming for data integrity
bbcp -e largefile.iso user@remotehost:/downloads/

# Compute and display MD5 checksum
bbcp -E md5 file.dat user@remotehost:/data/
```

### Resume Failed Transfers

```bash
# Resume a previously interrupted copy
bbcp -a /resume/directory file.dat user@remotehost:/data/
```

### Sample Output

```
> bbcp -P 2 -w 2M -s 10 my.big.file user@server:/destination/
bbcp: Creating /destination/my.big.file
bbcp: At 140506 17:33:18 copy 20% complete; 89998.2 KB/s
bbcp: At 140506 17:33:28 copy 41% complete; 89910.4 KB/s
bbcp: At 140506 17:33:38 copy 61% complete; 89802.5 KB/s
bbcp: At 140506 17:33:48 copy 80% complete; 88499.3 KB/s
bbcp: At 140506 17:33:58 copy 96% complete; 84571.9 KB/s
```

## Command Line Reference

    bbcp [Options] [Inspec] Outspec

    Options: [-a [dir]] [-b [+]bf] [-B bsz] [-c [lvl]] [-C cfn] [-D] [-d path]
         [-e] [-E csa] [-f] [-F] [-h] [-i idfn] [-I slfn] [-k] [-K]
         [-L opts[@logurl]] [-l logf] [-m mode] [-n] [-N nio] [-o] [-O] [-p]
         [-P sec] [-r] [-R [args]] [-q qos] [-s snum] [-S srcxeq] [-T trgxeq]
         [-t sec] [-v] [-V] [-u loc] [-U wsz] [-w [=]wsz] [-x rate] [-y] [-z]
         [-Z pnf[:pnl]] [-4 [loc]] [-$] [-#] [--]

    I/Ospec: [user@][host:]file

    Function: Secure and fast copy utility.
    
    -a dir  append mode to restart a previously failed copy.
    -b bf   sets the read blocking factor (default is 1).
    -b +bf  adds additional output buffers to mitigate ordering stalls.
    -B bsz  sets the read/write I/O buffer size (default is wsz).
    -c lvl  compress data before sending across the network (default lvl is 1).
    -C cfn  process the named configuration file at time of encounter.
    -d path requests relative source path addressing and target path creation.
    -D      turns on debugging.
    -e      error check data for transmission errors using md5 checksum.
    -E csa  specify checksum alorithm and optionally report or verify checksum.
            csa: [%]{a32|c32|md5}[=[<value> | <outfile>]]
    -f      forces the copy by first unlinking the target file before copying.
    -F      does not check to see if there is enough space on the target node.
    -h      print help information.
    -i idfn is the name of the ssh identify file for source and target.
    -I slfn is the name of the file that holds the list of files to be copied.
            With -I no source files need be specified on the command line.
    -k      keep the destination file even when the copy fails.
    -K      do not rm the file when -f specified, only truncate it.
    -l logf logs standard error to the specified file.
    -L args sets the logginng level and log message destination.
    -m mode target file mode as [dmode/][fmode] but one mode must be present.
            Default dmode is 0755 and fmode is 0644 or it comes via -p option.
    -n      do not use DNS to resolve IP addresses to host names.
    -N nio  enable named pipe processing; nio specifies input and output state:
            i -> input pipe or program, o -> output pipe or program
    -s snum number of network streams to use (default is 4).
    -o      enforces output ordering (writes in ascending offset order).
    -O      omits files that already exist at the target node (useful with -r).
    -p      preserve source mode, ownership, and dates.
    -P sec  produce a progress message every sec seconds (15 sec minimum).
    -q lvl  specifies the quality of service for routers that support QOS.
    -r      copy subdirectories and their contents (actual files only).
    -R args enables real-time copy where args specific handling options.
    -S cmd  command to start bbcp on the source node.
    -T cmd  command to start bbcp on the target node.
    -t sec  sets the time limit for the copy to complete.
    -v      verbose mode (provides per file transfer rate).
    -V      very verbose mode (excruciating detail).
    -u loc  use unbuffered I/O at source or target, if possible.
            loc: s | t | st
    -U wsz  unnegotiated window size (sets maximum and default for all parties).
    -w wsz  desired window size for transmission (the default is 128K).
            Prefixing wsz with '=' disables autotuning in favor of a fixed wsz.
    -x rate is the maximum transfer rate allowed in bytes, K, M, or G.
    -y what perform fsync before closing the output file when what is 'd'.
            When what is 'dd' then the file and directory are fsynced.
    -z      use reverse connection protocol (i.e., target to source).
    -Z      use port range pn1:pn2 for accepting data transfer connections.
    -4      use only IPV4 stack; optionally, at specified location.
    -$      print the license and exit.
    -#      print the version and exit.
    --      allows an option with a defaulted optional arg to appear last.
    
    user    the user under which the copy is to be performed. The default is
            to use the current login name.
    host    the location of the file. The default is to use the current host.
    Inspec  the name of the source file(s) (also see -I).
    Outspec the name of the target file or directory (required if >1 input file.
    
**Complete details**: http://www.slac.stanford.edu/~abh/bbcp

## Performance Tips

1. **Tune the number of streams** (`-s`) based on your network:
   - LAN: 4-8 streams
   - WAN (long distance): 8-16 streams
   - Very high latency: 16-32 streams

2. **Adjust window size** (`-w`) for your bandwidth-delay product:
   - LAN: 2M-4M
   - WAN: 8M-32M
   - Transatlantic/Pacific: 64M+

3. **Use compression** (`-c`) for:
   - Text files, logs, source code
   - Don't use for already compressed files (videos, archives)

4. **Enable checksums** (`-e`) for:
   - Critical data transfers
   - Long-distance transfers
   - Unreliable networks

## Comparison with Other Tools

| Feature | bbcp | scp | rsync | GridFTP |
|---------|------|-----|-------|---------|
| Parallel Streams | ✓ | ✗ | ✗ | ✓ |
| Built-in Compression | ✓ | ✓ | ✓ | ✓ |
| Checksumming | ✓ | ✗ | ✓ | ✓ |
| Resume Capability | ✓ | ✗ | ✓ | ✓ |
| Progress Display | ✓ | ✗ | ✓ | ✓ |
| SSH Compatible | ✓ | ✓ | ✓ | ✗ |

## Building from Source

### Quick Build

```bash
# Using the build script (easiest)
./build.sh --install

# Using make (traditional)
cd src && make
sudo cp ../bin/*/bbcp /usr/local/bin/

# Using CMake (modern)
mkdir build && cd build && cmake .. && make
sudo make install
```

**For detailed build instructions**, see [BUILDING.md](BUILDING.md)

### Prerequisites

- C++ compiler (g++ 7+ or clang++)
- OpenSSL development libraries
- zlib development libraries
- POSIX threads support
- CMake 3.10+ (optional, for CMake builds)

## Contributing

We welcome contributions! Here's how you can help:

- Report bugs and issues
- Suggest new features or enhancements
- Submit pull requests with bug fixes or improvements
- Improve documentation
- Share performance tuning tips

## Support

- **Issues**: https://github.com/cfpandrade/bbcp/issues
- **Original Documentation**: http://www.slac.stanford.edu/~abh/bbcp
- **Stanford SLAC**: Original authors and maintainers

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

Original work Copyright (C) 2002-2012 by the Board of Trustees of the Leland Stanford, Jr., University.
