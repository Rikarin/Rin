module Parser.Declaration;
@safe:

import Tokens;
import Lexer;
import Ast.Declaration;
import Domain.Name;
import Domain.Location;
import Parser.Utils;


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

    switch (trange.front.type) with (TokenType) {
        case Static:
            // TODO
            break;

        case Using: return trange.parseUsing();
        default: break;
    }


    trange.popFront();
    return null;
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