set(LLVM_LINK_COMPONENTS
  Support
)

add_clang_executable(clang-reflect
  Main.cpp
)

clang_target_link_libraries(clang-reflect
  PRIVATE
  clangAST
  clangASTMatchers
  clangBasic
  clangFrontend
  clangTooling
  clangToolingRefactoring
)
