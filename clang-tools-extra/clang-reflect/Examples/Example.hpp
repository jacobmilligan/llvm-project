/*
 *  Example.hpp
 *  LLVM
 *
 *  Copyright (c) 2019 Jacob Milligan. All rights reserved.
 */

#pragma once

#define CLANG_REFLECT_CLASS(...) __attribute__((annotate("clang-reflect-class[" #__VA_ARGS__ "]")))
#define CLANG_REFLECT_FIELD(...) __attribute__((annotate("clang-reflect-field[" #__VA_ARGS__ "]")))

struct CLANG_REFLECT_CLASS() HeaderStruct
{
    CLANG_REFLECT_FIELD()
    int int_field;

    CLANG_REFLECT_FIELD()
    char char_field;
};