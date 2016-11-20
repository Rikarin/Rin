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
        while (true) {
            switch (token.type) {
                case TokenType.None, TokenType.EndLine:
                    nextToken();
                    break;

                case TokenType.Eof:
                    return;

           /*     case TokenType.Func, TokenType.Final:
                    writeln("parsing function");
                    handleFunction();
                    break;

                case TokenType.For: // Testing
                    writeln("parsing for");
                    try parseFor();
                    catch (Exception e) writeln(e.msg);                    
                    break;
*/
                default:
                    try {
                        auto ret = parseVariable();
                        writeln(ret.generate);
                    }
                    catch (Exception e) writeln(e.msg);
            }
        }
    }



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

    

    private ScopeSymbol parseScope() {
        nextToken();

        writeln("begin scope");
        while (token.type != TokenType.CloseScope) {
            nextToken();
        }

        nextToken();
        writeln("end scope");

        return new ScopeSymbol();
    }


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

    // for val in vals { ... }
    // for i in 0 .. 10 { ... }
    private Symbol parseFor() {
        nextToken(); // eat for
        needSpace();

        if (token.type != TokenType.Identifier) {
            logError("variable name expected, not %s", token.type);
        }
        string var = token.str;
        nextToken(2); // eat identifier + space

        if (token.type != TokenType.In) {
            logError("expected `in`");
        }
        nextToken(2); // eat in + space

        if (token.type == TokenType.Identifier) {
            // currToken is var
            nextToken();
            needSpace();

            if (token.type == TokenType.Slice) {
                nextToken();
                needSpace();

                // currToken is var or constant
            }
        } else if (token.type == TokenType.Int) { // TODO: all numeric types
            double start = token.type;
            nextToken();
            needSpace();

            if (token.type != TokenType.Slice) {
                logError("expected `..`");
            }
            nextToken();
            needSpace();

            double end = token.type;
        } else {
            logError("Expected identifier or constant value not %s", token.type);
        }

        if (token.type != TokenType.OpenScope) {
            throw new Exception("expected { at end of the function");
        }
        auto scope_ = parseScope();

        return null;
    }
*/


    //[<attribs|@identifier[<tuple>]>... ]<basic_type|var|let|identifier> <identifier>[ = <bool|numeric|string|object|tuple|delegate>]
    private VariableSymbol parseVariable() {
        Token[] attribs;

        // Parse attribs
        while (Attribs.contains(token.type) || token.type == TokenType.At) {
            if (token.type == TokenType.At) {
                nextToken();

                if (token.type != TokenType.Identifier) {
                    logError("identifier expected");
                }

                // TODO: parse tuple for @identifier
            }
            attribs ~= *token;
            nextToken();
        }
        
        // Parse data type (TODO: accept tuple as data type)
        if (!BasicTypes.contains(token.type) && !token.type.among(TokenType.Identifier, TokenType.Var, TokenType.Let)) {
            logError("Type expected, not '%s'", token.type);
        }
        Token type = *token;
        nextToken(); // eat type
        nextToken(); // eat space

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
            
            if (token.type == TokenType.True || token.type == TokenType.False) {
                value = parseBoolean();
            } else if (token.type == TokenType.StringExpr) {
                value = parseString();
            } else if (BasicTypeValues.contains(token.type)) {
                value = parseNumber();
            } else if (token.type == TokenType.OpenBracket) {
                value = parseTuple();
            } else { // Add support for delegates
                logError("Unknow variable value %s", token.type);
            }
        } else if (token.type != TokenType.EndLine) {
            logError("Undefined symbol %s", token.type);
        }

        return new VariableSymbol(type, name, attribs, value);
    }



    private NumericSymbol parseNumber() {
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
        nextToken();
        Token[] types;
        
        while (token.type != TokenType.CloseBracket) {
            if (BasicTypeValues.contains(token.type) || 
                token.type == TokenType.Identifier   || 
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

        nextToken();
        return new TupleSymbol(types); // or NamedTupleSymbol for (name: 42) tuple
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
        //writeln(format(form, args));
    }

    string currTokenString() {
        if (token.type == TokenType.Identifier) {
            return token.str;
        }

        if (token.type == TokenType.StringExpr) {
            return "\"" ~ token.str ~ "\"";
        }

        if (BasicTypes.contains(token.type)) {
            return token.uvalue.to!string;
        }

        return token.type.to!string;
    }
}