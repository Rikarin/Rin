module Tokens;


enum Token {
    None,
    Eof,
    Space, // because we dont want to let the people to format code like !@#$
    EndLine, // We don't use ; at end of statement, statement end at the end of the line

    Identifier, // any other unparserable token like name of function, etc

    True,       // true
    False,      // false
    Null,       // null

    Var,        // var
    Let,        // let
    Bool,       // bool
    Byte,       // byte
    UByte,      // ubyte
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



    Import,         // import
    Alias,          // alias
    Class,          // class
    Struct,         // struct
    
    Func,           // func
    Task,           // task
    Return,         // return
    Throws,         // throws
    Final,          // final


    // TODO: implement
    Ref,            // ref
}



immutable BasicTypes = [
    Token.Bool,
    Token.Byte,
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
    Token.Ref
];


bool contains(T)(T[] array, T value) {
    import std.algorithm.searching;
    return array.countUntil(value) != -1;
}