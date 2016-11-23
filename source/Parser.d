module Parser;

import std.conv;
import std.array;
import std.format;
import std.stdio;
import std.ascii;
import std.algorithm.searching;
import std.algorithm.comparison;
import std.string;

import AST;
import Lexer;
import Tokens;


class Parser : Lexer {
@safe:
    private static immutable int[TokenType] m_precedence;
    private ScopeSymbol m_globalScope;
    private Symbol      m_currentScope;

    @property {
        ScopeSymbol globalScope() {
            return m_globalScope;
        }

        Symbol currScope() {
            return m_currentScope;
        }
    }

    shared static this() {
        m_precedence = [
            TokenType.Blyat:    5,
            //TokenType.: 10, // token >
            //'>': 10,
            TokenType.Plus:     20,
            TokenType.Minus:    20,
            TokenType.Asterisk: 40,
            //TokenType.: 40, // token /
            // '%': 40,
        ];
    }

    this(const(char)[] buffer) {
        super(buffer);
    }

    void parse() {
        auto sc = parseScope();
        writeln(sc.generate());
    }

    private ScopeSymbol parseScope(bool brackets = true) {
        // This can be called from global scope where is no { }
        bool wasOpened;
        if (tryToken(TokenType.OpenScope)) {
            wasOpened = true;
        }

        auto ret = new ScopeSymbol;
        do {
            switch (token.type) {
                case TokenType.None:
                case TokenType.EndLine:
                case TokenType.Space:
                    nextToken();
                    break;

                case TokenType.Eof:
                    if (wasOpened) {
                        logError("expected } at the end of line");
                    }
                    return ret;

                case TokenType.CloseScope:
                    nextToken(); // eat }
                    return ret;

                case TokenType.Import:
                    ret.add(parseImport());
                    break;

                // parse attribs for class, structs, etc. like this. e.g. const { ... }, override { ... }
                case TokenType.Class: .. case TokenType.Version:
                    ret.add(parseScopeAttribs());
                    break;

                case TokenType.Func:
                    ret.add(parseFunction());
                    break;

                case TokenType.For:
                    ret.add(parseFor());
                    break;

                case TokenType.Enum:
                    ret.add(parseEnum());
                    break;

                case TokenType.Identifier: // we cannot determine here if it is 'const AnyClass variable' or 'variable += AnyClass()'
                // or test.className.variable++;
                    if (peekNext == TokenType.Dot || peekNext == TokenType.OpenBracket/* || peekNext2 == TokenType.Blyat*/) {
                        writeln("method call with ", token.str, " tok ", token.type);
                        ret.add(parseIdentifier()); // TODO: parse expression, cuz it can be 'test.call = 42'
                    } else {
                        goto case TokenType.At;
                    }
                    break;

                case TokenType.At:
                case TokenType.Ref: .. case TokenType.Lazy:
                case TokenType.Var: .. case TokenType.Real:
                    ret.add(parseVariable());
                    break;

                default:
                    writeln("Undefined token ", token.type);
                    nextToken();
            }
        } while (brackets);

        return ret;
    }


    private ImportSymbol parseImport() {
        nextToken(); // eat import
        needSpace();
        string[] stages;

        while (token.type != TokenType.EndLine) {
            if (token.type == TokenType.Identifier) {
                stages ~= token.str;
            } else if (token.type != TokenType.Dot) {
                logError("expected identifier separated by dots not %s", tokenToString(*token));
            }
            nextToken();
        }

        return new ImportSymbol(stages);
    }

    private AttribScopeSymbol parseScopeAttribs() {
        auto tok = *token;
        nextToken();
        
        Symbol val;
        if (token.type == TokenType.OpenBracket) {
            val = parseTuple();
        }

        needSpace();
        auto sc = parseScope(token.type == TokenType.OpenScope);
        return new AttribScopeSymbol(tok, val, sc);
    }




    // TODO: enum should be flaggs
    private Symbol parseEnum() {
        Token type = Token(TokenType.UInt);
        nextToken(); // eat enum
        needSpace();
        
        string name = token.str;
        nextToken(); // eat identifier
        needSpace();

        // enum foo = "value"
        if (tryToken(TokenType.Blyat)) { // eat =
            needSpace();

            Symbol val = parsePrimary();
            return null; // type, name, val
        } else if (tryToken(TokenType.Colon)) { // eat :
            needSpace();

            if (token.type != TokenType.Identifier && !token.type.isBasicType) { // TODO: refactor required
                logError("enum size expected after : not '%s'", tokenToString(*token));
            }
            type = *token;
            nextToken();
            needSpace();
        }

        needToken(TokenType.OpenScope);
        string[] names;
        Token[]  values;
        while (true) {
            switch (token.type) with(TokenType) {
                case Space, EndLine:
                    nextToken(); // eat space|end_line
                    break;

                case Eof:
                    logError("end of file reached need }");
                    break;

                case CloseScope:
                    goto NRet;

                case Identifier:
                    names ~= token.str;
                    nextToken(); // eat identifier

                    if (token.type == TokenType.OpenBracket) {
                        // Token is tuple like Value(int, int, string) = 42
                        // parse type tuple
                    }
                    eatAllSpaces();

                    if (tryToken(TokenType.Blyat)) { // eat =
                        eatAllSpaces();
                        values ~= *token;
                        nextToken();
                    } else {
                        values ~= Token.init;
                    }

                    needToken(TokenType.Comma);
                    break;

                default:
                    logError("expected identifier not '%s'", tokenToString(*token));
            }
        }

    NRet:
        return new EnumSymbol(name, type, names, values);
    }


    // TODO: parse binary expressions!!

    // assert, enforce, asm
    // if else
    // continue break
    // while repeat
    // switch case default
    // lock define as __rin_lock? explained in Proposal4

    // module
    // alias
    // class
    // struct
    // protocol
    // extend
    // union
    
    // type tuple parser

    // maybe parse version and debug separately becasue they can have else statement version(a) { } else { }
    // Try catch finally
    // primary symbol array & associative array
    // parse binary & unary expr
    // whats about .glob.mthod.call()
    // delegates

    // Named symbols: class|struct|enum|var|protocol|extend|union|alias


    private PrototypeSymbol parsePrototype() {
        Token type = needToken(TokenType.Func, TokenType.Task); // eat func|task
        needSpace();
        
        VariableSymbol[] args;
        string name = needToken(TokenType.Identifier).str; // eat identifier
        
        needToken(TokenType.OpenBracket); // eat (
        while (token.type == TokenType.Identifier) {
            string argName = token.str;
            nextToken(); // eat name
            needToken(TokenType.Colon);
            needSpace();

            args ~= new VariableSymbol(parseType(), argName);
            if (tryToken(TokenType.Comma)) { // eat ,
                needSpace();
            }
        }
        needToken(TokenType.CloseBracket);

        // Parse attribs
        Token[] attribs;
        while (peekNext == TokenType.Throws) {
            needSpace();
            attribs ~= *token;
            nextToken();
        }

        // Parse return type
        Symbol retType;
        if (peekNext == TokenType.ReturnType) {
            needSpace();
            nextToken(); // eat ->
            needSpace();
            retType = parseType();
        }

        return new PrototypeSymbol(name, args, retType);
    }

    private Symbol parseFunction() {
        auto proto = parsePrototype();
        needSpace();

        // Scope
        if (token.type != TokenType.OpenScope) {
            return proto;
        }

        auto scope_ = parseScope();
        return new FunctionSymbol(proto, scope_);
    }

    // for <identifier> in <identifier|number|object>[ .. <identifier|number|object>] {
    private Symbol parseFor() {
        nextToken(); // eat for
        needSpace();

        // parse identifier
        lookToken(TokenType.Identifier);
        auto sym1 = parsePrimary();
        needSpace();

        needToken(TokenType.In);
        needSpace();
        auto sym2 = parsePrimary();
        needSpace();

        lookToken(TokenType.OpenScope);
        auto scope_ = parseScope();
        return new ForSymbol(sym1, sym2, scope_);
    }


    //[<attribs|@identifier[<tuple>]>... ]<basic_type|var|let|identifier> <identifier>[ = <bool|numeric|string|object|tuple|delegate>]
    private VariableSymbol parseVariable() {
        auto type = parseType();
        needSpace();

        // Parse name
        auto name = needToken(TokenType.Identifier).str;

        // Check fore redundant space at the end of declaration
        bool spaceAtEnd = eatAllSpaces() != 0;        
        if (token.type == TokenType.EndLine && spaceAtEnd) {
            logError("redundant space at end of variable declaration");
        }

        // Parse value assignment
        Symbol value;
        if (token.type == TokenType.Blyat) {
            if (!spaceAtEnd) {
                logError("space needed between name identifier and assignment operator");
            }
            
            nextToken();
            needSpace();
            value = parsePrimary();
        } else if (token.type != TokenType.EndLine && token.type != TokenType.Eof) {
            logError("Undefined symbol %s", token.type);
        }

        return new VariableSymbol(type, name, value);
    }


    private Symbol parseType() {
        Symbol parseArrayOrPtr(Symbol s) {
            Symbol ret = s;

            while (token.type == TokenType.OpenArray || token.type == TokenType.Asterisk) {
                if (tryToken(TokenType.OpenArray)) { // eat [
                    Token assoc;
                    if (token.type != TokenType.CloseArray) {
                        if (token.type == TokenType.StringExpr) {
                            logError("string expression cannot be as a array parameter");
                        }
                        assoc = *token;
                        nextToken(); // eat value inside []
                    }

                    needToken(TokenType.CloseArray); // eat ]
                    ret = new ArrayTypeSymbol(ret, assoc);
                } else if (tryToken(TokenType.Asterisk)) { // eat *
                    ret = new PointerTypeSymbol(ret);
                }
            }

            return ret;
        }

        // Parse attribs
        if (token.type.isAttribute || token.type == TokenType.At) {
            Symbol child;
            Token  attrib = *token;

            if (tryToken(TokenType.At)) { // eat @
                attrib = needToken(TokenType.Identifier);
                // TODO: parse tuple for @identifier("Test", 42)
                // or deprecated("foo bar")
            }
            nextToken(); // eat attrib
            
            if (tryToken(TokenType.OpenBracket)) { // eat (
                child = parseType();
                needToken(TokenType.CloseBracket); // eat )
            } else if (tryToken(TokenType.Space)) { // eat space
                child = parseType();
            }

            auto ret = new AttribTypeSymbol(child, attrib);
            return parseArrayOrPtr(ret);
        }
        
        // Parse data type (TODO: accept tuple as data type)
        // TODO: define basic types as array and use needToken(...);
        if (!token.type.isBasicType && token.type != TokenType.Identifier) {
            logError("Type expected, not '%s'", token.type);
        }
        Token type = *token;
        bool isMonad;
        nextToken(); // eat type

        if (tryToken(TokenType.Monad)) { // eat ?
            isMonad = true;
        }

        auto ret = new TypeSymbol(type, isMonad);
        return parseArrayOrPtr(ret); // parse [] or * after type
    }

    private Symbol parseNumber() {
        auto ret = new NumericSymbol(*token);
        nextToken(); // eat number

        return ret;
    }

    private StringSymbol parseString() {
        auto ret = new StringSymbol(token.str);
        nextToken();

        return ret;
    }

    private NumericSymbol parseBoolean() {
        auto ret = new NumericSymbol(*token);
        nextToken(); // eat true/false
        
        return ret; 
    }

    // ... = ([[<identifier>: ]... <identifier|string|bool|numeric|delegate|tuple>])
    private TupleSymbol parseTuple() {
        nextToken(); // eat (
        string[] names;
        Token[]  types;
        
        while (token.type != TokenType.CloseBracket) {
            if (token.type == TokenType.Identifier && peekNext == TokenType.Colon) { // named tuple 
                if (types.length && !names.length) {
                    logError("tuple parameters name mismatch!");
                }

                names ~= token.str;
                nextToken(); // eat name
                nextToken(); // eat :
                needSpace();
            } else if (names.length) {
                logError("tuple parameter name expected");
            }

            if (!token.type.isBasicTypeValue       && 
                token.type != TokenType.Identifier && 
                token.type != TokenType.StringExpr) {
                logError("expected value types not '%s'", tokenToString(*token));
            }

            types ~= *token;
            nextToken(); // eat value
            if (tryToken(TokenType.Comma)) { // eat ,
                needSpace();
            } else if (token.type != TokenType.CloseBracket) {
                logError("comma required");
            }
        }

        nextToken(); // eat )
        return names.length ? new NamedTupleSymbol(names, types) : new TupleSymbol(types);
    }

    private Symbol parseIdentifier() {
        string[] stages;
        while (peekNext == TokenType.Dot) {
            stages ~= token.str;
            nextToken(); // eat identifier
            nextToken(); // eat .
        }

        if (peekNext == TokenType.OpenBracket) {
            string name = token.str;
            nextToken(); // eat identifier
            nextToken(); // eat (

            string[] argName;
            Symbol[] vals;
            while (token.type.among(TokenType.Identifier, TokenType.StringExpr) || token.type.isBasicTypeValue) {
                if (token.type == TokenType.Identifier && peekNext == TokenType.Colon) {
                    argName ~= token.str;
                    nextToken(); // eat identifier
                    nextToken(); // eat colon
                    needSpace();
                } else if (argName.length) {
                    logError("argument name expected!");
                }

                vals ~= parsePrimary();
                if (token.type != TokenType.CloseBracket) {
                    needToken(TokenType.Comma); // eat ,
                    needSpace();
                }
            }

            needToken(TokenType.CloseBracket);
            nextToken();
            return new CallExprSymbol(stages, name, argName, vals);
        }

        auto ret = new VariableSymbol(null, token.str);
        nextToken();
        return ret;
    }

    private Symbol parsePrimary() {
        Symbol parseSlicePrimary() {
            switch (token.type) with (TokenType) {
                case CharValue: .. case RealValue:
                    return parseNumber();

                case Identifier:
                    return parseIdentifier();

                default:
                    logError("Unknown variable value %s", tokenToString(*token));
                    return null;
            }
        }

        if (peekNext2 == TokenType.DotDot) {
            Symbol s1 = parseSlicePrimary();
            needSpace();
            nextToken(); // eat ..
            needSpace();

            Symbol s2 = parseSlicePrimary();
            return new RangeSymbol(s1, s2);
        }

        switch (token.type) with (TokenType) {
            case True, False:
                return parseBoolean();

            case StringExpr:
                return parseString();

            case CharValue: .. case RealValue:
                return parseNumber();

            case OpenBracket:
                return parseTuple();

            case OpenArray:
                return null; // TODO

            case Identifier:
                return parseIdentifier();

            default:
                logError("Unknown variable value %s", tokenToString(*token));
                return null;
        }
    }

    private Symbol parseExpression() {
        // parse unary & binary expressions
        // assert(expression, string literal)
        assert(false);
    }



    private Token needToken(TokenType[] type...) {
        if (type.countUntil(token.type) == -1) {
            Token t = Token(type[0]); // TODO
            logError("expected '%s' not '%s'", tokenToString(t), tokenToString(*token));
        }

        Token ret = *token;
        nextToken();
        return ret;
    }

    private void lookToken(TokenType[] type...) {
        if (type.countUntil(token.type) == -1) {
            Token t = Token(type[0]); // TODO
            logError("expected '%s' not '%s'", tokenToString(t), tokenToString(*token));
        }
    }

    private bool tryToken(TokenType[] type...) {
        if (type.countUntil(token.type) == -1) {
            return false;
        }

        nextToken();
        return true;
    }

    private void needSpace() {
        if (token.type != TokenType.Space) {
            logError("expected space not %s!", token.type);
        }
        nextToken();
    }

    private int eatAllSpaces() {
        int ret;

        while (token.type == TokenType.Space) {
            nextToken();
            ret++;
        }

        return ret;
    }
    // TODO: add methods like needOpenScope, etc??

    private void logError(Args...)(string form, lazy Args args) {
        auto str = format("Error(%s, %s): %s", row, col, format(form, args));
        nextToken(); // eat last token for error handling
        throw new Exception(str);
    }
}