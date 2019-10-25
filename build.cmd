@echo off

set INSTALL_DIR=%1
set SECOND_ARG=%2

if "%INSTALL_DIR%"=="" (
    echo ERROR: missing "CMAKE_INSTALL_PREFIX". First argument must be the directory to install the LLVM binaries and include files
    goto :end
)

if "%SECOND_ARG%" NEQ "" if "%SECOND_ARG%" NEQ "configure" (
    echo ERROR: invalid argument "%SECOND_ARG%"
    goto :end
)

cmake .\llvm -B .\build -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" -DLLVM_TARGETS_TO_BUILD=X86 -G "Visual Studio 15 2017" -A x64 -Thost=x64

if "%SECOND_ARG%" NEQ "configure" (
    cmake --build .\build --target install --config Release --parallel
)

:end