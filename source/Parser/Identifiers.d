module Parser.Identifiers;

import Lexer;
import Tokens;

import Ast.Identifiers;
import Domain.Location;
import Parser.Utils;


Identifier parseIdentifier(ref TokenRange trange) {
    Location loc = trange.front.location;

    auto name = trange.front.name;
    trange.match(TokenType.Identifier);

    return null;
}