# Rin - One lang rule them all

[![Build Status](https://travis-ci.org/Rikarin/Rin.svg?branch=master)](https://travis-ci.org/Rikarin/Rin)

**What is Rin?**

Rin is a new generation language used for all purpose development. TODO can be used for web development, low level dev, or casual sw dev. Can be compiled into binary, web assembly or IR form.


**What have we done?**

What | Percentage
---- | ----------
Lexer | 100%
Parser | 70%
Semantic Analysis | 0%
IR | 2%
LLVM translation | 0%


**What are the differences between this and D?**

We primary focus on fast and easy development instead on runtime performance.

The language is strict, easy to learn, easy to use, no metaprogramming overheat.

The lang supports nullable types, conditional dereferencing, coallescence operator,
async/await, inline html tags, enhanced enums, C# style properties, default(type),
nameof(identifier), runtime reflection, tuples, default safety, implicit nothrow,
body expressions.

Instead of header files compiler can export semantically analyzed AST.
