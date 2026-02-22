# Amazon Redshift ODBC Driver Ov2.1.13F1.0.0-BLL - Complete Changelog

**Version:** Ov2.1.13F1.0.0-BLL  
**Release Date:** February 22, 2026  
**Maintainer:** Orel Ashush  
**Base Version:** AWS Amazon Redshift ODBC Driver v2.1.13.0 (Complete)

---

## Overview

Ov2.1.13F1.0.0-BLL is a **complete fork** of AWS Amazon Redshift ODBC Driver v2.1.13.0, incorporating ALL 13 commits from the official AWS release.

This release includes comprehensive improvements across:
- Platform compatibility (macOS)
- ODBC 2.x/3.x specification compliance  
- Error handling and reporting
- IAM authentication and proxy support
- Metadata API enhancements
- Escape clause handling

**Priority:** HIGH - Complete production-ready release

---

## Statistics

| Metric | Value |
|--------|-------|
| Total Commits | 13 |
| Files Modified | 30 |
| Lines Added | 5,008 |
| Lines Removed | 1,547 |
| Net Change | +3,461 lines |

---

## Changes Summary

| # | Description | Commit | Files | Priority |
|---|-------------|--------|-------|----------|
| 1 | macOS Build Compatibility | 19d5dd4 | 1 | CRITICAL |
| 2 | SQLGetTypeInfo ODBC Version | 9232564 | 8 | HIGH |
| 3 | IAMJwtPlugin Logging | 32dff2c | 2 | MEDIUM |
| 4 | Escape Clause Handling | a3c6e1d | 3 | HIGH |
| 5 | Descriptor Defaults | bcbd0ca | 1 | HIGH |
| 6 | Length Indicators | 7acd742 | 1 | MEDIUM |
| 7 | Descriptor Error Messages | 6e866fc | 1 | MEDIUM |
| 8 | Error Handling Improvements | da7a9cd | 6 | HIGH |
| 9 | SQL_DESC_CONCISE_TYPE | 2a66dfe | 1 | HIGH |
| 10 | SQLGetData Octet Length | a618af9 | 1 | HIGH |
| 11 | Region Prioritization CNAME | 3247ea3 | 2 | MEDIUM |
| 12 | IdC Browser HTTPS Proxy | d044f1a | 2 | HIGH |
| 13 | Changelog/Version Update | 7a30848 | 2 | LOW |

---

## Detailed Changes

### Change #1: macOS Build Compatibility Fix

**Commit:** 19d5dd4  
**Date:** February 9, 2026  
**Author:** Ruei-Yang Huang  
**Priority:** CRITICAL

#### Problem
Driver failed to compile on macOS (ARM64 and x86_64) due to incompatible std::string usage with snprintf().

#### Solution
Convert std::string to C-string using `.c_str()` method.

#### Files Modified
- `src/odbc/rsodbc/rscatalog.cpp` (5 locations)

#### Impact
- ✅ macOS ARM64/x86_64 compilation support
- ✅ Cross-platform compatibility
- ✅ No functional changes to Windows/Linux

---

### Change #2: SQLGetTypeInfo ODBC Version Support

**Commit:** 9232564  
**Date:** February 9, 2026  
**Priority:** HIGH

#### Problem
SQLGetTypeInfo returned column names inconsistent with application's ODBC version,
causing compatibility issues between ODBC 2.x and 3.x applications.

#### Solution
Dynamically adjust column names based on SQL_ATTR_ODBC_VERSION environment attribute.

#### Files Modified (8 files, 360+ lines)
- rsMetadataAPIHelper.cpp/h
- rsMetadataAPIPostProcessor.cpp/h
- rscatalog.cpp/h
- rslibpq.c
- rsodbc.h

#### Impact
- ✅ ODBC 2.x/3.x compatibility
- ✅ Correct column naming per version
- ✅ Standards compliance

---

### Change #3: IAMJwtPlugin Logging Enhancements

**Commit:** 32dff2c  
**Date:** February 9, 2026  
**Priority:** MEDIUM

#### Problem
Insufficient logging in IAMJwtPluginCredentialsProvider made troubleshooting difficult.

#### Solution
Enhanced logging for JWT token operations and credential provider lifecycle.

#### Files Modified
- IAMJwtPluginCredentialsProvider implementation files

#### Impact
- ✅ Better troubleshooting
- ✅ Improved debugging
- ✅ No performance impact

---

### Change #4: Escape Clause Handling

**Commit:** a3c6e1d  
**Date:** February 9, 2026  
**Priority:** HIGH

#### Problem
Gaps in escape clause implementation - missing ODBC scalar functions and date/time literals.

#### Solution
Comprehensive escape clause parser with full scalar function support.

#### Files Modified (3 files, major changes)
- Escape clause parser implementation
- unittest/odbcescapeclause_test.cpp (2,401 lines added)

#### Impact
- ✅ Full ODBC escape clause support
- ✅ All standard scalar functions
- ✅ Enhanced SQL compatibility

---

### Change #5: Descriptor Defaults Correction

**Commit:** bcbd0ca  
**Date:** February 9, 2026  
**Priority:** HIGH

#### Problem
Descriptor records not initialized with ODBC-compliant defaults.

#### Solution
Initialize ARD/APD/IRD/IPD fields per ODBC specification.

#### Files Modified
- `src/odbc/rsodbc/rsutil.c` (18 lines in checkAndAddDescRec)

#### Impact
- ✅ ODBC specification compliance
- ✅ Proper descriptor initialization
- ✅ Fixed edge cases

---

### Change #6: Length Indicators for Non-String Types

**Commit:** 7acd742  
**Date:** February 9, 2026  
**Priority:** MEDIUM

#### Problem
Length indicators (pcbLen) not set for non-string descriptor fields.

#### Solution
Add else block in SQLGetDescFieldW to propagate length for non-string types.

#### Files Modified
- `src/odbc/rsodbc/rsdesc.cpp` (6 lines)

#### Impact
- ✅ ODBC 3.x compliance
- ✅ Correct length reporting
- ✅ Application compatibility

---

### Change #7: Descriptor Error Messages

**Commit:** 6e866fc  
**Date:** February 9, 2026  
**Priority:** MEDIUM

#### Problem
Generic error codes (HY000) instead of ODBC-specified codes for descriptor errors.

#### Solution
Use HY091 for invalid fields, HY016 for read-only descriptors.

#### Files Modified
- `src/odbc/rsodbc/rsdesc.cpp` (2 error messages)

#### Impact
- ✅ ODBC-compliant error codes
- ✅ Better error handling
- ✅ Improved diagnostics

---

### Change #8: Error Handling Improvements

**Commit:** da7a9cd  
**Date:** February 9, 2026  
**Priority:** HIGH

#### Problem
Inconsistent error handling in SQLGetData, SQLPutData, SQLExtendedFetch, SQLSetCursorName.

#### Solution
Enhanced error detection, validation, and SQLSTATE reporting across all APIs.

#### Files Modified (6 files, 127+ lines)
- rsexecute.cpp (59 lines added)
- rsprepare.cpp
- rsresult.cpp
- rsodbc.h
- rsodbc_test.def
- unittest/rsresult_test.cpp

#### Impact
- ✅ Robust error handling
- ✅ Consistent SQLSTATE codes
- ✅ Better application compatibility

---

### Change #9: SQL_DESC_CONCISE_TYPE Synchronization

**Commit:** 2a66dfe  
**Date:** February 9, 2026  
**Priority:** HIGH

#### Problem
getCTypeFromConciseType didn't handle SQL_C_DEFAULT correctly.

#### Solution
Add SQL_C_DEFAULT check in type conversion logic.

#### Files Modified
- `src/odbc/rsodbc/rsutil.c` (1 line in getCTypeFromConciseType)

#### Impact
- ✅ Proper SQL_C_DEFAULT handling
- ✅ ODBC 3.x compliance
- ✅ Type conversion fixes

---

### Change #10: SQLGetData Octet Length Fix

**Commit:** a618af9  
**Date:** February 9, 2026  
**Priority:** HIGH

#### Problem
Incorrect buffer size calculation for SQL_NUMERIC types (added unnecessary 2 bytes).

#### Solution
Use sizeof(SQL_NUMERIC_STRUCT) directly.

#### Files Modified
- `src/odbc/rsodbc/rsutil.c` (2 locations in getOctetLenUsingCType)

#### Impact
- ✅ Prevents buffer overflows
- ✅ Correct memory allocation
- ✅ Data integrity

---

### Change #11: Region Prioritization for CNAME

**Commit:** 3247ea3  
**Date:** February 10, 2026  
**Priority:** MEDIUM

#### Problem
DNS lookup for CNAME connections didn't respect configured region, causing IAM auth failures.

#### Solution
Prioritize configured region over DNS-based region detection.

#### Files Modified
- IAM authentication region resolution logic

#### Impact
- ✅ Reliable CNAME connections
- ✅ Correct region selection
- ✅ IAM auth stability

---

### Change #12: IdC Browser HTTPS Proxy Support

**Commit:** d044f1a  
**Date:** February 10, 2026  
**Priority:** HIGH

#### Problem
IdC Browser authentication ignored HTTPS proxy settings, failing behind corporate firewalls.

#### Solution
Respect configured HTTPS_PROXY environment variable and driver settings.

#### Files Modified
- IdC Browser authentication plugin
- unittest/browser_idc_auth_test.cpp

#### Impact
- ✅ Corporate proxy support
- ✅ IdC authentication behind firewalls
- ✅ Enterprise compatibility

---

### Change #13: Changelog and Version Update

**Commit:** 7a30848  
**Date:** February 10, 2026  
**Priority:** LOW

#### Files Modified
- CHANGELOG.md
- version.txt

#### Impact
- ✅ Version tracking
- ✅ Release documentation

---

## Compatibility

### Platforms
- ✅ Windows (x64)
- ✅ Linux (x64, ARM64)
- ✅ macOS (x86_64, ARM64) - **FIXED**

### ODBC Compliance
- ✅ ODBC 2.x specification
- ✅ ODBC 3.x specification
- ✅ All standard escape clauses
- ✅ All descriptor operations
- ✅ Error code standards

### Backward Compatibility
- ✅ Fully compatible with v2.1.12
- ✅ No breaking changes
- ✅ Enhanced functionality only

---

## Migration from v2.1.12

**Recommended:** YES - Comprehensive improvements and bug fixes

**Breaking Changes:** NONE

**Steps:**
1. Replace existing driver DLL/SO/dylib with v2.1.13
2. No configuration changes required
3. Existing connections continue to work

**Applications may benefit from:**
- macOS platform support
- Better ODBC 2.x/3.x compatibility
- Improved error messages
- HTTPS proxy support for IdC auth
- Full escape clause support

---

## Testing Notes

See `TESTING.md` for comprehensive testing procedures.

**Critical Test Areas:**
- macOS compilation (ARM64, x86_64)
- ODBC 2.x/3.x version switching
- Escape clause parsing
- Descriptor operations
- Error handling edge cases
- IAM authentication with CNAME
- IdC authentication behind proxy
- Numeric data type handling

---

## Known Issues

None identified. All 13 commits are well-tested from AWS official release.

---

## Build Information

**Version:** Ov2.1.13F1.0.0-BLL  
**Build Date:** February 22, 2026  
**Compiler:** MSVC 2019+ (Windows), GCC 9+ (Linux), Clang 12+ (macOS)  
**Dependencies:** vcpkg, AWS SDK C++

---

## Credits

**AWS Contributors:**
- Ruei-Yang Huang (all 13 commits)

**Fork Maintainer:**
- Orel Ashush (ORELASH)

---

## References

- AWS Official Repository: https://github.com/aws/amazon-redshift-odbc-driver
- Fork Repository: https://github.com/ORELASH/amazon-redshift-odbc-driver
- ODBC Specification: https://docs.microsoft.com/en-us/sql/odbc/
- AWS Redshift Documentation: https://docs.aws.amazon.com/redshift/

---

**End of Changelog**
