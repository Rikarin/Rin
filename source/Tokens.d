module Tokens;


enum Token {
    None,
    Eof,
    Space,          // because we dont want to let the people to format code like !@#$
    EndLine,        // We don't use ; at end of statement, statement end at the end of the line

    Identifier,     // any other unparserable token like name of function, etc

    True,           // true
    False,          // false
    Null,           // null
    Assert,         // assert
    Enforce,        // enforce
    Asm,            // asm

    Var,            // var
    Let,            // let
    Void,           // void
    Bool,           // bool
    Char,           // char
    WChar,          // wchar
    DChar,          // dchar
    Byte,           // byte
    UByte,          // ubyte
    Short,
    UShort,
    Int,
    UInt,
    Long,
    ULong,
    Float,
    Double,
    Real,

    Colon,          // :
    Comma,          // ,
    Dot,            // .
    ReturnType,     // ->
    MonadDeref,     // ?.
    Monad,          // ?
    OpenScope,      // {
    CloseScope,     // }
    OpenArray,      // [
    CloseArray,     // ]
    OpenBracket,    // (
    CloseBracket,   // )
    Plus,           // +
    Minus,          // -

    Blyat,          // = 
    Equal,          // ==
    NotEqual,       // !=
    Is,             // is
    NotIs,          // !is
    Not,            // !

    If,             // if
    Else,           // else
    While,          // while
    Repeat,         // repeat
    For,            // for
    Switch,         // switch
    Case,           // case
    Default,        // default
    Break,          // break
    Continue,       // continue
    Lock,           // lock

    Import,         // import
    Module,         // module
    Alias,          // alias
    Class,          // class
    Struct,         // struct
    Protocol,       // protocol
    Extend,         // extend
    Enum,           // enum
    Union,          // union
    
    Func,           // func
    Task,           // task
    Return,         // return
    Throws,         // throws
    Final,          // final
    Self,           // self
    As,             // as
    In,             // in
    Throw,          // throw
    Try,            // try
    Catch,          // catch
    Finally,        // finally
    Override,       // override
    Abstract,       // abstract
    Deprecated,     // deprecated
    Debug,          // debug
    Version,        // version

    Ref,            // ref
    Const,          // const
    Weak,           // weak
    Lazy,           // lazy
}



immutable BasicTypes = [
    Token.Void,
    Token.Bool,
    Token.Byte,
    Token.Char,
    Token.WChar,
    Token.DChar,
    Token.UByte,
    Token.Short,
    Token.UShort,
    Token.Int,
    Token.UInt,
    Token.Long,
    Token.ULong,
    Token.Float,
    Token.Double,
    Token.Real,
];

immutable ArgAttrib = [
    Token.Ref,
    Token.Const,
    Token.Weak,
    Token.Lazy,
];


bool contains(T)(T[] array, T value) {
    import std.algorithm.searching;
    return array.countUntil(value) != -1;
}