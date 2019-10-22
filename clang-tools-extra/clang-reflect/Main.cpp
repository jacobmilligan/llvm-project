//===---- tools/extra/ToolTemplate.cpp - Template for refactoring tool ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file implements an empty refactoring tool using the clang tooling.
//  The goal is to lower the "barrier to entry" for writing refactoring tools.
//
//  Usage:
//  tool-template <cmake-output-dir> <file1> <file2> ...
//
//  Where <cmake-output-dir> is a CMake build directory in which a file named
//  compile_commands.json exists (enable -DCMAKE_EXPORT_COMPILE_COMMANDS in
//  CMake to get this output).
//
//  <file1> ... specify the paths of files in the CMake source tree. This path
//  is looked up in the compile command database. If the path of a file is
//  absolute, it needs to point into CMake's source tree. If the path is
//  relative, the current working directory needs to be in the CMake source
//  tree and the file must be in a subdirectory of the current working
//  directory. "./" prefixes in the relative files will be automatically
//  removed, but the rest of a relative path must be a suffix of a path in
//  the compile command line database.
//
//  For example, to use tool-template on all files in a subtree of the
//  source tree, use:
//
//    /path/in/subtree $ find . -name '*.cpp'|
//        xargs tool-template /path/to/build
//
//===----------------------------------------------------------------------===//

#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/Frontend/FrontendActions.h"
#include "clang/Tooling/CommonOptionsParser.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/Support/CommandLine.h"

using namespace clang;
using namespace clang::ast_matchers;
using namespace clang::tooling;
using namespace llvm;


struct RecordFinder final : public MatchFinder::MatchCallback
{
    void run(const MatchFinder::MatchResult& result) override
    {
        auto node = result.Nodes.getNodeAs<clang::CXXRecordDecl>("id");
        if (node == nullptr)
        {
            return;
        }

        for (auto& attribute : node->attrs())
        {
            if (attribute->getKind() != attr::Annotate)
            {
                continue;
            }

            auto annotation_decl = llvm::dyn_cast<AnnotateAttr>(attribute);
            if (annotation_decl == nullptr)
            {
                continue;
            }

            StringRef annotation = annotation_decl->getAnnotation();

            assert(annotation.startswith("clang-reflect-class"));

            node->dump();
            printf("%s\n", annotation.data());
        }
    }
};


// Set up the command line options
static cl::OptionCategory clang_reflect_category("clang-reflect options");


// CommonOptionsParser declares HelpMessage with a description of the common
// command-line options related to the compilation database and input files.
// It's nice to have this help message in all tools.
static cl::extrahelp CommonHelp(CommonOptionsParser::HelpMessage);

int main(int argc, const char **argv)
{
    CommonOptionsParser options_parser(argc, argv, clang_reflect_category);
    ClangTool tool(options_parser.getCompilations(), options_parser.getSourcePathList());

    RecordFinder record_finder;
    MatchFinder finder;

    // Match any record with an __annotate__ attribute and bind it to "id"
    static DeclarationMatcher record_matcher = cxxRecordDecl(recordDecl().bind("id"), hasAttr(attr::Annotate));
    finder.addMatcher(record_matcher, &record_finder);

    return tool.run(newFrontendActionFactory(&finder).get());
}
