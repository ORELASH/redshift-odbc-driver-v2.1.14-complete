# Building Amazon Redshift ODBC Driver Ov2.1.13F1.0.0-BLL

**Version:** Ov2.1.13F1.0.0-BLL
**Release Date:** February 22, 2026
**Maintainer:** Orel Ashush

---

## Overview

This document provides instructions for building the Amazon Redshift ODBC Driver from source on all supported platforms.

---

## Prerequisites

### All Platforms
- Git
- CMake 3.15+
- C++ compiler with C++17 support
- AWS SDK C++

### Windows
- **Visual Studio 2019 or 2022** (Community, Professional, or Enterprise)
  - Desktop development with C++ workload
- **vcpkg** package manager
- **WiX Toolset 3.11+** (for MSI creation)
- **Windows 10 SDK** (included with Visual Studio)

### Linux
- **GCC 9+** or **Clang 12+**
- **CMake 3.15+**
- **unixODBC development libraries**
  ```bash
  # Ubuntu/Debian
  sudo apt-get install unixodbc-dev

  # RHEL/CentOS/Fedora
  sudo dnf install unixODBC-devel
  ```
- **AWS SDK C++**

### macOS
- **Xcode 12+** (Command Line Tools)
- **Clang 12+**
- **CMake 3.15+**
- **iODBC** or **unixODBC**
  ```bash
  brew install cmake
  brew install unixodbc
  ```
- **AWS SDK C++**

---

## Building on Windows (MSI Installer)

### Option 1: Using GitHub Actions (Recommended)

The easiest way to build the MSI is using GitHub Actions:

1. **Fork or clone the repository:**
   ```bash
   git clone https://github.com/ORELASH/amazon-redshift-odbc-driver.git
   cd amazon-redshift-odbc-driver
   git checkout Ov2.1.13F1.0.0-BLL
   ```

2. **Push to GitHub:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/amazon-redshift-odbc-driver.git
   git push -u origin Ov2.1.13F1.0.0-BLL
   ```

3. **Trigger workflow:**
   - Go to Actions tab on GitHub
   - Select "Build Amazon Redshift ODBC Driver MSI"
   - Click "Run workflow"
   - Download the MSI from the artifacts

### Option 2: Manual Build on Windows

#### Step 1: Install Prerequisites

1. **Install Visual Studio 2022:**
   - Download from https://visualstudio.microsoft.com/
   - Select "Desktop development with C++"

2. **Install vcpkg:**
   ```cmd
   cd C:\
   git clone https://github.com/Microsoft/vcpkg.git
   cd vcpkg
   .\bootstrap-vcpkg.bat
   ```

3. **Install AWS SDK C++:**
   ```cmd
   cd C:\vcpkg
   .\vcpkg install aws-sdk-cpp[core,redshift,sts,sso,identity-management]:x64-windows
   .\vcpkg integrate install
   ```

4. **Install WiX Toolset:**
   - Download from https://github.com/wixtoolset/wix3/releases
   - Install WiX v3.11 or later
   - Add to PATH: `C:\Program Files (x86)\WiX Toolset v3.11\bin`

#### Step 2: Build PostgreSQL Client Library

```cmd
cd src\pgclient
build64.bat
```

#### Step 3: Build ODBC Driver

```cmd
cd src\odbc\rsodbc
mkdir build
cd build

cmake .. -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake ^
  -DCMAKE_INSTALL_PREFIX=..\..\..\..\install

cmake --build . --config Release --parallel
cmake --install . --config Release
```

#### Step 4: Build MSI Installer

```cmd
cd ..\install
set VERSION=2.1.13.0
set PROJECT_DIR=..\..\..\..
set DEPENDENCIES_INSTALL_DIR=C:\vcpkg\installed\x64-windows
set RS_BUILD_TYPE=Release

call Make_x64.bat
```

**Output:** `AmazonRedshiftODBC64-2.1.13.0.msi`

---

## Building on Linux

### Step 1: Install Prerequisites

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake git \
  unixodbc-dev libssl-dev libcurl4-openssl-dev \
  uuid-dev libpq-dev
```

**RHEL/CentOS/Fedora:**
```bash
sudo dnf install -y gcc-c++ cmake git \
  unixODBC-devel openssl-devel libcurl-devel \
  libuuid-devel postgresql-devel
```

### Step 2: Install AWS SDK C++

```bash
cd /tmp
git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp
cd aws-sdk-cpp
mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_ONLY="core;redshift;sts;sso;identity-management" \
  -DENABLE_TESTING=OFF \
  -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install
```

### Step 3: Build Driver

```bash
cd /path/to/Ov2.1.13F1.0.0-BLL/src/odbc/rsodbc
mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local

make -j$(nproc)
sudo make install
```

**Output:** `/usr/local/lib/librsodbc.so`

### Step 4: Install Driver

```bash
# Create ODBC configuration
sudo odbcinst -i -d -f /path/to/odbcinst.ini
```

**Example odbcinst.ini:**
```ini
[Amazon Redshift (x64)]
Description=Amazon Redshift ODBC Driver (64-bit)
Driver=/usr/local/lib/librsodbc.so
Setup=/usr/local/lib/librsodbc.so
```

---

## Building on macOS

### Step 1: Install Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install cmake unixodbc openssl curl
```

### Step 2: Install AWS SDK C++

```bash
cd /tmp
git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp
cd aws-sdk-cpp
mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_ONLY="core;redshift;sts;sso;identity-management" \
  -DENABLE_TESTING=OFF \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0

make -j$(sysctl -n hw.ncpu)
sudo make install
```

### Step 3: Build Driver (ARM64)

```bash
cd /path/to/Ov2.1.13F1.0.0-BLL/src/odbc/rsodbc
mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0

make -j$(sysctl -n hw.ncpu)
sudo make install
```

**Output:** `/usr/local/lib/librsodbc.dylib`

### Step 4: Build Driver (x86_64 - Intel Macs)

```bash
cmake .. -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15

make -j$(sysctl -n hw.ncpu)
sudo make install
```

---

## Build Verification

### Windows

```cmd
# Check DLL
dir install\bin\rsodbc64.dll

# Check MSI
dir src\odbc\rsodbc\install\AmazonRedshiftODBC64-*.msi
```

### Linux/macOS

```bash
# Check library
ls -l /usr/local/lib/librsodbc.*

# Test with odbcinst
odbcinst -q -d
```

---

## CMake Build Options

| Option | Description | Default |
|--------|-------------|---------|
| CMAKE_BUILD_TYPE | Build type (Debug, Release, RelWithDebInfo) | Release |
| CMAKE_INSTALL_PREFIX | Installation directory | /usr/local (Linux/macOS), C:\Program Files (Windows) |
| BUILD_TESTING | Build unit tests | OFF |
| CMAKE_OSX_ARCHITECTURES | macOS architecture (arm64, x86_64) | Native |

**Example:**
```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
```

---

## Troubleshooting

### Windows

**Issue:** `vcpkg not found`
- **Solution:** Install vcpkg and run `vcpkg integrate install`

**Issue:** `WiX candle/light not found`
- **Solution:** Install WiX Toolset and add to PATH

**Issue:** `AWS SDK not found`
- **Solution:** Install via vcpkg: `vcpkg install aws-sdk-cpp:x64-windows`

### Linux

**Issue:** `unixODBC headers not found`
- **Solution:** Install unixodbc-dev package

**Issue:** `AWS SDK not found`
- **Solution:** Build and install AWS SDK from source

### macOS

**Issue:** `std::string and snprintf() error`
- **Solution:** This is fixed in v2.1.13 (uses `.c_str()`)

**Issue:** `ARM64 build fails on Intel Mac`
- **Solution:** Use `CMAKE_OSX_ARCHITECTURES=x86_64` for Intel Macs

---

## Clean Build

### Windows
```cmd
cd src\odbc\rsodbc\build
rmdir /s /q *
```

### Linux/macOS
```bash
cd src/odbc/rsodbc/build
rm -rf *
```

---

## GitHub Actions (Automated Build)

The project includes GitHub Actions workflow for automated MSI building:

**File:** `.github/workflows/build-msi.yml`

**Triggers:**
- Push to main/master/Ov2.1.13F1.0.0-BLL branches
- Pull requests
- Manual workflow dispatch
- Git tags (creates GitHub release)

**Outputs:**
- MSI installer artifact
- SHA256 checksum
- GitHub release (for tags)

---

## Development Build

For development and testing, build in Debug mode:

```bash
cmake .. -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTING=ON
make -j$(nproc)
make test
```

---

## Support

- **Fork Repository:** https://github.com/ORELASH/amazon-redshift-odbc-driver
- **Fork Maintainer:** Orel Ashush (ORELASH)
- **Original AWS Repository:** https://github.com/aws/amazon-redshift-odbc-driver

---

**End of Build Instructions**
