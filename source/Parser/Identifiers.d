module Parser.Identifiers;
@safe:

import Lexer;
import Tokens;

import Ast.Type;
import Ast.Expression;
import Ast.Identifiers;
import Domain.Location;
import Parser.Utils;


Identifier parseIdentifier(ref TokenRange trange) {
    Location loc = trange.front.location;

    auto name = trange.front.name;
    trange.match(TokenType.Identifier);

    return trange.parseBuiltIdentifier(new BasicIdentifier(loc, name));
}


// .identifier
Identifier parseDotIdentifier(ref TokenRange trange) {
    Location loc = trange.front.location;
    trange.match(TokenType.Dot);

    auto name = trange.front.name;
    trange.match(TokenType.Identifier);

    loc.spanTo(trange.previous);
    return trange.parseBuiltIdentifier(new DotIdentifier(loc, name));
}


// qualifier.identifier
auto parseQualifiedIdentifier(N)(ref TokenRange trange, Location loc, N ns) {
    auto name = trange.front.name;
    trange.match(TokenType.Identifier);

    loc.spanTo(trange.previous);

    static if (is(N : Identifier)) {
        alias QualifiedIdentifier = IdentifierDotIdentifier;
    } else static if (is(N : AstType)) {
        alias QualifiedIdentifier = TypeDotIdentifier;
    } else static if (is(N : AstExpression)) {
        alias QualifiedIdentifier = ExpressionDotIdentifier;
    } else {
        static assert(false);
    }

    return trange.parseBuiltIdentifier(new QualifiedIdentifier(loc, name, ns));
}


private Identifier parseBuiltIdentifier(ref TokenRange trange, Identifier identifier) {
    Location loc = identifier.location;

    while (true) {
        switch (trange.front.type) with (TokenType) {
            case Dot:
                trange.popFront();

                auto name = trange.front.name;
                trange.match(Identifier);

                loc.spanTo(trange.previous);
                identifier = new IdentifierDotIdentifier(loc, name, identifier);
                break;

            case Less:
                trange.popFront();

                assert(false, "TODO parse template arguments");
                //trange.match(More);
                //break;
                // TODO: template parsing

            default:
                return identifier;
        }
    }
}
