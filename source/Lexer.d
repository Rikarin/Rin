module Lexer;

import std.conv;
import std.array;
import std.stdio;
import std.ascii;
import std.algorithm.searching;

import Tokens;


class Lexer {
@safe:
    private File m_file;
    private const(char)* m_ptr;

    private Token m_token;

    private int m_row;
    private int m_col;

    @property {
        int row() const {
            return m_row;
        }

        int col() const {
            return m_col;
        }

        private char nextChar() @trusted {
            assert(*m_ptr != '\0', "End of the line reached!");
            m_col++;
            return *m_ptr++;
        }
        
        private char peekChar(int offset = 0) @trusted {
            return m_ptr[offset];
        }

        private char currChar() @trusted {
            return *m_ptr;
        }

        Token* token() {
            return &m_token;
        }
    }

    this(const(char)[] buffer) {
        m_ptr = &buffer[0];
    }

    final TokenType nextToken() {
        import core.stdc.string: memcpy;
        import core.stdc.stdlib: free;

        if (m_token.next) {
            auto t = m_token.next;
            () @trusted {
                memcpy(&m_token, t, Token.sizeof);
                //TODO t.free();
            }();
        } else {
            scan(&m_token);
        }

        return m_token.type;
    }

    final TokenType peekNext() {
        return peek(&m_token).type;
    }

    final TokenType peekNext2() {
        return peek(peek(&m_token)).type;
    }

    private Token* peek(Token* tok) {
        if (tok.next) {
            return tok.next;
        }

        auto t = new Token;
        scan(t);
        tok.next = t;
        return t;
    }

    // Always end this function with new token in the buffer
    void scan(Token* tok) @trusted {
        *tok = Token.init;

        switch (currChar) {
            case 0:
            case 0x1A:
                tok.type = TokenType.Eof;
                break;

            case ' ':
                nextChar();
                tok.type = TokenType.Space;
                break;

            case '\t':
                nextChar();
                tok.type                = TokenType.Space;
                tok.next                = new Token(TokenType.Space);
                tok.next.next           = new Token(TokenType.Space);
                tok.next.next.next      = new Token(TokenType.Space);
                break; 

            case '\n', '\r':
                m_col = 0;
                m_row++;
                nextChar();
                tok.type = TokenType.EndLine;
                break;

            case '0': .. case '9':
                if (!peekChar(1).isDigit) {
                    tok.uvalue = currChar;
                    tok.type   = TokenType.IntValue;
                    nextToken();
                    break;
                }
                tok.type = parseNumeric(tok);
                break;

            case 'A': .. case 'Z':
            case 'a': .. case 'z':
            case '_':
                parseIdentifier(tok);
                break;

            case '"':
            case '\'':
            case '`':
                parseString(tok);
                break;

            case '(': nextChar(); tok.type = TokenType.OpenBracket;  break;
            case ')': nextChar(); tok.type = TokenType.CloseBracket; break;
            case '{': nextChar(); tok.type = TokenType.OpenScope;    break;
            case '}': nextChar(); tok.type = TokenType.CloseScope;   break;
            case '[': nextChar(); tok.type = TokenType.OpenArray;    break;
            case ']': nextChar(); tok.type = TokenType.CloseArray;   break;

            case ':': nextChar(); tok.type = TokenType.Colon;        break;
            case ',': nextChar(); tok.type = TokenType.Comma;        break;
            case '@': nextChar(); tok.type = TokenType.At;           break;
            case '*': nextChar(); tok.type = TokenType.Asterisk;     break;

            case '.':
                if (peekChar(1).isDigit) {
                    tok.type = parseNumeric(tok);
                    break;
                }

                nextChar();
                if (currChar == '.') {
                    nextChar();
                    tok.type = TokenType.Slice; // ..
                } else {
                    tok.type = TokenType.Dot;
                }
                break;

            case '-':
                nextChar();
                if (currChar == '>') {
                    nextChar();
                    tok.type = TokenType.ReturnType;
                } else {
                    tok.type = TokenType.Minus;
                }
                break;

            case '?':
                nextChar();
                if (currChar == '.') {
                    nextChar();
                    tok.type = TokenType.MonadDeref;
                } else {
                    tok.type = TokenType.Monad;
                }
                break;

            case '=':
                nextChar();
                if (currChar == '=') {
                    nextChar();
                    tok.type = TokenType.Equal;
                } else {
                    tok.type = TokenType.Blyat;
                }
                break;

            case '!':
                nextChar();
                if (currChar == '=') {
                    nextChar();
                    tok.type = TokenType.NotEqual;
                } else if (currChar == 'i' && peekChar(1) == 's') {
                    nextChar();
                    nextChar();
                    tok.type = TokenType.NotIs;
                } else {
                    tok.type = TokenType.Not;
                }
                break;

            default:
                assert(false, "Unexpected character " ~ cast(int)currChar);
        }
    }

    private void parseString(Token* tok) {
        Appender!(char[]) buf;
        auto c = currChar; // can be ' " `
        nextChar();

        while (currChar != c) {
            buf.put(currChar);
            nextChar();
        }

        nextChar();
        if (currChar == 'w' || currChar == 'd') {
            tok.postfix = currChar;
            nextChar();
        }
        
        () @trusted {
            tok.type = TokenType.StringExpr;
            tok.str  = buf.data.to!string;
        }();
    }

    private void parseIdentifier(Token* tok) {
        Appender!(char[]) buf;

        do {
            buf.put(nextChar);
        } while (currChar.isAlphaNum || currChar == '_');

        switch (buf.data) {
            case "true":       tok.type = TokenType.True;       break;
            case "false":      tok.type = TokenType.False;      break;
            case "null":       tok.type = TokenType.Null;       break;
            case "assert":     tok.type = TokenType.Assert;     break;
            case "enforce":    tok.type = TokenType.Enforce;    break;
            case "asm":        tok.type = TokenType.Asm;        break;

            // Vars
            case "var":        tok.type = TokenType.Var;        break;
            case "let":        tok.type = TokenType.Let;        break;
            case "void":       tok.type = TokenType.Void;       break;
            case "bool":       tok.type = TokenType.Bool;       break;
            case "char":       tok.type = TokenType.Char;       break;
            case "wchar":      tok.type = TokenType.WChar;      break;
            case "dchar":      tok.type = TokenType.DChar;      break;
            case "byte":       tok.type = TokenType.Byte;       break;
            case "ubyte":      tok.type = TokenType.UByte;      break;
            case "short":      tok.type = TokenType.Short;      break;
            case "ushort":     tok.type = TokenType.UShort;     break;
            case "int":        tok.type = TokenType.Int;        break;
            case "uint":       tok.type = TokenType.UInt;       break;
            case "long":       tok.type = TokenType.Long;       break;
            case "ulong":      tok.type = TokenType.ULong;      break;
            case "float":      tok.type = TokenType.Float;      break;
            case "double":     tok.type = TokenType.Double;     break;
            case "real":       tok.type = TokenType.Real;       break;

            case "is":         tok.type = TokenType.Is;         break;
            case "if":         tok.type = TokenType.If;         break;
            case "else":       tok.type = TokenType.Else;       break;
            case "while":      tok.type = TokenType.While;      break;
            case "repeat":     tok.type = TokenType.Repeat;     break;
            case "for":        tok.type = TokenType.For;        break;
            case "switch":     tok.type = TokenType.Switch;     break;
            case "case":       tok.type = TokenType.Case;       break;
            case "default":    tok.type = TokenType.Default;    break;
            case "break":      tok.type = TokenType.Break;      break;
            case "continue":   tok.type = TokenType.Continue;   break;
            case "lock":       tok.type = TokenType.Lock;       break;

            // classes, etc
            case "import":     tok.type = TokenType.Import;     break;
            case "module":     tok.type = TokenType.Module;     break;
            case "alias":      tok.type = TokenType.Alias;      break;
            case "class":      tok.type = TokenType.Class;      break;
            case "struct":     tok.type = TokenType.Struct;     break;
            case "protocol":   tok.type = TokenType.Protocol;   break;
            case "extend":     tok.type = TokenType.Extend;     break;
            case "enum":       tok.type = TokenType.Enum;       break;
            case "union":      tok.type = TokenType.Union;      break;
        
            // Funcs, etc
            case "func":       tok.type = TokenType.Func;       break;
            case "task":       tok.type = TokenType.Task;       break;
            case "return":     tok.type = TokenType.Return;     break;
            case "throws":     tok.type = TokenType.Throws;     break;
            case "final":      tok.type = TokenType.Final;      break;
            case "self":       tok.type = TokenType.Self;       break;
            case "as":         tok.type = TokenType.As;         break;
            case "in":         tok.type = TokenType.In;         break;
            case "throw":      tok.type = TokenType.Throw;      break;
            case "try":        tok.type = TokenType.Try;        break;
            case "catch":      tok.type = TokenType.Catch;      break;
            case "finally":    tok.type = TokenType.Finally;    break;
            case "override":   tok.type = TokenType.Override;   break;
            case "abstract":   tok.type = TokenType.Abstract;   break;
            case "global":     tok.type = TokenType.Global;     break;
            case "deprecated": tok.type = TokenType.Deprecated; break;
            case "debug":      tok.type = TokenType.Debug;      break;
            case "version":    tok.type = TokenType.Version;    break;

            case "ref":        tok.type = TokenType.Ref;        break;
            case "const":      tok.type = TokenType.Const;      break;
            case "weak":       tok.type = TokenType.Weak;       break;
            case "lazy":       tok.type = TokenType.Lazy;       break;

            default:
                () @trusted {
                    tok.type = TokenType.Identifier;
                    tok.str  = buf.data.to!string;
                }();
        }
    }

    private TokenType parseNumeric(Token* tok) {
        int base = 10;
        Appender!(char[]) buf;

        if (currChar == '0') {
            nextChar();
            switch (currChar) {
                case '0': .. case '7':
                    buf.put(nextChar);
                    base = 8;
                    break;

                case 'x':
                    base = 16;
                    nextChar();
                    break;

                case 'b':
                    base = 2;
                    nextChar();
                    break;

                case '.':
                    if (peekChar(1).isAlpha || peekChar(1) == '_') {
                        // dont go to next char, dot is not our. ex. 123.seconds
                        goto SizeVar;
                    }

                    buf.put(nextChar);
                    break;
                
                default:
            }
        }

        while (true) {
            switch (currChar) {
                case '0':
                case '1':
                    buf.put(nextChar);
                    break;

                case '2': .. case '7':
                    if (base == 2) {
                        throw new Exception("binary digit expected!");
                    }

                    buf.put(nextChar);
                    break;

                case '8':
                case '9':
                    if (base < 10) {
                        throw new Exception("octal digit expected!");
                    }

                    buf.put(nextChar);
                    break;

                case 'A': .. case 'F':
                    if (base < 16) {
                        throw new Exception("hex digit expected!");
                    }

                    buf.put(nextChar);
                    break;

                case '.':
                    if (peekChar(1).isAlpha || peekChar(1) == '_') {
                        // dont go to next char, dot is not our. ex. 123.seconds
                        goto SizeVar;
                    }

                    buf.put(nextChar);
                    break;

                case '_':
                    nextChar();
                    break;

                default:
                    goto SizeVar;
            }
        }

    SizeVar:
        TokenType type = TokenType.IntValue;
        // TODO: do fit by checking length of num

             if (currChar == 'f') type = TokenType.FloatValue;
        else if (currChar == 'd') type = TokenType.DoubleValue;
        else if (currChar == 'r') type = TokenType.RealValue;
        else if (currChar == 'L') type = TokenType.LongValue;
        else if (currChar == 'U') {
            nextChar();
            type = currChar == 'L' ? TokenType.ULongValue : TokenType.UIntValue;
        }

        switch (type) with (TokenType) {
            case FloatValue, DoubleValue, RealValue:
                tok.rvalue = buf.data.to!real;
                break;

            case IntValue, LongValue:
                tok.value = buf.data.to!long;
                break;

            case UIntValue, ULongValue:
                tok.uvalue = buf.data.to!ulong;

            default:
        }

        return type;
    }
}

@safe:
private bool isSpace(char c) {
    return c == ' '; // Add some other UTF-8 spaces?
}

private bool isEOF(char c) {
    return c == '\0';
}

private bool isEOL(char c) {
    return c == '\n' || c == '\r';
}

private bool isWhiteChar(char c) {
    return c.isSpace() || c.isEOF() || c.isEOL();
}