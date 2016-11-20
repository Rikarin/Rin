module Tokens;


enum TokenType {
    None,
    Eof,
    Space,          // because we dont want to let the people to format code like !@#$
    EndLine,        // We don't use ; at end of statement, statement end at the end of the line

    Identifier,     // any other unparserable token like name of function, etc
    StringExpr,     // string in " "

    True,           // true
    False,          // false
    Null,           // null
    Assert,         // assert
    Enforce,        // enforce
    Asm,            // asm

    // Must be grouped together, used in case range
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

    CharValue,      // char
    WCharValue,     // wchar
    DCharValue,     // dchar
    ByteValue,      // byte
    UByteValue,     // ubyte
    ShortValue,
    UShortValue,
    IntValue,
    UIntValue,
    LongValue,
    ULongValue,
    FloatValue,
    DoubleValue,
    RealValue,

    Colon,          // :
    Comma,          // ,
    Dot,            // .
    Slice,          // ..
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
    At,             // @

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

struct Token {
    TokenType type;
    Token*    next;

    union {
        long  value;
        ulong uvalue;
        real  rvalue;
    }

    string str;
    char   postfix;
}


// TODO: this should be removed??
immutable BasicTypes = [
    TokenType.Void,
    TokenType.Bool,
    TokenType.Byte,
    TokenType.Char,
    TokenType.WChar,
    TokenType.DChar,
    TokenType.UByte,
    TokenType.Short,
    TokenType.UShort,
    TokenType.Int,
    TokenType.UInt,
    TokenType.Long,
    TokenType.ULong,
    TokenType.Float,
    TokenType.Double,
    TokenType.Real,
];

immutable BasicTypeValues = [
    TokenType.True,
    TokenType.False,
    TokenType.ByteValue,
    TokenType.CharValue,
    TokenType.WCharValue,
    TokenType.DCharValue,
    TokenType.UByteValue,
    TokenType.ShortValue,
    TokenType.UShortValue,
    TokenType.IntValue,
    TokenType.UIntValue,
    TokenType.LongValue,
    TokenType.ULongValue,
    TokenType.FloatValue,
    TokenType.DoubleValue,
    TokenType.RealValue,
];

immutable Attribs = [
    TokenType.Ref,
    TokenType.Const,
    TokenType.Weak,
    TokenType.Lazy,
];


bool contains(T)(T[] array, T value) {
    import std.algorithm.searching;
    return array.countUntil(value) != -1;
}