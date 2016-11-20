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

       /+ while (true) {
            switch (token.type) {
                case TokenType.None:
                case TokenType.EndLine:
                case TokenType.Space:
                    nextToken();
                    break;

                case TokenType.Eof:
                    return;

                case TokenType.Import:
                    parseImport();
                    break;

           /*     case TokenType.Func, TokenType.Final:
                    writeln("parsing function");
                    handleFunction();
                    break;
*/
                case TokenType.For:
                    parseFor();                    
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
                    auto ret = parseVariable();
                    writeln(ret.generate);
                    break;

                default:
                    writeln("Undefined token ", token.type);
                    nextToken();
            }
        }+/
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
    // for in
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

    // Func,           // func
    // Task,           // task
    // Try catch finally
    // Debug,          // debug
    // Version,        // version



/*
    private void handleFunction() {
        try {
            auto func = parseFunction();
        } catch (Exception e) {
            writeln(e.msg);
        }
    }


    private PrototypeSymbol parsePrototype() {
        if (token.type != TokenType.Identifier) {
            logError("expected function identifier");
        }

        Arg[] args;
        string name = token.str;
        nextToken(); // eat identifier

        if (token.type != TokenType.OpenBracket) {
            logError("expected '(' not '%s'", token.type);
        }
        nextToken(); // eat (

        while (token.type == TokenType.Identifier) {
            Arg arg = Arg(null, identifier);
            nextToken(); // eat name

            if (token.type != TokenType.Colon) {
                logError("expected `:` after name declaration!");
            }
            nextToken(2); // eat colon + space

            // Looks for attrib like ref, const, etc.
            if (ArgAttrib.contains(token.type)) {
                writeln("found attrib ", token.type);
                arg.attrib = token.type;
                nextToken(2); // eat token + space after
            }

            if (token.type == TokenType.Identifier) {
                // We found an custom data type
                writeln("found custom type ", token.str);
                nextToken();
            } else if (BasicTypes.contains(token.type)) {
                // We found basic data type
                writeln("found basic type ", token.type);
                nextToken();
            } else if (token.type == TokenType.OpenBracket) {
                // we found tuple
                auto tuple = parseTuple();
                writeln("found tuple ");
                nextToken();
            } else {
                logError("Expected data type");
            }
            
            if (token.type == TokenType.OpenArray) {
                // We found an array of items
                // TODO: parse array: int[], int[42], int[string], int[][], etc.
                writeln("found array ");
                nextToken(2); // HACK: for arrays like []
            }

            args ~= arg;
            if (token.type == TokenType.Comma) {
                nextToken();
                needSpace();
            }
        }
            
        if (token.type != TokenType.CloseBracket) {
            logError("expected ')' not '%s'", token.type);
        }
        nextToken(); // eat )

        return new PrototypeSymbol(name, args);
    }

    private FunctionSymbol parseFunction() {
        bool isFinal;

        if (token.type == TokenType.Final) {
            isFinal = true;
            nextToken(2); // eat final + space

            if (token.type != TokenType.Func) {
                logError("expected 'func' keyword");
            }
        }
        nextToken(2); // eat func + space

        auto proto = parsePrototype();
        needSpace();

        // ReturnType
        if (token.type == TokenType.ReturnType) {
            nextToken(); // eat ->
            needSpace();
            
            if (!SymbolTable.current.findOrAddType(token.type, token.str)) {
                logError("expression '%s' is not valid return type!", token.type);
            }

            writeln("return val = ", token.type == TokenType.Identifier ? token.str : token.type.to!string);
            nextToken();
            needSpace();            
        }

        // Here start parsing ScopeSymbol
        if (token.type != TokenType.OpenScope) {
            throw new Exception("expected { at end of the function");
        }

        auto scope_ = parseScope();
        return new FunctionSymbol(proto, scope_);
    }

    */

    private ScopeSymbol parseScope() {
        if (token.type == TokenType.OpenScope) { // This can be called from global scope where is no { }
            nextToken();
        }

        auto ret = new ScopeSymbol;
        while (true) {
            switch (token.type) {
                case TokenType.None:
                case TokenType.EndLine:
                case TokenType.Space:
                    nextToken();
                    break;

                case TokenType.Eof:
                case TokenType.CloseScope:
                    goto NRet;

                case TokenType.Import:
                    ret.add(parseImport());
                    break;

           /*     case TokenType.Func, TokenType.Final:
                    writeln("parsing function");
                    handleFunction();
                    break;
*/
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

/*
    private Symbol parseExpression() {
        assert(false);
    }


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

    // for val in vals { ... }
    // for i in 0 .. 10 { ... }
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
            throw new Exception("expected { at end of the function");
        }
        
        auto scope_ = parseScope();

        //writeln("for " ~ sym1.generate ~ " in " ~ (sym2 ? sym2.generate : ""));
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
        if (token.type == TokenType.Space) {
            spaceAtEnd = true;
            nextToken(); // eat space
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
        if (!token.type.isBasicType && !token.type != TokenType.Identifier) {
            logError("Type expected, not '%s'", token.type);
        }
        Token type = *token;
        nextToken(); // eat type

        auto ret = new TypeSymbol(type);
        return parseArrayOrPtr(ret);
    }

    private NumericSymbol parseNumber() {
        // TODO: peekNext2 == .. its numeric range
        auto ret = new NumericSymbol(token.type, token.rvalue);
        nextToken();

        return ret;
    }

    private StringSymbol parseString() {
        auto ret = new StringSymbol(token.str);
        nextToken();

        return ret;
    }

    private NumericSymbol parseBoolean() {
        auto sym = token.type;
        nextToken();

        return sym == TokenType.True ? new NumericSymbol(TokenType.True, 1) : new NumericSymbol(TokenType.False, 0); 
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