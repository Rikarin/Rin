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
    CharValue,      // char value
    WCharValue,     // wchar value
    DCharValue,     // dchar value
    ByteValue,      // byte value
    UByteValue,     // ubyte value
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

    Colon,            // :
    Comma,            // ,
    Dot,              // .
    DotDot,           // ..
    DotDotDot,        // ...
    ReturnType,       // ->
    MonadDeref,       // ?.
    Monad,            // ?
    OpenScope,        // {
    CloseScope,       // }
    OpenArray,        // [
    CloseArray,       // ]
    OpenBracket,      // (
    CloseBracket,     // )
    Plus,             // +
    Minus,            // -
    At,               // @
    Asterisk,         // *
    Dildo,            // ~
    Mul,              // /
    Modulo,           // %
    Ampersand,        // &
    Or,               // |
    Xor,              // ^
    AndAnd,           // &&
    OrOr,             // ||
    PlusPlus,         // ++
    MinusMinus,       // --
    LessThan,         // <
    GreaterThan,      // >
    LeftShift,        // <<
    RightShift,       // >>
    Dollar,           // $
    PlusAssign,       // +=
    MinusAssign,      // -=
    AsteriskAssign,   // *=
    MulAssign,        // /=
    ModuloAssign,     // %=
    DildoAssign,      // ~=
    OrAssign,         // |=
    AmpersandAssign,  // &=
    XorAssign,        // ^=
    LeftShiftAssign,  // <<=
    RightShiftAssign, // >>=
    LessEqual,        // <=
    GreaterEqual,     // >=
    Blyat,            // = 
    Equal,            // ==
    NotEqual,         // !=
    Is,               // is
    NotIs,            // !is
    Not,              // !

    If,               // if
    Else,             // else
    While,            // while
    Repeat,           // repeat
    For,              // for
    Switch,           // switch
    Case,             // case
    Default,          // default
    Break,            // break
    Continue,         // continue
    Lock,             // lock

    Import,           // import
    Module,           // module
    Alias,            // alias
    Struct,           // struct
    Protocol,         // protocol
    Extend,           // extend
    Enum,             // enum
    Union,            // union
    
    Func,             // func
    Task,             // task
    Return,           // return
    Throws,           // throws
    Self,             // self
    As,               // as
    In,               // in
    Throw,            // throw
    Try,              // try
    Catch,            // catch
    Finally,          // finally

    // Common attributes. Can be applied to single statement like func, task, class, etc. or to scope
    // ============================
    Class,          // class
    Final,          // final
    Override,       // override
    Abstract,       // abstract
    Global,         // global
    Deprecated,     // deprecated
    Debug,          // debug
    Version,        // version
    // ============================

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
    Location  location;

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

bool isFuncAttribute(TokenType type) {
    return type >= TokenType.Final && type <= TokenType.Const;
}



struct Location {
    string file;
    int column;
    int line;
}

enum Precedence : int {
    Zero,
    Expression,
    Assign,

    Unary,
    Primary,
}

immutable Precedence[TokenType.max] TypePrecedence = [
    TokenType.Blyat: Precedence.Zero
];

/**
        m_precedence = [
            TokenType.Blyat:    5,
            //TokenType.: 10, // token >
            //'>': 10,
            TokenType.Plus:     20,
            TokenType.Minus:    20,
            TokenType.Asterisk: 40,
            //TokenType.: 40, // token /
            // '%': 40,
        ];

*/