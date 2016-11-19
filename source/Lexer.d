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
    private bool m_empty;
    private char m_buffer;
    private Appender!(char[]) m_identifier;
    private double m_numeric;

    private int m_row;
    private int m_col;

    @property {
        string identifier() const @trusted {
            return cast(string)m_identifier.data;
        }

        double numeric() const {
            return m_numeric;
        }

        int row() const {
            return m_row;
        }

        int col() const {
            return m_col;
        }
    }

    this(File file) {
        m_empty = true;
        m_file  = file;
    }

    // This must return Token + ident/number
    Token getToken() {
        if (m_empty) {
            readToken();
            m_empty = false;
        }

        // Space
        if (m_buffer.isSpace) {
            return emptyByReturn(Token.Space);
        }

        // End of Line
        if (m_buffer.isEOL) {
            m_col = 0;
            m_row++;
            return emptyByReturn(Token.EndLine);
        }

        // Parse string tokens
        if (m_buffer.isAlpha) {
            return parseString();
        }

        // Parse numeric tokens
        if (m_buffer.isDigit || m_buffer == '.') { // For .42 doubles
            return parseNumeric();
        }

        // Parse other types of tokens like brackets, etc.
        auto tok = parseOtherTokens();
        if (tok != Token.None) {
            return tok;
        }

        // Look for EOF
        if (m_buffer.isEOF) {
            return emptyByReturn(Token.Eof);
        }

        assert(false, "Unexpected token!");
    }

    private Token parseString() {
        m_identifier.clear();

        do {
            m_identifier.put(m_buffer);
            readToken();
        } while (m_buffer.isAlphaNum);

        switch (m_identifier.data) {
            case "true":    return Token.True;
            case "false":   return Token.False;
            case "null":    return Token.Null;
            case "assert":  return Token.Assert;
            case "enforce": return Token.Enforce;
            case "asm":     return Token.Asm;

            // Vars
            case "var":     return Token.Var;
            case "let":     return Token.Let;
            case "void":    return Token.Void;
            case "bool":    return Token.Bool;
            case "char":    return Token.Char;
            case "wchar":   return Token.WChar;
            case "dchar":   return Token.DChar;
            case "byte":    return Token.Byte;
            case "ubyte":   return Token.UByte;
            case "short":   return Token.Short;
            case "ushort":  return Token.UShort;
            case "int":     return Token.Int;
            case "uint":    return Token.UInt;
            case "long":    return Token.Long;
            case "ulong":   return Token.ULong;
            case "float":   return Token.Float;
            case "double":  return Token.Double;
            case "real":    return Token.Real;

            case "is":      return Token.Is;
            case "if":      return Token.If;
            case "else":    return Token.Else;
            case "while":   return Token.While;
            case "repeat":  return Token.Repeat;
            case "for":     return Token.For;
            case "switch":  return Token.Switch;
            case "case":    return Token.Case;
            case "default": return Token.Default;
            case "break":   return Token.Break;
            case "continue": return Token.Continue;
            case "lock":    return Token.Lock;

            // classes, etc
            case "import":  return Token.Import;
            case "module":  return Token.Module;
            case "alias":   return Token.Alias;
            case "class":   return Token.Class;
            case "struct":  return Token.Struct;
            case "Protocol": return Token.Protocol;
            case "Extend":  return Token.Extend;
            case "Enum":    return Token.Enum;
            case "Union":   return Token.Union;
        
            // Funcs, etc
            case "func":    return Token.Func;
            case "task":    return Token.Task;
            case "return":  return Token.Return;
            case "throws":  return Token.Throws;
            case "final":   return Token.Final;
            case "self":    return Token.Self;
            case "as":      return Token.As;
            case "in":      return Token.In;
            case "throw":   return Token.Throw;
            case "try":     return Token.Try;
            case "catch":   return Token.Catch;
            case "finally": return Token.Finally;
            case "override": return Token.Override;
            case "abstract": return Token.Abstract;
            case "deprecated": return Token.Deprecated;
            case "debug":   return Token.Debug;
            case "version": return Token.Version;

            case "ref":     return Token.Ref;
            case "const":   return Token.Const;
            case "weak":    return Token.Weak;
            case "lazy":    return Token.Lazy;

            default:
                return Token.Identifier;
        }
    }

    private Token parseNumeric() {
        Appender!(char[]) numStr;
        Token specific = Token.Int;

        do {
            numStr.put(m_buffer);
            readToken();
        } while (m_buffer.isDigit || m_buffer == '.');

        if (numStr.data.countUntil('.') != -1) {
            specific = Token.Double;
        }

             if (m_buffer == 'f') specific = emptyByReturn(Token.Float);
        else if (m_buffer == 'd') specific = emptyByReturn(Token.Double);
        else if (m_buffer == 'r') specific = emptyByReturn(Token.Real);
        else if (m_buffer == 'L') specific = emptyByReturn(Token.Long);
        else if (m_buffer == 'U') {
            readToken();

            if (m_buffer == 'L') {
                specific = emptyByReturn(Token.ULong);
            } else if (m_buffer.isWhiteChar) {
                specific = Token.UInt;
            } else {
                writeln("Error undefined numeric type `", m_buffer, "`");
            }
        } else if (m_buffer.isWhiteChar) {
            // White char ignore
        } else {
            writeln("Error undefined numeric type `", m_buffer, "`");
        }

        m_numeric = numStr.data.to!double;
        return specific;
    }

    private Token parseOtherTokens() {
        switch (m_buffer) {
            case ':': return emptyByReturn(Token.Colon);
            case ',': return emptyByReturn(Token.Comma);
            
            case '.':
                readToken();
                if (m_buffer == '.') {
                    return emptyByReturn(Token.Slice);
                }
                return Token.Dot;

            case '-':
                readToken();
                if (m_buffer == '>') {
                    return emptyByReturn(Token.ReturnType);
                }
                return Token.Minus;

            case '?':
                readToken();
                if (m_buffer == '.') {
                    return emptyByReturn(Token.MonadDeref);
                }
                return Token.Monad;

            case '{': return emptyByReturn(Token.OpenScope);
            case '}': return emptyByReturn(Token.CloseScope);
            case '[': return emptyByReturn(Token.OpenArray);
            case ']': return emptyByReturn(Token.CloseArray);
            case '(': return emptyByReturn(Token.OpenBracket);
            case ')': return emptyByReturn(Token.CloseBracket);
            case '+': return emptyByReturn(Token.CloseBracket);

            case '=':
                readToken();
                if (m_buffer == '=') {
                    return emptyByReturn(Token.Equal);
                }
                return Token.Blyat;

            case '!':
                readToken();
                if (m_buffer == '=') {
                    return emptyByReturn(Token.NotEqual);
                } else if (m_buffer == 'i' && peekToken() == 's') {
                    readToken();
                    return emptyByReturn(Token.NotIs);
                }
                return Token.Not;
                
            default:
                return Token.None;
        }
    }

    private Token emptyByReturn(Token tok) {
        m_empty = true;
        return tok;
    }

    private void readToken() @trusted {
        m_file.rawRead((&m_buffer)[0 .. 1]);
        m_col++;
    }

    private char peekToken() @trusted {
        char c;
        m_file.rawRead((&c)[0 .. 1]);
        m_file.seek(-1, SEEK_CUR);

        return c;
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