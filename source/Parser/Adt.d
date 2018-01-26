module Parser.Adt;
@safe:

import Lexer;
import Tokens;
import Ast.Identifiers;
import Ast.Declaration;
import Domain.Name;
import Domain.Location;
import Parser.Utils;
import Parser.Declaration;
import Parser.Identifiers;


Declaration parseClass(ref TokenRange trange, StorageClass sc) {
    return trange.parsePolymorfic!true(sc);
}

Declaration parseInterface(ref TokenRange trange, StorageClass sc) {
    return trange.parsePolymorfic!false(sc);
}

private Declaration parsePolymorfic(bool isClass)(ref TokenRange trange, StorageClass sc) {
    Location loc = trange.front.location;

    static if (isClass) {
        trange.match(TokenType.Class);
        alias DeclarationType = ClassDeclaration;
    } else {
        trange.match(TokenType.Interface);
        alias DeclarationType = InterfaceDeclaration;
    }

    if (trange.front.type == TokenType.OpenParen) {
        assert(false, "TODO");
        // TODO: template params
    }

    auto name = trange.front.name;
    trange.match(TokenType.Identifier);

    Identifier[] bases;
    if (trange.front.type == TokenType.Colon) {
        do {
            trange.popFront();
            bases ~= trange.parseIdentifier();
        } while (trange.front.type == TokenType.Comma);
    }

    // TODO: parse constrant
    auto members = trange.parseAggregate();
    loc.spanTo(trange.previous);

    // TODO: return template... when templates will be implemented
    return new DeclarationType(loc, sc, name, bases, members);
}

Declaration parseStruct(ref TokenRange trange, StorageClass sc) {
    return trange.parseMonomorphic!true(sc);
}

Declaration parseUnion(ref TokenRange trange, StorageClass sc) {
    return trange.parseMonomorphic!true(sc);
}

private Declaration parseMonomorphic(bool isStruct)(ref TokenRange trange, StorageClass sc) {
    Location loc = trange.front.location;

    static if (isStruct) {
        trange.match(TokenType.Struct);
        alias DeclarationType = StructDeclaration;
    } else {
        trange.match(TokenType.Union);
        alias DeclarationType = UnionDeclaration;
    }

    Name name;
    if (trange.front.type == TokenType.Identifier) {
        name = trange.front.name;
        trange.popFront();

        if (trange.front.type == TokenType.OpenParen) {
            assert(false, "TODO implement template arguments");
            // TODO
        }
    }

    auto members = trange.parseAggregate();
    loc.spanTo(trange.previous);

    // TODO: template 
    return new DeclarationType(loc, sc, name, members);
}

Declaration parseEnum(ref TokenRange trange, StorageClass sc) {
    assert(sc.isEnum);


    return null; // TODO
}
