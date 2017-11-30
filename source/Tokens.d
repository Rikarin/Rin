module Tokens;

import Domain.Name;
import Domain.Location;


enum TokenType {
    Invalid = 0,

    Begin,          // What is this?
    End,

    // Literals
    Identifier,     // any other unparserable token like name of function, etc
    StringLiteral,
    CharacterLiteral,
    IntegerLiteral,
    FloatLiteral,

    // Keywords
    Abstract, Alias, Align, As, Asm, Assert,
    Async, Await,
    Bool, Break, Byte,
    Case, Catch, Cent, Char,
    Class, Const, Continue,
    DChar, Debug, Default, Delegate,
    Deprecated, Do, Double,
    Else, Enum, Extern,
    False, Final, Finally, Float, For, Foreach,
    Function,
    Goto, Global,
    If, In, Inout, Int, Interface, Invariant, Is,
    Internal,
    Lazy, Long, Let, Lock,
    Mixin,
    NameOf, NameSpace, Nothrow, Null,
    Out, Override,
    Pragma, Private, Protected, Public, Pure, Partial,
    Real, Ref, Return,
    Scope, Shared, Short, Static, Struct, Super,
    Self, Switch,
    Template, Throw, True, Try,
    TypeOf,
    UByte, UCent, UInt, ULong, Union, Unittest, Ushort,
    Using, Unsafe,
    Version, Void, Volatile, Var,
    WChar, While, With, Weak,

    // Operators
    Slash,              // /
    SlashEquals,        // /=
    Dot,                // .
    DotDot,             // ..
    DotDotDot,          // ...
    Ampersand,          // &
    AmpersandEqual,     // &=
    AmpersandAmpersand, // &&
    Pipe,               // |
    PipeEqual,          // |=
    PipePipe,           // ||
    Minus,              // -
    MinusEqual,         // -=
    MinusMinus,         // --
    Plus,               // +
    PlusEqual,          // +=
    PlusPlus,           // ++
    Less,               // <
    LessEqual,          // <=
    LessLess,           // <<
    LessLessEqual,      // <<=
    More,               // >
    MoreEqual,          // >=
    MoreMore,           // >>
    MoreMoreEqual,      // >>=
    Bang,               // !
    BangEqual,          // !=
    BandLess,           // !<
    BangLessEqual,      // !<=
    BangMore,           // !>
    BangMoreEqual,      // !>=
    OpenParen,          // (
    CloseParen,         // )
    OpenBracket,        // [
    CloseBracket,       // ]
    OpenBrace,          // {
    CloseBrace,         // }
    QuestionMark,       // ?
    QuestionMarkQuestionMark, // ??
    QuestionMarkDot,    // ?.
    Comma,              // ,
    Semicolon,          // ;
    Colon,              // :
    MinusMore,          // ->
    Dollar,             // $
    Equal,              // =
    EqualEqual,         // ==
    Asterisk,           // *
    AsteriskEqual,      // *=
    Percent,            // %
    PercentEqual,       // %=
    Caret,              // ^
    CaretEqual,         // ^=
    CaretCaret,         // ^^
    CaretCaretEqual,    // ^^=
    Tilde,              // ~
    TildeEqual,         // ~=
    At,                 // @
    EqualMore,          // =>
    Hash,               // #

    //Enforce,        // enforce
    // >>> maybe this?
    // <>, <>=, !<>, !<>=

    /// ?? Protocol,         // protocol
    // ??Extend,           // extend

    // Global == __gshared
    // let == immutable
}

auto operatorsMap() {
    with (TokenType)
    return [
        "/" : Slash,
        "/=": SlashEquals,
        // TODO
    ];
}

auto keywordsMap() {
    with (TokenType)
    return [
        "abstract":     Abstract,
        "alias":        Alias,
        // TODO
    ];
}

private auto lexerMap() {
    auto ret = [
        // Whitespaces
        " ": "?lextWhiteSpace",
        "\t": "?lexWhiteSpace",
        // TODO
    ];

    // TODO
}


struct Token {
    TokenType type;
    Location  location;
    Name      name;    
}
