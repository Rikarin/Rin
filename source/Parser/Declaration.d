module Parser.Declaration;
@safe:

import Tokens;
import Lexer;

import Ast.Type;
import Ast.Statement;
import Ast.Expression;
import Ast.Declaration;

import Domain.Name;
import Domain.Location;
import Common.Qualifier;

import Parser.Type;
import Parser.Utils;
import Parser.Statement;
import Parser.Expression;

import std.conv;


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

        case Static: goto case; // static if
        case Version: goto case;
        case Debug: goto case;
        //case Unsafe: goto case; // TODO: isn't this statement?
        case Mixin:
            assert(false, "TODO");

        case Using: return trange.parseUsing();

        default:
    }

    // Parse attributes
    AstExpression[] attribs;
    while (trange.front.type == TokenType.OpenBracket) {
        trange.popFront();

        do {
            attribs ~= trange.parseAssignExpression();
        } while (trange.front.type == TokenType.Comma);

        trange.match(TokenType.CloseBracket);
    }

    auto sc = trange.parsePrefixStorageClasses();
    switch (trange.front.type) with (TokenType) {
        case Identifier: // function, property or class's variable decl
            auto name = trange.front.name;
            trange.popFront();

            switch (trange.front.type) {
                case OpenParen: return trange.parseFunction(loc, sc, name, attribs);
                case Colon:     return trange.parseVariable(loc, sc, name, attribs);
                case MinusMore: return trange.parseProperty(loc, sc, name, attribs);

                default:
                    trange.match(OpenParen);
                    assert(false);
            }

        case Var:
            trange.popFront();
            auto name = trange.front.name;
            trange.match(Identifier);

            return trange.parseVariable(loc, sc, name, attribs);

        case Self:
            trange.popFront();
            return trange.parseFunction(loc, sc, BuiltinName!"__ctor", attribs);

        case Tilde:
            trange.popFront();
            trange.match(Self);
            return trange.parseFunction(loc, sc, BuiltinName!"__dtor", attribs);
        
        case Alias: goto case;
        case Unittest: goto case;
        case Class: goto case;
        case Struct: goto case;
        case Enum: goto case;
        case Interface: goto case;
        case Template: goto case;
        case Union: 
            assert(false, "TODO");

        default:
    }

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

    if (trange.front.type == TokenType.Partial) {
        trange.popFront();
        sc.isPartial = true;
    }

    if (trange.front.type == TokenType.External) {
        trange.popFront();
        assert(false); // TODO
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


void parsePostfixStorageClasses(ref TokenRange trange, ref StorageClass sc) {
    if (trange.front.type == TokenType.Pure) {
        sc.isPure = true;
    }

    if (trange.front.type == TokenType.Throws) {
        sc.isThrows = true;
    }

    if (trange.front.type == TokenType.Shared) {
        sc.qualifier = TypeQualifier.Shared;
    }

    switch (trange.front.type) with (TokenType) {
        case Const:    sc.qualifier = sc.qualifier.add(TypeQualifier.Const);    break;
        case ReadOnly: sc.qualifier = sc.qualifier.add(TypeQualifier.ReadOnly); break;
        case Inout:    sc.qualifier = sc.qualifier.add(TypeQualifier.Inout);    break;
        default:
    }
}


VariableDeclaration parseVariable(ref TokenRange trange, Location loc, StorageClass sc, Name name, AstExpression[] attribs) {
    AstType type;
    if (trange.front.type == TokenType.Colon) {
        trange.popFront();
        type = trange.parseType();
    }

    AstExpression value;
    if (trange.front.type == TokenType.Equal) {
        trange.popFront();
        value = trange.parseAssignExpression();
    } else if (type is null) {
        assert(false, "Value or type required");
    }

    trange.match(TokenType.Semicolon);
    loc.spanTo(trange.previous);
    return new VariableDeclaration(loc, sc, name, type, value);
}


Declaration parseFunction(ref TokenRange trange, Location loc, StorageClass sc, Name name, AstExpression[] attribs) {
    bool isVariadic;
    
    // TODO: parse template params

    auto params = trange.parseParameters(isVariadic);

    // constrain
    if (false && trange.front.type == TokenType.Where) { // TODO
        // TODO: parse constrain
    }

    trange.parsePostfixStorageClasses(sc);

    // return type
    AstType retType; // TODO: = AstType.getVoid();
    if (trange.front.type == TokenType.MinusMore) {
        trange.popFront();
        retType = trange.parseType();
    }

    auto block = trange.parseBlock();
    loc.spanTo(trange.previous);
    return new FunctionDeclaration(loc, sc, name, retType, params, isVariadic, block);
}


Declaration parseProperty(ref TokenRange trange, Location loc, StorageClass sc, Name name, AstExpression[] attribs) {
    trange.parsePostfixStorageClasses(sc);

    trange.match(TokenType.MinusMore);
    auto type = trange.parseType();

    auto block = trange.parseBlock();

    loc.spanTo(trange.previous);
    return new PropertyDeclaration(loc, sc, name, type, block);
}


auto parseParameters(ref TokenRange trange, out bool isVariadic) {
    trange.match(TokenType.OpenParen);
    
    ParamDecl[] params;
    switch (trange.front.type) with (TokenType) {
        case CloseParen:
            break;

        case DotDotDot:
            trange.popFront();
            isVariadic = true;
            break;

        default:
            params ~= trange.parseParameter();

            while (trange.front.type == Comma) {
                trange.popFront();

                if (trange.front.type == DotDotDot) {
                    goto case DotDotDot;
                }

                if (trange.front.type == CloseParen) {
                    goto case CloseParen;    
                }

                params ~= trange.parseParameter();
            }
    }

    trange.match(TokenType.CloseParen);
    return params;
}


// Parse one function parameter, e.g. name: Value = 42
private auto parseParameter(ref TokenRange trange) {
    Location loc = trange.front.location;
    Name name = trange.front.name;

    trange.match(TokenType.Identifier);
    trange.match(TokenType.Colon);

    bool exit;
    while (!exit) { 
        switch (trange.front.type) with (TokenType) {
            case In, Out, Ref, Lazy:
                assert(false, "TODO");

            default:
                exit = true;
                break;
        }
    }

    auto type = trange.parseType();
    AstExpression value;

    if (trange.front.type == TokenType.Equal) {
        trange.popFront();
        value = trange.parseAssignExpression();
    }

    loc.spanTo(trange.previous);
    return ParamDecl(loc, type, name, value);
}
