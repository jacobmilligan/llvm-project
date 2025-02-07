@echo off

set SHOULD_CONFIG=%1
set INSTALL_DIR=.\install\RelWithDebInfo
set BUILD_DIR=.\build\RelWithDebInfo


if "%SHOULD_CONFIG%" NEQ "" if "%SHOULD_CONFIG%" NEQ "configure" (
    echo ERROR: invalid argument "%SHOULD_CONFIG%"
    goto :end
)

cmake .\llvm -B "%BUILD_DIR%" -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" -DLLVM_TARGETS_TO_BUILD=X86 -G "Visual Studio 15 2017" -A x64 -Thost=x64 -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_USE_CRT_DEBUG=MDd -DLLVM_USE_CRT_RELEASE=MD -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_ENABLE_ASSERTIONS=ON

if "%SHOULD_CONFIG%" NEQ "configure" (
    cmake --build "%BUILD_DIR%" --target install --config RelWithDebInfo --parallel
)

:end