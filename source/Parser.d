module Parser;

import std.conv;
import std.array;
import std.format;
import std.stdio;
import std.ascii;
import std.algorithm.searching;

import AST;
import Lexer;
import Tokens;


class Parser : Lexer {
@safe:
    private Token m_currentToken;
    
    @property {
        Token currToken() const {
            return m_currentToken;
        }
    }

    this(File file) {
        super(file);
    }

    void parse() {
        while (true) {
            switch (currToken) {
                case Token.None, Token.EndLine:
                    nextToken();
                    break;

                case Token.Eof:
                    return;

                case Token.Func, Token.Final:
                    writeln("parsing function");
                    handleFunction();
                    break;

                case Token.For: // Testing
                    writeln("parsing for");
                    try parseFor();
                    catch (Exception e) writeln(e.msg);                    
                    break;

                default:
                    writeln("parsing variable");
                    try {
                        auto ret = parseVariable();
                        writeln(ret.generate);
                    }
                    catch (Exception e) writeln(e.msg);
            }
        }
    }

    Token nextToken(int eatNumber = 1) {
        foreach (i; 0 .. eatNumber) {
            m_currentToken = getToken();
        }

        return m_currentToken;
    }


    private void handleFunction() {
        try {
            auto func = parseFunction();
        } catch (Exception e) {
            writeln(e.msg);
        }
    }


    private PrototypeSymbol parsePrototype() {
        if (currToken != Token.Identifier) {
            logError("expected function identifier");
        }

        Arg[] args;
        string name = identifier;
        nextToken(); // eat identifier

        if (currToken != Token.OpenBracket) {
            logError("expected '(' not '%s'", currToken);
        }
        nextToken(); // eat (

        while (currToken == Token.Identifier) {
            Arg arg = Arg(null, identifier);
            nextToken(); // eat name

            if (currToken != Token.Colon) {
                logError("expected `:` after name declaration!");
            }
            nextToken(2); // eat colon + space

            // Looks for attrib like ref, const, etc.
            if (ArgAttrib.contains(currToken)) {
                writeln("found attrib ", currToken);
                arg.attrib = currToken;
                nextToken(2); // eat token + space after
            }

            if (currToken == Token.Identifier) {
                // We found an custom data type
                writeln("found custom type ", identifier);
                nextToken();
            } else if (BasicTypes.contains(currToken)) {
                // We found basic data type
                writeln("found basic type ", currToken);
                nextToken();
            } else if (currToken == Token.OpenBracket) {
                // we found tuple
                auto tuple = parseTuple();
                writeln("found tuple ");
                nextToken();
            } else {
                logError("Expected data type");
            }
            
            if (currToken == Token.OpenArray) {
                // We found an array of items
                // TODO: parse array: int[], int[42], int[string], int[][], etc.
                writeln("found array ");
                nextToken(2); // HACK: for arrays like []
            }

            args ~= arg;
            if (currToken == Token.Comma) {
                nextToken();
                needSpace();
            }
        }
            
        if (currToken != Token.CloseBracket) {
            logError("expected ')' not '%s'", currToken);
        }
        nextToken(); // eat )

        return new PrototypeSymbol(name, args);
    }

    private FunctionSymbol parseFunction() {
        bool isFinal;

        if (currToken == Token.Final) {
            isFinal = true;
            nextToken(2); // eat final + space

            if (currToken != Token.Func) {
                logError("expected 'func' keyword");
            }
        }
        nextToken(2); // eat func + space

        auto proto = parsePrototype();
        needSpace();

        // ReturnType
        if (currToken == Token.ReturnType) {
            nextToken(); // eat ->
            needSpace();
            
            if (!SymbolTable.current.findOrAddType(currToken, identifier)) {
                logError("expression '%s' is not valid return type!", currToken);
            }

            writeln("return val = ", currToken == Token.Identifier ? identifier : currToken.to!string);
            nextToken();
            needSpace();            
        }

        // Here start parsing ScopeSymbol
        if (currToken != Token.OpenScope) {
            throw new Exception("expected { at end of the function");
        }

        auto scope_ = parseScope();
        return new FunctionSymbol(proto, scope_);
    }

    private TupleSymbol parseTuple() {
        // TODO
        return new TupleSymbol(null);
    }

    private ScopeSymbol parseScope() {
        nextToken();

        writeln("begin scope");
        while (currToken != Token.CloseScope) {
            nextToken();
        }

        nextToken();
        writeln("end scope");

        return new ScopeSymbol();
    }


    private Symbol parseExpression() {
        assert(false);
    }

    private NumericSymbol parseNumber() {
        auto ret = new NumericSymbol(currToken, numeric);
        nextToken();

        return ret;
    }

    private StringSymbol parseString() {
        auto ret = new StringSymbol(identifier);
        nextToken();

        return ret;
    }

    private NumericSymbol parseBoolean() {
        auto sym = currToken;
        nextToken();

        return sym == Token.True ? new NumericSymbol(Token.Bool, 1) : new NumericSymbol(Token.Bool, 0); 
    }

    private Symbol parseBrackets() {
        nextToken(); // eat (
        auto ret = parseExpression();

        if (currToken != Token.CloseBracket) {
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

        if (currToken != Token.Identifier) {
            logError("variable name expected, not %s", currToken);
        }
        string var = identifier;
        nextToken(2); // eat identifier + space

        if (currToken != Token.In) {
            logError("expected `in`");
        }
        nextToken(2); // eat in + space

        if (currToken == Token.Identifier) {
            // currToken is var
            nextToken();
            needSpace();

            if (currToken == Token.Slice) {
                nextToken();
                needSpace();

                // currToken is var or constant
            }
        } else if (currToken == Token.Int) { // TODO: all numeric types
            double start = currToken;
            nextToken();
            needSpace();

            if (currToken != Token.Slice) {
                logError("expected `..`");
            }
            nextToken();
            needSpace();

            double end = currToken;
        } else {
            logError("Expected identifier or constant value not %s", currToken);
        }

        if (currToken != Token.OpenScope) {
            throw new Exception("expected { at end of the function");
        }
        auto scope_ = parseScope();

        return null;
    }

    // <type> <name>[ = <bool|numeric|string|object|tuple|delegate>]
    private VariableSymbol parseVariable() {
        auto st = SymbolTable.current;
        TypeSymbol type;

        if (currToken != Token.Var && currToken != Token.Let) {
            type = cast(TypeSymbol)st.findOrAddType(currToken, identifier);

            if (!type) {
                nextToken(); // eat wrong type identifier
                logError("%s is not valid type identifier", identifier);
            }
        }

        nextToken(2); // eat type + space
        if (currToken != Token.Identifier) {
            logError("expected variable identifier not %s", currToken);
        }
        auto name = identifier;
        Symbol value;
        nextToken();

        bool spaceAtEnd;
        if (currToken == Token.Space) {
            spaceAtEnd = true;
            nextToken(); // eat space
        }
        

        if (currToken == Token.EndLine && spaceAtEnd) {
            logError("redundant space at end of variable declaration");
        }

        if (currToken == Token.Blyat) {
            if (!spaceAtEnd) {
                logError("space needed between name identifier and assignment operator");
            }

            nextToken();
            needSpace();
            
            auto saveType = type;
            if (currToken == Token.True || currToken == Token.False) {
                type  = cast(TypeSymbol)st.findOrAddType(Token.Bool, null);
                value = parseBoolean();
            } else if (currToken == Token.StringExpr) {
                type  = cast(TypeSymbol)st.findOrAddType(Token.Char, "string"); //"let(char)[]"
                value = parseString();
            } else if (BasicTypes.contains(currToken)) {
                type  = cast(TypeSymbol)st.findOrAddType(currToken, identifier);
                value = parseNumber();
            } else if (currToken == Token.OpenBracket) {
                // TODO: get tuple type by value
                value = parseTuple();
            } else { // Add support for delegates
                logError("Unknow variable value %s", identifier);
            }

            if (saveType && saveType !is type) {
                logError("declaration type and initialization value mismatch %s != %s", saveType.name, type.name);
            }
        } else if (currToken != Token.EndLine) {
            logError("Undefined symbol %s", currToken);
        }

        if (!type) {
            logError("var or let needs initialization value");
        }

        return new VariableSymbol(type, name, value);
    }




    private void needSpace() {
        if (currToken != Token.Space) {
            logError("expected space not %s!", currToken);
        }
        nextToken();
    }
    // TODO: add methods like needOpenScope, etc??

    private void logError(Args...)(string form, lazy Args args) {
        throw new Exception(format("Error(%s, %s): %s", row, col, format(form, args)));
        //writeln(format(form, args));
    }
}