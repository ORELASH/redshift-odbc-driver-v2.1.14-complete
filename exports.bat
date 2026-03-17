@echo off
rem Custom exports for vcpkg-based build
set "VCPKG_ROOT=C:\vcpkg\installed\x64-windows-static"

rem Set dependencies - flat vcpkg structure with include/ and lib/ directly
set "RS_DEPS_DIRS=%VCPKG_ROOT%;!LINK_PKG_PATH!\src\pgclient\kfw-3-2-2-final"

rem OpenSSL is in the same vcpkg root (has include/openssl/ and lib/libssl.lib)
set "RS_OPENSSL_DIR=%VCPKG_ROOT%"

rem Override RS_MULTI_DEPS_DIRS to empty - we use RS_DEPS_DIRS instead
set "RS_MULTI_DEPS_DIRS="

rem Disable testing (test target has CRT linking issues with vcpkg static libs)
set ENABLE_TESTING=0

echo Loaded custom exports.bat for vcpkg dependencies
echo RS_DEPS_DIRS=%RS_DEPS_DIRS%
echo RS_OPENSSL_DIR=%RS_OPENSSL_DIR%
