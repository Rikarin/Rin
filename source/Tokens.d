module Tokens;

import Domain.Name;
import Domain.Location;


enum TokenType {
    Invalid = 0,

    Begin,
    End,

    // Literals
    Identifier,     // any other unparserable token like name of function, etc
    StringLiteral,
    CharacterLiteral,
    IntegerLiteral,
    FloatLiteral,

    // Keywords
    Abstract, Alias, Align, As, Asm, Assert,
    Async, Await, Any,
    Bool, Break, Byte,
    Case, Catch, Cent, Char,
    Class, Const, Continue,
    DChar, Debug, Default, Delegate,
    Deprecated, Double, Defer,
    Else, Enum, Extern, External,
    False, Final, Finally, Float, For,
    Function,
    Goto, Get,
    If, In, Inout, Int, Interface, Invariant, Is,
    Internal,
    Lazy, Long, Let, Lock,
    Mixin,
    NameOf, Namespace, Null,
    Out, Override,
    Pragma, Private, Protected, Public, Pure, Partial,
    Real, Ref, Return, Repeat,
    Set, Scope, Shared, Short, Static, Struct, Super,
    Self, Switch, Synchronized,
    Template, Throw, True, Try, TypeOf, TypeId, Traits,
    Throws,
    UByte, UCent, UInt, ULong, Union, Unittest, Ushort,
    Using, Unsafe,
    Version, Void, Volatile, Var,
    WChar, While, With, Weak, Where,
    SharpFile, SharpLine,

    // Operators
    Slash,              // /
    SlashEqual,         // /=
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
    MoreMoreMore,       // >>>
    MoreMoreEqual,      // >>=
    MoreMoreMoreEqual,  // >>>=
    Bang,               // !
    BangEqual,          // !=
    BangLess,           // !<
    BangLessEqual,      // !<=
    BangMore,           // !>
    BangMoreEqual,      // !>=
    LessMoreEqual,      // <>=
    BangLessMoreEqual,  // !<>=
    LessMore,           // <>
    BangLessMore,       // !<>
    OpenParen,          // (
    CloseParen,         // )
    OpenBracket,        // [
    CloseBracket,       // ]
    OpenBrace,          // {
    CloseBrace,         // }
    QuestionMark,       // ?
    QuestionMarkQuestionMark, // ??
    QuestionMarkDot,    // ?.
    QuestionMarkOpenBracket, // ?[
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
    //At,                 // @ TODO, do I need this simbol?
    EqualMore,          // =>
    Sharp,              // #

    //Enforce,        // enforce


    // __gshared = mark variable as unsafe e.g. private unsafe test: int;
    // let == immutable
}

auto operatorsMap() {
    with (TokenType)
    return [
        "/" :   Slash,
        "/=":   SlashEqual,
        ".":    Dot,
        "..":   DotDot,
        "...":  DotDotDot,
        "&":    Ampersand,
        "&=":   AmpersandEqual,
        "&&":   AmpersandAmpersand,
        "|":    Pipe,
        "|=":   PipeEqual,
        "||":   PipePipe,
        "-":    Minus,
        "-=":   MinusEqual,
        "--":   MinusMinus,
        "+":    Plus,
        "+=":   PlusEqual,
        "++":   PlusPlus,
        "<":    Less,
        "<=":   LessEqual,
        "<<":   LessLess,
        "<<=":  LessLessEqual,
        ">":    More,
        ">=":   MoreEqual,
        ">>":   MoreMore,
        ">>>":  MoreMoreMore,
        ">>=":  MoreMoreEqual,
        ">>>=": MoreMoreMoreEqual,
        "!":    Bang,
        "!=":   BangEqual,
        "!<":   BangLess,
        "!<=":  BangLessEqual,
        "!>":   BangMore,
        "!>=":  BangMoreEqual,
        "<>=":  LessMoreEqual,
        "!<>=": BangLessMoreEqual,
        "<>":   LessMore,
        "!<>":  BangLessMore,
        "(":    OpenParen,
        ")":    CloseParen,
        "[":    OpenBracket,
        "]":    CloseBracket,
        "{":    OpenBrace,
        "}":    CloseBrace,
        "?":    QuestionMark,
        "??":   QuestionMarkQuestionMark,
        "?.":   QuestionMarkDot,
        "?[":   QuestionMarkOpenBracket,
        ",":    Comma,
        ";":    Semicolon,
        ":":    Colon,
        "->":   MinusMore,
        "$":    Dollar,
        "=":    Equal,
        "==":   EqualEqual,
        "*":    Asterisk,
        "*=":   AsteriskEqual,
        "%":    Percent,
        "%=":   PercentEqual,
        "^":    Caret,
        "^=":   CaretEqual,
        "^^":   CaretCaret,
        "^^=":  CaretCaretEqual,
        "~":    Tilde,
        "~=":   TildeEqual,
        "=>":   EqualMore,
        "#":    Sharp,
        "\0":   End
    ];
}

auto keywordsMap() {
    with (TokenType)
    return [
        "abstract":     Abstract,
        "alias":        Alias,
        "align":        Align,
        "as":           As,
        "asm":          Asm,
        "assert":       Assert,
        "async":        Async,
        "await":        Await,
        "any":          Any,
        "bool":         Bool,
        "break":        Break,
        "byte":         Byte,
        "case":         Case,
        "catch":        Catch,
        "cent":         Cent,
        "char":         Char,
        "class":        Class,
        "const":        Const,
        "continue":     Continue,
        "dchar":        DChar,
        "debug":        Debug,
        "default":      Default,
        "delegate":     Delegate,
        "deprecated":   Deprecated,
        "double":       Double,
        "defer":        Defer,
        "else":         Else,
        "enum":         Enum,
        "extern":       Extern,
        "external":     External,
        "false":        False,
        "final":        Final,
        "finally":      Finally,
        "float":        Float,
        "for":          For,
        "function":     Function,
        "goto":         Goto,
        "get":          Get,
        "if":           If,
        "in":           In,
        "inout":        Inout,
        "int":          Int,
        "interface":    Interface,
        "invariant":    Invariant,
        "is":           Is,
        "internal":     Internal,
        "lazy":         Lazy,
        "long":         Long,
        "let":          Let,
        "lock":         Lock,
        "mixin":        Mixin,
        "nameof":       NameOf,
        "namespace":    Namespace,
        "null":         Null,
        "out":          Out,
        "override":     Override,
        "pragma":       Pragma,
        "private":      Private,
        "protected":    Protected,
        "public":       Public,
        "pure":         Pure,
        "partial":      Partial,
        "real":         Real,
        "ref":          Ref,
        "return":       Return,
        "repeat":       Repeat,
        "scope":        Scope,
        "shared":       Shared,
        "short":        Short,
        "static":       Static,
        "struct":       Struct,
        "super":        Super,
        "self":         Self,
        "set":          Set,
        "switch":       Switch,
        "synchronized": Synchronized,
        "template":     Template,
        "throw":        Throw,
        "throws":       Throws,
        "true":         True,
        "try":          Try,
        "typeof":       TypeOf,
        "ubyte":        UByte,
        "ucent":        UCent,
        "uint":         UInt,
        "ulong":        ULong,
        "union":        Union,
        "unittest":     Unittest,
        "ushort":       Ushort,
        "using":        Using,
        "unsafe":       Unsafe,
        "version":      Version,
        "void":         Void,
        "volatile":     Volatile,
        "var":          Var,
        "wchar":        WChar,
        "while":        While,
        "with":         With,
        "weak":         Weak,
        "where":        Where,
        "#file":        SharpFile,
        "#line":        SharpLine
    ];
}


struct Token {
    TokenType type;
    Location  location;
    Name      name;    
}
