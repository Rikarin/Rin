module Parser.Ambigous;

import Lexer;
import Tokens;

import Ast.Statement;
import Ast.Declaration;
import Domain.Location;

import Parser.Declaration;


auto parseAmbigousStatement(ref TokenRange trange) {
    switch (trange.front.type) with (TokenType) {
        case Var:
            auto decl = trange.parseDeclaration();
            return trange.finalizeStatement(decl.location, decl);

        default:
            return null; // TODO
    }
}


Statement finalizeStatement(T)(ref TokenRange trange, Location loc, T parsed) {
    static if (is(T : Declaration)) {
        return new DeclarationStatement(loc, parsed);
    }
}