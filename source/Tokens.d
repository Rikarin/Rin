module Tokens;


enum TokenType {
    None,
    Eof,
    Space,          // because we dont want to let the people to format code like !@#$
    EndLine,        // We don't use ; at end of statement, statement end at the end of the line

    Identifier,     // any other unparserable token like name of function, etc
    StringExpr,     // string in " "
    Assert,         // assert
    Enforce,        // enforce
    Asm,            // asm

    // Must be grouped together, used in case range
    // ============================
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
    // ============================

    // constant value types
    // ============================
    Null,           // null
    True,           // true
    False,          // false
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
    // ============================

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
    Asterisk,       // *

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

    // Type attributes
    // ============================
    Ref,            // ref
    Const,          // const
    Weak,           // weak
    Lazy,           // lazy
    // ============================
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

@safe:
bool isBasicType(TokenType type) {
    return type >= TokenType.Var && type <= TokenType.Real;
}

bool isBasicTypeValue(TokenType type) {
    return type >= TokenType.Null && type <= TokenType.RealValue;
}

bool isAttribute(TokenType type) {
    return type >= TokenType.Ref && type <= TokenType.Lazy;
}