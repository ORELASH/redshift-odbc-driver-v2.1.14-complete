# Amazon Redshift ODBC Driver - Fork Ov2.1.13F1.0.0-BLL

**Version:** Ov2.1.13F1.0.0-BLL
**Release Date:** February 22, 2026
**Maintainer:** Orel Ashush
**Based On:** AWS Amazon Redshift ODBC Driver v2.1.13.0

---

## Overview

This is a **complete fork** of the official AWS Amazon Redshift ODBC Driver v2.1.13.0, including all 13 commits from the AWS release.

### Naming Convention

- **O** = Original AWS version (2.1.13)
- **F** = Fork version (1.0.0 - full release)
- **BLL** = Build suffix

---

## What's Included

This fork contains **ALL 13 improvements** from AWS v2.1.13.0:

### Platform & Build
1. ✅ macOS Build Compatibility Fix
2. ✅ Escape Clause Handling Enhancements

### ODBC Compliance
3. ✅ SQLGetTypeInfo ODBC Version Support
4. ✅ Descriptor Defaults Correction
5. ✅ Length Indicators for Non-String Types
6. ✅ Descriptor Error Messages (HY091, HY016)
7. ✅ SQL_DESC_CONCISE_TYPE Synchronization
8. ✅ SQLGetData Octet Length Fix

### Error Handling
9. ✅ Improved Error Handling across SQLGetData, SQLPutData, SQLExtendedFetch, SQLSetCursorName

### IAM & Authentication
10. ✅ IAMJwtPlugin Logging Enhancements
11. ✅ Region Prioritization for CNAME Connections
12. ✅ IdC Browser HTTPS Proxy Support

### Metadata
13. ✅ Version and Changelog Updates

---

## Statistics

- **Total Changes:** 5,008 lines added, 1,547 removed
- **Files Modified:** 30 files
- **Commits:** 13 from AWS v2.1.13.0

---

## Directory Structure

```
Ov2.1.13F1.0.0-BLL/
├── src/                 # Full AWS v2.1.13.0 source code
│   ├── LICENSE          # Apache 2.0 + Fork appendix
│   ├── version.txt      # Ov2.1.13F1.0.0-BLL
│   ├── odbc/            # ODBC driver implementation
│   ├── logging/         # Logging components
│   └── pgclient/        # PostgreSQL client library
├── docs/
│   ├── CHANGES.md       # Detailed changelog
│   └── TESTING.md       # Testing procedures
└── README.md            # This file
```

---

## Previous Incremental Builds

Before this full release, incremental builds were created:

- **Ov2.1.13F0.0.1-BLL** - Foundation fixes (3 changes)
- **Ov2.1.13F0.0.2-BLL** - ODBC compliance (3 changes)
- **Ov2.1.13F1.0.0-BLL** - Full AWS v2.1.13.0 (13 changes) ← **Current**

---

## Documentation

- **CHANGES.md** - Comprehensive changelog with all 13 modifications
- **TESTING.md** - Testing procedures for all changes
- **LICENSE** - Apache 2.0 with fork modifications appendix

---

## Compatibility

### Platforms
- ✅ Windows (x64)
- ✅ Linux (x64, ARM64)
- ✅ macOS (x86_64, ARM64)

### ODBC Versions
- ✅ ODBC 2.x
- ✅ ODBC 3.x

### AWS Redshift
- Redshift v1.0.40000+
- All authentication methods (IAM, Azure OAuth, etc.)

---

## Installation

Follow the same installation procedures as the official AWS driver:

**Windows:**
```cmd
msiexec /i AmazonRedshiftODBC64-2.1.13.msi
```

**Linux/macOS:**
```bash
tar -xzf AmazonRedshiftODBC-2.1.13.tar.gz
cd AmazonRedshiftODBC-2.1.13
sudo ./install.sh
```

---

## Testing

See `docs/TESTING.md` for comprehensive testing procedures.

**Quick Test:**
```bash
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make test
```

---

## Support

- **Fork Repository:** https://github.com/ORELASH/amazon-redshift-odbc-driver
- **Fork Maintainer:** ORELASH
- **Original AWS Repository:** https://github.com/aws/amazon-redshift-odbc-driver

---

## License

Apache License 2.0

See LICENSE file for full text and fork modifications appendix.

---

## Credits

**AWS Contributors:**
- Ruei-Yang Huang (all 13 commits from v2.1.13.0)

**Fork Maintainer:**
- Orel Ashush (ORELASH)

---

## Changelog Summary

### February 22, 2026 - Ov2.1.13F1.0.0-BLL

**Complete AWS v2.1.13.0 fork with all 13 improvements**

- macOS compilation support
- Full ODBC 2.x/3.x compliance
- Enhanced error handling
- IAM/Auth improvements
- Escape clause support
- Metadata API enhancements

See `docs/CHANGES.md` for detailed information.

---

**End of README**
