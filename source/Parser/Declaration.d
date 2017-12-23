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

    // Namespace
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

    // Declarations without storage classes support
    switch (trange.front.type) with (TokenType) {
        case Static: goto case;
        case Version: goto case;
        case Debug: goto case;
        case Mixin:
            TODO;
            break;

        case Using: return trange.parseUsing();

        default:
    }

    auto sc = StorageClass.defaults;

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
        default:
    }

    if (trange.front.type == TokenType.Async) {
        trange.popFront();
        sc.isAsync = true;
    }

    if (trange.front.type == TokenType.Synchronized) {
        trange.popFront();
        sc.isSynchronized = true;
    }

    if (trange.front.type == TokenType.Virtual) { // virtual or final or abstract
        trange.popFront();
        sc.isVirtual = true;
    }

    // TODO
     // [Attrib()]
     // abstract, override, deprecated, static, final
     // nameFunc()
     // const, ref, shared, readonly, nogc, pure, inout
     // -> return type
    
    // func and class must have the same qualifiers before name declaration
    // visibility, abstract, final, static, external, extern, synchronized


     // can be extern (C) or external


    // name (can be property, function or variable)
    // return type


    // TODO: parse qualifiers in strict order!
    // visibility, async, synchronized, virtual, pure, nogc, unsafe, <name>, ->, return type

    assert(false, "undefined " ~ trange.front.type.to!string);

    //trange.popFront();
    //return null;
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


// TODO refactor
void parseTupleTypeDecl(ref TokenRange trange) {
    Location loc = trange.front.location;
    trange.match(TokenType.OpenParen);
}