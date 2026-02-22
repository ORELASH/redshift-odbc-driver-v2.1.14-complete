# Amazon Redshift ODBC Driver Ov2.1.13F1.0.0-BLL - Testing Guide

**Version:** Ov2.1.13F1.0.0-BLL
**Release Date:** February 22, 2026
**Maintainer:** Orel Ashush
**Testing Priority:** HIGH - Complete production release

---

## Overview

This document provides comprehensive testing procedures for Ov2.1.13F1.0.0-BLL. This release contains **ALL 13 improvements** from AWS v2.1.13.0 that must be validated before production deployment.

**Test Focus Areas:**
1. ✅ macOS Build Compilation (Change #1)
2. ✅ SQLGetTypeInfo ODBC Version Support (Change #2)
3. ✅ IAMJwtPlugin Logging (Change #3)
4. ✅ Escape Clause Handling (Change #4)
5. ✅ Descriptor Defaults (Change #5)
6. ✅ Length Indicators (Change #6)
7. ✅ Descriptor Error Messages (Change #7)
8. ✅ Error Handling Improvements (Change #8)
9. ✅ SQL_DESC_CONCISE_TYPE (Change #9)
10. ✅ SQLGetData Octet Length (Change #10)
11. ✅ Region Prioritization CNAME (Change #11)
12. ✅ IdC Browser HTTPS Proxy (Change #12)
13. ✅ Version/Changelog Update (Change #13)

---

## Prerequisites

### Build Environment

**Windows:**
- Visual Studio 2019 or 2022
- vcpkg package manager
- AWS SDK C++
- WiX Toolset (for MSI creation)

**Linux:**
- GCC 9+ or Clang 12+
- CMake 3.15+
- AWS SDK C++
- unixODBC development libraries

**macOS:**
- Xcode 12+ (Command Line Tools)
- Clang 12+
- CMake 3.15+
- AWS SDK C++
- iODBC or unixODBC

### Test Database
- Amazon Redshift cluster (v1.0.40000+)
- Test credentials with sufficient permissions
- Sample tables with various data types

### ODBC Test Tools
- SQL Workbench/J
- DBeaver
- isql/iusql (Linux/macOS)
- Microsoft ODBC Test (Windows)

---

## Test Suite

### Test 1: Build Compilation (CRITICAL - Change #1)

**Objective:** Verify successful compilation on all platforms, especially macOS.

#### Test 1.1: macOS ARM64 Build

**Platform:** macOS (Apple Silicon M1/M2/M3)

**Steps:**
```bash
cd /path/to/Ov2.1.13F1.0.0-BLL/src
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_OSX_ARCHITECTURES=arm64 \
         -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
make -j$(sysctl -n hw.ncpu)
```

**Expected Result:**
- ✅ Compilation completes without errors
- ✅ No warnings about `std::string` and `snprintf()`
- ✅ Driver library created: `librsodbc.dylib`

**Pass Criteria:**
- Exit code 0
- No compilation errors in rscatalog.cpp
- Library file size > 5MB

---

#### Test 1.2: macOS x86_64 Build

**Platform:** macOS (Intel)

**Steps:**
```bash
cd /path/to/Ov2.1.13F1.0.0-BLL/src
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_OSX_ARCHITECTURES=x86_64 \
         -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15
make -j$(sysctl -n hw.ncpu)
```

**Expected Result:**
- ✅ Compilation completes without errors
- ✅ Driver library created: `librsodbc.dylib`

---

#### Test 1.3: Windows x64 Build

**Platform:** Windows 10/11 (64-bit)

**Steps:**
```cmd
cd \path\to\Ov2.1.13F1.0.0-BLL\src
build64.bat
```

**Expected Result:**
- ✅ Compilation completes without errors
- ✅ MSI installer created
- ✅ Driver DLL created: `rsodbc64.dll`

---

#### Test 1.4: Linux x64 Build

**Platform:** Ubuntu 20.04+ / RHEL 8+

**Steps:**
```bash
cd /path/to/Ov2.1.13F1.0.0-BLL/src
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

**Expected Result:**
- ✅ Compilation completes without errors
- ✅ Driver library created: `librsodbc.so`

---

### Test 2: SQLGetTypeInfo ODBC Version Support (HIGH - Change #2)

**Objective:** Verify column names change based on ODBC version.

#### Test 2.1: ODBC 2.x Column Names

**Test Code:**
```c
#include <sql.h>
#include <sqlext.h>
#include <stdio.h>

void test_odbc2_type_info() {
    SQLHENV henv;
    SQLHDBC hdbc;
    SQLHSTMT hstmt;
    SQLCHAR colName[128];
    SQLSMALLINT nameLen;

    // Allocate handles
    SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
    SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC2, 0);
    SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);

    // Connect
    SQLConnect(hdbc, (SQLCHAR*)"your_dsn", SQL_NTS,
               (SQLCHAR*)"username", SQL_NTS,
               (SQLCHAR*)"password", SQL_NTS);

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    // Execute SQLGetTypeInfo
    SQLGetTypeInfo(hstmt, SQL_ALL_TYPES);

    // Check column 2 name (should be DATA_TYPE for ODBC 2.x)
    SQLColAttribute(hstmt, 2, SQL_DESC_NAME, colName, sizeof(colName), &nameLen, NULL);

    if (strcmp((char*)colName, "DATA_TYPE") == 0) {
        printf("✅ ODBC 2.x: Column 2 is 'DATA_TYPE'\n");
    } else {
        printf("❌ FAIL: Column 2 is '%s' (expected DATA_TYPE)\n", colName);
    }

    // Cleanup
    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
    SQLDisconnect(hdbc);
    SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle(SQL_HANDLE_ENV, henv);
}
```

**Expected Result:**
- ✅ Column 2 name is "DATA_TYPE" (ODBC 2.x)
- ✅ Column 7 name is "PRECISION" (not COLUMN_SIZE)

---

#### Test 2.2: ODBC 3.x Column Names

**Test Code:**
```c
void test_odbc3_type_info() {
    SQLHENV henv;
    SQLHDBC hdbc;
    SQLHSTMT hstmt;
    SQLCHAR colName[128];
    SQLSMALLINT nameLen;

    // Allocate handles
    SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
    SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0);
    SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);

    // Connect
    SQLConnect(hdbc, (SQLCHAR*)"your_dsn", SQL_NTS,
               (SQLCHAR*)"username", SQL_NTS,
               (SQLCHAR*)"password", SQL_NTS);

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    // Execute SQLGetTypeInfo
    SQLGetTypeInfo(hstmt, SQL_ALL_TYPES);

    // Check column 2 name (should be DATA_TYPE for ODBC 3.x)
    SQLColAttribute(hstmt, 2, SQL_DESC_NAME, colName, sizeof(colName), &nameLen, NULL);

    if (strcmp((char*)colName, "DATA_TYPE") == 0) {
        printf("✅ ODBC 3.x: Column 2 is 'DATA_TYPE'\n");
    } else {
        printf("❌ FAIL: Column 2 is '%s' (expected DATA_TYPE)\n", colName);
    }

    // Check column 3 name (should be COLUMN_SIZE for ODBC 3.x)
    SQLColAttribute(hstmt, 3, SQL_DESC_NAME, colName, sizeof(colName), &nameLen, NULL);

    if (strcmp((char*)colName, "COLUMN_SIZE") == 0) {
        printf("✅ ODBC 3.x: Column 3 is 'COLUMN_SIZE'\n");
    } else {
        printf("❌ FAIL: Column 3 is '%s' (expected COLUMN_SIZE)\n", colName);
    }

    // Cleanup
    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
    SQLDisconnect(hdbc);
    SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle(SQL_HANDLE_ENV, henv);
}
```

**Expected Result:**
- ✅ Column 2 name is "DATA_TYPE"
- ✅ Column 3 name is "COLUMN_SIZE" (not PRECISION)

---

### Test 3: IAMJwtPlugin Logging (MEDIUM - Change #3)

**Objective:** Verify enhanced logging in JWT authentication.

**Setup:**
1. Enable driver logging
2. Configure JWT authentication
3. Attempt connection

**Connection String:**
```
Driver={Amazon Redshift (x64)};
Server=your-cluster.redshift.amazonaws.com;
Port=5439;
Database=dev;
Plugin_Name=com.amazon.redshift.plugin.IAMJwtPlugin;
JWT_Token=your-jwt-token;
LogLevel=4;
LogPath=/tmp/redshift_odbc.log;
```

**Test:**
1. Initiate connection
2. Check log file for JWT-specific messages

**Expected Result:**
- ✅ Log contains "IAMJwtPluginCredentialsProvider" entries
- ✅ Log shows JWT token lifecycle events
- ✅ Connection succeeds or fails with detailed error

**Pass Criteria:**
- Enhanced logging present (more detailed than v2.1.12)
- No sensitive token data in logs

---

### Test 4: Escape Clause Handling (HIGH - Change #4)

**Objective:** Verify comprehensive escape clause parser.

#### Test 4.1: Scalar Functions

**Test Queries:**
```sql
-- String functions
SELECT {fn CONCAT('Hello', 'World')} AS result;
SELECT {fn UCASE('hello')} AS result;
SELECT {fn LCASE('HELLO')} AS result;
SELECT {fn LENGTH('test')} AS result;

-- Numeric functions
SELECT {fn ABS(-5)} AS result;
SELECT {fn CEILING(4.3)} AS result;
SELECT {fn FLOOR(4.7)} AS result;
SELECT {fn ROUND(4.567, 2)} AS result;

-- Date/Time functions
SELECT {fn CURDATE()} AS result;
SELECT {fn CURTIME()} AS result;
SELECT {fn NOW()} AS result;
SELECT {fn YEAR(CURRENT_DATE)} AS result;
```

**Expected Result:**
- ✅ All queries execute successfully
- ✅ Correct results returned
- ✅ No parse errors

---

#### Test 4.2: Date/Time Literals

**Test Queries:**
```sql
SELECT {d '2026-02-22'} AS date_literal;
SELECT {t '14:30:00'} AS time_literal;
SELECT {ts '2026-02-22 14:30:00'} AS timestamp_literal;
```

**Expected Result:**
- ✅ All literals parsed correctly
- ✅ Correct data types returned
- ✅ Values match input

---

#### Test 4.3: Outer Join Escape

**Test Query:**
```sql
SELECT * FROM {oj table1 LEFT OUTER JOIN table2 ON table1.id = table2.id};
```

**Expected Result:**
- ✅ Query executes successfully
- ✅ Proper LEFT OUTER JOIN semantics

---

### Test 5: Descriptor Defaults (HIGH - Change #5)

**Objective:** Verify descriptor records initialized with ODBC-compliant defaults.

#### Test 5.1: ARD Initialization

**Test Code:**
```c
void test_ard_initialization() {
    SQLHDESC hdesc;
    SQLHSTMT hstmt;
    SQLSMALLINT descType;
    SQLSMALLINT conciseType;
    SQLSMALLINT datetimeCode;

    // Allocate statement
    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    // Get ARD
    SQLGetStmtAttr(hstmt, SQL_ATTR_APP_ROW_DESC, &hdesc, 0, NULL);

    // Bind a column to trigger descriptor allocation
    SQLINTEGER buffer;
    SQLBindCol(hstmt, 1, SQL_C_DEFAULT, &buffer, sizeof(buffer), NULL);

    // Get descriptor fields
    SQLGetDescField(hdesc, 1, SQL_DESC_TYPE, &descType, sizeof(descType), NULL);
    SQLGetDescField(hdesc, 1, SQL_DESC_CONCISE_TYPE, &conciseType, sizeof(conciseType), NULL);
    SQLGetDescField(hdesc, 1, SQL_DESC_DATETIME_INTERVAL_CODE, &datetimeCode, sizeof(datetimeCode), NULL);

    // Verify defaults
    if (descType == SQL_C_DEFAULT) {
        printf("✅ ARD TYPE = SQL_C_DEFAULT\n");
    } else {
        printf("❌ FAIL: ARD TYPE = %d (expected %d)\n", descType, SQL_C_DEFAULT);
    }

    if (conciseType == SQL_C_DEFAULT) {
        printf("✅ ARD CONCISE_TYPE = SQL_C_DEFAULT\n");
    } else {
        printf("❌ FAIL: ARD CONCISE_TYPE = %d (expected %d)\n", conciseType, SQL_C_DEFAULT);
    }

    if (datetimeCode == 0) {
        printf("✅ ARD DATETIME_INTERVAL_CODE = 0\n");
    } else {
        printf("❌ FAIL: ARD DATETIME_INTERVAL_CODE = %d (expected 0)\n", datetimeCode);
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ TYPE == SQL_C_DEFAULT
- ✅ CONCISE_TYPE == SQL_C_DEFAULT
- ✅ DATETIME_INTERVAL_CODE == 0

---

#### Test 5.2: IPD Initialization

**Test Code:**
```c
void test_ipd_initialization() {
    SQLHDESC hdesc;
    SQLHSTMT hstmt;
    SQLSMALLINT paramType;

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    // Get IPD
    SQLGetStmtAttr(hstmt, SQL_ATTR_IMP_PARAM_DESC, &hdesc, 0, NULL);

    // Prepare a statement with parameters
    SQLPrepare(hstmt, (SQLCHAR*)"SELECT * FROM table WHERE id = ?", SQL_NTS);

    // Get parameter type
    SQLGetDescField(hdesc, 1, SQL_DESC_PARAMETER_TYPE, &paramType, sizeof(paramType), NULL);

    if (paramType == SQL_PARAM_INPUT) {
        printf("✅ IPD PARAMETER_TYPE = SQL_PARAM_INPUT\n");
    } else {
        printf("❌ FAIL: IPD PARAMETER_TYPE = %d (expected %d)\n", paramType, SQL_PARAM_INPUT);
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ PARAMETER_TYPE == SQL_PARAM_INPUT

---

### Test 6: Length Indicators (MEDIUM - Change #6)

**Objective:** Verify length indicators set for non-string descriptor fields.

**Test Code:**
```c
void test_length_indicators() {
    SQLHDESC hdesc;
    SQLHSTMT hstmt;
    SQLINTEGER typeValue;
    SQLLEN indicator = -1;

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
    SQLGetStmtAttr(hstmt, SQL_ATTR_APP_ROW_DESC, &hdesc, 0, NULL);

    // Get a non-string field with length indicator
    SQLRETURN ret = SQLGetDescFieldW(hdesc, 1, SQL_DESC_TYPE, &typeValue, sizeof(typeValue), &indicator);

    if (ret == SQL_SUCCESS && indicator > 0) {
        printf("✅ Length indicator set: %lld bytes\n", indicator);
    } else {
        printf("❌ FAIL: Length indicator not set (indicator=%lld)\n", indicator);
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ indicator > 0
- ✅ indicator reflects actual size of field

---

### Test 7: Descriptor Error Messages (MEDIUM - Change #7)

**Objective:** Verify correct SQLSTATE codes for descriptor errors.

#### Test 7.1: Invalid Field Identifier

**Test Code:**
```c
void test_invalid_field() {
    SQLHDESC hdesc;
    SQLHSTMT hstmt;
    SQLINTEGER value;
    SQLCHAR sqlstate[6];
    SQLCHAR message[256];
    SQLSMALLINT msgLen;
    SQLINTEGER nativeError;

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
    SQLGetStmtAttr(hstmt, SQL_ATTR_APP_ROW_DESC, &hdesc, 0, NULL);

    // Try to get invalid field (9999)
    SQLRETURN ret = SQLGetDescField(hdesc, 1, 9999, &value, sizeof(value), NULL);

    if (ret == SQL_ERROR) {
        SQLGetDiagRec(SQL_HANDLE_DESC, hdesc, 1, sqlstate, &nativeError, message, sizeof(message), &msgLen);

        if (strcmp((char*)sqlstate, "HY091") == 0) {
            printf("✅ Invalid field error: SQLSTATE = HY091\n");
        } else {
            printf("❌ FAIL: SQLSTATE = %s (expected HY091)\n", sqlstate);
        }
    } else {
        printf("❌ FAIL: No error for invalid field\n");
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ SQLSTATE == "HY091"
- ✅ Message contains "Invalid descriptor field identifier"

---

#### Test 7.2: Read-Only Descriptor

**Test Code:**
```c
void test_readonly_descriptor() {
    SQLHDESC hdesc;
    SQLHSTMT hstmt;
    SQLCHAR sqlstate[6];

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    // Get IRD (read-only)
    SQLGetStmtAttr(hstmt, SQL_ATTR_IMP_ROW_DESC, &hdesc, 0, NULL);

    // Try to set a field (should fail)
    SQLRETURN ret = SQLSetDescField(hdesc, 1, SQL_DESC_TYPE, (SQLPOINTER)SQL_INTEGER, 0);

    if (ret == SQL_ERROR) {
        SQLGetDiagRec(SQL_HANDLE_DESC, hdesc, 1, sqlstate, NULL, NULL, 0, NULL);

        if (strcmp((char*)sqlstate, "HY016") == 0) {
            printf("✅ Read-only descriptor error: SQLSTATE = HY016\n");
        } else {
            printf("❌ FAIL: SQLSTATE = %s (expected HY016)\n", sqlstate);
        }
    } else {
        printf("❌ FAIL: No error for read-only descriptor modification\n");
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ SQLSTATE == "HY016"
- ✅ Message contains "Cannot modify an implementation row descriptor"

---

### Test 8: Error Handling Improvements (HIGH - Change #8)

**Objective:** Verify enhanced error detection in SQLGetData, SQLPutData, SQLExtendedFetch, SQLSetCursorName.

#### Test 8.1: SQLGetData Error Handling

**Test Code:**
```c
void test_sqlgetdata_errors() {
    SQLHSTMT hstmt;
    SQLCHAR buffer[100];
    SQLLEN indicator;
    SQLCHAR sqlstate[6];

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
    SQLExecDirect(hstmt, (SQLCHAR*)"SELECT id FROM test_table", SQL_NTS);
    SQLFetch(hstmt);

    // Test 1: Invalid column number
    SQLRETURN ret = SQLGetData(hstmt, 999, SQL_C_CHAR, buffer, sizeof(buffer), &indicator);
    if (ret == SQL_ERROR) {
        SQLGetDiagRec(SQL_HANDLE_STMT, hstmt, 1, sqlstate, NULL, NULL, 0, NULL);
        printf("✅ Invalid column: SQLSTATE = %s\n", sqlstate);
    }

    // Test 2: NULL buffer with non-zero length
    ret = SQLGetData(hstmt, 1, SQL_C_CHAR, NULL, 100, &indicator);
    if (ret == SQL_ERROR) {
        SQLGetDiagRec(SQL_HANDLE_STMT, hstmt, 1, sqlstate, NULL, NULL, 0, NULL);
        printf("✅ NULL buffer error: SQLSTATE = %s\n", sqlstate);
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ Proper SQLSTATE codes for all error conditions
- ✅ Detailed error messages
- ✅ Consistent error handling

---

### Test 9: SQL_DESC_CONCISE_TYPE (HIGH - Change #9)

**Objective:** Verify SQL_C_DEFAULT handling in type conversion.

**Test Code:**
```c
void test_sql_c_default() {
    SQLHSTMT hstmt;
    SQLINTEGER buffer;
    SQLLEN indicator;

    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

    // Bind with SQL_C_DEFAULT
    SQLBindCol(hstmt, 1, SQL_C_DEFAULT, &buffer, sizeof(buffer), &indicator);

    // Execute query
    SQLExecDirect(hstmt, (SQLCHAR*)"SELECT 12345", SQL_NTS);

    // Fetch data
    SQLRETURN ret = SQLFetch(hstmt);

    if (ret == SQL_SUCCESS) {
        printf("✅ SQL_C_DEFAULT binding successful, value = %d\n", buffer);
    } else {
        printf("❌ FAIL: SQL_C_DEFAULT binding failed\n");
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ Fetch succeeds with SQL_C_DEFAULT
- ✅ Data converted to appropriate C type
- ✅ No type conversion errors

---

### Test 10: SQLGetData Octet Length (HIGH - Change #10)

**Objective:** Verify correct buffer size for SQL_NUMERIC types.

**Test Code:**
```c
void test_numeric_octet_length() {
    SQLHSTMT hstmt;
    SQL_NUMERIC_STRUCT numericValue;
    SQLLEN indicator;

    // Create test table
    SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
    SQLExecDirect(hstmt, (SQLCHAR*)"CREATE TEMP TABLE test_numeric (val NUMERIC(38,10))", SQL_NTS);
    SQLExecDirect(hstmt, (SQLCHAR*)"INSERT INTO test_numeric VALUES (12345678901234567890.1234567890)", SQL_NTS);

    // Query
    SQLExecDirect(hstmt, (SQLCHAR*)"SELECT val FROM test_numeric", SQL_NTS);

    // Bind as SQL_C_NUMERIC
    SQLBindCol(hstmt, 1, SQL_C_NUMERIC, &numericValue, sizeof(SQL_NUMERIC_STRUCT), &indicator);

    // Fetch
    if (SQLFetch(hstmt) == SQL_SUCCESS) {
        if (indicator == sizeof(SQL_NUMERIC_STRUCT)) {
            printf("✅ Correct buffer size: %lld bytes (expected %zu bytes)\n",
                   indicator, sizeof(SQL_NUMERIC_STRUCT));
        } else {
            printf("❌ FAIL: Buffer size = %lld bytes (expected %zu bytes)\n",
                   indicator, sizeof(SQL_NUMERIC_STRUCT));
        }
    } else {
        printf("❌ FAIL: Fetch failed\n");
    }

    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
}
```

**Expected Result:**
- ✅ indicator == sizeof(SQL_NUMERIC_STRUCT) (19 bytes)
- ✅ No buffer overflow
- ✅ Correct numeric value retrieved

**Pass Criteria:**
- Buffer size exactly 19 bytes (not 21)
- No memory corruption

---

### Test 11: Region Prioritization for CNAME (MEDIUM - Change #11)

**Objective:** Verify configured region takes precedence over DNS-based detection.

**Setup:**
```
Driver={Amazon Redshift (x64)};
Server=custom-cname.example.com;
Port=5439;
Database=dev;
Region=us-west-2;
AuthMethod=IAMCredentials;
AccessKeyID=your-access-key;
SecretAccessKey=your-secret-key;
```

**Test:**
1. Connect using CNAME with explicit Region
2. Monitor logs for region selection
3. Verify IAM authentication succeeds

**Expected Result:**
- ✅ Driver uses configured region (us-west-2)
- ✅ IAM authentication succeeds
- ✅ No DNS region lookup errors

**Pass Criteria:**
- Connection succeeds
- Logs show "Using configured region: us-west-2"
- No fallback to DNS-based region

---

### Test 12: IdC Browser HTTPS Proxy (HIGH - Change #12)

**Objective:** Verify IdC authentication respects HTTPS proxy settings.

#### Test 12.1: Environment Variable Proxy

**Setup:**
```bash
export HTTPS_PROXY=http://proxy.company.com:8080
```

**Connection String:**
```
Driver={Amazon Redshift (x64)};
Server=your-cluster.redshift.amazonaws.com;
Port=5439;
Database=dev;
AuthMethod=BrowserAzureAD;
AADClientID=your-app-id;
AADClientSecret=your-secret;
AADTenant=your-tenant-id;
Scope=api://your-app-id/jdbc_login;
```

**Test:**
1. Set HTTPS_PROXY environment variable
2. Initiate connection
3. Browser opens through proxy

**Expected Result:**
- ✅ Browser authentication uses proxy
- ✅ OAuth flow completes
- ✅ Connection succeeds

---

#### Test 12.2: Driver Setting Proxy

**Connection String:**
```
...same as above...
HTTPSProxy=http://proxy.company.com:8080;
```

**Expected Result:**
- ✅ Driver uses configured proxy
- ✅ Environment variable overridden (if both set)
- ✅ Authentication succeeds

---

### Test 13: Version Verification (LOW - Change #13)

**Objective:** Verify version string and changelog.

**Test Code:**
```c
void test_version() {
    SQLHENV henv;
    SQLHDBC hdbc;
    SQLCHAR version[128];
    SQLSMALLINT versionLen;

    SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
    SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0);
    SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);

    SQLGetInfo(hdbc, SQL_DRIVER_VER, version, sizeof(version), &versionLen);

    printf("Driver version: %s\n", version);

    if (strstr((char*)version, "2.1.13") != NULL) {
        printf("✅ Version contains 2.1.13\n");
    } else {
        printf("❌ FAIL: Version does not contain 2.1.13\n");
    }

    SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle(SQL_HANDLE_ENV, henv);
}
```

**Expected Result:**
- ✅ Version string contains "2.1.13"
- ✅ CHANGELOG.md exists and is updated
- ✅ version.txt contains "Ov2.1.13F1.0.0-BLL"

---

## Automated Test Script

### Linux/macOS Script

**File:** `run_all_tests.sh`

```bash
#!/bin/bash

echo "========================================"
echo "Amazon Redshift ODBC Ov2.1.13F1.0.0-BLL"
echo "Complete Test Suite"
echo "========================================"

FAILED=0
PASSED=0

# Test 1: Build
echo ""
echo "Test 1: Building driver..."
cd src
mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
if make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4); then
    echo "✅ Build successful"
    ((PASSED++))
else
    echo "❌ Build failed"
    ((FAILED++))
    exit 1
fi

# Test 2: Check library
if [ -f "librsodbc.so" ] || [ -f "librsodbc.dylib" ]; then
    echo "✅ Driver library found"
    ((PASSED++))
else
    echo "❌ Driver library not found"
    ((FAILED++))
fi

# Test 3: Version check
echo ""
echo "Test 2: Version verification..."
if [ -f "../version.txt" ]; then
    VERSION=$(cat ../version.txt)
    if [ "$VERSION" = "Ov2.1.13F1.0.0-BLL" ]; then
        echo "✅ Version correct: $VERSION"
        ((PASSED++))
    else
        echo "❌ Version incorrect: $VERSION"
        ((FAILED++))
    fi
else
    echo "❌ version.txt not found"
    ((FAILED++))
fi

# Test 4: Unit tests (if available)
echo ""
echo "Test 3: Running unit tests..."
if [ -f "./unittest/rsodbc_test" ]; then
    ./unittest/rsodbc_test
    if [ $? -eq 0 ]; then
        echo "✅ Unit tests passed"
        ((PASSED++))
    else
        echo "❌ Unit tests failed"
        ((FAILED++))
    fi
else
    echo "⚠️  Unit tests not available (skipped)"
fi

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
```

---

## Performance Testing

### Benchmark 1: Numeric Operations

**Query:**
```sql
SELECT
    id,
    CAST(RANDOM() * 1000000 AS NUMERIC(38,10)) as num1,
    CAST(RANDOM() * 1000000 AS NUMERIC(38,10)) as num2
FROM
    generate_series(1, 100000) as id;
```

**Metrics:**
- Fetch time < 10 seconds
- Memory usage stable
- No memory leaks

---

### Benchmark 2: Escape Clause Performance

**Query:**
```sql
SELECT
    {fn CONCAT(col1, col2)} as concat_result,
    {fn UCASE(col3)} as upper_result,
    {fn ABS(col4)} as abs_result
FROM large_table
LIMIT 50000;
```

**Metrics:**
- Query time comparable to non-escape version
- No significant overhead

---

## Regression Test Checklist

Before production deployment:

### Build Tests
- [ ] ✅ Windows x64 build compiles
- [ ] ✅ Linux x64 build compiles
- [ ] ✅ macOS ARM64 build compiles
- [ ] ✅ macOS x86_64 build compiles

### Platform Tests
- [ ] ✅ macOS builds without std::string errors
- [ ] ✅ All platforms create valid driver binaries

### ODBC Compliance
- [ ] ✅ ODBC 2.x SQLGetTypeInfo column names correct
- [ ] ✅ ODBC 3.x SQLGetTypeInfo column names correct
- [ ] ✅ ARD defaults: SQL_C_DEFAULT
- [ ] ✅ APD defaults: SQL_C_DEFAULT
- [ ] ✅ IPD defaults: SQL_PARAM_INPUT
- [ ] ✅ Length indicators set for non-string fields
- [ ] ✅ Error codes: HY091 for invalid fields
- [ ] ✅ Error codes: HY016 for read-only descriptors
- [ ] ✅ SQL_C_DEFAULT type conversion works

### Data Type Tests
- [ ] ✅ SQL_NUMERIC buffer size = 19 bytes
- [ ] ✅ High-precision DECIMAL retrieval works
- [ ] ✅ Multiple numeric columns work
- [ ] ✅ No buffer overflows

### Escape Clause Tests
- [ ] ✅ String scalar functions work
- [ ] ✅ Numeric scalar functions work
- [ ] ✅ Date/time scalar functions work
- [ ] ✅ Date literals work
- [ ] ✅ Time literals work
- [ ] ✅ Timestamp literals work
- [ ] ✅ Outer join escape works

### Error Handling Tests
- [ ] ✅ SQLGetData error detection
- [ ] ✅ SQLPutData error detection
- [ ] ✅ SQLExtendedFetch error detection
- [ ] ✅ SQLSetCursorName error detection
- [ ] ✅ Consistent SQLSTATE codes

### Authentication Tests
- [ ] ✅ IAMJwtPlugin logging works
- [ ] ✅ CNAME region prioritization works
- [ ] ✅ IdC HTTPS proxy (env var) works
- [ ] ✅ IdC HTTPS proxy (driver setting) works
- [ ] ✅ Basic IAM authentication works

### Performance Tests
- [ ] ✅ No performance regression
- [ ] ✅ No memory leaks
- [ ] ✅ Escape clause overhead acceptable

---

## Known Issues

None identified. All 13 commits are from AWS official release v2.1.13.0 and well-tested.

---

## Bug Reporting

If tests fail, report with:
1. Test name/number
2. Platform and OS version
3. Full error message
4. Stack trace (if crash)
5. ODBC trace log (if available)
6. Reproduction steps

**Contact:**
- Fork Repository: https://github.com/ORELASH/amazon-redshift-odbc-driver
- Maintainer: Orel Ashush

---

## Summary

Ov2.1.13F1.0.0-BLL is a **complete fork** of AWS v2.1.13.0 with all 13 improvements:

**Critical Areas:**
- macOS platform support
- ODBC 2.x/3.x compliance
- Error handling robustness
- Authentication enhancements
- Data type correctness

**Recommendation:** Complete full test suite before production deployment.

---

**End of Testing Guide**
