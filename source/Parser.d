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
        if (token.type == TokenType.OpenScope) {
            nextToken();
            wasOpened = true;
        }

        auto ret = new ScopeSymbol;
        while (brackets) {
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
                    goto NRet;

                case TokenType.CloseScope:
                    goto NRet;

                case TokenType.Import:
                    ret.add(parseImport());
                    break;

                    // parse attribs for class, structs, etc. like this. e.g. const { ... }, override { ... }
          /*      case TokenType.Final: .. case TokenType.Const:
                    auto tok = *token;
                    nextToken();
                    needSpace();
                    parseScope(token.type == TokenType.OpenBracket);
                    break;
                    */

                case TokenType.Func:
                    ret.add(parseFunction());
                    break;

                case TokenType.For:
                    ret.add(parseFor());                    
                    break;

                case TokenType.Identifier:
                    if (peekNext == TokenType.Dot || peekNext == TokenType.OpenBracket) { // method call test.foo(), foo()
                        writeln("method call with ", token.str, " tok ", token.type);
                        nextToken();
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
        }

    NRet:
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
    // enum
    // union

    // Try catch finally
    // Debug,          // debug
    // Version,        // version


    private PrototypeSymbol parsePrototype() {
        if (token.type != TokenType.Func && token.type != TokenType.Task) {
            logError("expected 'func' or `task` keyword not '%s'", tokenToString(*token));
        }

        Token type = *token;
        nextToken(); // eat func
        needSpace();

        if (token.type != TokenType.Identifier) {
            logError("expected function identifier not '%s'", tokenToString(*token));
        }
        
        VariableSymbol[] args;
        string name = token.str;
        nextToken(); // eat identifier

        if (token.type != TokenType.OpenBracket) {
            logError("expected '(' not '%s'", tokenToString(*token));
        }
        nextToken(); // eat (

        while (token.type == TokenType.Identifier) {
            string argName = token.str;
            nextToken(); // eat name

            if (token.type != TokenType.Colon) {
                logError("expected `:` after name declaration not '%s'", tokenToString(*token));
            }
            nextToken(); // eat colon
            needSpace();

            args ~= new VariableSymbol(parseType(), argName);
            if (token.type == TokenType.Comma) {
                nextToken(); // eat ,
                needSpace();
            }
        }
            
        if (token.type != TokenType.CloseBracket) {
            logError("expected ')' not '%s'", tokenToString(*token));
        }
        nextToken(); // eat )

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





/*
    


    private Symbol parseBrackets() {
        nextToken(); // eat (
        auto ret = parseExpression();

        if (token.type != TokenType.CloseBracket) {
            logError("expected ')'");
        }
        nextToken();
        return ret;
    }
*/

    // for <identifier> in <identifier|number|object>[ .. <identifier|number|object>] {
    private Symbol parseFor() {
        nextToken(); // eat for
        needSpace();

        if (token.type != TokenType.Identifier) {
            logError("variable name expected, not %s", token.type);
        }

        auto sym1 = parsePrimary();
        needSpace();

        if (token.type != TokenType.In) {
            logError("expected `in`");
        }
        nextToken(); // eat in
        needSpace();
        auto sym2 = parsePrimary();
        needSpace();

        if (token.type != TokenType.OpenScope) {
            logError("expected { at end of the function not '%s'", tokenToString(*token));
        }
        
        auto scope_ = parseScope();
        return new ForSymbol(sym1, sym2, scope_);
    }


    //[<attribs|@identifier[<tuple>]>... ]<basic_type|var|let|identifier> <identifier>[ = <bool|numeric|string|object|tuple|delegate>]
    private VariableSymbol parseVariable() {
        auto type = parseType();
        needSpace();

        // Parse name      
        if (token.type != TokenType.Identifier) {
            logError("expected variable identifier not %s", token.type);
        }
        auto name = token.str;
        nextToken();

        // Check fore redundant space at the end of declaration
        bool spaceAtEnd;
        while (token.type == TokenType.Space) {
            nextToken(); // eat all spaces between <identifier> and =
            spaceAtEnd = true;
        }
        
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
                if (token.type == TokenType.OpenArray) {
                    nextToken(); // eat [
                    
                    Token assoc;
                    if (token.type != TokenType.CloseArray) {
                        assoc = *token;
                        nextToken(); // eat value inside []
                    }

                    if (token.type != TokenType.CloseArray) {
                        logError("expected ]");
                    }

                    nextToken(); // eat ]
                    ret = new ArrayTypeSymbol(ret, assoc);
                } else if (token.type == TokenType.Asterisk) {
                    nextToken(); // eat *
                    ret = new PointerTypeSymbol(ret);
                }
            }

            return ret;
        }

        // Parse attribs
        if (token.type.isAttribute || token.type == TokenType.At) {
            Symbol child;
            Token  attrib = *token;

            if (token.type == TokenType.At) {
                nextToken(); // eat @

                if (token.type != TokenType.Identifier) {
                    logError("identifier expected");
                }

                attrib = *token;
                // TODO: parse tuple for @identifier("Test", 42)
                // or deprecated("foo bar")
            }
            nextToken(); // eat attrib
            
            if (token.type == TokenType.OpenBracket) {
                nextToken(); // eat (
                child = parseType();

                if (token.type != TokenType.CloseBracket) {
                    logError(") expected");
                }
                nextToken(); // eat )
            } else if (token.type == TokenType.Space) {
                nextToken(); // eat space
                child = parseType();
            }

            auto ret = new AttribTypeSymbol(child, attrib);
            return parseArrayOrPtr(ret);
        }
        
        // Parse data type (TODO: accept tuple as data type)
        if (!token.type.isBasicType && token.type != TokenType.Identifier) {
            logError("Type expected, not '%s'", token.type);
        }
        Token type = *token;
        nextToken(); // eat type

        auto ret = new TypeSymbol(type);
        return parseArrayOrPtr(ret);
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

            if (token.type.isBasicTypeValue        || 
                token.type == TokenType.Identifier || 
                token.type == TokenType.StringExpr) {
                types ~= *token;
            }

            nextToken();
            if (token.type == TokenType.Comma) {
                nextToken();
                needSpace();
            } else if (token.type != TokenType.CloseBracket) {
                logError("comma required");
            }
        }

        nextToken(); // eat )
        return names.length ? new NamedTupleSymbol(names, types) : new TupleSymbol(types);
    }

    private Symbol parseIdentifier() {
        // TODO: return call/var identifier

        // if peek == ( its call
        // there can be classname.variable.call()

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

        if (peekNext2 == TokenType.Slice) {
            Symbol s1 = parseSlicePrimary();
            writeln("primary token for slice ", s1.generate);
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



    private void needSpace() {
        if (token.type != TokenType.Space) {
            logError("expected space not %s!", token.type);
        }
        nextToken();
    }
    // TODO: add methods like needOpenScope, etc??

    private void logError(Args...)(string form, lazy Args args) {
        auto str = format("Error(%s, %s): %s", row, col, format(form, args));
        nextToken(); // eat last token for error handling
        throw new Exception(str);
    }
}