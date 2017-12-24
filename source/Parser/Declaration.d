module Parser.Declaration;
@safe:

import Tokens;
import Lexer;
import Ast.Declaration;
import Domain.Name;
import Domain.Location;
import Common.Qualifier;
import Parser.Utils;

import std.conv;

void TODO() {
    assert(false, "TODO");
}


Namespace parseNamespace(ref TokenRange trange) {
    trange.match(TokenType.Begin);
    Location loc = trange.front.location;

    trange.match(TokenType.Namespace);

    Name[] name = [trange.front.name];
    trange.match(TokenType.Identifier);

    while (trange.front.type == TokenType.Dot) {
        trange.popFront();

        name ~= trange.front.name;
        trange.match(TokenType.Identifier);
    }
    trange.match(TokenType.Semicolon);

    auto declarations = trange.parseAggregate!false();
    loc.spanTo(trange.previous);

    return new Namespace(loc, name, declarations);
}


// Parse block of declarations
Declaration[] parseAggregate(bool braces = true)(ref TokenRange trange) {
    static if (braces) {
        trange.match(TokenType.OpenBrace);
    }

    Declaration[] declarations;
    while (!trange.empty && trange.front.type != TokenType.CloseBrace) {
        declarations ~= trange.parseDeclaration();
    }

    static if (braces) {
        trange.match(TokenType.CloseBrace);
    }

    return declarations;
}


Declaration parseDeclaration(ref TokenRange trange) {
    Location loc = trange.front.location;

    // Declarations without storage class support
    switch (trange.front.type) with (TokenType) {
        case OpenParen: // Tuple
            return trange.parseTuple();

        case Var: goto case;
        case Static: goto case; // static if
        case Version: goto case;
        case Debug: goto case;
        case Unsafe: goto case;
        case Mixin:
            TODO;
            break;

        case Using: return trange.parseUsing();

        default:
    }

    // Parse attributes
    if (trange.front.type == TokenType.OpenBracket) {
        TODO;
        //parse attributes
    }

    auto sc = trange.parsePrefixStorageClasses();
    switch (trange.front.type) with (TokenType) {
        case Identifier: goto case; // function, property or class's variable decl
        case Class: goto case;
        case Struct: goto case;
        case Enum: goto case;
        case Interface: goto case;
        case Template: goto case;
        case Self: goto case; // constructor
        case Alias: goto case;
        case Unittest: goto case;
        case Union: 
            TODO;
            break;

        default:
    }

    // name (can be property, function or variable)
    // const, ref, shared, readonly, nogc, pure, inout
    // -> return type
    
    // parse qualifiers in strict order!

    assert(false, "undefined " ~ trange.front.type.to!string);
}


UsingDeclaration parseUsing(ref TokenRange trange) {
    Location loc = trange.front.location;
    trange.match(TokenType.Using);

    Name[] name = [trange.front.name];
    trange.match(TokenType.Identifier);

    // TODO: parse 'als =' eg. using name = System.Name;

    while (trange.front.type == TokenType.Dot) {
        trange.popFront();

        name ~= trange.front.name;
        trange.match(TokenType.Identifier);
    }

    trange.match(TokenType.Semicolon);
    loc.spanTo(trange.previous);

    return new UsingDeclaration(loc, name);
}


auto parseTuple(ref TokenRange trange) {
    Location loc = trange.front.location;

    bool isVariadic;
    auto params = parseParameters(trange, isVariadic);
    
    assert(!isVariadic, "Tuple cannot be variadic");
    return new TupleDeclaration(loc, params);
}




// Parse parameters for function or tuple declaration
auto parseParameters(ref TokenRange trange, out bool isVariadic) {
    trange.match(TokenType.OpenParen);
    ParamDecl[] params;

    // TODO

    trange.match(TokenType.CloseParen);
    return params;
}


StorageClass parsePrefixStorageClasses(ref TokenRange trange) {
    auto sc = StorageClass.defaults;

    if (trange.front.type == TokenType.Deprecated) {
        trange.popFront();
        sc.isDeprecated = true;
    }

    // Parse Visibility qualifier
    void processToken(Visibility v) {
        trange.popFront();
        sc.visibility = v;
    }

    switch (trange.front.type) with (TokenType) {
        case Public:    processToken(Visibility.Public);    break;
        case Protected: processToken(Visibility.Protected); break;
        case Internal:  processToken(Visibility.Internal);  break;
        case Private:   processToken(Visibility.Private);   break;
        case Extern:    processToken(Visibility.Extern);    break;
        default:
    }

    // TODO: scope somewhere (class can be scoped)

    if (trange.front.type == TokenType.External) {
        trange.popFront();
        TODO;
    }

    if (trange.front.type == TokenType.Static) {
        trange.popFront();
        sc.isStatic = true;
    }

    if (trange.front.type == TokenType.Async) {
        trange.popFront();
        sc.isAsync = true;
    }

    if (trange.front.type == TokenType.Synchronized) {
        trange.popFront();
        sc.isSynchronized = true;
    }

    if (trange.front.type == TokenType.Override) {
        trange.popFront();
        sc.isOverride = true;
    }

    switch (trange.front.type) with (TokenType) {
        case Virtual:
            trange.popFront();
            sc.isVirtual = true;
            break;

        case Abstract:
            trange.popFront();
            sc.isAbstract = true;
            break;

        case Final:
            trange.popFront();
            sc.isFinal = true;
            break;

        default:
    }

    return sc;
}