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
    private Token  m_currentToken;
    private Type[] m_types;
    
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

                case Token.Func:
                    writeln("parsing function");
                    handleFunction();
                    break;

                default:
                    writeln("Error! tok ", currToken);
                    nextToken();
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


    private PrototypeAST parsePrototype() {
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
            Arg arg = Arg(Type.init, identifier);
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

        return new PrototypeAST(name, args);
    }

    private FunctionAST parseFunction() {
        nextToken(2); // eat func + space

        auto proto = parsePrototype();
        needSpace();

        // ReturnType
        if (currToken == Token.ReturnType) {
            nextToken(); // eat ->
            needSpace();
            
            if (!checkType(currToken, identifier)) {
                logError("expression '%s' is not valid return type!", currToken);
            }

            writeln("return val = ", currToken);
            nextToken();
            needSpace();            
        }

        // Here start parsing ScopeAST
        if (currToken != Token.OpenScope) {
            throw new Exception("expected at end of the function {");
        }

        auto scope_ = parseScope();
        return new FunctionAST(null, scope_);
    }

    private TupleAST parseTuple() {
        // TODO
        return new TupleAST();
    }

    private ScopeAST parseScope() {
        nextToken();

        writeln("begin scope");
        while (currToken != Token.CloseScope) {
            nextToken();
        }

        nextToken();
        writeln("end scope");

        return new ScopeAST();
    }




    private void needSpace() {
        if (currToken != Token.Space) {
            logError("expected space!");
        }
        nextToken();
    }
    // TODO: add methods like needOpenScope, etc??

    private bool checkType(Token token, string identifier) {
        if (token == Token.Identifier) {
            foreach (x; m_types) {
                if (x.name == identifier) {
                    return true;
                }
            }

            m_types ~= Type(identifier, null); // Add symbol for lazy resolve
            return true;
        }
        
        return BasicTypes.contains(token);
    }

    private void logError(Args...)(string form, lazy Args args) {
        throw new Exception(format("Error(%s, %s): %s", row, col, format(form, args)));
        //writeln(format(form, args));
    }
}