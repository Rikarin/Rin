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

        case Var:
            trange.popFront();
            auto name = trange.front.name;
            trange.match(Identifier);

            AstType type;
            if (trange.front.type == Colon) {
                trange.popFront();
                type = trange.parseType();
            }

            AstExpression value;
            if (trange.front.type == Equal) {
                trange.popFront();
                value = trange.parseAssignExpression();
            } else if (type is null) {
                assert(false, "Value or type required");
            }
        
            // TODO: finish this
            goto case; // local variable

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
    if (trange.front.type == TokenType.OpenBracket) {
        trange.popFront();

        while (trange.front.type != TokenType.CloseBracket) {
            trange.popFront(); // TODO: imeplement this
        }

        trange.match(TokenType.CloseBracket);
        // TODO
    }

    auto sc = trange.parsePrefixStorageClasses();
    switch (trange.front.type) with (TokenType) {
        case Identifier: // function, property or class's variable decl
            auto name = trange.front.name;
            trange.popFront();

            switch (trange.front.type) {
                case OpenParen: // Func
                    return trange.parseFunction(loc, sc, null, name);

                case Colon: // Variable
                    break;

                case MinusMore: // Property
                    break;

                default:
                    trange.match(OpenParen);
            }
            break;

        // func() -> bool { }
        // prop -> bool { get; set; }
        // var: int;


        
        case Class: goto case;
        case Struct: goto case;
        case Enum: goto case;
        case Interface: goto case;
        case Template: goto case;
        case Self: goto case; // constructor
        case Tilde: goto case; // destructor
        case Alias: goto case;
        case Unittest: goto case;
        case Union: 
assert(false, "TODO");

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







private Declaration parseFunction(ref TokenRange trange, Location loc, StorageClass sc, AstType type, Name name) {
    bool isVariadic;
    
    // TODO: parse template params

    // TODO: parse parameters
    auto params = trange.parseParameters(isVariadic);

    if (false && trange.front.type == TokenType.Where) { // TODO
        // TODO: parse constrain
    }


    // TODO: parse post attributes: throws, pure
    // const, ref, shared, readonly, nogc, pure, inout

    if (trange.front.type == TokenType.Pure) {
        sc.isPure = true;
    }


    auto block = trange.parseBlock();

    return null;
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
